SET NAMES utf8mb4;
SET time_zone = '+00:00';

USE recursos_hidricos;

START TRANSACTION;

INSERT INTO tipo_corpo_hidrico (codigo_tipo_corpo, nome)
SELECT novo.codigo, novo.nome
FROM (SELECT 'RIO' AS codigo, 'Rio' AS nome UNION ALL
      SELECT 'RESERVATORIO', 'Reservatório') AS novo
WHERE NOT EXISTS (SELECT 1 FROM tipo_corpo_hidrico t WHERE t.codigo_tipo_corpo = novo.codigo);

INSERT INTO orgao_responsavel (codigo, nome) VALUES
    ('ORG-REGIONAL', 'Agência Regional de Monitoramento Hídrico');

INSERT INTO usuario (email, nome, tipo_identidade) VALUES
    ('monitoramento@simulacao.example', 'Serviço de monitoramento', 'SERVICO');

INSERT INTO bacia_hidrografica (codigo, nome) VALUES
    ('BAC-01', 'Bacia do Rio Cedro'),
    ('BAC-02', 'Bacia do Rio Capivari'),
    ('BAC-03', 'Bacia do Rio Jacutinga'),
    ('BAC-04', 'Bacia do Rio Monjolo');

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-01', 'Rio Cedro', id_bacia, 'RIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-01';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-01', 'Ponte do Cedro', c.id_corpo_hidrico, o.id_orgao, -22.010000, -47.010000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-01' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-02', 'Rio Figueira', id_bacia, 'RIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-02';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-02', 'Passagem da Figueira', c.id_corpo_hidrico, o.id_orgao, -22.020000, -47.020000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-02' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-03', 'Rio Garças', id_bacia, 'RIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-03';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-03', 'Poço das Garças', c.id_corpo_hidrico, o.id_orgao, -22.030000, -47.030000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-03' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-04', 'Rio Monjolo', id_bacia, 'RIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-04';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-04', 'Foz do Monjolo', c.id_corpo_hidrico, o.id_orgao, -22.040000, -47.040000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-04' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-05', 'Rio Ipê', id_bacia, 'RIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-01';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-05', 'Várzea do Ipê', c.id_corpo_hidrico, o.id_orgao, -22.050000, -47.050000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-05' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-06', 'Rio Canela', id_bacia, 'RIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-02';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-06', 'Porto da Canela', c.id_corpo_hidrico, o.id_orgao, -22.060000, -47.060000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-06' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-07', 'Rio Pedras', id_bacia, 'RIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-03';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-07', 'Ponte das Pedras', c.id_corpo_hidrico, o.id_orgao, -22.070000, -47.070000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-07' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-08', 'Rio Capivari', id_bacia, 'RIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-04';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-08', 'Barra do Capivari', c.id_corpo_hidrico, o.id_orgao, -22.080000, -47.080000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-08' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-09', 'Rio Jacutinga', id_bacia, 'RIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-01';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-09', 'Travessia do Jacutinga', c.id_corpo_hidrico, o.id_orgao, -22.090000, -47.090000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-09' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-10', 'Rio Angico', id_bacia, 'RIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-02';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-10', 'Baixada do Angico', c.id_corpo_hidrico, o.id_orgao, -22.100000, -47.100000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-10' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-11', 'Rio Barreiro', id_bacia, 'RIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-03';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-11', 'Ponte do Barreiro', c.id_corpo_hidrico, o.id_orgao, -22.110000, -47.110000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-11' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-12', 'Rio Limeira', id_bacia, 'RIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-04';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-12', 'Foz da Limeira', c.id_corpo_hidrico, o.id_orgao, -22.120000, -47.120000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-12' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-13', 'Reservatório Serra Azul', id_bacia, 'RESERVATORIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-01';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-13', 'Barragem da Serra Azul', c.id_corpo_hidrico, o.id_orgao, -22.130000, -47.130000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-13' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-14', 'Reservatório Pinhal', id_bacia, 'RESERVATORIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-02';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-14', 'Tomada do Pinhal', c.id_corpo_hidrico, o.id_orgao, -22.140000, -47.140000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-14' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-15', 'Reservatório Horizonte', id_bacia, 'RESERVATORIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-03';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-15', 'Dique do Horizonte', c.id_corpo_hidrico, o.id_orgao, -22.150000, -47.150000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-15' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-16', 'Reservatório Esperança', id_bacia, 'RESERVATORIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-04';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-16', 'Margem da Esperança', c.id_corpo_hidrico, o.id_orgao, -22.160000, -47.160000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-16' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-17', 'Reservatório Boa Vista', id_bacia, 'RESERVATORIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-01';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-17', 'Barragem da Boa Vista', c.id_corpo_hidrico, o.id_orgao, -22.170000, -47.170000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-17' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-18', 'Reservatório Pedra Branca', id_bacia, 'RESERVATORIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-02';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-18', 'Tomada da Pedra Branca', c.id_corpo_hidrico, o.id_orgao, -22.180000, -47.180000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-18' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-19', 'Reservatório Retiro', id_bacia, 'RESERVATORIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-03';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-19', 'Dique do Retiro', c.id_corpo_hidrico, o.id_orgao, -22.190000, -47.190000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-19' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO corpo_hidrico (codigo, nome, id_bacia, codigo_tipo_corpo)
SELECT 'CH-20', 'Reservatório Vale Verde', id_bacia, 'RESERVATORIO'
FROM bacia_hidrografica WHERE codigo = 'BAC-04';

