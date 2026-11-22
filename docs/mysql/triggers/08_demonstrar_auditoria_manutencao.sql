-- Executar após 08_triggers.sql, em uma conexão sem alterações pendentes.
USE recursos_hidricos;

START TRANSACTION;

SET @responsavel = (SELECT id_usuario FROM usuario WHERE email = 'monitoramento@simulacao.example');
SET @estacao = (SELECT id_estacao FROM estacao_monitoramento WHERE codigo = 'EST-03');

-- Registrar uma inspeção para demonstrar a trigger AFTER INSERT.
INSERT INTO manutencao
    (id_estacao, tipo_intervencao, inicio_em, fim_em, descricao, resultado, id_usuario_responsavel)
VALUES
    (@estacao, 'INSPECAO', UTC_TIMESTAMP(3) - INTERVAL 30 MINUTE, UTC_TIMESTAMP(3),
     'Inspeção de demonstração do cadastro de intervenções.',
     'Registro utilizado para conferir a auditoria automática.', @responsavel);
SET @manutencao = LAST_INSERT_ID();

-- A auditoria é criada pela trigger, sem INSERT manual nestas tabelas.
SELECT e.id_evento, e.operacao, e.alvo_relacao, e.chave_alvo_1, e.ocorrido_em,
       d.nome_atributo, d.anterior_presente, d.posterior_presente,
       d.valor_anterior, d.valor_posterior
FROM evento_auditoria e
INNER JOIN detalhe_auditoria d ON d.id_evento = e.id_evento
WHERE e.alvo_relacao = 'manutencao' AND e.chave_alvo_1 = CAST(@manutencao AS CHAR)
ORDER BY e.id_evento, d.nome_atributo;

ROLLBACK;

-- A inspeção e sua auditoria foram desfeitas juntas.
SELECT COUNT(*) AS inspecoes_demonstrativas_restantes
FROM manutencao WHERE id_manutencao = @manutencao;

SELECT COUNT(*) AS eventos_demonstrativos_restantes
FROM evento_auditoria
WHERE alvo_relacao = 'manutencao' AND chave_alvo_1 = CAST(@manutencao AS CHAR);

