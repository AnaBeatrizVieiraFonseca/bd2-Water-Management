# Sistema de Monitoramento e Gestão de Recursos Hídricos

Projeto desenvolvido pelo **Grupo 4**, na disciplina de **Banco de Dados II**, para uma entidade fictícia responsável pelo monitoramento de rios e reservatórios de uma região.

## Descrição

O acompanhamento dos recursos hídricos envolve informações de naturezas diferentes: cadastros de estações e equipamentos, histórico de instalação dos sensores, medições ambientais, diagnósticos técnicos e atendimento de situações críticas.

A solução reúne essas informações em duas bases integradas: **MySQL**, responsável pelos cadastros e pela gestão operacional, e **MongoDB**, responsável pelas medições, telemetria e logs. Os dados utilizados são simulados para estudo e demonstração do funcionamento do projeto.

## Objetivo

Apoiar o acompanhamento das condições dos corpos hídricos, permitindo consultar o histórico das medições, identificar desvios em relação aos limites configurados, acompanhar alertas e registrar ocorrências, manutenções e calibrações.

Os parâmetros monitorados são temperatura da água, pH, oxigênio dissolvido, turbidez e nível da água.

## Tecnologias utilizadas

| Tecnologia | Utilização |
| --- | --- |
| MySQL 8.0 | Armazenamento relacional, consultas, views, procedures, triggers, índices e controle de acesso. |
| MySQL Workbench | Modelagem, execução dos scripts SQL e consulta aos dados. |
| MongoDB Community 8.0 | Armazenamento dos documentos de monitoramento. |
| MongoDB Compass e mongosh | Importação de JSON, manipulação de documentos, consultas e pipelines. |
| Python 3.14 | Integração entre MongoDB e MySQL. |
| mysql-connector-python 9.7.0 e PyMongo 4.20.0 | Conexão do integrador com os bancos de dados. |
| Git e GitHub | Versionamento e organização dos arquivos do projeto. |

A reprodução dos scripts foi verificada com MySQL **8.0.44**, MongoDB **8.0.38** e Python **3.14**, em ambiente Windows. O painel Streamlit é iniciado por `docs/apresentacao/ABRIR_PAINEL.bat`, que prepara o ambiente Python quando necessário.

## Arquitetura de dados

As duas bases recebem o nome `recursos_hidricos`, cada uma em seu respectivo servidor.

### MySQL

O modelo relacional organiza bacias hidrográficas, corpos hídricos, estações, sensores, períodos de instalação, parâmetros, unidades de medida e versões das regras de monitoramento. Também armazena usuários, perfis, permissões, alertas, referências às evidências, ocorrências, ações, intervenções e auditoria.

Essas informações possuem relações e regras de integridade representadas por chaves primárias, chaves estrangeiras e restrições. Os resumos diários ficam no MySQL para permitir a análise consolidada por estação, parâmetro e período.

### MongoDB

| Collection | Conteúdo |
| --- | --- |
| `medicoes` | Coletas identificadas por estação e horário, com um array de leituras contendo sensor, parâmetro, unidade, valor e indicação de validade. |
| `telemetria` | Diagnósticos dos equipamentos, incluindo bateria, sinal e atributos técnicos incorporados ao documento. |
| `logs_ingestao` | Registros de ingestão e integração, com resultado do processamento e informações de origem. |

Os documentos agrupam informações recebidas no mesmo contexto de coleta e comportam estruturas aninhadas, arrays e atributos técnicos variáveis. As collections possuem validação dos campos e tipos essenciais.

### Integração

```text
Arquivos JSON e inserções de exemplo
                 |
                 v
MongoDB: medições, telemetria e logs
                 |
                 | Python consulta as medições e os cadastros/regras do MySQL
                 v
MySQL: resumos diários, alertas e referências às evidências
                 |
                 v
Consultas, views, relatórios e atendimento dos alertas
```

O painel chama o integrador Python. Ele lê as medições do MongoDB e as regras no MySQL, usa as leituras marcadas como válidas para calcular resumos e comparar valores com a regra vigente no horário da coleta.