INSERT INTO estacao_monitoramento (codigo, nome, id_corpo_hidrico, id_orgao, latitude, longitude)
SELECT 'EST-20', 'Margem do Vale Verde', c.id_corpo_hidrico, o.id_orgao, -22.200000, -47.200000
FROM corpo_hidrico c CROSS JOIN orgao_responsavel o
WHERE c.codigo = 'CH-20' AND o.codigo = 'ORG-REGIONAL';

INSERT INTO unidade_medida (codigo, nome, simbolo) VALUES
    ('CELSIUS', 'Grau Celsius', '°C'),
    ('ADIM', 'Adimensional', '1'),
    ('MG_L', 'Miligrama por litro', 'mg/L'),
    ('NTU', 'Unidade nefelométrica de turbidez', 'NTU'),
    ('METRO', 'Metro', 'm');

INSERT INTO tipo_sensor (codigo, nome) VALUES
    ('TEMP', 'Sensor de temperatura da água'),
    ('PH', 'Sensor de ph'),
    ('OXIG', 'Sensor de oxigênio dissolvido'),
    ('TURB', 'Sensor de turbidez'),
    ('NIV', 'Sensor de nível da água');

INSERT INTO parametro_monitoramento (codigo, nome, id_unidade)
SELECT 'TEMPERATURA', 'Temperatura da água', id_unidade FROM unidade_medida WHERE codigo = 'CELSIUS';
INSERT INTO tipo_sensor_parametro (id_tipo_sensor, id_parametro)
SELECT t.id_tipo_sensor, p.id_parametro FROM tipo_sensor t CROSS JOIN parametro_monitoramento p
WHERE t.codigo = 'TEMP' AND p.codigo = 'TEMPERATURA';

INSERT INTO parametro_monitoramento (codigo, nome, id_unidade)
SELECT 'PH', 'pH', id_unidade FROM unidade_medida WHERE codigo = 'ADIM';
INSERT INTO tipo_sensor_parametro (id_tipo_sensor, id_parametro)
SELECT t.id_tipo_sensor, p.id_parametro FROM tipo_sensor t CROSS JOIN parametro_monitoramento p
WHERE t.codigo = 'PH' AND p.codigo = 'PH';

INSERT INTO parametro_monitoramento (codigo, nome, id_unidade)
SELECT 'OXIGENIO', 'Oxigênio dissolvido', id_unidade FROM unidade_medida WHERE codigo = 'MG_L';
INSERT INTO tipo_sensor_parametro (id_tipo_sensor, id_parametro)
SELECT t.id_tipo_sensor, p.id_parametro FROM tipo_sensor t CROSS JOIN parametro_monitoramento p
WHERE t.codigo = 'OXIG' AND p.codigo = 'OXIGENIO';

INSERT INTO parametro_monitoramento (codigo, nome, id_unidade)
SELECT 'TURBIDEZ', 'Turbidez', id_unidade FROM unidade_medida WHERE codigo = 'NTU';
INSERT INTO tipo_sensor_parametro (id_tipo_sensor, id_parametro)
SELECT t.id_tipo_sensor, p.id_parametro FROM tipo_sensor t CROSS JOIN parametro_monitoramento p
WHERE t.codigo = 'TURB' AND p.codigo = 'TURBIDEZ';

INSERT INTO parametro_monitoramento (codigo, nome, id_unidade)
SELECT 'NIVEL', 'Nível da água', id_unidade FROM unidade_medida WHERE codigo = 'METRO';
INSERT INTO tipo_sensor_parametro (id_tipo_sensor, id_parametro)
SELECT t.id_tipo_sensor, p.id_parametro FROM tipo_sensor t CROSS JOIN parametro_monitoramento p
WHERE t.codigo = 'NIV' AND p.codigo = 'NIVEL';

INSERT INTO sensor (codigo_patrimonial, id_tipo_sensor)
SELECT CONCAT(e.codigo, '-', t.codigo), t.id_tipo_sensor
FROM estacao_monitoramento e CROSS JOIN tipo_sensor t
WHERE e.codigo BETWEEN 'EST-01' AND 'EST-20'
  AND t.codigo IN ('TEMP','PH','OXIG','TURB','NIV');

