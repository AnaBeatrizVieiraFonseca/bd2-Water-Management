import argparse
import hashlib
import json
import re
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from getpass import getpass

import mysql.connector
from bson import Decimal128, ObjectId, json_util
from pymongo import MongoClient


INICIO = datetime(2025, 1, 1, tzinfo=timezone.utc)
FIM = datetime(2026, 6, 5, tzinfo=timezone.utc)
MOTIVOS_INVALIDADE = {'ERRO_SENSOR', 'VALOR_FORA_FAIXA_TECNICA', 'FORMATO_INVALIDO'}


def utc(valor):
    if valor.tzinfo is None:
        return valor.replace(tzinfo=timezone.utc)
    return valor.astimezone(timezone.utc)


def ler_contexto(conexao):
    cur = conexao.cursor(dictionary=True)
    try:
        cur.execute('SELECT id_estacao, codigo FROM estacao_monitoramento ORDER BY codigo')
        estacoes = cur.fetchall()
        cur.execute('''SELECT p.id_parametro, p.codigo, u.simbolo AS unidade
                       FROM parametro_monitoramento p
                       INNER JOIN unidade_medida u ON u.id_unidade=p.id_unidade''')
        parametros = {p['codigo']: p for p in cur.fetchall()}
        cur.execute('''SELECT s.id_sensor, s.codigo_patrimonial, t.id_parametro
                       FROM sensor s INNER JOIN tipo_sensor_parametro t
                       ON t.id_tipo_sensor=s.id_tipo_sensor''')
        sensores = {}
        capacidades = {}
        for s in cur.fetchall():
            sensores[s['codigo_patrimonial']] = s['id_sensor']
            capacidades.setdefault(s['id_sensor'], set()).add(s['id_parametro'])
        cur.execute('SELECT id_sensor,id_estacao,inicio_em,fim_em FROM instalacao_sensor')
        instalacoes = {}
        for i in cur.fetchall():
            i['inicio_em'] = utc(i['inicio_em'])
            i['fim_em'] = utc(i['fim_em']) if i['fim_em'] else None
            instalacoes.setdefault(i['id_sensor'], []).append(i)
        cur.execute('''SELECT r.id_regra,r.id_estacao,r.id_parametro,v.id_versao,
                              v.inicio_em,v.fim_em,v.limite_inferior,v.limite_superior
                       FROM regra_monitoramento r INNER JOIN versao_regra_monitoramento v
                       ON v.id_regra=r.id_regra WHERE r.ativo=1''')
        regras = {}
        for r in cur.fetchall():
            r['inicio_em'] = utc(r['inicio_em'])
            r['fim_em'] = utc(r['fim_em']) if r['fim_em'] else None
            regras.setdefault((r['id_estacao'], r['id_parametro']), []).append(r)
        cur.execute('''SELECT id_usuario FROM usuario WHERE email=%s AND ativo=1 AND tipo_identidade='SERVICO' ''',
                    ('monitoramento@simulacao.example',))
        ator = cur.fetchone()
        if not ator:
            raise ValueError('Usuário de serviço do monitoramento não encontrado ou inativo.')
        return estacoes, parametros, sensores, capacidades, instalacoes, regras, ator['id_usuario']
    finally:
        cur.close()
        conexao.commit()


def assinatura(documento):
    texto = json_util.dumps(documento, json_options=json_util.CANONICAL_JSON_OPTIONS, sort_keys=True)
    return hashlib.sha256(texto.encode('utf8')).hexdigest()


def aplicaveis(linhas, instante):
    return [l for l in linhas if l['inicio_em'] <= instante and (l['fim_em'] is None or instante < l['fim_em'])]


def parametros_esperados(estacao, dia, instalacoes, capacidades):
    fim = dia + timedelta(days=1)
    resultado = set()
    for sensor, periodos in instalacoes.items():
        if any(i['id_estacao'] == estacao and i['inicio_em'] < fim
               and (i['fim_em'] is None or i['fim_em'] > dia) for i in periodos):
            resultado.update(capacidades.get(sensor, set()))
    return resultado


