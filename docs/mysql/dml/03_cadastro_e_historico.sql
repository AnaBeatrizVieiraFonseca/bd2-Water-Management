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


SET @ator=(SELECT id_usuario FROM usuario WHERE email='monitoramento@simulacao.example');
SET @e1=(SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-01');
SET @e2=(SELECT id_estacao FROM estacao_monitoramento WHERE codigo='EST-02');
SET @s1=(SELECT id_sensor FROM sensor WHERE codigo_patrimonial='EST-01-TURB');
SET @s2=(SELECT id_sensor FROM sensor WHERE codigo_patrimonial='EST-02-TURB');
SET @inicio='2025-07-01 08:00:00';
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
VALUES (@s2,'CALIBRACAO','2025-07-02 08:00:00','2025-07-02 09:30:00',
'Comparação com padrão de turbidez.','Ajuste de leitura registrado.',@ator);
SET @manut=LAST_INSERT_ID();
INSERT INTO calibracao_parametro (id_manutencao,id_parametro,valor_referencia,valor_observado,conclusao,ajuste_realizado)
VALUES (@manut,@par,20,20.2,'Sensor comparado com padrão de 20 NTU.','Correção de desvio de 0,2 NTU.');
COMMIT;
	