INSERT INTO instalacao_sensor (id_sensor, id_estacao, inicio_em, id_usuario_instalacao)
SELECT s.id_sensor, e.id_estacao, '2025-01-01 00:00:00.000', u.id_usuario
FROM sensor s JOIN tipo_sensor t ON t.id_tipo_sensor = s.id_tipo_sensor
JOIN estacao_monitoramento e ON s.codigo_patrimonial = CONCAT(e.codigo, '-', t.codigo)
CROSS JOIN usuario u
WHERE e.codigo BETWEEN 'EST-01' AND 'EST-20'
  AND t.codigo IN ('TEMP','PH','OXIG','TURB','NIV')
  AND u.email = 'monitoramento@simulacao.example';

INSERT INTO regra_monitoramento (id_estacao, id_parametro)
SELECT e.id_estacao, p.id_parametro
FROM estacao_monitoramento e CROSS JOIN parametro_monitoramento p
WHERE e.codigo BETWEEN 'EST-01' AND 'EST-20'
  AND p.codigo IN ('TEMPERATURA','PH','OXIGENIO','TURBIDEZ','NIVEL');

INSERT INTO versao_regra_monitoramento
    (id_regra, numero_versao, limite_inferior, limite_superior, prioridade, inicio_em, id_usuario_configuracao)
SELECT r.id_regra, 1,
       CASE p.codigo WHEN 'PH' THEN 6.5 WHEN 'OXIGENIO' THEN 5
            WHEN 'NIVEL' THEN CASE c.codigo_tipo_corpo WHEN 'RIO' THEN 0.5 ELSE 7.5 END END,
       CASE p.codigo WHEN 'PH' THEN 8.5 WHEN 'TEMPERATURA' THEN 31 WHEN 'TURBIDEZ' THEN 45
            WHEN 'NIVEL' THEN CASE c.codigo_tipo_corpo WHEN 'RIO' THEN 2 ELSE 11 END END,
       'ATENCAO', '2025-01-01 00:00:00.000', u.id_usuario
FROM regra_monitoramento r
JOIN estacao_monitoramento e ON e.id_estacao = r.id_estacao
JOIN corpo_hidrico c ON c.id_corpo_hidrico = e.id_corpo_hidrico
JOIN parametro_monitoramento p ON p.id_parametro = r.id_parametro
CROSS JOIN usuario u
WHERE e.codigo BETWEEN 'EST-01' AND 'EST-20'
  AND p.codigo IN ('TEMPERATURA','PH','OXIGENIO','TURBIDEZ','NIVEL')
  AND u.email = 'monitoramento@simulacao.example';

COMMIT;

SET NAMES utf8mb4;
USE recursos_hidricos;
SET time_zone = '+00:00';
START TRANSACTION;

SET @ator = (SELECT id_usuario FROM usuario WHERE email='monitoramento@simulacao.example');


SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-01');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='OXIGENIO');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 20 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-01');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='NIVEL');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 190 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-01');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='TURBIDEZ');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 360 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,NULL,NULL,NULL,@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-02');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='NIVEL');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 25 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-02');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='TURBIDEZ');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 195 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO ocorrencia (titulo, descricao, aberta_em, id_usuario_abertura,
    tratamento_iniciado_em, id_usuario_tratamento, concluida_em, id_usuario_conclusao, justificativa_conclusao)
VALUES ('Verificação de TURBIDEZ em EST-02', 'Equipe acionada após desvio do parâmetro.',
    DATE_ADD(@aberto, INTERVAL 1 HOUR), @ator, DATE_ADD(@aberto, INTERVAL 2 HOUR), @ator,
    DATE_ADD(@aberto, INTERVAL 6 HOUR), @ator, 'Inspeção concluída e monitoramento restabelecido.');
SET @ocorrencia = LAST_INSERT_ID();
INSERT INTO ocorrencia_estacao (id_ocorrencia,id_estacao) VALUES (@ocorrencia,@estacao);
INSERT INTO acao_ocorrencia (id_ocorrencia,descricao,realizada_em,id_usuario_responsavel)
VALUES (@ocorrencia,'Vistoria e comparação com a medição de referência.',DATE_ADD(@aberto, INTERVAL 3 HOUR),@ator);
INSERT INTO manutencao (id_estacao,id_ocorrencia,tipo_intervencao,inicio_em,fim_em,descricao,resultado,id_usuario_responsavel)
VALUES (@estacao,@ocorrencia,'MANUTENCAO',DATE_ADD(@aberto, INTERVAL 3 HOUR),
    DATE_ADD(@aberto, INTERVAL 5 HOUR),'Revisão da estação e limpeza preventiva.','Estação liberada.',@ator);

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-02');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='OXIGENIO');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 365 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,NULL,NULL,NULL,NULL,NULL,@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-03');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='TURBIDEZ');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 30 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO ocorrencia (titulo, descricao, aberta_em, id_usuario_abertura,
    tratamento_iniciado_em, id_usuario_tratamento, concluida_em, id_usuario_conclusao, justificativa_conclusao)