def validar(leitura, estacao, instante, parametros, sensores, capacidades, instalacoes):
    identificador = leitura.get('id_leitura')
    if not isinstance(identificador, str) or not re.fullmatch(r'[A-Za-z0-9_-]{1,40}', identificador):
        raise ValueError('Identificador de leitura inválido.')
    p = parametros.get(leitura.get('parametro_codigo'))
    sensor = sensores.get(leitura.get('sensor_codigo'))
    if not p or sensor is None or p['id_parametro'] not in capacidades.get(sensor, set()):
        raise ValueError('Sensor ou parâmetro inexistente ou incompatível.')
    if leitura.get('unidade') != p['unidade']:
        raise ValueError('Unidade diferente do cadastro MySQL.')
    periodos = aplicaveis(instalacoes.get(sensor, []), instante)
    if len(periodos) != 1 or periodos[0]['id_estacao'] != estacao:
        raise ValueError('Instalação ausente, sobreposta ou de outra estação.')
    valor = leitura.get('valor')
    if not isinstance(valor, Decimal128):
        raise ValueError('Valor não é Decimal128.')
    valor = valor.to_decimal()
    if not valor.is_finite() or abs(valor) > Decimal('99999999.999999'):
        raise ValueError('Valor fora da representação DECIMAL(14,6).')
    if valor != valor.quantize(Decimal('0.000001')):
        raise ValueError('Valor com mais de seis casas decimais.')
    if leitura.get('valida') is False:
        if leitura.get('motivo_invalidade') not in MOTIVOS_INVALIDADE:
            raise ValueError('Leitura inválida sem motivo reconhecido.')
        return p['id_parametro'], None
    if leitura.get('valida') is not True or 'motivo_invalidade' in leitura:
        raise ValueError('Indicação de validade inconsistente.')
    return p['id_parametro'], valor


def registrar_desvio(cur, regra, documento, leitura, instante, ator, evidencias, episodios):
    chave = (str(documento['_id']), leitura['id_leitura'])
    if chave in evidencias:
        if evidencias[chave] != regra['id_versao']:
            raise ValueError('A leitura já tem evidência com outra versão de regra.')
        return 0, 0
    id_regra = regra['id_regra']
    if id_regra not in episodios:
        cur.execute('''SELECT MAX(a.encerrado_em) AS ultimo
                       FROM alerta a INNER JOIN versao_regra_monitoramento v ON v.id_versao=a.id_versao_abertura
                       WHERE v.id_regra=%s''', (id_regra,))
        encerramento = cur.fetchone()['ultimo']
        cur.execute('''SELECT a.id_alerta,a.aberto_em FROM alerta a
                       INNER JOIN versao_regra_monitoramento v ON v.id_versao=a.id_versao_abertura
                       WHERE v.id_regra=%s AND a.encerrado_em IS NULL
                       ORDER BY a.aberto_em,a.id_alerta''', (id_regra,))
        abertos = cur.fetchall()
        if len(abertos) > 1:
            raise ValueError('Há mais de um alerta aberto para a mesma regra.')
        episodios[id_regra] = {'encerramento': utc(encerramento) if encerramento else None,
                              'aberto': abertos[0] if abertos else None}
    episodio = episodios[id_regra]
    if episodio['encerramento'] and instante <= episodio['encerramento']:
        return 0, 1
    aberto = episodio['aberto']
    if aberto and instante < utc(aberto['aberto_em']):
        return 0, 1
    origem = 0
    if not aberto:
        cur.execute('''INSERT INTO alerta(id_versao_abertura,aberto_em,id_usuario_abertura)
                       VALUES(%s,%s,%s)''', (regra['id_versao'], instante.replace(tzinfo=None), ator))
        aberto = {'id_alerta': cur.lastrowid, 'aberto_em': instante}
        episodio['aberto'] = aberto
        origem = 1
    cur.execute('''INSERT INTO evidencia_alerta
                   (id_documento_mongo,id_leitura,id_alerta,id_versao_avaliacao,origem)
                   VALUES(%s,%s,%s,%s,%s)''', (*chave, aberto['id_alerta'], regra['id_versao'], origem))
    evidencias[chave] = regra['id_versao']
    return 1, 0


