-- Executar como root. Contas existentes mantem a senha; guardar senhas novas fora do GitHub.
CREATE USER IF NOT EXISTS 'rh_integracao_projeto'@'localhost' IDENTIFIED BY RANDOM PASSWORD;

-- 1. Consultar os cadastros e historicos usados para validar cada leitura.
GRANT SELECT ON recursos_hidricos.estacao_monitoramento TO 'rh_integracao_projeto'@'localhost';
GRANT SELECT ON recursos_hidricos.corpo_hidrico TO 'rh_integracao_projeto'@'localhost';
GRANT SELECT ON recursos_hidricos.sensor TO 'rh_integracao_projeto'@'localhost';
GRANT SELECT ON recursos_hidricos.instalacao_sensor TO 'rh_integracao_projeto'@'localhost';
GRANT SELECT ON recursos_hidricos.tipo_sensor_parametro TO 'rh_integracao_projeto'@'localhost';
GRANT SELECT ON recursos_hidricos.parametro_monitoramento TO 'rh_integracao_projeto'@'localhost';
GRANT SELECT ON recursos_hidricos.unidade_medida TO 'rh_integracao_projeto'@'localhost';
GRANT SELECT ON recursos_hidricos.regra_monitoramento TO 'rh_integracao_projeto'@'localhost';
GRANT SELECT ON recursos_hidricos.versao_regra_monitoramento TO 'rh_integracao_projeto'@'localhost';

-- 2. Identificar o responsavel de servico sem acesso a senha_hash.
GRANT SELECT (id_usuario, email, ativo, tipo_identidade)
ON recursos_hidricos.usuario TO 'rh_integracao_projeto'@'localhost';

-- 3. Registrar novos alertas e evidencias, preservando o atendimento feito pela equipe.
GRANT SELECT, INSERT ON recursos_hidricos.alerta TO 'rh_integracao_projeto'@'localhost';
GRANT SELECT, INSERT ON recursos_hidricos.evidencia_alerta TO 'rh_integracao_projeto'@'localhost';

-- 4. Inserir ou recalcular os resumos sem criar outra linha para o mesmo dia e contexto.
GRANT SELECT, INSERT, UPDATE ON recursos_hidricos.resumo_diario_monitoramento
TO 'rh_integracao_projeto'@'localhost';

SHOW GRANTS FOR 'rh_integracao_projeto'@'localhost';