VALUES ('Verificação de TURBIDEZ em EST-03', 'Equipe acionada após desvio do parâmetro.',
    DATE_ADD(@aberto, INTERVAL 1 HOUR), @ator, DATE_ADD(@aberto, INTERVAL 2 HOUR), @ator,
    DATE_ADD(@aberto, INTERVAL 6 HOUR), @ator, 'Inspeção concluída e monitoramento restabelecido.');
SET @ocorrencia = LAST_INSERT_ID();
INSERT INTO ocorrencia_estacao (id_ocorrencia,id_estacao) VALUES (@ocorrencia,@estacao);
INSERT INTO acao_ocorrencia (id_ocorrencia,descricao,realizada_em,id_usuario_responsavel)
VALUES (@ocorrencia,'Vistoria e comparação com a medição de referência.',DATE_ADD(@aberto, INTERVAL 3 HOUR),@ator);
INSERT INTO manutencao (id_estacao,id_ocorrencia,tipo_intervencao,inicio_em,fim_em,descricao,resultado,id_usuario_responsavel)
VALUES (@estacao,@ocorrencia,'MANUTENCAO',DATE_ADD(@aberto, INTERVAL 3 HOUR),
    DATE_ADD(@aberto, INTERVAL 5 HOUR),'Revisão da estação e limpeza preventiva.','Estação liberada.',@ator);

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-03');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='OXIGENIO');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 200 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-03');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='NIVEL');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 370 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-04');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='OXIGENIO');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 35 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-04');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='NIVEL');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 205 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-04');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='TURBIDEZ');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 375 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,NULL,NULL,NULL,@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-05');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='NIVEL');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 40 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-05');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='TURBIDEZ');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 210 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO ocorrencia (titulo, descricao, aberta_em, id_usuario_abertura,
    tratamento_iniciado_em, id_usuario_tratamento, concluida_em, id_usuario_conclusao, justificativa_conclusao)
VALUES ('Verificação de TURBIDEZ em EST-05', 'Equipe acionada após desvio do parâmetro.',
    DATE_ADD(@aberto, INTERVAL 1 HOUR), @ator, DATE_ADD(@aberto, INTERVAL 2 HOUR), @ator,
    DATE_ADD(@aberto, INTERVAL 6 HOUR), @ator, 'Inspeção concluída e monitoramento restabelecido.');
SET @ocorrencia = LAST_INSERT_ID();
INSERT INTO ocorrencia_estacao (id_ocorrencia,id_estacao) VALUES (@ocorrencia,@estacao);
INSERT INTO acao_ocorrencia (id_ocorrencia,descricao,realizada_em,id_usuario_responsavel)
VALUES (@ocorrencia,'Vistoria e comparação com a medição de referência.',DATE_ADD(@aberto, INTERVAL 3 HOUR),@ator);
INSERT INTO manutencao (id_estacao,id_ocorrencia,tipo_intervencao,inicio_em,fim_em,descricao,resultado,id_usuario_responsavel)
VALUES (@estacao,@ocorrencia,'MANUTENCAO',DATE_ADD(@aberto, INTERVAL 3 HOUR),
    DATE_ADD(@aberto, INTERVAL 5 HOUR),'Revisão da estação e limpeza preventiva.','Estação liberada.',@ator);

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-05');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='OXIGENIO');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 380 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,NULL,NULL,NULL,NULL,NULL,@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-06');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='TURBIDEZ');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 45 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO ocorrencia (titulo, descricao, aberta_em, id_usuario_abertura,
    tratamento_iniciado_em, id_usuario_tratamento, concluida_em, id_usuario_conclusao, justificativa_conclusao)
VALUES ('Verificação de TURBIDEZ em EST-06', 'Equipe acionada após desvio do parâmetro.',
    DATE_ADD(@aberto, INTERVAL 1 HOUR), @ator, DATE_ADD(@aberto, INTERVAL 2 HOUR), @ator,
    DATE_ADD(@aberto, INTERVAL 6 HOUR), @ator, 'Inspeção concluída e monitoramento restabelecido.');
