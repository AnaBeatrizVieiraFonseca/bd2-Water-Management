USE recursos_hidricos;

START TRANSACTION;

SET @responsavel = (
    SELECT id_usuario FROM usuario
    WHERE email = 'monitoramento@simulacao.example' AND ativo = 1
);
SET @alerta = (
    SELECT id_alerta FROM alerta
    WHERE reconhecido_em IS NULL AND encerrado_em IS NULL
      AND aberto_em <= UTC_TIMESTAMP(3)
    ORDER BY aberto_em, id_alerta LIMIT 1
);

-- 1. Mostrar o alerta antes e depois do reconhecimento.
SELECT id_alerta, situacao, aberto_em, reconhecido_em, encerrado_em
FROM vw_alertas_contexto WHERE id_alerta = @alerta;

CALL sp_reconhecer_alerta(@alerta, @responsavel);

-- 2. Encerrar o mesmo alerta com justificativa e conferir o resultado.
CALL sp_encerrar_alerta(@alerta, @responsavel, 'Atendimento concluído.');

SELECT id_alerta, reconhecido_em, encerrado_em, motivo_encerramento
FROM alerta WHERE id_alerta = @alerta;

-- 3. Recuperar indicadores de uma estação informando as datas como parâmetros.
CALL sp_indicadores_periodo('EST-01', '2025-01-01', '2025-02-01');

-- Após instalar as triggers, conferir a auditoria dos dois UPDATEs realizados pelas procedures.
SELECT e.id_evento, e.operacao, e.ocorrido_em,
       d.nome_atributo, d.valor_anterior, d.valor_posterior
FROM evento_auditoria e
INNER JOIN detalhe_auditoria d ON d.id_evento = e.id_evento
WHERE e.alvo_relacao = 'alerta' AND e.chave_alvo_1 = CAST(@alerta AS CHAR)
ORDER BY e.id_evento, d.nome_atributo;

ROLLBACK;

-- Confirmar que a demonstração não manteve as alterações do atendimento.
SELECT id_alerta, situacao, reconhecido_em, encerrado_em
FROM vw_alertas_contexto WHERE id_alerta = @alerta;
