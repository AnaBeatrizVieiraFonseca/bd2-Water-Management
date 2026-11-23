"""Tela Recursos Hídricos: pipelines, modelagem e integração dos bancos."""
from datetime import datetime, timezone
from decimal import Decimal
import pandas as pd
import streamlit as st
from bson import Decimal128, ObjectId, json_util
import banco

st.set_page_config(page_title='Recursos hídricos', page_icon='💧', layout='wide')


def simples(valor):
    if isinstance(valor, Decimal128):
        return float(valor.to_decimal())
    if isinstance(valor, Decimal):
        return float(valor)
    if isinstance(valor, ObjectId):
        return str(valor)
    if isinstance(valor, dict):
        return {k: simples(v) for k, v in valor.items()}
    if isinstance(valor, list):
        return [simples(v) for v in valor]
    return valor


def tabela(dados):
    if dados:
        st.dataframe(pd.json_normalize(simples(dados)), hide_index=True, width='stretch')
    else:
        st.info('Nenhum registro corresponde a este filtro')


@st.cache_data(ttl=60)
def consultar(indice):
    """Consulta o catálogo MongoDB e mantém o resultado em cache"""
    return simples(banco.consultar(banco.carregar_catalogo()[indice]))


def detalhes_pipeline(indice):
    item = banco.carregar_catalogo()[indice]
    with st.expander('Código'):
        st.code(' → '.join(next(iter(p)) for p in item['pipeline']), language=None)
        st.code(item['code'], language='javascript')
        if st.button('Mostrar quantidade de registros por etapa', key=f'etapas{indice}'):
            contagens = banco.etapas_pipeline(item)
            tabela(contagens)


def mostrar_rastreio(resultado):
    st.success(f"Rastreio concluído para a coleta {resultado['coleta']} (somente leitura).")
    st.markdown('**MongoDB · `medicoes` · leitura encontrada na coleta**')
    st.json(simples(resultado['leitura']))
    st.markdown('**MySQL · versões da regra para EST-01 / TURBIDEZ**')
    tabela(resultado['versoes_da_regra_mysql'])
    st.markdown('**MySQL · evidência e estado do alerta associado**')
    tabela(resultado['evidencia_e_alerta_mysql'])
    st.markdown('**MongoDB · `logs_ingestao` · até cinco eventos recentes**')
    tabela(resultado['ultimos_logs_mongodb'])


def mostrar_integracao(resultado):
    st.success(f"Integração concluída · {resultado['periodo_UTC']}")
    st.caption(resultado['explicacao'])
    totais = resultado['totais']
    colunas = st.columns(5)
    colunas[0].metric('Dias processados', totais['dias_processados'])
    colunas[1].metric('Resumos gravados', totais['resumos_gravados'])
    colunas[2].metric('Novas evidências', totais['novas_evidencias'])
    colunas[3].metric('Leituras válidas', totais['leituras_validas_processadas'])
    colunas[4].metric('Leituras inválidas', totais['leituras_invalidas'])

    linhas_estacao = []
    for linha in resultado['saida_original'].splitlines():
        if ' - concluída;' in linha:
            codigo, detalhe = linha.split(' - concluída;', 1)
            quantidade = detalhe.split(' resumos gravados', 1)[0].strip()
            linhas_estacao.append({'Estação': codigo.strip(), 'Resumos gravados até aqui': quantidade})
    if linhas_estacao:
        st.markdown('**Saída por estação**')
        tabela(linhas_estacao)

st.title('Sistema de Monitoramento de Recursos Hídricos')
if st.sidebar.button('Atualizar dados'):
    st.cache_data.clear()
turbidez, equipamentos, modelo, integracao = st.tabs([
    'Turbidez', 'Prioridade de inspeção', 'Modelagem', 'Integração Python'])

