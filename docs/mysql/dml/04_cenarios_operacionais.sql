SET NAMES utf8mb4;
SET time_zone = '+00:00';
USE recursos_hidricos;

START TRANSACTION;

SET @responsavel = (SELECT id_usuario FROM usuario WHERE email = 'monitoramento@simulacao.example');
SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo = 'EST-03');
SET @sensor = (SELECT id_sensor FROM sensor WHERE codigo_patrimonial = 'EST-04-PH');
SET @corpo = (SELECT id_corpo_hidrico FROM corpo_hidrico WHERE codigo = 'CH-05');
SET @parametro = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo = 'PH');

INSERT INTO ocorrencia
    (titulo, descricao, aberta_em, id_usuario_abertura,
     tratamento_iniciado_em, id_usuario_tratamento)
VALUES
    ('Acesso obstruído à estação Poço das Garças',
     'Vegetação sobre a passagem de acesso identificada em vistoria de rotina.',
     '2025-02-10 08:00:00', @responsavel,
     '2025-02-10 09:00:00', @responsavel);
SET @ocorrencia_acesso = LAST_INSERT_ID();

INSERT INTO ocorrencia_estacao (id_ocorrencia, id_estacao)
VALUES (@ocorrencia_acesso, @estacao);

INSERT INTO acao_ocorrencia (id_ocorrencia, descricao, realizada_em, id_usuario_responsavel)
VALUES
    (@ocorrencia_acesso, 'Vistoria do acesso e delimitação do trecho que exige limpeza.',
     '2025-02-10 09:30:00', @responsavel),
    (@ocorrencia_acesso, 'Conferência da passagem após a retirada da vegetação.',
     '2025-02-11 11:00:00', @responsavel);

INSERT INTO manutencao
    (id_estacao, id_ocorrencia, tipo_intervencao, inicio_em, fim_em,
     descricao, resultado, id_usuario_responsavel)
VALUES
    (@estacao, @ocorrencia_acesso, 'INSPECAO',
     '2025-02-10 09:00:00', '2025-02-10 10:00:00',
     'Inspeção da passagem e do abrigo da estação.',
     'Equipamentos preservados; identificada necessidade de limpeza do acesso.', @responsavel),
    (@estacao, @ocorrencia_acesso, 'MANUTENCAO',
     '2025-02-11 08:00:00', '2025-02-11 10:30:00',
     'Retirada da vegetação na passagem de acesso.',
     'Acesso liberado e abrigo mantido sem alterações.', @responsavel);

UPDATE ocorrencia
SET concluida_em = '2025-02-11 11:30:00',
    id_usuario_conclusao = @responsavel,
    justificativa_conclusao = 'Passagem liberada e conferida na vistoria de encerramento.'
WHERE id_ocorrencia = @ocorrencia_acesso;

INSERT INTO ocorrencia
    (titulo, descricao, aberta_em, id_usuario_abertura,
     tratamento_iniciado_em, id_usuario_tratamento)
VALUES
    ('Acompanhamento da calibração do sensor de pH do Monjolo',
     'Verificação preventiva do eletrodo de pH durante a rotina de manutenção.',
     '2025-03-12 08:00:00', @responsavel,
     '2025-03-12 09:00:00', @responsavel);
SET @ocorrencia_sensor = LAST_INSERT_ID();

INSERT INTO ocorrencia_sensor (id_ocorrencia, id_sensor)
VALUES (@ocorrencia_sensor, @sensor);

INSERT INTO manutencao
    (id_sensor, id_ocorrencia, tipo_intervencao, inicio_em, fim_em,
     descricao, resultado, id_usuario_responsavel)
VALUES
    (@sensor, @ocorrencia_sensor, 'CALIBRACAO',
     '2025-03-12 09:00:00', '2025-03-12 10:00:00',
     'Comparação do eletrodo com solução de referência de pH 7.',
     'Registrado desvio e realizado ajuste; programada uma nova verificação.', @responsavel);
SET @calibracao_inicial = LAST_INSERT_ID();

INSERT INTO calibracao_parametro
    (id_manutencao, id_parametro, valor_referencia, valor_observado, conclusao, ajuste_realizado)
VALUES
    (@calibracao_inicial, @parametro, 7.000000, 7.080000,
     'Comparação inicial apresentou desvio de 0,08 em relação à referência.',
     'Limpeza do eletrodo e ajuste conforme a solução de referência.');

INSERT INTO manutencao
    (id_sensor, id_ocorrencia, tipo_intervencao, inicio_em, fim_em,
     descricao, resultado, id_usuario_responsavel)
VALUES
    (@sensor, @ocorrencia_sensor, 'CALIBRACAO',
     '2025-03-14 09:00:00', '2025-03-14 09:40:00',
     'Nova comparação após o ajuste do eletrodo.',
     'Observado valor igual ao de referência; acompanhamento permanece em tratamento.', @responsavel);
SET @calibracao_retorno = LAST_INSERT_ID();

INSERT INTO calibracao_parametro
    (id_manutencao, id_parametro, valor_referencia, valor_observado, conclusao, ajuste_realizado)
VALUES
    (@calibracao_retorno, @parametro, 7.000000, 7.000000,
     'Não foi observado desvio nessa comparação.', NULL);

INSERT INTO acao_ocorrencia (id_ocorrencia, descricao, realizada_em, id_usuario_responsavel)
VALUES
    (@ocorrencia_sensor, 'Registrado o resultado inicial e programada a comparação de retorno.',
     '2025-03-12 10:15:00', @responsavel),
    (@ocorrencia_sensor, 'Conferida a comparação de retorno; aguardada decisão sobre encerramento.',
     '2025-03-14 10:00:00', @responsavel);

INSERT INTO ocorrencia
    (titulo, descricao, aberta_em, id_usuario_abertura,
     tratamento_iniciado_em, id_usuario_tratamento)
VALUES
    ('Resíduos sólidos na margem do Rio Ipê',
     'Resíduos visíveis na margem registrados por vistoria de campo, sem atribuição de alteração aos parâmetros da água.',
     '2025-04-07 08:00:00', @responsavel,
     '2025-04-07 10:00:00', @responsavel);
SET @ocorrencia_corpo = LAST_INSERT_ID();

INSERT INTO ocorrencia_corpo_hidrico (id_ocorrencia, id_corpo_hidrico)
VALUES (@ocorrencia_corpo, @corpo);

INSERT INTO acao_ocorrencia (id_ocorrencia, descricao, realizada_em, id_usuario_responsavel)
VALUES
    (@ocorrencia_corpo, 'Delimitado o trecho da margem e solicitada a coleta dos resíduos.',
     '2025-04-07 10:30:00', @responsavel),
    (@ocorrencia_corpo, 'Vistoria de retorno confirmou a retirada dos resíduos visíveis.',
     '2025-04-09 15:00:00', @responsavel);

UPDATE ocorrencia
SET concluida_em = '2025-04-09 16:00:00',
    id_usuario_conclusao = @responsavel,
    justificativa_conclusao = 'Retirada dos resíduos confirmada na vistoria de retorno.'
WHERE id_ocorrencia = @ocorrencia_corpo;

COMMIT;
