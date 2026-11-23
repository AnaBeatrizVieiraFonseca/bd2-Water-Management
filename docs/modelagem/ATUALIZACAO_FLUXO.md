# Atualização do fluxo integrado

Esta nota complementa a modelagem MongoDB e registra o comportamento do código atual do painel. Em caso de diferença sobre a execução, esta nota e os arquivos Python são a referência atual.

## Como executar

O painel é iniciado por `docs/apresentacao/ABRIR_PAINEL.bat`. A ação **Integrar 01/07/2025** chama `app.py`, que delega a conexão e a chamada ao integrador em `banco.py`; `banco.py` carrega `docs/integração/01_integrar.py` e chama `integrar()` para o intervalo de 1º de julho de 2025, com o dia 2 como limite final exclusivo. Não há mais um BAT separado para executar o integrador no terminal.

## O que o integrador faz

1. Lê do MongoDB as medições do período e do MySQL as estações, parâmetros e regras.
2. Ignora leituras com `valida: false`; acumula quantidade, soma, mínimo e máximo das válidas.
3. Compara cada leitura com a versão da regra válida no instante da coleta.
4. Registra alertas e evidências no MySQL quando há desvio, e logs de integração em `logs_ingestao` no MongoDB.
5. Grava ou atualiza os resumos diários no MySQL.

## Premissas da versão simplificada

O integrador foi reduzido para a carga fixa de demonstração. Ele pressupõe que as relações entre estação, sensor, parâmetro, unidade e instalação já estejam corretas; não faz essas validações entre bancos. Também não calcula hash dos documentos nem identifica dias sem alteração. Ao executar novamente o período, atualiza os resumos, evita duplicar evidências existentes e acrescenta logs novos.

## Observações sobre o PDF de modelagem

O PDF `Modelagem_mongodb.pdf` registra a modelagem e decisões anteriores. As descrições de validação cruzada do integrador, hash de origem e criação do índice `ix_logs_integracao_documento_instante` não correspondem à versão simplificada atual. O índice MongoDB atualmente usado no painel é `ix_medicoes_estacao_data`, criado pelos scripts de consulta/indexação.
