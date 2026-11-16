USE recursos_hidricos;

DELIMITER $$
CREATE PROCEDURE sp_reconhecer_alerta(IN p_alerta BIGINT UNSIGNED, IN p_usuario INT UNSIGNED)
SQL SECURITY DEFINER
BEGIN
    UPDATE alerta a SET reconhecido_em=GREATEST(UTC_TIMESTAMP(3),aberto_em), id_usuario_reconhecimento=p_usuario
    WHERE id_alerta=p_alerta AND reconhecido_em IS NULL AND encerrado_em IS NULL
      AND EXISTS (SELECT 1 FROM usuario u WHERE u.id_usuario=p_usuario AND u.ativo=1);
    IF ROW_COUNT()<>1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Alerta não está aberto ou usuário não está ativo.';
    END IF;
END$$

CREATE PROCEDURE sp_encerrar_alerta(IN p_alerta BIGINT UNSIGNED, IN p_usuario INT UNSIGNED, IN p_motivo VARCHAR(500))
SQL SECURITY DEFINER
BEGIN
    IF p_motivo IS NULL OR CHAR_LENGTH(TRIM(p_motivo))=0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Informe o motivo do encerramento.';
    END IF;
    UPDATE alerta SET encerrado_em=GREATEST(UTC_TIMESTAMP(3),reconhecido_em),
        id_usuario_encerramento=p_usuario, motivo_encerramento=TRIM(p_motivo)
    WHERE id_alerta=p_alerta AND reconhecido_em IS NOT NULL AND encerrado_em IS NULL
      AND EXISTS (SELECT 1 FROM usuario u WHERE u.id_usuario=p_usuario AND u.ativo=1);
    IF ROW_COUNT()<>1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Alerta precisa estar reconhecido e usuário ativo.';
    END IF;
END$$

CREATE PROCEDURE sp_indicadores_periodo(IN p_estacao VARCHAR(20), IN p_inicio DATE, IN p_fim DATE)
SQL SECURITY INVOKER
BEGIN
    IF p_inicio IS NULL OR p_fim IS NULL OR p_inicio>p_fim THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Período inválido.';
    END IF;
    SELECT parametro,SUM(quantidade_validas) AS leituras,SUM(soma)/NULLIF(SUM(quantidade_validas),0) AS media,
           MIN(minimo) AS menor,MAX(maximo) AS maior
    FROM vw_indicadores_diarios WHERE estacao=p_estacao AND dia_utc BETWEEN p_inicio AND p_fim
    GROUP BY parametro ORDER BY parametro;
END$$
DELIMITER ;

-- O operador reconhece e encerra um alerta pendente, registrando o motivo.
START TRANSACTION;

SET @alerta_demo = (
    SELECT MIN(id_alerta)
    FROM alerta
    WHERE reconhecido_em IS NULL AND encerrado_em IS NULL
);
SET @usuario_demo = (
    SELECT id_usuario FROM usuario
    WHERE email = 'monitoramento@simulacao.example' AND ativo = 1
);

SELECT 'Antes' AS etapa, id_alerta, estado, reconhecido_em, encerrado_em
FROM vw_alertas_contexto WHERE id_alerta = @alerta_demo;

CALL sp_reconhecer_alerta(@alerta_demo, @usuario_demo);
SELECT 'Após reconhecer' AS etapa, id_alerta, estado, reconhecido_em, encerrado_em
FROM vw_alertas_contexto WHERE id_alerta = @alerta_demo;

CALL sp_encerrar_alerta(@alerta_demo, @usuario_demo, 'Equipe conferiu o desvio de medição.');
SELECT 'Após encerrar' AS etapa, v.id_alerta, v.estado, v.encerrado_em, a.motivo_encerramento
FROM vw_alertas_contexto v INNER JOIN alerta a USING (id_alerta)
WHERE v.id_alerta = @alerta_demo;

ROLLBACK;

SELECT 'Após desfazer a demonstração' AS etapa, id_alerta, estado
FROM vw_alertas_contexto WHERE id_alerta = @alerta_demo;

-- O analista informa a estação e o intervalo; a rotina consolida os resumos.
CALL sp_indicadores_periodo('EST-01', '2025-01-01', '2025-01-07');