SET @ocorrencia = LAST_INSERT_ID();
INSERT INTO ocorrencia_estacao (id_ocorrencia,id_estacao) VALUES (@ocorrencia,@estacao);
INSERT INTO acao_ocorrencia (id_ocorrencia,descricao,realizada_em,id_usuario_responsavel)
VALUES (@ocorrencia,'Vistoria e comparação com a medição de referência.',DATE_ADD(@aberto, INTERVAL 3 HOUR),@ator);
INSERT INTO manutencao (id_estacao,id_ocorrencia,tipo_intervencao,inicio_em,fim_em,descricao,resultado,id_usuario_responsavel)
VALUES (@estacao,@ocorrencia,'MANUTENCAO',DATE_ADD(@aberto, INTERVAL 3 HOUR),
    DATE_ADD(@aberto, INTERVAL 5 HOUR),'Revisão da estação e limpeza preventiva.','Estação liberada.',@ator);

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-06');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='OXIGENIO');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 215 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-06');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='NIVEL');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 385 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-07');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='OXIGENIO');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 50 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-07');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='NIVEL');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 220 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-07');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='TURBIDEZ');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 390 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,NULL,NULL,NULL,@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-08');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='NIVEL');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 55 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-08');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='TURBIDEZ');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 225 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO ocorrencia (titulo, descricao, aberta_em, id_usuario_abertura,
    tratamento_iniciado_em, id_usuario_tratamento, concluida_em, id_usuario_conclusao, justificativa_conclusao)
VALUES ('Verificação de TURBIDEZ em EST-08', 'Equipe acionada após desvio do parâmetro.',
    DATE_ADD(@aberto, INTERVAL 1 HOUR), @ator, DATE_ADD(@aberto, INTERVAL 2 HOUR), @ator,
    DATE_ADD(@aberto, INTERVAL 6 HOUR), @ator, 'Inspeção concluída e monitoramento restabelecido.');
SET @ocorrencia = LAST_INSERT_ID();
INSERT INTO ocorrencia_estacao (id_ocorrencia,id_estacao) VALUES (@ocorrencia,@estacao);
INSERT INTO acao_ocorrencia (id_ocorrencia,descricao,realizada_em,id_usuario_responsavel)
VALUES (@ocorrencia,'Vistoria e comparação com a medição de referência.',DATE_ADD(@aberto, INTERVAL 3 HOUR),@ator);
INSERT INTO manutencao (id_estacao,id_ocorrencia,tipo_intervencao,inicio_em,fim_em,descricao,resultado,id_usuario_responsavel)
VALUES (@estacao,@ocorrencia,'MANUTENCAO',DATE_ADD(@aberto, INTERVAL 3 HOUR),
    DATE_ADD(@aberto, INTERVAL 5 HOUR),'Revisão da estação e limpeza preventiva.','Estação liberada.',@ator);

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-08');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='OXIGENIO');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 395 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,NULL,NULL,NULL,NULL,NULL,@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-09');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='TURBIDEZ');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 60 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO ocorrencia (titulo, descricao, aberta_em, id_usuario_abertura,
    tratamento_iniciado_em, id_usuario_tratamento, concluida_em, id_usuario_conclusao, justificativa_conclusao)
VALUES ('Verificação de TURBIDEZ em EST-09', 'Equipe acionada após desvio do parâmetro.',
    DATE_ADD(@aberto, INTERVAL 1 HOUR), @ator, DATE_ADD(@aberto, INTERVAL 2 HOUR), @ator,
    DATE_ADD(@aberto, INTERVAL 6 HOUR), @ator, 'Inspeção concluída e monitoramento restabelecido.');
SET @ocorrencia = LAST_INSERT_ID();
INSERT INTO ocorrencia_estacao (id_ocorrencia,id_estacao) VALUES (@ocorrencia,@estacao);
INSERT INTO acao_ocorrencia (id_ocorrencia,descricao,realizada_em,id_usuario_responsavel)
VALUES (@ocorrencia,'Vistoria e comparação com a medição de referência.',DATE_ADD(@aberto, INTERVAL 3 HOUR),@ator);
INSERT INTO manutencao (id_estacao,id_ocorrencia,tipo_intervencao,inicio_em,fim_em,descricao,resultado,id_usuario_responsavel)
VALUES (@estacao,@ocorrencia,'MANUTENCAO',DATE_ADD(@aberto, INTERVAL 3 HOUR),
    DATE_ADD(@aberto, INTERVAL 5 HOUR),'Revisão da estação e limpeza preventiva.','Estação liberada.',@ator);

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-09');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='OXIGENIO');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 230 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-09');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='NIVEL');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 400 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-10');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='OXIGENIO');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 65 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-10');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='NIVEL');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 235 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-10');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='TURBIDEZ');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 405 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,NULL,NULL,NULL,@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-11');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='NIVEL');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 70 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-11');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='TURBIDEZ');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 240 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO ocorrencia (titulo, descricao, aberta_em, id_usuario_abertura,
    tratamento_iniciado_em, id_usuario_tratamento, concluida_em, id_usuario_conclusao, justificativa_conclusao)
