-- 1. ADMINISTRADOR: conectar como rh_admin_projeto.
USE recursos_hidricos;
SELECT CURRENT_USER() AS conta, CURRENT_ROLE() AS perfil_ativo;
SHOW GRANTS;

-- PERMITIDO: consultar a auditoria e realizar uma instrução de escrita sem alterar linhas.
SELECT COUNT(*) AS eventos_auditoria FROM evento_auditoria;
UPDATE orgao_responsavel SET descricao = descricao WHERE id_orgao = 0;

-- 2. OPERADOR: conectar como rh_operador_projeto.
USE recursos_hidricos;
SELECT CURRENT_USER() AS conta, CURRENT_ROLE() AS perfil_ativo;
SHOW GRANTS;

-- PERMITIDO: localizar estações e consultar os alertas destinados ao atendimento.
SELECT estacao_codigo, estacao, bacia FROM vw_estacoes_contexto ORDER BY estacao_codigo;
SELECT id_alerta, parametro, situacao FROM vw_alertas_contexto ORDER BY aberto_em LIMIT 10;

-- NEGADO: consultar a tabela de identidades, que contém informações de acesso.
SELECT id_usuario, email FROM usuario LIMIT 1;

-- NEGADO: editar alertas diretamente, mesmo que a instrução não afete linhas.
UPDATE alerta SET motivo_encerramento = motivo_encerramento WHERE id_alerta = 0;

-- 3. ANALISTA: conectar como rh_analista_projeto.
USE recursos_hidricos;
SELECT CURRENT_USER() AS conta, CURRENT_ROLE() AS perfil_ativo;
SHOW GRANTS;

-- PERMITIDO: consultar calibrações e chamar o relatório por estação e período.
SELECT codigo_patrimonial, parametro, desvio_absoluto FROM vw_calibracoes ORDER BY inicio_em;
CALL sp_indicadores_periodo('EST-01', '2025-01-01', '2025-02-01');

-- NEGADO: a concessão de consulta à auditoria já foi retirada pelo REVOKE.
SELECT id_evento, operacao FROM evento_auditoria LIMIT 1;

-- NEGADO: o analista não pode executar uma operação de atendimento.
CALL sp_reconhecer_alerta(0, 0);
