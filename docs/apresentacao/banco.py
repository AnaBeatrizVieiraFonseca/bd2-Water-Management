import importlib.util
import io
from contextlib import redirect_stdout
from datetime import datetime, timezone
from pathlib import Path

import mysql.connector
from bson import json_util
from pymongo import MongoClient

PASTA = Path(__file__).resolve().parent
DOCS = PASTA.parent


def conectar_mongo():
    return MongoClient('mongodb://localhost:27017', tz_aware=True,
                       serverSelectionTimeoutMS=4000, socketTimeoutMS=20000)


def carregar_catalogo():
    return json_util.loads((PASTA / 'catalogo.json').read_text(encoding='utf-8'))


def consultar(consulta):
    """Executa uma operação MongoDB guardada em catalogo.json."""
    with conectar_mongo() as cliente:
        colecao = cliente.recursos_hidricos[consulta['collection']]
        if consulta['kind'] == 'aggregate':
            return list(colecao.aggregate(consulta['pipeline'], maxTimeMS=15000))
        cursor = colecao.find(consulta['filter'], consulta['projection'])
        if consulta.get('sort'):
            cursor = cursor.sort(list(consulta['sort'].items()))
        return list(cursor.limit(consulta.get('limit', 100)).max_time_ms(15000))


def documentos():
    with conectar_mongo() as cliente:
        db = cliente.recursos_hidricos
        codigo = 'EST-01_20250701T070000Z'
        return {
            'medicoes': db.medicoes.find_one({'mensagem_codigo': codigo}),
            'telemetria': db.telemetria.find_one({'sensor_codigo': 'EST-01-TURB'}),
            'logs_ingestao': db.logs_ingestao.find_one({'mensagem_codigo': codigo, 'etapa': 'INGESTAO'}),
        }


def etapas_pipeline(pipeline_catalogado):
    with conectar_mongo() as cliente:
        colecao = cliente.recursos_hidricos[pipeline_catalogado['collection']]
        contagens = []
        for numero_etapa, estagio in enumerate(pipeline_catalogado['pipeline'], start=1):
            pipeline_etapa = pipeline_catalogado['pipeline'][:numero_etapa] + [{'$count': 'total'}]
            resultado = list(colecao.aggregate(pipeline_etapa, maxTimeMS=15000))
            contagens.append({'Etapa': f'{numero_etapa}. {next(iter(estagio))}',
                              'Registros na saída': resultado[0]['total'] if resultado else 0})
        return contagens


def serie_turbidez():
    pipeline = carregar_catalogo()[10]['pipeline'][:3]
    pipeline += [{'$project': {'_id': 0, 'coletado_em': 1, 'valor': '$leituras.valor'}},
                 {'$sort': {'coletado_em': 1}}]
    with conectar_mongo() as cliente:
        return list(cliente.recursos_hidricos.medicoes.aggregate(pipeline, maxTimeMS=15000))


def comparar_indice():
    item = carregar_catalogo()[0]
    comando = {'find': 'medicoes', 'filter': item['filter'],
               'projection': item['projection'], 'sort': item['sort'], 'maxTimeMS': 15000}
    resultado = {}
    with conectar_mongo() as cliente:
        db = cliente.recursos_hidricos
        for nome, dica in [('Varredura da coleção', {'$natural': 1}),
                           ('Índice estação + data', 'ix_medicoes_estacao_data')]:
            plano = db.command('explain', {**comando, 'hint': dica}, verbosity='executionStats')
            dados = plano['executionStats']
            resultado[nome] = {campo: dados[campo] for campo in
                              ['nReturned', 'totalDocsExamined', 'totalKeysExamined', 'executionTimeMillis']}
    return resultado


def conectar_mysql(senha):
    """Abre o MySQL com a conta de integração e a senha digitada no painel"""
    return mysql.connector.connect(host='localhost', port=3306,
                                   user='rh_integracao_projeto', password=senha,
                                   database='recursos_hidricos', connection_timeout=5)


def rastrear_alerta(senha):
    # leitura de turbidez da coleta da EST-01, as regras aplicáveis,
    # se existe uma evidência ligada a um alerta e até cinco logs recentes
    with conectar_mongo() as cliente:
        db = cliente.recursos_hidricos
        coleta = db.medicoes.find_one({'mensagem_codigo': 'EST-01_20250701T070000Z'})
        if coleta is None:
            raise ValueError('Coleta de exemplo não encontrada. Confira a carga MongoDB.')
        leitura = next(item for item in coleta['leituras'] if item['parametro_codigo'] == 'TURBIDEZ')
        logs = list(db.logs_ingestao.find({'documento_medicao_id': coleta['_id']})
                    .sort('registrado_em', -1).limit(5))

    conexao = conectar_mysql(senha)
    cursor_sql = conexao.cursor(dictionary=True)
    try:
        cursor_sql.execute('''SELECT v.numero_versao, v.limite_superior, v.inicio_em, v.fim_em
            FROM versao_regra_monitoramento v
            INNER JOIN regra_monitoramento r ON r.id_regra=v.id_regra
            INNER JOIN estacao_monitoramento e ON e.id_estacao=r.id_estacao
            INNER JOIN parametro_monitoramento p ON p.id_parametro=r.id_parametro
            WHERE e.codigo='EST-01' AND p.codigo='TURBIDEZ' ORDER BY v.inicio_em''')
        regras = cursor_sql.fetchall()
        cursor_sql.execute('''SELECT ev.id_documento_mongo, ev.id_leitura, ev.id_alerta,
            ev.id_versao_avaliacao, a.aberto_em, a.reconhecido_em, a.encerrado_em
            FROM evidencia_alerta ev INNER JOIN alerta a ON a.id_alerta=ev.id_alerta
            WHERE ev.id_documento_mongo=%s AND ev.id_leitura=%s''',
                           (str(coleta['_id']), leitura['id_leitura']))
        evidencias = cursor_sql.fetchall()
    finally:
        cursor_sql.close()
        conexao.close()
    return {'coleta': coleta['mensagem_codigo'], 'leitura': leitura,
            'versoes_da_regra_mysql': regras, 'evidencia_e_alerta_mysql': evidencias,
            'ultimos_logs_mongodb': logs}


def executar_integracao(senha):
    """Chama o integrador para 01/07/2025 """
    caminho = DOCS / 'integração' / '01_integrar.py'
    # Importa o módulo de integração, sem executar uma segunda interface ou terminal.
    spec = importlib.util.spec_from_file_location('integrador', caminho)
    integrador = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(integrador)
    conexao = conectar_mysql(senha)
    saida = io.StringIO()
    try:
        # meia-noite de 1/jul incluída e meia-noite de 2/jul excluída.
        with conectar_mongo() as cliente, redirect_stdout(saida):
            totais = integrador.integrar(
                conexao, cliente.recursos_hidricos,
                datetime(2025, 7, 1, tzinfo=timezone.utc),
                datetime(2025, 7, 2, tzinfo=timezone.utc))
        # totais vem do integrador; saida_original contém uma linha para cada estação.
        return {'periodo_UTC': '01/07/2025 (20 estações)', 'totais': totais,
                'explicacao': 'O período é processado novamente; os resumos são atualizados e as evidências existentes são reaproveitadas.',
                'saida_original': saida.getvalue()}
    finally:
        conexao.close()