VALUES ('Verificação de TURBIDEZ em EST-11', 'Equipe acionada após desvio do parâmetro.',
    DATE_ADD(@aberto, INTERVAL 1 HOUR), @ator, DATE_ADD(@aberto, INTERVAL 2 HOUR), @ator,
    DATE_ADD(@aberto, INTERVAL 6 HOUR), @ator, 'Inspeção concluída e monitoramento restabelecido.');
SET @ocorrencia = LAST_INSERT_ID();
INSERT INTO ocorrencia_estacao (id_ocorrencia,id_estacao) VALUES (@ocorrencia,@estacao);
INSERT INTO acao_ocorrencia (id_ocorrencia,descricao,realizada_em,id_usuario_responsavel)
VALUES (@ocorrencia,'Vistoria e comparação com a medição de referência.',DATE_ADD(@aberto, INTERVAL 3 HOUR),@ator);
INSERT INTO manutencao (id_estacao,id_ocorrencia,tipo_intervencao,inicio_em,fim_em,descricao,resultado,id_usuario_responsavel)
VALUES (@estacao,@ocorrencia,'MANUTENCAO',DATE_ADD(@aberto, INTERVAL 3 HOUR),
    DATE_ADD(@aberto, INTERVAL 5 HOUR),'Revisão da estação e limpeza preventiva.','Estação liberada.',@ator);

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-11');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='OXIGENIO');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 410 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,NULL,NULL,NULL,NULL,NULL,@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-12');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='TURBIDEZ');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 75 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO ocorrencia (titulo, descricao, aberta_em, id_usuario_abertura,
    tratamento_iniciado_em, id_usuario_tratamento, concluida_em, id_usuario_conclusao, justificativa_conclusao)
VALUES ('Verificação de TURBIDEZ em EST-12', 'Equipe acionada após desvio do parâmetro.',
    DATE_ADD(@aberto, INTERVAL 1 HOUR), @ator, DATE_ADD(@aberto, INTERVAL 2 HOUR), @ator,
    DATE_ADD(@aberto, INTERVAL 6 HOUR), @ator, 'Inspeção concluída e monitoramento restabelecido.');
SET @ocorrencia = LAST_INSERT_ID();
INSERT INTO ocorrencia_estacao (id_ocorrencia,id_estacao) VALUES (@ocorrencia,@estacao);
INSERT INTO acao_ocorrencia (id_ocorrencia,descricao,realizada_em,id_usuario_responsavel)
VALUES (@ocorrencia,'Vistoria e comparação com a medição de referência.',DATE_ADD(@aberto, INTERVAL 3 HOUR),@ator);
INSERT INTO manutencao (id_estacao,id_ocorrencia,tipo_intervencao,inicio_em,fim_em,descricao,resultado,id_usuario_responsavel)
VALUES (@estacao,@ocorrencia,'MANUTENCAO',DATE_ADD(@aberto, INTERVAL 3 HOUR),
    DATE_ADD(@aberto, INTERVAL 5 HOUR),'Revisão da estação e limpeza preventiva.','Estação liberada.',@ator);

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-12');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='OXIGENIO');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 245 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-12');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo='NIVEL');
SET @aberto = DATE_ADD('2025-01-01 10:00:00', INTERVAL 415 DAY);
SET @versao = (
    SELECT v.id_versao FROM versao_regra_monitoramento v
    JOIN regra_monitoramento r ON r.id_regra=v.id_regra
    WHERE r.id_estacao=@estacao AND r.id_parametro=@parametro
      AND v.inicio_em<=@aberto AND (v.fim_em IS NULL OR @aberto<v.fim_em)
);
SET @ocorrencia = NULL;

INSERT INTO alerta (id_versao_abertura,aberto_em,id_usuario_abertura,
    reconhecido_em,id_usuario_reconhecimento,encerrado_em,id_usuario_encerramento,motivo_encerramento,id_ocorrencia)
VALUES (@versao,@aberto,@ator,DATE_ADD(@aberto, INTERVAL 1 HOUR),@ator,DATE_ADD(@aberto, INTERVAL 6 HOUR),@ator,'Desvio avaliado pela equipe.',@ocorrencia);

INSERT INTO resumo_diario_monitoramento
    (id_estacao,id_parametro,dia_utc,quantidade_validas,soma,minimo,maximo,consolidado_em)
