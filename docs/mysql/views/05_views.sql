USE recursos_hidricos;

-- 1. Contexto das estações: corpo hídrico e bacia.
CREATE OR REPLACE VIEW vw_estacoes_contexto AS
SELECT e.id_estacao, e.codigo AS estacao_codigo, e.nome AS estacao,
       c.id_corpo_hidrico, c.nome AS corpo_hidrico, c.codigo_tipo_corpo,
       b.id_bacia, b.nome AS bacia
FROM estacao_monitoramento e
INNER JOIN corpo_hidrico c ON c.id_corpo_hidrico = e.id_corpo_hidrico
INNER JOIN bacia_hidrografica b ON b.id_bacia = c.id_bacia;

-- 2. Alertas com parâmetro, limites de abertura e situação do atendimento.
CREATE OR REPLACE VIEW vw_alertas_contexto AS
SELECT a.id_alerta, r.id_estacao, r.id_parametro,
       a.id_versao_abertura, a.id_ocorrencia,
       a.aberto_em, a.reconhecido_em, a.encerrado_em,
       p.codigo AS parametro_codigo, p.nome AS parametro,
       v.numero_versao, v.limite_inferior, v.limite_superior,
       CASE WHEN a.encerrado_em IS NOT NULL THEN 'ENCERRADO'
            WHEN a.reconhecido_em IS NOT NULL THEN 'RECONHECIDO'
            ELSE 'ABERTO' END AS situacao
FROM alerta a
INNER JOIN versao_regra_monitoramento v ON v.id_versao = a.id_versao_abertura
INNER JOIN regra_monitoramento r ON r.id_regra = v.id_regra
INNER JOIN parametro_monitoramento p ON p.id_parametro = r.id_parametro;

-- 3. Indicadores diários por estação e parâmetro, incluindo a média.
CREATE OR REPLACE VIEW vw_indicadores_diarios AS
SELECT d.id_estacao, d.id_parametro, p.codigo AS parametro_codigo,
       d.dia_utc, d.quantidade_validas, d.soma, d.minimo, d.maximo,
       d.soma / NULLIF(d.quantidade_validas, 0) AS media
FROM resumo_diario_monitoramento d
INNER JOIN parametro_monitoramento p ON p.id_parametro = d.id_parametro;

-- 4. Histórico dos limites e da vigência das versões de cada regra.
CREATE OR REPLACE VIEW vw_historico_regras AS
SELECT r.id_regra, r.id_estacao, r.id_parametro,
       e.codigo AS estacao_codigo, p.codigo AS parametro_codigo,
       v.id_versao, v.numero_versao, v.limite_inferior, v.limite_superior,
       v.prioridade, v.inicio_em, v.fim_em
FROM regra_monitoramento r
INNER JOIN versao_regra_monitoramento v ON v.id_regra = r.id_regra
INNER JOIN estacao_monitoramento e ON e.id_estacao = r.id_estacao
INNER JOIN parametro_monitoramento p ON p.id_parametro = r.id_parametro;

-- 5. Resultados de calibração com sensor, unidade e desvio absoluto.
CREATE OR REPLACE VIEW vw_calibracoes AS
SELECT m.id_manutencao, m.id_sensor, c.id_parametro,
       s.codigo_patrimonial, p.codigo AS parametro_codigo, p.nome AS parametro,
       u.simbolo AS unidade, m.inicio_em, m.fim_em,
       c.valor_referencia, c.valor_observado,
       ABS(c.valor_observado - c.valor_referencia) AS desvio_absoluto,
       c.conclusao, c.ajuste_realizado
FROM calibracao_parametro c
INNER JOIN manutencao m ON m.id_manutencao = c.id_manutencao
INNER JOIN sensor s ON s.id_sensor = m.id_sensor
INNER JOIN parametro_monitoramento p ON p.id_parametro = c.id_parametro
INNER JOIN unidade_medida u ON u.id_unidade = p.id_unidade
WHERE m.tipo_intervencao = 'CALIBRACAO';
