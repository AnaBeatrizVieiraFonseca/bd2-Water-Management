USE recursos_hidricos;

DROP PROCEDURE IF EXISTS sp_reconhecer_alerta;
DROP PROCEDURE IF EXISTS sp_encerrar_alerta;
DROP PROCEDURE IF EXISTS sp_indicadores_periodo;

DELIMITER $$

-- 1. Registrar o reconhecimento de um alerta aberto por um responsável ativo.
CREATE PROCEDURE sp_reconhecer_alerta (
    IN p_alerta BIGINT UNSIGNED,
    IN p_usuario INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM usuario WHERE id_usuario = p_usuario AND ativo = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Informe um responsável ativo.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM alerta
        WHERE id_alerta = p_alerta
          AND reconhecido_em IS NULL AND encerrado_em IS NULL
          AND aberto_em <= UTC_TIMESTAMP(3)
    ) THEN
        UPDATE alerta
        SET reconhecido_em = UTC_TIMESTAMP(3), id_usuario_reconhecimento = p_usuario
        WHERE id_alerta = p_alerta
          AND reconhecido_em IS NULL AND encerrado_em IS NULL
          AND aberto_em <= UTC_TIMESTAMP(3);

        SELECT id_alerta, situacao, reconhecido_em
        FROM vw_alertas_contexto WHERE id_alerta = p_alerta;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Alerta inexistente, já atendido ou com abertura futura.';
    END IF;
END$$

-- 2. Encerrar um alerta reconhecido, registrando responsável e motivo.
CREATE PROCEDURE sp_encerrar_alerta (
    IN p_alerta BIGINT UNSIGNED,
    IN p_usuario INT UNSIGNED,
    IN p_motivo VARCHAR(500)
)
BEGIN
    IF p_motivo IS NULL OR CHAR_LENGTH(TRIM(p_motivo)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Informe o motivo do encerramento.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM usuario WHERE id_usuario = p_usuario AND ativo = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Informe um responsável ativo.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM alerta
        WHERE id_alerta = p_alerta AND reconhecido_em IS NOT NULL
          AND encerrado_em IS NULL AND reconhecido_em <= UTC_TIMESTAMP(3)
    ) THEN
        UPDATE alerta
        SET encerrado_em = UTC_TIMESTAMP(3), id_usuario_encerramento = p_usuario,
            motivo_encerramento = TRIM(p_motivo)
        WHERE id_alerta = p_alerta AND reconhecido_em IS NOT NULL
          AND encerrado_em IS NULL AND reconhecido_em <= UTC_TIMESTAMP(3);

        SELECT id_alerta, situacao, encerrado_em
        FROM vw_alertas_contexto WHERE id_alerta = p_alerta;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O alerta precisa estar reconhecido e ainda não encerrado.';
    END IF;
END$$

-- 3. Consultar indicadores de uma estação no período, com data final exclusiva.
CREATE PROCEDURE sp_indicadores_periodo (
    IN p_estacao VARCHAR(20),
    IN p_inicio DATE,
    IN p_fim DATE
)
BEGIN
    IF p_inicio IS NULL OR p_fim IS NULL OR p_inicio >= p_fim THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Informe um período com início anterior ao fim.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM estacao_monitoramento WHERE codigo = p_estacao) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estação não encontrada.';
    END IF;

    SELECT p.codigo AS parametro, p.nome, u.simbolo AS unidade,
           SUM(d.quantidade_validas) AS quantidade_validas,
           SUM(d.soma) AS soma,
           ROUND(SUM(d.soma) / NULLIF(SUM(d.quantidade_validas), 0), 6) AS media,
           MIN(d.minimo) AS minimo, MAX(d.maximo) AS maximo
    FROM vw_indicadores_diarios d
    INNER JOIN estacao_monitoramento e ON e.id_estacao = d.id_estacao
    INNER JOIN parametro_monitoramento p ON p.id_parametro = d.id_parametro
    INNER JOIN unidade_medida u ON u.id_unidade = p.id_unidade
    WHERE e.codigo = p_estacao AND d.dia_utc >= p_inicio AND d.dia_utc < p_fim
    GROUP BY p.id_parametro, p.codigo, p.nome, u.simbolo
    ORDER BY p.nome;
END$$

DELIMITER ;