WITH RECURSIVE dias AS (
    SELECT 0 AS n UNION ALL SELECT n+1 FROM dias WHERE n<519
), contexto AS (
    SELECT r.id_estacao,r.id_parametro,d.n,DATE_ADD('2025-01-01',INTERVAL d.n DAY) AS dia,
           p.codigo, c.codigo_tipo_corpo, v.limite_inferior,v.limite_superior,
           EXISTS (
               SELECT 1 FROM alerta a WHERE a.id_versao_abertura=v.id_versao
                 AND a.aberto_em>=DATE_ADD('2025-01-01',INTERVAL d.n DAY)
                 AND a.aberto_em<DATE_ADD('2025-01-02',INTERVAL d.n DAY)
           ) AS desvio
    FROM dias d CROSS JOIN regra_monitoramento r
    JOIN estacao_monitoramento e ON e.id_estacao=r.id_estacao
    JOIN corpo_hidrico c ON c.id_corpo_hidrico=e.id_corpo_hidrico
    JOIN parametro_monitoramento p ON p.id_parametro=r.id_parametro
    JOIN versao_regra_monitoramento v ON v.id_regra=r.id_regra AND v.numero_versao=1
    WHERE e.codigo BETWEEN 'EST-01' AND 'EST-20'
), faixa AS (
    SELECT contexto.*,
        CASE WHEN MOD(n+id_estacao,31)=0 THEN 18 ELSE 24 END AS qtd,
        CASE codigo WHEN 'TEMPERATURA' THEN 23+MOD(n,90)*0.04
          WHEN 'PH' THEN 7+MOD(n+id_estacao,10)*0.08
          WHEN 'OXIGENIO' THEN 6.6+MOD(n+id_estacao,18)*0.08
          WHEN 'TURBIDEZ' THEN 10+MOD(n+id_estacao,30)*0.45
          WHEN 'NIVEL' THEN IF(codigo_tipo_corpo='RIO',0.95,8.5)+MOD(n,40)*0.012 END AS centro,
        CASE WHEN codigo IN ('PH','NIVEL') THEN 0.08 ELSE 0.35 END AS amplitude
    FROM contexto
), extremos AS (
    SELECT faixa.*,
        IF(desvio AND codigo='OXIGENIO',limite_inferior-0.5,centro-amplitude) AS lo,
        IF(desvio AND codigo IN ('TURBIDEZ','NIVEL'),limite_superior+0.6,centro+amplitude) AS hi
    FROM faixa
)
SELECT id_estacao,id_parametro,dia,qtd,centro*(qtd-2)+lo+hi,lo,hi,UTC_TIMESTAMP(3)
FROM extremos;

COMMIT;

START TRANSACTION;
UPDATE bacia_hidrografica SET nome=CASE codigo
 WHEN 'BAC-01' THEN 'Bacia do Rio Cedro' WHEN 'BAC-02' THEN 'Bacia do Rio Capivari'
 WHEN 'BAC-03' THEN 'Bacia do Rio Jacutinga' WHEN 'BAC-04' THEN 'Bacia do Rio Monjolo' END