O integrador assume que a carga fixa já está consistente: não confere a compatibilidade de sensores, unidades ou instalações entre os bancos. Leituras inválidas são ignoradas nos resumos. Desvios geram alertas/evidências no MySQL; cada execução registra logs em `logs_ingestao` no MongoDB. Reexecutar o mesmo dia atualiza os resumos, não duplica evidências existentes e acrescenta novos logs.

Os valores individuais das medições permanecem no MongoDB; no MySQL ficam os dados de gestão e os resultados consolidados necessários às consultas.

## Estrutura do repositório

```text
bd2-Water-Management/
├── README.md
├── .gitignore
└── docs/
    ├── requisitos/       # Levantamento de requisitos
    ├── dicionario/       # Dicionário de dados
    ├── modelagem/        # MER, modelo relacional e documentação MongoDB
    ├── mysql/
    │   ├── ddl/          # Criação do banco e das tabelas
    │   ├── dml/          # Cadastros e cenários operacionais
    │   ├── consultas/    # Consultas do domínio
    │   ├── views/        # Consultas reutilizáveis
    │   ├── procedures/   # Operações e relatório parametrizado
    │   ├── triggers/     # Auditoria de operações
    │   ├── indices/      # Índices e análise com EXPLAIN
    │   └── dcl/          # Contas, perfis, permissões e testes de acesso
    ├── mongodb/
    │   ├── 01_criar_colecoes.js
    │   ├── dados/        # Carga JSON e manipulação de documentos
    │   └── consultas/    # Consultas, pipelines e indexação
    ├── integração/       # Função Python chamada pelo painel
    └── apresentacao/     # Painel Streamlit, catálogo e arquivos de demonstração
```

Documentos disponíveis:

- [Levantamento de requisitos](docs/requisitos/Levantamento%20de%20requisitos%20-%20Grupo%204.pdf).
- [Dicionário de dados](docs/dicionario/Dicion%C3%A1rio%20de%20dados.pdf).
- [Modelagem relacional (.mwb)](docs/modelagem/modelagem.mwb).
- [Modelo Entidade-Relacionamento](docs/modelagem/MER.png).
- [Documentação da modelagem MongoDB](docs/modelagem/Modelagem_mongodb.pdf).
- [Atualização do fluxo integrado](docs/modelagem/ATUALIZACAO_FLUXO.md), com o comportamento atual do painel e do integrador.

## Como executar

As etapas abaixo descrevem a montagem das bases e a execução do painel integrado.

### 1. Preparar o ambiente

Baixe o repositório em **Code > Download ZIP** e extraia os arquivos. Instale MySQL Server, Workbench, MongoDB Community, Compass e Python com `pip`. Os servidores devem estar em execução; Workbench e Compass são os clientes de acesso.

Os padrões locais são MySQL em `localhost:3306` e MongoDB em `mongodb://localhost:27017`. `localhost` corresponde ao computador em que o projeto está sendo executado. O cenário acadêmico utiliza MongoDB local sem autenticação, restrito ao próprio computador.

Use bases novas e dedicadas ao projeto. Se `recursos_hidricos` já existir, confira seu conteúdo antes de iniciar. Os caminhos abaixo partem da raiz do repositório.

### 2. Montar o MySQL

No Workbench, conecte-se como `root` ou outra conta autorizada a criar os objetos e conceder os privilégios. Abra os arquivos em **File > Open SQL Script** e execute nesta ordem:

| Ordem | Arquivo | Finalidade |
| --- | --- | --- |
| 1 | [01_criacao_banco.sql](docs/mysql/ddl/01_criacao_banco.sql) | Criar a base. |
| 2 | [02_criacao_tabelas.sql](docs/mysql/ddl/02_criacao_tabelas.sql) | Criar tabelas e restrições. |
| 3 | [03_cadastro_e_historico.sql](docs/mysql/dml/03_cadastro_e_historico.sql) | Inserir os cadastros e históricos iniciais. |
| 4 | [04_cenarios_operacionais.sql](docs/mysql/dml/04_cenarios_operacionais.sql) | Inserir ocorrências, ações, manutenções e calibrações. |
| 5 | [05_views.sql](docs/mysql/views/05_views.sql) | Criar as cinco views. |
| 6 | [07_procedure.sql](docs/mysql/procedures/07_procedure.sql) | Criar as três procedures. |
| 7 | [08_triggers.sql](docs/mysql/triggers/08_triggers.sql) | Criar as três triggers de auditoria. |
| 8 | [09_usuarios_e_permissoes.sql](docs/mysql/dcl/09_usuarios_e_permissoes.sql) | Criar os perfis administrador, operador e analista. |
| 9 | [10_usuario_integracao.sql](docs/mysql/dcl/10_usuario_integracao.sql) | Criar a conta técnica da integração. |

