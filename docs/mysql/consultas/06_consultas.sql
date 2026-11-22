USE recursos_hidricos;

-- 1. Quais parâmetros estão ativos e em quais unidades são monitorados?
SELECT p.codigo, p.nome AS parametro, u.simbolo AS unidade
FROM parametro_monitoramento p
INNER JOIN unidade_medida u ON u.id_unidade = p.id_unidade
WHERE p.ativo = 1
ORDER BY p.nome;

-- 2. Quais alertas de rios estão pendentes e há quantas horas estão abertos?
SELECT a.id_alerta, e.estacao_codigo, e.estacao, e.bacia,
       a.parametro, a.situacao, a.aberto_em,
       TIMESTAMPDIFF(HOUR, a.aberto_em, UTC_TIMESTAMP()) AS horas_em_aberto
FROM vw_alertas_contexto a
INNER JOIN vw_estacoes_contexto e ON e.id_estacao = a.id_estacao
WHERE e.codigo_tipo_corpo = 'RIO'
  AND a.encerrado_em IS NULL
  AND a.aberto_em <= UTC_TIMESTAMP()
ORDER BY horas_em_aberto DESC, a.id_alerta;

-- 3. Quais estações tiveram pelo menos três alertas abertos no período?
SELECT e.codigo AS estacao_codigo, e.nome AS estacao,
       COUNT(*) AS quantidade_alertas,
       SUM(CASE WHEN a.encerrado_em IS NULL THEN 1 ELSE 0 END) AS pendentes
FROM alerta a
INNER JOIN versao_regra_monitoramento v ON v.id_versao = a.id_versao_abertura
INNER JOIN regra_monitoramento r ON r.id_regra = v.id_regra
INNER JOIN estacao_monitoramento e ON e.id_estacao = r.id_estacao
WHERE a.aberto_em >= '2025-01-01' AND a.aberto_em < '2026-06-05'
GROUP BY e.id_estacao, e.codigo, e.nome
HAVING COUNT(*) >= 3
ORDER BY quantidade_alertas DESC, e.codigo;

-- 4. Quais estações tiveram leituras válidas de turbidez, mas nenhum alerta desse parâmetro aberto no período?
SELECT e.codigo AS estacao_codigo, e.nome AS estacao,
       COUNT(*) AS dias_com_leituras_validas,
       ROUND(SUM(d.soma) / NULLIF(SUM(d.quantidade_validas), 0), 3) AS media_turbidez_ntu
FROM resumo_diario_monitoramento d
INNER JOIN estacao_monitoramento e ON e.id_estacao = d.id_estacao
INNER JOIN parametro_monitoramento p ON p.id_parametro = d.id_parametro
WHERE p.codigo = 'TURBIDEZ'
  AND d.quantidade_validas > 0
  AND d.dia_utc >= '2025-01-01' AND d.dia_utc < '2026-06-05'
  AND NOT EXISTS (
      SELECT 1
      FROM vw_alertas_contexto a
      WHERE a.id_estacao = e.id_estacao
        AND a.id_parametro = p.id_parametro
        AND a.aberto_em >= '2025-01-01' AND a.aberto_em < '2026-06-05'
  )
GROUP BY e.id_estacao, e.codigo, e.nome
ORDER BY media_turbidez_ntu DESC, e.codigo;

-- 5. Qual foi a média de turbidez por bacia, ponderada pela quantidade de leituras válidas no período?
SELECT e.id_bacia, e.bacia, COUNT(DISTINCT e.id_estacao) AS estacoes_com_dados,
       SUM(d.quantidade_validas) AS leituras_validas,
       ROUND(SUM(d.soma) / NULLIF(SUM(d.quantidade_validas), 0), 3) AS media_turbidez_ntu,
       MIN(d.minimo) AS menor_turbidez_ntu, MAX(d.maximo) AS maior_turbidez_ntu
FROM vw_indicadores_diarios d
INNER JOIN vw_estacoes_contexto e ON e.id_estacao = d.id_estacao
WHERE d.parametro_codigo = 'TURBIDEZ'
  AND d.quantidade_validas > 0
  AND d.dia_utc >= '2025-01-01' AND d.dia_utc < '2026-06-05'
GROUP BY e.id_bacia, e.bacia
ORDER BY media_turbidez_ntu DESC, e.bacia;

-- 6. Quais estações e parâmetros tiveram dias com menos de 24 leituras válidas no período?
SELECT e.codigo AS estacao_codigo, p.codigo AS parametro,
       COUNT(*) AS dias_com_menos_de_24_validas,
       SUM(24 - d.quantidade_validas) AS deficit_de_leituras,
       ROUND(AVG(d.quantidade_validas), 2) AS media_validas_nesses_dias
