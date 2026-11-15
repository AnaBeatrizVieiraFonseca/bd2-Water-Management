USE recursos_hidricos;

-- 1. Quais parâmetros são monitorados e em quais unidades de medida?
SELECT p.codigo, p.nome AS parametro, u.simbolo AS unidade
FROM parametro_monitoramento p JOIN unidade_medida u USING (id_unidade)
WHERE p.ativo = 1 ORDER BY p.nome;

-- 2. Quais alertas de rios estão pendentes e há quanto tempo?
SELECT a.id_alerta, e.codigo AS estacao, p.nome AS parametro, a.aberto_em,
       TIMESTAMPDIFF(HOUR, a.aberto_em, TIMESTAMP('2026-07-03 12:00:00')) AS horas_em_aberto,
       CASE WHEN a.reconhecido_em IS NULL OR a.reconhecido_em > TIMESTAMP('2026-07-03 12:00:00')
            THEN 'ABERTO' ELSE 'RECONHECIDO' END AS estado
FROM alerta a
JOIN versao_regra_monitoramento v ON v.id_versao = a.id_versao_abertura
JOIN regra_monitoramento r USING (id_regra)
JOIN parametro_monitoramento p USING (id_parametro)
JOIN estacao_monitoramento e USING (id_estacao)
JOIN corpo_hidrico c USING (id_corpo_hidrico)
WHERE c.codigo_tipo_corpo = 'RIO' AND a.aberto_em <= TIMESTAMP('2026-07-03 12:00:00')
  AND (a.encerrado_em IS NULL OR a.encerrado_em > TIMESTAMP('2026-07-03 12:00:00'))
ORDER BY horas_em_aberto DESC, a.id_alerta;

-- 3. Quais estações tiveram ao menos três alertas no período histórico?
SELECT e.codigo, e.nome, COUNT(*) AS total,
       SUM(a.encerrado_em IS NOT NULL AND a.encerrado_em <= TIMESTAMP('2026-07-03 12:00:00')) AS encerrados,
       SUM(a.encerrado_em IS NULL OR a.encerrado_em > TIMESTAMP('2026-07-03 12:00:00')) AS pendentes
FROM alerta a JOIN versao_regra_monitoramento v ON v.id_versao = a.id_versao_abertura
JOIN regra_monitoramento r USING (id_regra) JOIN estacao_monitoramento e USING (id_estacao)
WHERE a.aberto_em >= '2025-01-01' AND a.aberto_em < '2026-06-05'
GROUP BY e.codigo, e.nome HAVING COUNT(*) >= 3 ORDER BY total DESC, e.codigo;

-- 4. Quais estações tiveram dados de turbidez, mas nenhum alerta desse parâmetro no período?
SELECT e.codigo, e.nome, COUNT(*) AS dias_com_dados
FROM estacao_monitoramento e JOIN resumo_diario_monitoramento d USING (id_estacao)
JOIN parametro_monitoramento p USING (id_parametro)
WHERE p.codigo = 'TURBIDEZ' AND d.quantidade_validas > 0
  AND d.dia_utc >= '2025-01-01' AND d.dia_utc < '2026-06-05'
  AND NOT EXISTS (
      SELECT 1 FROM alerta a JOIN versao_regra_monitoramento v ON v.id_versao = a.id_versao_abertura
      JOIN regra_monitoramento r USING (id_regra)
      WHERE r.id_estacao = e.id_estacao AND r.id_parametro = p.id_parametro
        AND a.aberto_em >= '2025-01-01' AND a.aberto_em < '2026-06-05'
  )
GROUP BY e.codigo, e.nome ORDER BY e.codigo;

-- 5. Em quais estações de rio a turbidez média subiu de uma semana para a outra?
WITH medias AS (
    SELECT e.codigo, e.nome,
        SUM(CASE WHEN d.dia_utc < '2025-01-08' THEN d.soma END)
        / NULLIF(SUM(CASE WHEN d.dia_utc < '2025-01-08' THEN d.quantidade_validas END),0) AS semana_1,
        SUM(CASE WHEN d.dia_utc >= '2025-01-08' THEN d.soma END)
        / NULLIF(SUM(CASE WHEN d.dia_utc >= '2025-01-08' THEN d.quantidade_validas END),0) AS semana_2
    FROM resumo_diario_monitoramento d JOIN estacao_monitoramento e USING (id_estacao)
    JOIN corpo_hidrico c USING (id_corpo_hidrico) JOIN parametro_monitoramento p USING (id_parametro)
    WHERE c.codigo_tipo_corpo = 'RIO' AND p.codigo = 'TURBIDEZ'
      AND d.dia_utc >= '2025-01-01' AND d.dia_utc < '2025-01-15'
    GROUP BY e.codigo, e.nome
)
SELECT codigo, nome, ROUND(semana_1,3) AS media_1_ntu, ROUND(semana_2,3) AS media_2_ntu,
       ROUND(semana_2-semana_1,3) AS aumento_ntu
