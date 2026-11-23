import json
from datetime import datetime, timedelta, timezone
from decimal import Decimal


INICIO = datetime(2025, 1, 1, tzinfo=timezone.utc)
FIM = datetime(2026, 6, 5, tzinfo=timezone.utc)


def ler_contexto(conexao):
    cursor_sql = conexao.cursor(dictionary=True)
    try:
        cursor_sql.execute('SELECT id_estacao, codigo FROM estacao_monitoramento ORDER BY codigo')
        estacoes = cursor_sql.fetchall()
        # junta parametro_monitoramento com unidade_medida
        cursor_sql.execute('''SELECT p.id_parametro, p.codigo, u.simbolo AS unidade
                       FROM parametro_monitoramento p
                       INNER JOIN unidade_medida u ON u.id_unidade=p.id_unidade''')
        # organiza esses dados pelo código, como TURBIDEZ
        parametros = {item['codigo']: item for item in cursor_sql.fetchall()}
        # busca regras ativas e suas versões
        cursor_sql.execute('''SELECT r.id_regra,r.id_estacao,r.id_parametro,v.id_versao,
                              v.inicio_em,v.fim_em,v.limite_inferior,v.limite_superior
                       FROM regra_monitoramento r INNER JOIN versao_regra_monitoramento v
                       ON v.id_regra=r.id_regra WHERE r.ativo=1''')
        regras = {}
        for regra in cursor_sql.fetchall():
            regra['inicio_em'] = regra['inicio_em'].replace(tzinfo=timezone.utc)
            if regra['fim_em']:
                regra['fim_em'] = regra['fim_em'].replace(tzinfo=timezone.utc)
            regras.setdefault((regra['id_estacao'], regra['id_parametro']), []).append(regra)

        cursor_sql.execute('''SELECT id_usuario FROM usuario WHERE email=%s AND ativo=1 AND tipo_identidade='SERVICO' ''',
                    ('monitoramento@simulacao.example',))
        usuario_servico = cursor_sql.fetchone()
        if not usuario_servico:
            raise ValueError('Usuário de serviço do monitoramento não encontrado ou inativo.')
        conexao.commit()
        return estacoes, parametros, regras, usuario_servico['id_usuario']
    finally:
        cursor_sql.close()


def registrar_desvio(cursor_sql, regra, medicao, leitura, horario_coleta, usuario_servico_id):
    chave = (str(medicao['_id']), leitura['id_leitura'])
    cursor_sql.execute('''SELECT id_alerta FROM evidencia_alerta
                          WHERE id_documento_mongo=%s AND id_leitura=%s''', chave)
    if cursor_sql.fetchone():
        return 0, 0

    cursor_sql.execute('''SELECT a.id_alerta FROM alerta a
                          JOIN versao_regra_monitoramento v ON v.id_versao=a.id_versao_abertura
                          WHERE v.id_regra=%s AND a.encerrado_em IS NULL
                          ORDER BY a.aberto_em LIMIT 1''', (regra['id_regra'],))
    alerta_aberto = cursor_sql.fetchone()
    if alerta_aberto:
        id_alerta = alerta_aberto['id_alerta']
        origem = 0
    else:
        # alerta: abre um episódio usando a versão da regra vigente
        cursor_sql.execute('''INSERT INTO alerta(id_versao_abertura,aberto_em,id_usuario_abertura)
                              VALUES(%s,%s,%s)''',
                           (regra['id_versao'], horario_coleta.replace(tzinfo=None), usuario_servico_id))
        id_alerta = cursor_sql.lastrowid
        origem = 1
    #evidencia_alerta: associa a leitura do MongoDB ao alerta e à regra
    cursor_sql.execute('''INSERT INTO evidencia_alerta
                   (id_documento_mongo,id_leitura,id_alerta,id_versao_avaliacao,origem)
                   VALUES(%s,%s,%s,%s,%s)''', (*chave, id_alerta, regra['id_versao'], origem))
    return 1, int(origem == 1)