Guarde as senhas retornadas para as contas novas em local privado. Elas são geradas no computador de destino e não estão no repositório. A montagem inicial contém **491 registros**; os resumos e alertas serão preenchidos pela integração.

### 3. Montar e carregar o MongoDB

Conecte o Compass ao servidor local e abra o mongosh integrado. Copie e execute o conteúdo de [01_criar_colecoes.js](docs/mongodb/01_criar_colecoes.js), que seleciona a base e cria as três collections com seus validadores.

Extraia [02_carga_mongodb.zip](docs/mongodb/dados/02_carga_mongodb.zip). Em cada collection, use **Add Data > Import JSON or CSV file** e importe o arquivo correspondente:

| Arquivo extraído | Collection |
| --- | --- |
| `medicoes.json` | `medicoes` |
| `telemetria.json` | `telemetria` |
| `logs_ingestao.json` | `logs_ingestao` |

Depois da importação:

1. Insira o documento de [03_exemplo_insercao_manual.json](docs/mongodb/dados/03_exemplo_insercao_manual.json) na collection `telemetria`, pelo editor **Add Data > Insert Document**. Use a visualização JSON compatível com Extended JSON; se o editor estiver no modo shell e solicitar conversão de `$date`, use **Convert**.
2. Execute [04_inserir_exemplos.js](docs/mongodb/dados/04_inserir_exemplos.js) no mongosh para os exemplos de `insertOne()` e `insertMany()`.
3. Execute [05_atualizacao_e_exclusao.js](docs/mongodb/dados/05_atualizacao_e_exclusao.js) no mongosh para atualizar diagnósticos e excluir os exemplos indicados pelo script.
4. Execute [06_consultas.js](docs/mongodb/consultas/06_consultas.js), [07_aggregation_pipelines.js](docs/mongodb/consultas/07_aggregation_pipelines.js) e [08_indexacao.js](docs/mongodb/consultas/08_indexacao.js), nesta ordem.

O script de indexação compara a consulta antes e depois da criação do índice. Preserve os resultados dessa primeira execução para a análise de desempenho.

### 4. Executar a integração

Com os servidores MySQL e MongoDB em execução e os dados carregados, abra `docs/apresentacao/ABRIR_PAINEL.bat`. Na aba **Integração Python**, informe a senha de `rh_integracao_projeto` e escolha a ação. A opção de integração processa as medições de **01/07/2025** nas 20 estações. A senha é usada somente durante a conexão.

### 5. Consultar e testar a solução

Após a integração, execute no Workbench:

| Arquivo | Utilização |
| --- | --- |
| [06_consultas.sql](docs/mysql/consultas/06_consultas.sql) | Executar as dez consultas do domínio com os dados consolidados. |
| [indices.sql](docs/mysql/indices/indices.sql) | Comparar os planos com `EXPLAIN`, criar os cinco índices adicionais e analisar os planos posteriores. |
| [07_demonstrar_procedure.sql](docs/mysql/procedures/07_demonstrar_procedure.sql) | Reconhecer e encerrar um alerta, gerar o relatório e consultar a auditoria. |
| [08_demonstrar_auditoria_manutencao.sql](docs/mysql/triggers/08_demonstrar_auditoria_manutencao.sql) | Registrar uma inspeção e verificar sua auditoria automática. |
| [11_demostrar_acessos.sql](docs/mysql/dcl/11_demostrar_acessos.sql) | Conferir operações permitidas e negadas para cada perfil. |