WHERE codigo IN ('BAC-01','BAC-02','BAC-03','BAC-04');
UPDATE estacao_monitoramento SET nome='Ponte do Cedro' WHERE codigo='EST-01';
UPDATE corpo_hidrico SET nome='Rio Cedro' WHERE codigo='CH-01';
UPDATE estacao_monitoramento SET nome='Passagem da Figueira' WHERE codigo='EST-02';
UPDATE corpo_hidrico SET nome='Rio Figueira' WHERE codigo='CH-02';
UPDATE estacao_monitoramento SET nome='Poço das Garças' WHERE codigo='EST-03';
UPDATE corpo_hidrico SET nome='Rio Garças' WHERE codigo='CH-03';
UPDATE estacao_monitoramento SET nome='Foz do Monjolo' WHERE codigo='EST-04';
UPDATE corpo_hidrico SET nome='Rio Monjolo' WHERE codigo='CH-04';
UPDATE estacao_monitoramento SET nome='Várzea do Ipê' WHERE codigo='EST-05';
UPDATE corpo_hidrico SET nome='Rio Ipê' WHERE codigo='CH-05';
UPDATE estacao_monitoramento SET nome='Porto da Canela' WHERE codigo='EST-06';
UPDATE corpo_hidrico SET nome='Rio Canela' WHERE codigo='CH-06';
UPDATE estacao_monitoramento SET nome='Ponte das Pedras' WHERE codigo='EST-07';
UPDATE corpo_hidrico SET nome='Rio Pedras' WHERE codigo='CH-07';
UPDATE estacao_monitoramento SET nome='Barra do Capivari' WHERE codigo='EST-08';
UPDATE corpo_hidrico SET nome='Rio Capivari' WHERE codigo='CH-08';
UPDATE estacao_monitoramento SET nome='Travessia do Jacutinga' WHERE codigo='EST-09';
UPDATE corpo_hidrico SET nome='Rio Jacutinga' WHERE codigo='CH-09';
UPDATE estacao_monitoramento SET nome='Baixada do Angico' WHERE codigo='EST-10';
UPDATE corpo_hidrico SET nome='Rio Angico' WHERE codigo='CH-10';
UPDATE estacao_monitoramento SET nome='Ponte do Barreiro' WHERE codigo='EST-11';
UPDATE corpo_hidrico SET nome='Rio Barreiro' WHERE codigo='CH-11';
UPDATE estacao_monitoramento SET nome='Foz da Limeira' WHERE codigo='EST-12';
UPDATE corpo_hidrico SET nome='Rio Limeira' WHERE codigo='CH-12';
UPDATE estacao_monitoramento SET nome='Barragem da Serra Azul' WHERE codigo='EST-13';
UPDATE corpo_hidrico SET nome='Reservatório Serra Azul' WHERE codigo='CH-13';
UPDATE estacao_monitoramento SET nome='Tomada do Pinhal' WHERE codigo='EST-14';
UPDATE corpo_hidrico SET nome='Reservatório Pinhal' WHERE codigo='CH-14';
UPDATE estacao_monitoramento SET nome='Dique do Horizonte' WHERE codigo='EST-15';
UPDATE corpo_hidrico SET nome='Reservatório Horizonte' WHERE codigo='CH-15';
UPDATE estacao_monitoramento SET nome='Margem da Esperança' WHERE codigo='EST-16';
UPDATE corpo_hidrico SET nome='Reservatório Esperança' WHERE codigo='CH-16';
UPDATE estacao_monitoramento SET nome='Barragem da Boa Vista' WHERE codigo='EST-17';
UPDATE corpo_hidrico SET nome='Reservatório Boa Vista' WHERE codigo='CH-17';
UPDATE estacao_monitoramento SET nome='Tomada da Pedra Branca' WHERE codigo='EST-18';
UPDATE corpo_hidrico SET nome='Reservatório Pedra Branca' WHERE codigo='CH-18';
UPDATE estacao_monitoramento SET nome='Dique do Retiro' WHERE codigo='EST-19';
UPDATE corpo_hidrico SET nome='Reservatório Retiro' WHERE codigo='CH-19';
UPDATE estacao_monitoramento SET nome='Margem do Vale Verde' WHERE codigo='EST-20';
UPDATE corpo_hidrico SET nome='Reservatório Vale Verde' WHERE codigo='CH-20';
SET @ator=(SELECT id_usuario FROM usuario WHERE email='monitoramento@simulacao.example');
SET @e1=(SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-01');
SET @e2=(SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-02');
SET @s1=(SELECT id_sensor FROM sensor WHERE codigo_patrimonial='EST-01-TURB');
SET @s2=(SELECT id_sensor FROM sensor WHERE codigo_patrimonial='EST-02-TURB');
SET @inicio='2026-07-01 08:00:00';
UPDATE instalacao_sensor SET fim_em=@inicio,id_usuario_retirada=@ator
WHERE (id_sensor=@s1 AND id_estacao=@e1 OR id_sensor=@s2 AND id_estacao=@e2) AND fim_em IS NULL;
INSERT INTO instalacao_sensor (id_sensor,id_estacao,inicio_em,id_usuario_instalacao,observacao)
VALUES (@s1,@e2,@inicio,@ator,'Remanejamento após inspeção.'),(@s2,@e1,@inicio,@ator,'Remanejamento após inspeção.');

SET @par=(SELECT id_parametro FROM parametro_monitoramento WHERE codigo='TURBIDEZ');
SET @regra=(SELECT id_regra FROM regra_monitoramento WHERE id_estacao=@e1 AND id_parametro=@par);
UPDATE versao_regra_monitoramento SET fim_em=@inicio WHERE id_regra=@regra AND numero_versao=1 AND fim_em IS NULL;
INSERT INTO versao_regra_monitoramento (id_regra,numero_versao,limite_superior,prioridade,inicio_em,id_usuario_configuracao)
VALUES (@regra,2,50,'ATENCAO',@inicio,@ator);

INSERT INTO manutencao (id_sensor,tipo_intervencao,inicio_em,fim_em,descricao,resultado,id_usuario_responsavel)
VALUES (@s2,'CALIBRACAO','2026-07-02 08:00:00','2026-07-02 09:30:00',
'Comparação com padrão de turbidez.','Ajuste de leitura registrado.',@ator);
SET @manut=LAST_INSERT_ID();
INSERT INTO calibracao_parametro (id_manutencao,id_parametro,valor_referencia,valor_observado,conclusao,ajuste_realizado)
VALUES (@manut,@par,20,20.2,'Sensor comparado com padrão de 20 NTU.','Correção de desvio de 0,2 NTU.');
COMMIT;

