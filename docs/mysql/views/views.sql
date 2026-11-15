USE recursos_hidricos;

CREATE OR REPLACE VIEW vw_estacoes_contexto AS
SELECT e.id_estacao,e.codigo,e.nome,c.nome AS corpo,c.codigo_tipo_corpo,b.nome AS bacia
FROM estacao_monitoramento e JOIN corpo_hidrico c USING(id_corpo_hidrico) JOIN bacia_hidrografica b USING(id_bacia);

CREATE OR REPLACE VIEW vw_instalacoes_atuais AS
SELECT e.codigo AS estacao,s.codigo_patrimonial,i.inicio_em
FROM instalacao_sensor i JOIN estacao_monitoramento e USING(id_estacao) JOIN sensor s USING(id_sensor)
WHERE i.inicio_em<=UTC_TIMESTAMP(3) AND (i.fim_em IS NULL OR i.fim_em>UTC_TIMESTAMP(3));

CREATE OR REPLACE VIEW vw_alertas_contexto AS
SELECT a.id_alerta,e.codigo AS estacao,p.codigo AS parametro,a.aberto_em,a.reconhecido_em,a.encerrado_em,
       v.numero_versao,v.limite_inferior,v.limite_superior,
       CASE WHEN a.encerrado_em IS NOT NULL THEN 'ENCERRADO'
            WHEN a.reconhecido_em IS NOT NULL THEN 'RECONHECIDO' ELSE 'ABERTO' END AS estado
FROM alerta a JOIN versao_regra_monitoramento v ON v.id_versao=a.id_versao_abertura
JOIN regra_monitoramento r USING(id_regra) JOIN estacao_monitoramento e USING(id_estacao)
JOIN parametro_monitoramento p USING(id_parametro);

CREATE OR REPLACE VIEW vw_indicadores_diarios AS
SELECT e.codigo AS estacao,p.codigo AS parametro,r.dia_utc,r.quantidade_validas,r.soma,
       r.minimo,r.maximo,r.soma/NULLIF(r.quantidade_validas,0) AS media
FROM resumo_diario_monitoramento r JOIN estacao_monitoramento e USING(id_estacao)
JOIN parametro_monitoramento p USING(id_parametro);

CREATE OR REPLACE VIEW vw_calibracoes AS
SELECT s.codigo_patrimonial,p.codigo AS parametro,m.inicio_em,c.valor_referencia,c.valor_observado,c.conclusao
FROM calibracao_parametro c JOIN manutencao m USING(id_manutencao)
JOIN sensor s USING(id_sensor) JOIN parametro_monitoramento p USING(id_parametro);

-- Organizar o atendimento: listar alertas que ainda precisam de ação.
SELECT id_alerta, estacao, parametro, estado, aberto_em
FROM vw_alertas_contexto
WHERE estado IN ('ABERTO', 'RECONHECIDO')
ORDER BY aberto_em, id_alerta;

-- Planejar uma vistoria: localizar as estações de rio por bacia.
SELECT codigo, nome AS estacao, corpo AS rio, bacia
FROM vw_estacoes_contexto
WHERE codigo_tipo_corpo = 'RIO'
ORDER BY bacia, estacao;

-- Direcionar a equipe de campo para a instalação vigente do sensor remanejado.
SELECT codigo_patrimonial, estacao, inicio_em
FROM vw_instalacoes_atuais
WHERE codigo_patrimonial = 'EST-01-TURB';

-- Acompanhar a turbidez da estação durante uma semana.
SELECT estacao, dia_utc, quantidade_validas, ROUND(media, 3) AS media_ntu, maximo AS maximo_ntu
FROM vw_indicadores_diarios
WHERE estacao = 'EST-01' AND parametro = 'TURBIDEZ'
  AND dia_utc >= '2025-01-01' AND dia_utc < '2025-01-08'
ORDER BY dia_utc;

-- Consultar o último ensaio de calibração antes de revisar o sensor.
SELECT codigo_patrimonial, parametro, inicio_em, valor_referencia,
       valor_observado, conclusao
FROM vw_calibracoes
WHERE codigo_patrimonial = 'EST-02-TURB'
ORDER BY inicio_em DESC
LIMIT 1;
