-- Executar como root ou conta com autorização para criar usuários, papéis e conceder privilégios.
-- Executar uma única vez. Guardar as senhas retornadas em local privado, fora do GitHub.
USE recursos_hidricos;

-- 1. Criar os três perfis de acesso no MySQL.
CREATE ROLE 'rh_admin', 'rh_operador', 'rh_analista';

-- 2. Criar uma conta local para demonstrar cada perfil.
CREATE USER 'rh_admin_projeto'@'localhost' IDENTIFIED BY RANDOM PASSWORD;
CREATE USER 'rh_operador_projeto'@'localhost' IDENTIFIED BY RANDOM PASSWORD;
CREATE USER 'rh_analista_projeto'@'localhost' IDENTIFIED BY RANDOM PASSWORD;

-- 3. Administrador: gerenciar os objetos e dados somente da base do projeto.
GRANT ALL PRIVILEGES ON recursos_hidricos.* TO 'rh_admin';

-- 4. Operador: consultar o contexto e executar o atendimento sem UPDATE direto em alerta.
GRANT SELECT ON recursos_hidricos.vw_estacoes_contexto TO 'rh_operador';
GRANT SELECT ON recursos_hidricos.vw_alertas_contexto TO 'rh_operador';
GRANT EXECUTE ON PROCEDURE recursos_hidricos.sp_reconhecer_alerta TO 'rh_operador';
GRANT EXECUTE ON PROCEDURE recursos_hidricos.sp_encerrar_alerta TO 'rh_operador';

-- 5. Analista: consultar as views e executar o relatório sem alterar as tabelas.
GRANT SELECT ON recursos_hidricos.vw_estacoes_contexto TO 'rh_analista';
GRANT SELECT ON recursos_hidricos.vw_alertas_contexto TO 'rh_analista';
GRANT SELECT ON recursos_hidricos.vw_indicadores_diarios TO 'rh_analista';
GRANT SELECT ON recursos_hidricos.vw_historico_regras TO 'rh_analista';
GRANT SELECT ON recursos_hidricos.vw_calibracoes TO 'rh_analista';
GRANT EXECUTE ON PROCEDURE recursos_hidricos.sp_indicadores_periodo TO 'rh_analista';

-- 6. Demonstrar uma concessão temporária de consulta à auditoria e sua retirada.
GRANT SELECT ON recursos_hidricos.evento_auditoria TO 'rh_analista';
SHOW GRANTS FOR 'rh_analista';

REVOKE SELECT ON recursos_hidricos.evento_auditoria FROM 'rh_analista';
SHOW GRANTS FOR 'rh_analista';

-- 7. Associar os papéis às contas e ativá-los por padrão no próximo login.
GRANT 'rh_admin' TO 'rh_admin_projeto'@'localhost';
GRANT 'rh_operador' TO 'rh_operador_projeto'@'localhost';
GRANT 'rh_analista' TO 'rh_analista_projeto'@'localhost';

SET DEFAULT ROLE 'rh_admin' TO 'rh_admin_projeto'@'localhost';
SET DEFAULT ROLE 'rh_operador' TO 'rh_operador_projeto'@'localhost';
SET DEFAULT ROLE 'rh_analista' TO 'rh_analista_projeto'@'localhost';

-- 8. Conferir os privilégios atribuídos a cada papel.
SHOW GRANTS FOR 'rh_admin';
SHOW GRANTS FOR 'rh_operador';
SHOW GRANTS FOR 'rh_analista';
