USE recursos_hidricos;

DELIMITER $$
CREATE TRIGGER trg_alerta_marcos_antes_update BEFORE UPDATE ON alerta FOR EACH ROW
BEGIN
    IF NOT (NEW.aberto_em <=> OLD.aberto_em) OR NEW.id_usuario_abertura<>OLD.id_usuario_abertura
       OR NEW.id_versao_abertura<>OLD.id_versao_abertura
       OR (OLD.reconhecido_em IS NOT NULL AND (NOT (NEW.reconhecido_em <=> OLD.reconhecido_em)
           OR NOT (NEW.id_usuario_reconhecimento <=> OLD.id_usuario_reconhecimento)))
       OR (OLD.encerrado_em IS NOT NULL AND (NOT (NEW.encerrado_em <=> OLD.encerrado_em)
           OR NOT (NEW.id_usuario_encerramento <=> OLD.id_usuario_encerramento)
           OR NOT (NEW.motivo_encerramento <=> OLD.motivo_encerramento))) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Marcos já registrados do alerta não podem ser alterados.';
    END IF;
END$$

CREATE TRIGGER trg_alerta_auditoria_depois_update AFTER UPDATE ON alerta FOR EACH ROW
BEGIN
    DECLARE evento BIGINT UNSIGNED;
    IF OLD.encerrado_em IS NULL AND NEW.encerrado_em IS NOT NULL THEN
        INSERT INTO evento_auditoria(id_usuario,ocorrido_em,operacao,alvo_relacao,chave_alvo_1,descricao)
        VALUES (NEW.id_usuario_encerramento,NEW.encerrado_em,'ENCERRAR','alerta',NEW.id_alerta,'Encerramento do episódio');
        SET evento=LAST_INSERT_ID();
        INSERT INTO detalhe_auditoria(id_evento,nome_atributo,anterior_presente,posterior_presente,valor_anterior,valor_posterior)
        VALUES (evento,'encerrado_em',1,1,OLD.encerrado_em,NEW.encerrado_em),
               (evento,'motivo_encerramento',1,1,OLD.motivo_encerramento,NEW.motivo_encerramento);
    END IF;
END$$

CREATE TRIGGER trg_calibracao_compat_antes_insert BEFORE INSERT ON calibracao_parametro FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM manutencao m JOIN sensor s ON s.id_sensor=m.id_sensor
        JOIN tipo_sensor_parametro tp ON tp.id_tipo_sensor=s.id_tipo_sensor
        WHERE m.id_manutencao=NEW.id_manutencao AND m.tipo_intervencao='CALIBRACAO'
          AND tp.id_parametro=NEW.id_parametro
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='A calibração precisa de um sensor compatível com o parâmetro.';
    END IF;
END$$

DELIMITER ;

-- Teste 1: encerrar um alerta pela procedure e conferir a auditoria automática.
START TRANSACTION;
SET @alerta_demo = (SELECT MIN(id_alerta) FROM alerta
                    WHERE reconhecido_em IS NULL AND encerrado_em IS NULL);
SET @ator_demo = (SELECT id_usuario FROM usuario
                  WHERE email = 'monitoramento@simulacao.example' AND ativo = 1);

SELECT id_alerta, estado FROM vw_alertas_contexto WHERE id_alerta = @alerta_demo;
CALL sp_reconhecer_alerta(@alerta_demo, @ator_demo);
CALL sp_encerrar_alerta(@alerta_demo, @ator_demo, 'Equipe conferiu o alerta e concluiu a vistoria.');

SELECT e.operacao, e.chave_alvo_1 AS id_alerta, d.nome_atributo,
       d.valor_anterior, d.valor_posterior
FROM evento_auditoria e
INNER JOIN detalhe_auditoria d USING (id_evento)
INNER JOIN alerta a ON e.chave_alvo_1 = CAST(a.id_alerta AS CHAR)
                   AND e.ocorrido_em = a.encerrado_em
WHERE a.id_alerta = @alerta_demo AND e.alvo_relacao = 'alerta'
  AND e.operacao = 'ENCERRAR'
ORDER BY d.nome_atributo;

ROLLBACK;
SELECT id_alerta, estado FROM vw_alertas_contexto WHERE id_alerta = @alerta_demo;

-- Teste 2: execute somente este bloco, comando por comando, na mesma aba.
-- O UPDATE deve falhar. Execute o ROLLBACK mesmo após a mensagem de erro.

START TRANSACTION;
UPDATE alerta
SET aberto_em = DATE_ADD(aberto_em, INTERVAL 1 SECOND)
WHERE id_alerta = @alerta_demo;
ROLLBACK;


-- Teste 3: execute somente este bloco, comando por comando, na mesma aba.
-- O INSERT de pH para o sensor de turbidez deve falhar. Depois execute ROLLBACK.

START TRANSACTION;
SET @calibracao_demo = (
    SELECT MIN(m.id_manutencao)
    FROM manutencao m INNER JOIN sensor s USING (id_sensor)
    WHERE m.tipo_intervencao = 'CALIBRACAO' AND s.codigo_patrimonial = 'EST-02-TURB'
);
SET @parametro_ph = (SELECT id_parametro FROM parametro_monitoramento WHERE codigo = 'PH');

INSERT INTO calibracao_parametro
    (id_manutencao, id_parametro, valor_referencia, valor_observado, conclusao)
VALUES (@calibracao_demo, @parametro_ph, 7.0, 7.2, 'Teste de compatibilidade.');
ROLLBACK;