FROM resumo_diario_monitoramento d
INNER JOIN estacao_monitoramento e ON e.id_estacao = d.id_estacao
INNER JOIN parametro_monitoramento p ON p.id_parametro = d.id_parametro
WHERE d.dia_utc >= '2025-01-01' AND d.dia_utc < '2026-06-05'
  AND d.quantidade_validas < 24
GROUP BY e.id_estacao, e.codigo, p.id_parametro, p.codigo
ORDER BY dias_com_menos_de_24_validas DESC, deficit_de_leituras DESC, e.codigo, p.codigo;

-- 7. Quais ocorrências abertas no período receberam intervenções, quantas foram realizadas e qual a situação atual?
SELECT o.id_ocorrencia, o.titulo,
       CASE WHEN o.concluida_em IS NOT NULL THEN 'CONCLUIDA'
            WHEN o.tratamento_iniciado_em IS NOT NULL THEN 'EM TRATAMENTO'
            ELSE 'ABERTA' END AS situacao,
       COUNT(m.id_manutencao) AS quantidade_intervencoes,
       MIN(m.inicio_em) AS primeira_intervencao,
       MAX(m.fim_em) AS ultima_intervencao
FROM ocorrencia o
INNER JOIN manutencao m ON m.id_ocorrencia = o.id_ocorrencia
WHERE o.aberta_em >= '2025-01-01' AND o.aberta_em < '2026-06-05'
GROUP BY o.id_ocorrencia, o.titulo, o.concluida_em, o.tratamento_iniciado_em
ORDER BY quantidade_intervencoes DESC, o.id_ocorrencia;

-- 8. Quais regras tiveram limites alterados entre versões consecutivas, com início da nova versão no período?
SELECT anterior.estacao_codigo, anterior.parametro_codigo,
       anterior.numero_versao AS versao_anterior, nova.numero_versao AS nova_versao,
       anterior.limite_inferior AS limite_inferior_anterior,
       nova.limite_inferior AS novo_limite_inferior,
       anterior.limite_superior AS limite_superior_anterior,
       nova.limite_superior AS novo_limite_superior,
       nova.limite_superior - anterior.limite_superior AS diferenca_limite_superior,
       nova.inicio_em AS alterado_em
FROM vw_historico_regras anterior
INNER JOIN vw_historico_regras nova
    ON nova.id_regra = anterior.id_regra
   AND nova.numero_versao = anterior.numero_versao + 1
WHERE nova.inicio_em >= '2025-01-01' AND nova.inicio_em < '2026-06-05'
  AND (
      anterior.limite_inferior <> nova.limite_inferior
      OR (anterior.limite_inferior IS NULL AND nova.limite_inferior IS NOT NULL)
      OR (anterior.limite_inferior IS NOT NULL AND nova.limite_inferior IS NULL)
      OR anterior.limite_superior <> nova.limite_superior
      OR (anterior.limite_superior IS NULL AND nova.limite_superior IS NOT NULL)
      OR (anterior.limite_superior IS NOT NULL AND nova.limite_superior IS NULL)
  )
ORDER BY anterior.estacao_codigo, anterior.parametro_codigo, nova.numero_versao;

-- 9. Em quais estações e corpos hídricos o sensor EST-01-TURB esteve instalado ao longo do tempo?
SELECT s.codigo_patrimonial, e.codigo AS estacao_codigo, e.nome AS estacao,
       c.nome AS corpo_hidrico, b.nome AS bacia, i.inicio_em, i.fim_em
FROM instalacao_sensor i
INNER JOIN sensor s ON s.id_sensor = i.id_sensor
INNER JOIN estacao_monitoramento e ON e.id_estacao = i.id_estacao
INNER JOIN corpo_hidrico c ON c.id_corpo_hidrico = e.id_corpo_hidrico
INNER JOIN bacia_hidrografica b ON b.id_bacia = c.id_bacia
WHERE s.codigo_patrimonial = 'EST-01-TURB'
ORDER BY i.inicio_em;

-- 10. Quais parâmetros tiveram desvio em alguma calibração no período e quais as estatísticas dos ensaios?
SELECT c.id_parametro, c.parametro, c.unidade,
       COUNT(*) AS calibracoes_realizadas,
       SUM(CASE WHEN c.desvio_absoluto > 0 THEN 1 ELSE 0 END) AS calibracoes_com_desvio,
       ROUND(AVG(c.desvio_absoluto), 6) AS desvio_medio_absoluto,
       MIN(c.desvio_absoluto) AS menor_desvio,
       MAX(c.desvio_absoluto) AS maior_desvio
FROM vw_calibracoes c
WHERE c.inicio_em >= '2025-01-01' AND c.inicio_em < '2026-06-05'
GROUP BY c.id_parametro, c.parametro, c.unidade
HAVING MAX(c.desvio_absoluto) > 0
ORDER BY c.parametro;