def integrar(conexao, base, inicio=INICIO, fim=FIM, reprocessar=False):
    if inicio >= fim or any((d.hour, d.minute, d.second, d.microsecond) != (0, 0, 0, 0) for d in (inicio, fim)):
        raise ValueError('Informe um período de dias completos, com fim exclusivo.')
    conexao.cmd_query("SET time_zone='+00:00'")
    estacoes, parametros, sensores, capacidades, instalacoes, regras, ator = ler_contexto(conexao)
    codigos = {e['codigo'] for e in estacoes}
    encontradas = set(base.medicoes.distinct('estacao_codigo', {'coletado_em': {'$gte': inicio, '$lt': fim}}))
    if encontradas - codigos:
        raise ValueError('Há coletas de estações não cadastradas no MySQL: ' + ', '.join(sorted(encontradas - codigos)))
    base.logs_ingestao.create_index([('etapa', 1), ('documento_medicao_id', 1), ('registrado_em', -1)],
                                   name='ix_logs_integracao_documento_instante')
    totais = {'dias_processados': 0, 'dias_sem_mudanca': 0, 'resumos_gravados': 0,
              'novas_evidencias': 0, 'leituras_validas_processadas': 0,
              'leituras_invalidas': 0, 'desvios_historicos_sem_reabertura': 0, 'documentos_pendentes': 0}
    cur = conexao.cursor(dictionary=True)
    try:
        for estacao in estacoes:
            cursor = base.medicoes.find({'estacao_codigo': estacao['codigo'],
                'coletado_em': {'$gte': inicio, '$lt': fim}}).sort('coletado_em', 1)
            proximo = next(cursor, None)
            dia = inicio
            while dia < fim:
                documentos = []
                while proximo is not None and utc(proximo['coletado_em']) < dia + timedelta(days=1):
                    documentos.append(proximo)
                    proximo = next(cursor, None)
                esperados = parametros_esperados(estacao['id_estacao'], dia, instalacoes, capacidades)
                if not esperados:
                    if documentos:
                        raise ValueError('Há coletas fora do calendário de instalação.')
                    dia += timedelta(days=1)
                    continue
                ids = [d['_id'] for d in documentos]
                hashes = {d['_id']: assinatura(d) for d in documentos}
                ultimos = {}
                if ids:
                    for item in base.logs_ingestao.aggregate([
                        {'$match': {'etapa': 'INTEGRACAO', 'documento_medicao_id': {'$in': ids}}},
                        {'$sort': {'registrado_em': -1, '_id': -1}},
                        {'$group': {'_id': '$documento_medicao_id', 'ultimo': {'$first': '$$ROOT'}}}
                    ]):
                        ultimos[item['_id']] = item['ultimo']
                for id_doc, antigo in ultimos.items():
                    if antigo.get('hash_origem') and antigo['hash_origem'] != hashes[id_doc]:
                        raise ValueError('Coleta processada foi alterada. Exige correção controlada, não reprocessamento automático.')
                cur.execute('''SELECT id_parametro FROM resumo_diario_monitoramento
                               WHERE id_estacao=%s AND dia_utc=%s''', (estacao['id_estacao'], dia.date()))
                existentes = {r['id_parametro'] for r in cur.fetchall()}
                conexao.commit()
                completos = all(ultimos.get(d['_id'], {}).get('resultado') == 'PROCESSADA'
                                and ultimos[d['_id']].get('hash_origem') == hashes[d['_id']] for d in documentos)
                if not reprocessar and completos and esperados.issubset(existentes):
                    totais['dias_sem_mudanca'] += 1
                    dia += timedelta(days=1)
                    continue

                conexao.start_transaction()
                agregados = {p: [0, Decimal('0'), None, None] for p in esperados}
                evidencias = {}
                if ids:
                    marcadores = ','.join(['%s'] * len(ids))
                    cur.execute('SELECT id_documento_mongo,id_leitura,id_versao_avaliacao FROM evidencia_alerta '
                                'WHERE id_documento_mongo IN (' + marcadores + ')', tuple(str(i) for i in ids))
                    evidencias = {(e['id_documento_mongo'], e['id_leitura']): e['id_versao_avaliacao'] for e in cur.fetchall()}
                episodios = {}
                logs = []
                for doc in documentos:
                    instante = utc(doc['coletado_em'])
                    motivos = []
                    sem_regra = False
                    leituras = doc.get('leituras', [])
                    identidades = [l.get('id_leitura') for l in leituras]
                    if not isinstance(doc['_id'], ObjectId) or not leituras or len(set(identidades)) != len(identidades):
                        motivos.append('Identidade documental ou identificadores de leitura inválidos.')
                        leituras = []
                    for leitura in leituras:
                        try:
                            parametro, valor = validar(leitura, estacao['id_estacao'], instante,
                                parametros, sensores, capacidades, instalacoes)
                        except (ValueError, TypeError, KeyError) as erro:
                            motivos.append(str(erro))
                            continue
                        if valor is None:
                            totais['leituras_invalidas'] += 1
                            continue
                        if parametro not in agregados:
                            motivos.append('Parâmetro fora do calendário esperado.')
                            continue
                        a = agregados[parametro]
                        a[0] += 1
                        a[1] += valor
                        a[2] = valor if a[2] is None else min(a[2], valor)
                        a[3] = valor if a[3] is None else max(a[3], valor)
                        totais['leituras_validas_processadas'] += 1
                        versoes = aplicaveis(regras.get((estacao['id_estacao'], parametro), []), instante)
                        if not versoes:
                            sem_regra = True
                            continue
                        if len(versoes) != 1:
                            raise ValueError('Versões de regra sobrepostas. Corrigir antes de continuar.')
                        regra = versoes[0]
                        desvio = ((regra['limite_inferior'] is not None and valor < regra['limite_inferior'])
                                  or (regra['limite_superior'] is not None and valor > regra['limite_superior']))
                        if desvio:
                            novas, historicas = registrar_desvio(cur, regra, doc, leitura, instante, ator, evidencias, episodios)
                            totais['novas_evidencias'] += novas
                            totais['desvios_historicos_sem_reabertura'] += historicas
                    resultado = 'PENDENTE' if motivos else ('SEM_REGRA' if sem_regra else 'PROCESSADA')
                    if motivos:
                        totais['documentos_pendentes'] += 1
                    logs.append({'mensagem_codigo': doc['mensagem_codigo'], 'registrado_em': datetime.now(timezone.utc),
                                 'etapa': 'INTEGRACAO', 'resultado': resultado, 'documento_medicao_id': doc['_id'],
                                 'motivo': '; '.join(sorted(set(motivos))) if motivos else 'Leituras avaliadas e resumo diário consolidado.',
                                 'hash_origem': hashes[doc['_id']], 'origem': {'programa': 'INTEGRADOR_V1'}})
                linhas = []
                for parametro, (quantidade, soma, minimo, maximo) in agregados.items():
                    valores = (quantidade, soma if quantidade else None, minimo, maximo)
                    linhas.append((estacao['id_estacao'], parametro, dia.date(), *valores, *valores))
                for linha in linhas:
                    cur.execute('''INSERT INTO resumo_diario_monitoramento
                        (id_estacao,id_parametro,dia_utc,quantidade_validas,soma,minimo,maximo,consolidado_em)
                        VALUES(%s,%s,%s,%s,%s,%s,%s,UTC_TIMESTAMP(3))
                        ON DUPLICATE KEY UPDATE quantidade_validas=%s,soma=%s,minimo=%s,maximo=%s,consolidado_em=UTC_TIMESTAMP(3)''', linha)
                conexao.commit()
                if logs:
                    base.logs_ingestao.insert_many(logs, ordered=True)
                totais['dias_processados'] += 1
                totais['resumos_gravados'] += len(linhas)
                dia += timedelta(days=1)
            cursor.close()
            print(estacao['codigo'], '- concluída;', totais['resumos_gravados'], 'resumos gravados nesta execução.', flush=True)
    except Exception:
        conexao.rollback()
        raise
    finally:
        cur.close()
    print(json.dumps(totais, ensure_ascii=False, indent=2), flush=True)
    return totais


