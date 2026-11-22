USE recursos_hidricos;

-- Executar uma vez, apos a carga. Cada bloco compara o EXPLAIN antes e depois do indice.

-- 1. Consultar um parametro em todas as estacoes durante um periodo.
EXPLAIN
SELECT id_estacao, dia_utc, quantidade_validas, soma
FROM resumo_diario_monitoramento
WHERE id_parametro = (
    SELECT id_parametro FROM parametro_monitoramento WHERE codigo = 'TURBIDEZ'
)
AND dia_utc >= '2025-07-01' AND dia_utc < '2025-08-01';

CREATE INDEX ix_resumo_parametro_data
ON resumo_diario_monitoramento (id_parametro, dia_utc);

EXPLAIN
SELECT id_estacao, dia_utc, quantidade_validas, soma
FROM resumo_diario_monitoramento
WHERE id_parametro = (
    SELECT id_parametro FROM parametro_monitoramento WHERE codigo = 'TURBIDEZ'
)
AND dia_utc >= '2025-07-01' AND dia_utc < '2025-08-01';

-- 2. Recuperar todos os parametros de uma estacao durante um periodo.
EXPLAIN
SELECT id_parametro, dia_utc, quantidade_validas, soma
FROM resumo_diario_monitoramento
WHERE id_estacao = (
    SELECT id_estacao FROM estacao_monitoramento WHERE codigo = 'EST-01'
)
AND dia_utc >= '2025-07-01' AND dia_utc < '2025-08-01';

CREATE INDEX ix_resumo_estacao_data
ON resumo_diario_monitoramento (id_estacao, dia_utc);

EXPLAIN
SELECT id_parametro, dia_utc, quantidade_validas, soma
FROM resumo_diario_monitoramento
WHERE id_estacao = (
    SELECT id_estacao FROM estacao_monitoramento WHERE codigo = 'EST-01'
)
AND dia_utc >= '2025-07-01' AND dia_utc < '2025-08-01';

-- 3. Priorizar o atendimento dos dez alertas pendentes mais antigos.
EXPLAIN
SELECT id_alerta, aberto_em
FROM alerta
WHERE encerrado_em IS NULL
ORDER BY aberto_em, id_alerta
LIMIT 10;

CREATE INDEX ix_alerta_pendencia_abertura
ON alerta (encerrado_em, aberto_em);

EXPLAIN
SELECT id_alerta, aberto_em
FROM alerta
WHERE encerrado_em IS NULL
ORDER BY aberto_em, id_alerta
LIMIT 10;

-- 4. Localizar as calibracoes realizadas no periodo, em ordem cronologica.
EXPLAIN
SELECT id_manutencao, inicio_em, fim_em
FROM manutencao
WHERE tipo_intervencao = 'CALIBRACAO'
  AND inicio_em >= '2025-01-01' AND inicio_em < '2026-06-05'
ORDER BY inicio_em, id_manutencao;

CREATE INDEX ix_manutencao_tipo_inicio
ON manutencao (tipo_intervencao, inicio_em);

EXPLAIN
SELECT id_manutencao, inicio_em, fim_em
FROM manutencao
WHERE tipo_intervencao = 'CALIBRACAO'
  AND inicio_em >= '2025-01-01' AND inicio_em < '2026-06-05'
ORDER BY inicio_em, id_manutencao;

-- 5. Localizar a leitura que originou o primeiro alerta registrado.
EXPLAIN
SELECT id_documento_mongo, id_leitura
FROM evidencia_alerta
WHERE id_alerta = (SELECT MIN(id_alerta) FROM alerta)
  AND origem = 1;

CREATE INDEX ix_evidencia_alerta_origem
ON evidencia_alerta (id_alerta, origem);

EXPLAIN
SELECT id_documento_mongo, id_leitura
FROM evidencia_alerta
WHERE id_alerta = (SELECT MIN(id_alerta) FROM alerta)
  AND origem = 1;


