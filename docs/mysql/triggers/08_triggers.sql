USE recursos_hidricos;

DROP TRIGGER IF EXISTS trg_alerta_auditoria_reconhecimento;
DROP TRIGGER IF EXISTS trg_alerta_auditoria_encerramento;
DROP TRIGGER IF EXISTS trg_manutencao_auditoria_insercao;

DELIMITER $$

-- 1. Auditar o reconhecimento de um alerta após sua atualização.
CREATE TRIGGER trg_alerta_auditoria_reconhecimento
AFTER UPDATE ON alerta
FOR EACH ROW
BEGIN
    DECLARE v_evento BIGINT UNSIGNED;

    IF OLD.reconhecido_em IS NULL AND NEW.reconhecido_em IS NOT NULL THEN
        INSERT INTO evento_auditoria
            (id_usuario, ocorrido_em, operacao, alvo_relacao, chave_alvo_1, descricao)
        VALUES
            (NEW.id_usuario_reconhecimento, UTC_TIMESTAMP(3), 'RECONHECER',
             'alerta', NEW.id_alerta, 'Reconhecimento do alerta.');
        SET v_evento = LAST_INSERT_ID();

        INSERT INTO detalhe_auditoria
            (id_evento, nome_atributo, anterior_presente, posterior_presente,
             valor_anterior, valor_posterior)
        VALUES
            (v_evento, 'reconhecido_em', 1, 1, OLD.reconhecido_em, NEW.reconhecido_em);
    END IF;
END$$

-- 2. Auditar o encerramento do alerta, preservando horário e motivo registrados.
CREATE TRIGGER trg_alerta_auditoria_encerramento
AFTER UPDATE ON alerta
FOR EACH ROW
BEGIN
    DECLARE v_evento BIGINT UNSIGNED;

    IF OLD.encerrado_em IS NULL AND NEW.encerrado_em IS NOT NULL THEN
        INSERT INTO evento_auditoria
            (id_usuario, ocorrido_em, operacao, alvo_relacao, chave_alvo_1, descricao)
        VALUES
            (NEW.id_usuario_encerramento, UTC_TIMESTAMP(3), 'ENCERRAR',
             'alerta', NEW.id_alerta, 'Encerramento do alerta com justificativa.');
        SET v_evento = LAST_INSERT_ID();

        INSERT INTO detalhe_auditoria
            (id_evento, nome_atributo, anterior_presente, posterior_presente,
             valor_anterior, valor_posterior)
        VALUES
            (v_evento, 'encerrado_em', 1, 1, OLD.encerrado_em, NEW.encerrado_em),
            (v_evento, 'motivo_encerramento', 1, 1,
             OLD.motivo_encerramento, NEW.motivo_encerramento);
    END IF;
END$$

-- 3. Auditar o cadastro de uma manutenção, inspeção ou calibração.
CREATE TRIGGER trg_manutencao_auditoria_insercao
AFTER INSERT ON manutencao
FOR EACH ROW
BEGIN
    DECLARE v_evento BIGINT UNSIGNED;

    INSERT INTO evento_auditoria
        (id_usuario, ocorrido_em, operacao, alvo_relacao, chave_alvo_1, descricao)
    VALUES
        (NEW.id_usuario_responsavel, UTC_TIMESTAMP(3), 'REGISTRAR',
         'manutencao', NEW.id_manutencao, 'Intervenção cadastrada.');
    SET v_evento = LAST_INSERT_ID();

    INSERT INTO detalhe_auditoria
        (id_evento, nome_atributo, anterior_presente, posterior_presente,
         valor_anterior, valor_posterior)
    VALUES
        (v_evento, 'tipo_intervencao', 0, 1, NULL, NEW.tipo_intervencao);
END$$

DELIMITER ;