def main():
    parser = argparse.ArgumentParser(description='Integrar medições MongoDB aos indicadores e alertas MySQL.')
    parser.add_argument('--mysql-host', default='localhost')
    parser.add_argument('--mysql-port', type=int, default=3306)
    parser.add_argument('--mysql-user', default='rh_integracao_projeto')
    parser.add_argument('--mysql-base', default='recursos_hidricos')
    parser.add_argument('--mongo-uri', default='mongodb://localhost:27017')
    parser.add_argument('--mongo-base', default='recursos_hidricos')
    parser.add_argument('--inicio', default='2025-01-01')
    parser.add_argument('--fim', default='2026-06-05')
    parser.add_argument('--reprocessar', action='store_true')
    parser.add_argument('--janela-senha', action='store_true')
    args = parser.parse_args()
    if args.janela_senha:
        import tkinter as tk
        from tkinter.simpledialog import askstring
        janela = tk.Tk()
        janela.withdraw()
        senha = askstring('Integração MySQL e MongoDB', 'Senha MySQL de ' + args.mysql_user + ':', show='*', parent=janela)
        janela.destroy()
        if senha is None:
            print('Execução cancelada antes da conexão.')
            return
    else:
        senha = getpass('Senha MySQL de ' + args.mysql_user + ': ')
    conexao = mysql.connector.connect(host=args.mysql_host, port=args.mysql_port,
        user=args.mysql_user, password=senha, database=args.mysql_base, connection_timeout=10)
    cliente = MongoClient(args.mongo_uri, tz_aware=True, serverSelectionTimeoutMS=5000)
    try:
        integrar(conexao, cliente[args.mongo_base], datetime.fromisoformat(args.inicio).replace(tzinfo=timezone.utc),
                 datetime.fromisoformat(args.fim).replace(tzinfo=timezone.utc), args.reprocessar)
    finally:
        conexao.close()
        cliente.close()


if __name__ == '__main__':
    try:
        main()
    except Exception as erro:
        print('Integração interrompida:', erro)
        print('Os dias já confirmados permanecem gravados. Não apague a base: confira a causa antes de retomar.')
        raise SystemExit(1)