FROM medias WHERE semana_2 > semana_1 ORDER BY aumento_ntu DESC, codigo;

-- 6. Onde houve mais dias com menos de 24 leituras válidas em março?
SELECT e.codigo AS estacao, p.codigo AS parametro, COUNT(*) AS dias_incompletos,
       SUM(24-d.quantidade_validas) AS deficit_de_leituras
FROM resumo_diario_monitoramento d JOIN estacao_monitoramento e USING (id_estacao)
JOIN parametro_monitoramento p USING (id_parametro)
WHERE d.dia_utc >= '2025-03-01' AND d.dia_utc < '2025-04-01' AND d.quantidade_validas < 24
GROUP BY e.codigo, p.codigo ORDER BY dias_incompletos DESC, deficit_de_leituras DESC, estacao, parametro;

-- 7. Quais alertas levaram a uma manutenção e quanto tempo passou até a intervenção?
SELECT a.id_alerta, o.titulo, m.tipo_intervencao,
       TIMESTAMPDIFF(MINUTE,a.aberto_em,m.inicio_em) AS minutos_ate_intervencao, m.resultado
FROM alerta a JOIN ocorrencia o USING (id_ocorrencia) JOIN manutencao m USING (id_ocorrencia)
WHERE m.inicio_em >= a.aberto_em ORDER BY a.aberto_em, m.inicio_em;

-- 8. Qual limite abriu cada alerta de turbidez e qual vale na data de referência?
SELECT a.id_alerta, e.codigo AS estacao, a.aberto_em, abertura.numero_versao AS versao_abertura,
       abertura.limite_superior AS limite_abertura_ntu, vigente.limite_superior AS limite_referencia_ntu,
       ev.id_documento_mongo, ev.id_leitura
FROM alerta a JOIN versao_regra_monitoramento abertura ON abertura.id_versao = a.id_versao_abertura
JOIN regra_monitoramento r ON r.id_regra = abertura.id_regra
JOIN estacao_monitoramento e USING (id_estacao)
JOIN parametro_monitoramento p USING (id_parametro)
LEFT JOIN versao_regra_monitoramento vigente ON vigente.id_regra = r.id_regra
    AND vigente.inicio_em <= TIMESTAMP('2026-07-03 12:00:00') AND (vigente.fim_em IS NULL OR vigente.fim_em > TIMESTAMP('2026-07-03 12:00:00'))
LEFT JOIN evidencia_alerta ev ON ev.id_alerta = a.id_alerta AND ev.origem = 1
WHERE p.codigo = 'TURBIDEZ' AND a.aberto_em <= TIMESTAMP('2026-07-03 12:00:00')
ORDER BY e.codigo, a.aberto_em, a.id_alerta;

-- 9. Que corpos hídricos o mesmo sensor monitorou antes e depois do remanejamento?
SELECT s.codigo_patrimonial, e.codigo AS estacao, e.nome, c.nome AS corpo_hidrico, b.nome AS bacia,
       i.inicio_em, i.fim_em
FROM instalacao_sensor i JOIN sensor s USING (id_sensor) JOIN estacao_monitoramento e USING (id_estacao)
JOIN corpo_hidrico c USING (id_corpo_hidrico) JOIN bacia_hidrografica b USING (id_bacia)
WHERE s.codigo_patrimonial = 'EST-01-TURB' ORDER BY i.inicio_em;

-- 10. Quais calibrações detectaram desvio e que ajuste foi registrado?
SELECT s.codigo_patrimonial, p.nome AS parametro, m.inicio_em,
       c.valor_referencia, c.valor_observado, ABS(c.valor_observado-c.valor_referencia) AS desvio_absoluto,
       c.ajuste_realizado
FROM calibracao_parametro c JOIN manutencao m USING (id_manutencao) JOIN sensor s USING (id_sensor)
JOIN parametro_monitoramento p USING (id_parametro)
WHERE m.tipo_intervencao = 'CALIBRACAO' AND c.valor_observado <> c.valor_referencia
ORDER BY m.inicio_em, s.codigo_patrimonial;