try:
    # Pipeline MongoDB em medicoes: resumo diário da turbidez da EST-01
    with turbidez:
        st.header('Turbidez da água')
        st.caption('Pipeline 1 · EST-01 · 01/07/2025')
        resultado = consultar(10)
        if resultado:
            resumo = resultado[0]
            coluna_qtd, coluna_media, coluna_pico = st.columns(3)
            coluna_qtd.metric('Leituras válidas', resumo['quantidade_validas'])
            coluna_media.metric('Média diária', f"{resumo['media']:.2f} NTU")
            coluna_pico.metric('Maior turbidez', f"{resumo['maximo']:.2f} NTU")
            serie = pd.DataFrame(simples(banco.serie_turbidez())).rename(columns={'coletado_em': 'Horário UTC', 'valor': 'Turbidez (NTU)'})
            serie['Horário UTC'] = pd.to_datetime(serie['Horário UTC'], utc=True).dt.hour
            serie['Média diária (NTU)'] = resumo['media']
            st.line_chart(serie, x='Horário UTC', y=['Turbidez (NTU)', 'Média diária (NTU)'], color=['#168aad', '#e6a23c'])
            tabela(resultado)
        detalhes_pipeline(10)

    # Pipeline MongoDB em telemetria: ranking de alertas técnicos por estação
    with equipamentos:
        st.header('Prioridade de verificação dos equipamentos')
        st.caption('Pipeline 2 · 01 a 07/03/2025 · Bateria abaixo de 20% OU sinal inferior a -85 dBm')
        resultado = consultar(11)
        coluna_estacoes, coluna_diagnosticos = st.columns(2)
        coluna_estacoes.metric('Estações no resultado', len(resultado))
        coluna_diagnosticos.metric('Diagnósticos no período',
                                   sum(item['quantidade_diagnosticos'] for item in resultado))
        if resultado:
            dados_grafico = pd.DataFrame(resultado).rename(
                columns={'estacao': 'Estação', 'quantidade_diagnosticos': 'Diagnósticos'})
            st.bar_chart(dados_grafico, x='Estação', y='Diagnósticos', sort='-Diagnósticos', color='#168aad')
        tabela(resultado)
        detalhes_pipeline(11)

    # Exemplos MongoDB e modelo documental; compara também o índice.
    with modelo:
        st.write('MongoDB preserva pacotes e eventos → Python valida e consolida → MySQL guarda regras e gestão dos alertas.')
        st.write('**medicoes:** uma coleta com leituras incorporadas. **telemetria:** diagnóstico com equipamento incorporado. **logs_ingestao:** evento com referência à coleta.')
        documentos = banco.documentos()
        nome = st.selectbox('Collection', list(documentos))
        st.json(json_util.dumps(documentos[nome], ensure_ascii=False))
        with st.expander('Código de criação e validadores'):
            st.code((banco.DOCS / 'mongodb/01_criar_colecoes.js').read_text(encoding='utf-8'), language='javascript')
        if st.button('Comparar índice e varredura'):
            tabela([{'Plano': k, **v} for k, v in banco.comparar_indice().items()])
        with st.expander('Carga e CRUD em base de ensaio'):
            st.caption('Execute este script no mongosh. A base de ensaio é separada da principal.')
            st.code((banco.PASTA / '03_demo_crud.js').read_text(encoding='utf-8'), language='javascript')

    # Rastreia uma leitura sem gravar ou executa a integração, que grava dados.
    with integracao:
        st.header('Da medição à evidência do alerta')
        st.write('Caso guia: EST-01, 01/07/2025 às 07h, turbidez de 47 NTU. O limite vigente era 45 NTU; às 08h passou a 50.')
        origem, processamento, destino = st.columns(3)
        origem.info('**MongoDB · entrada**\n\n`medicoes`: coletas e leituras. `logs_ingestao`: histórico do processamento.')
        processamento.info('**Python · integração**\n\nLê as leituras válidas, calcula resumos e aplica a regra vigente na coleta.')
        destino.info('**MySQL · resultado**\n\n`resumo_diario_monitoramento`, `alerta` e `evidencia_alerta`.')
        with st.form('conexao', clear_on_submit=True):
            senha_mysql = st.text_input('Senha de rh_integracao_projeto', type='password')
            acao = st.radio('Ação', ['Rastrear evidência (somente leitura)', 'Integrar 01/07/2025 nas 20 estações (grava dados)'])
            executar = st.form_submit_button('Executar')
        if executar:
            if not senha_mysql:
                st.warning('Informe a senha da conta de integração.')
            else:
                with st.spinner('Consultando os bancos…'):
                    if acao.startswith('Integrar'):
                        resultado = banco.executar_integracao(senha_mysql)
                    else:
                        resultado = banco.rastrear_alerta(senha_mysql)
                if acao.startswith('Integrar'):
                    mostrar_integracao(resultado)
                else:
                    mostrar_rastreio(resultado)
                st.cache_data.clear()
except Exception as erro:
    st.error(f'Não foi possível concluir: {erro}')
    st.info('Confira os serviços MongoDB e MySQL80 e as cargas do projeto.')