Os dois arquivos de demonstração de procedures e manutenção terminam com `ROLLBACK`, desfazendo as alterações do ensaio. Execute-os por inteiro, sem outras alterações pendentes na conexão. No arquivo de acessos, execute cada bloco na conexão da conta indicada; os comandos marcados como **NEGADO** devem produzir erro de permissão.

As cargas e os comandos `CREATE INDEX` devem ser executados uma vez durante a montagem. Para estudar uma base pronta, utilize as consultas e os roteiros de demonstração. Se ocorrer erro no meio de uma carga, confira a mensagem e o estado dos dados antes de repetir o arquivo.

Na carga publicada, a consulta SQL 7 pode retornar vazia porque os alertas gerados ainda não estão vinculados às ocorrências. As consultas de falhas de integração também podem retornar vazias quando não há falhas registradas.

## Dados e desempenho

A carga simulada representa **4 bacias hidrográficas, 20 corpos hídricos, 20 estações e 100 sensores**. Os arquivos JSON estão incluídos no repositório; a montagem não depende de gerar novamente a simulação.

Snapshot da reprodução completa anterior, após a carga, exemplos e integração de todo o período:

| Conjunto | Quantidade |
| --- | ---: |
| Registros totais no MySQL | 58.293 |
| Resumos diários no MySQL | 52.000 |
| Alertas no MySQL | 68 |
| Referências às evidências no MySQL | 5.734 |
| Documentos em `medicoes` | 249.501 |
| Documentos em `telemetria` | 52.017 |
| Documentos em `logs_ingestao`, após a integração | 499.101 |

Um documento de medição pode conter várias leituras. Na reprodução completa anterior, a integração processou **1.241.038 leituras válidas** e identificou **6.467 inválidas**. Esses valores não são o resultado da ação atual do painel, que integra somente 01/07/2025; novas operações podem alterar os totais.

O maior crescimento ocorre nas medições e nos logs. Como estimativa, 20 estações enviando uma coleta por hora produzem **175.200 documentos de medição por ano**; com cinco leituras por coleta, são **876.000 leituras anuais**. Para 20 estações e cinco parâmetros, os resumos diários representam **36.500 registros por ano**. São projeções desse cenário, antes de falhas, reenvios e mudanças na frequência de coleta.

A separação entre medições individuais e resumos reduz o volume consultado nos relatórios consolidados. Os scripts de indexação analisam filtros por estação, parâmetro, período e situação operacional. No teste MongoDB, o índice reduziu os documentos examinados de **249.501 para 24**, mantendo os mesmos 24 resultados. Os tempos de execução dependem do equipamento, do cache e do ambiente.

## Integrantes

| Integrante | GitHub |
| --- | --- |
| Ana Beatriz Vieira Fonseca | [@AnaBeatrizVieiraFonseca](https://github.com/AnaBeatrizVieiraFonseca) |
| Atílio Miranda | [@atiliozem-droid](https://github.com/atiliozem-droid) |
| Giovanni Andrade | [@GiovanniADCS](https://github.com/GiovanniADCS) |
| Lucas Vonach | [@Lucasvmb](https://github.com/Lucasvmb) |
| Miguel Rodrigues | [@miguelsouzz](https://github.com/miguelsouzz) |

## Disciplina

Banco de Dados II.

## Painel integrado

O painel Streamlit em `docs/apresentacao/app.py` mostra os dois pipelines, a modelagem e a integração Python. Para abrir, execute `docs/apresentacao/Recursos Hidricos.exe` (requer o .NET 9 Desktop Runtime) ou `docs/apresentacao/ABRIR_PAINEL.bat`. O lançador prepara o ambiente virtual e instala `requirements.txt` na primeira execução; depois abra `http://127.0.0.1:8501` se o navegador não abrir automaticamente.

Na aba **Integração Python**, “Rastrear evidência” consulta os bancos sem gravar. “Integrar 01/07/2025” grava resumos, alertas/evidências e logs. A senha de `rh_integracao_projeto` é solicitada no painel e não é salva em arquivo.