def integrar(conexao_mysql, mongo_db, inicio=INICIO, fim=FIM):
    """Processa medições MongoDB, compara regras MySQL e grava resumos/alertas."""
    conexao_mysql.cmd_query("SET time_zone='+00:00'")

    # Lê estações, parâmetros e regras no MySQL
    estacoes, parametros, regras, usuario_servico_id = ler_contexto(conexao_mysql)

    totais = {'dias_processados': 0, 'resumos_gravados': 0,
              'novas_evidencias': 0, 'leituras_validas_processadas': 0, 'leituras_invalidas': 0}
    cursor_sql = conexao_mysql.cursor(dictionary=True)
    try:
        # Percorre cada estação. Para cada uma, busca no MongoDB as medições daquela estação
        for estacao in estacoes:
            cursor_medicoes = mongo_db.medicoes.find({'estacao_codigo': estacao['codigo'],
                'coletado_em': {'$gte': inicio, '$lt': fim}}).sort('coletado_em', 1)
            proxima_medicao = next(cursor_medicoes, None)
            dia = inicio
            while dia < fim:
                medicoes_do_dia = []
                while proxima_medicao is not None and proxima_medicao['coletado_em'] < dia + timedelta(days=1):
                    medicoes_do_dia.append(proxima_medicao)
                    proxima_medicao = next(cursor_medicoes, None)
                if not medicoes_do_dia:
                    dia += timedelta(days=1)
                    continue

                conexao_mysql.start_transaction()
                resumo_por_parametro = {}
                logs = []
                #  processa seus itens do array leituras
                for medicao in medicoes_do_dia:
                    horario_coleta = medicao['coletado_em']
                    sem_regra = False
                    leituras = medicao.get('leituras', [])
                    for leitura in leituras:
                        id_parametro = parametros[leitura['parametro_codigo']]['id_parametro']
                        if not leitura['valida']:
                            # não entra na estatística
                            totais['leituras_invalidas'] += 1
                            continue
                        valor = leitura['valor'].to_decimal()
                        # Acumula quantidade, soma, mínimo e máximo por parâmetro
                        resumo = resumo_por_parametro.setdefault(id_parametro, [0, Decimal('0'), None, None])
                        resumo[0] += 1
                        resumo[1] += valor
                        resumo[2] = valor if resumo[2] is None else min(resumo[2], valor)
                        resumo[3] = valor if resumo[3] is None else max(resumo[3], valor)
                        totais['leituras_validas_processadas'] += 1
                        # Escolhe a versão MySQL
                        versoes = [regra for regra in regras.get((estacao['id_estacao'], id_parametro), [])
                                   if regra['inicio_em'] <= horario_coleta
                                   and (regra['fim_em'] is None or horario_coleta < regra['fim_em'])]
                        if not versoes:
                            sem_regra = True
                            continue
                        if len(versoes) != 1:
                            raise ValueError('Versões de regra sobrepostas. Corrigir antes de continuar.')
                        regra = versoes[0]
                        desvio = ((regra['limite_inferior'] is not None and valor < regra['limite_inferior'])
                                  or (regra['limite_superior'] is not None and valor > regra['limite_superior']))
                        if desvio:
                            # verifica se a evidência já existe, se não existir, associa a leitura a um alerta
                            novas, _ = registrar_desvio(
                                cursor_sql, regra, medicao, leitura, horario_coleta, usuario_servico_id)
                            totais['novas_evidencias'] += novas
                    resultado = 'SEM_REGRA' if sem_regra else 'PROCESSADA'
                    logs.append({'mensagem_codigo': medicao['mensagem_codigo'], 'registrado_em': datetime.now(timezone.utc),
                                 'etapa': 'INTEGRACAO', 'resultado': resultado, 'documento_medicao_id': medicao['_id'],
                                 'motivo': 'Leituras avaliadas e resumo diário consolidado.',
                                 'origem': {'programa': 'INTEGRADOR_V1'}})

                linhas_resumo = []
                for id_parametro, (quantidade, soma, minimo, maximo) in resumo_por_parametro.items():
                    valores = (quantidade, soma if quantidade else None, minimo, maximo)
                    linhas_resumo.append((estacao['id_estacao'], id_parametro, dia.date(), *valores, *valores))
                for linha_resumo in linhas_resumo:
                    # grava ou atualiza o resumo em resumo_diario_monitoramento
                    cursor_sql.execute('''INSERT INTO resumo_diario_monitoramento
                        (id_estacao,id_parametro,dia_utc,quantidade_validas,soma,minimo,maximo,consolidado_em)
                        VALUES(%s,%s,%s,%s,%s,%s,%s,UTC_TIMESTAMP(3))
                        ON DUPLICATE KEY UPDATE quantidade_validas=%s,soma=%s,minimo=%s,maximo=%s,consolidado_em=UTC_TIMESTAMP(3)''', linha_resumo)
                conexao_mysql.commit()
                # recursos_hidricos.logs_ingestao: salva os logs preparados
                if logs:
                    mongo_db.logs_ingestao.insert_many(logs, ordered=True)
                totais['dias_processados'] += 1
                totais['resumos_gravados'] += len(linhas_resumo)
                dia += timedelta(days=1)
            cursor_medicoes.close()
            print(estacao['codigo'], '- concluída;', totais['resumos_gravados'], 'resumos gravados nesta execução.', flush=True)
    except Exception:
        conexao_mysql.rollback()
        raise
    finally:
        cursor_sql.close()
    print(json.dumps(totais, ensure_ascii=False, indent=2), flush=True)
    return totais
