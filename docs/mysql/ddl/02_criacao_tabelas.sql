USE recursos_hidricos;

CREATE TABLE `orgao_responsavel` (
  `id_orgao` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_orgao`),
  CONSTRAINT `uq_orgao_responsavel_1` UNIQUE (`codigo`),
  CONSTRAINT `ck_orgao_responsavel_codigo_conteudo` CHECK (CHAR_LENGTH(TRIM(`codigo`)) > 0),
  CONSTRAINT `ck_orgao_responsavel_nome_conteudo` CHECK (CHAR_LENGTH(TRIM(`nome`)) > 0),
  CONSTRAINT `ck_orgao_responsavel_ativo` CHECK (`ativo` IN (0, 1))
) ENGINE=InnoDB;

CREATE TABLE `usuario` (
  `id_usuario` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(254) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `tipo_identidade` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `senha_hash` VARCHAR(255) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_usuario`),
  CONSTRAINT `uq_usuario_1` UNIQUE (`email`),
  CONSTRAINT `ck_usuario_email_conteudo` CHECK (CHAR_LENGTH(TRIM(`email`)) > 0),
  CONSTRAINT `ck_usuario_nome_conteudo` CHECK (CHAR_LENGTH(TRIM(`nome`)) > 0),
  CONSTRAINT `ck_usuario_tipo_identidade_conteudo` CHECK (CHAR_LENGTH(TRIM(`tipo_identidade`)) > 0),
  CONSTRAINT `ck_usuario_ativo` CHECK (`ativo` IN (0, 1)),
  CONSTRAINT `ck_usuario_identidade` CHECK ((tipo_identidade = 'PESSOA' AND senha_hash IS NOT NULL AND CHAR_LENGTH(TRIM(senha_hash)) > 0) OR (tipo_identidade = 'SERVICO' AND senha_hash IS NULL))
) ENGINE=InnoDB;

CREATE TABLE `perfil` (
  `id_perfil` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_perfil`),
  CONSTRAINT `uq_perfil_1` UNIQUE (`codigo`),
  CONSTRAINT `ck_perfil_codigo_conteudo` CHECK (CHAR_LENGTH(TRIM(`codigo`)) > 0),
  CONSTRAINT `ck_perfil_nome_conteudo` CHECK (CHAR_LENGTH(TRIM(`nome`)) > 0),
  CONSTRAINT `ck_perfil_ativo` CHECK (`ativo` IN (0, 1))
) ENGINE=InnoDB;

CREATE TABLE `permissao` (
  `id_permissao` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_permissao`),
  CONSTRAINT `uq_permissao_1` UNIQUE (`codigo`),
  CONSTRAINT `ck_permissao_codigo_conteudo` CHECK (CHAR_LENGTH(TRIM(`codigo`)) > 0),
  CONSTRAINT `ck_permissao_nome_conteudo` CHECK (CHAR_LENGTH(TRIM(`nome`)) > 0),
  CONSTRAINT `ck_permissao_ativo` CHECK (`ativo` IN (0, 1))
) ENGINE=InnoDB;

CREATE TABLE `usuario_perfil` (
  `id_usuario` INT UNSIGNED NOT NULL,
  `id_perfil` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_usuario`, `id_perfil`)
) ENGINE=InnoDB;

CREATE TABLE `perfil_permissao` (
  `id_perfil` INT UNSIGNED NOT NULL,
  `id_permissao` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_perfil`, `id_permissao`)
) ENGINE=InnoDB;

CREATE TABLE `bacia_hidrografica` (
  `id_bacia` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_bacia`),
  CONSTRAINT `uq_bacia_hidrografica_1` UNIQUE (`codigo`),
  CONSTRAINT `ck_bacia_hidrografica_codigo_conteudo` CHECK (CHAR_LENGTH(TRIM(`codigo`)) > 0),
  CONSTRAINT `ck_bacia_hidrografica_nome_conteudo` CHECK (CHAR_LENGTH(TRIM(`nome`)) > 0),
  CONSTRAINT `ck_bacia_hidrografica_ativo` CHECK (`ativo` IN (0, 1))
) ENGINE=InnoDB;

CREATE TABLE `tipo_corpo_hidrico` (
  `codigo_tipo_corpo` VARCHAR(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`codigo_tipo_corpo`),
  CONSTRAINT `uq_tipo_corpo_hidrico_1` UNIQUE (`nome`),
  CONSTRAINT `ck_tipo_corpo_hidrico_codigo_tipo_corpo_conteudo` CHECK (CHAR_LENGTH(TRIM(`codigo_tipo_corpo`)) > 0),
  CONSTRAINT `ck_tipo_corpo_hidrico_nome_conteudo` CHECK (CHAR_LENGTH(TRIM(`nome`)) > 0),
  CONSTRAINT `ck_tipo_corpo_hidrico_dominio` CHECK (codigo_tipo_corpo IN ('RIO', 'RESERVATORIO'))
) ENGINE=InnoDB;

CREATE TABLE `corpo_hidrico` (
  `id_corpo_hidrico` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `id_bacia` INT UNSIGNED NOT NULL,
  `codigo_tipo_corpo` VARCHAR(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_corpo_hidrico`),
  CONSTRAINT `uq_corpo_hidrico_1` UNIQUE (`codigo`),
  CONSTRAINT `ck_corpo_hidrico_codigo_conteudo` CHECK (CHAR_LENGTH(TRIM(`codigo`)) > 0),
  CONSTRAINT `ck_corpo_hidrico_nome_conteudo` CHECK (CHAR_LENGTH(TRIM(`nome`)) > 0),
  CONSTRAINT `ck_corpo_hidrico_codigo_tipo_corpo_conteudo` CHECK (CHAR_LENGTH(TRIM(`codigo_tipo_corpo`)) > 0),
  CONSTRAINT `ck_corpo_hidrico_ativo` CHECK (`ativo` IN (0, 1))
) ENGINE=InnoDB;

CREATE TABLE `estacao_monitoramento` (
  `id_estacao` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `id_corpo_hidrico` INT UNSIGNED NOT NULL,
  `id_orgao` INT UNSIGNED NOT NULL,
  `latitude` DECIMAL(8,6) NOT NULL,
  `longitude` DECIMAL(9,6) NOT NULL,
  `descricao_localizacao` VARCHAR(255) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_estacao`),
  CONSTRAINT `uq_estacao_monitoramento_1` UNIQUE (`codigo`),
  CONSTRAINT `ck_estacao_monitoramento_codigo_conteudo` CHECK (CHAR_LENGTH(TRIM(`codigo`)) > 0),
  CONSTRAINT `ck_estacao_monitoramento_nome_conteudo` CHECK (CHAR_LENGTH(TRIM(`nome`)) > 0),
  CONSTRAINT `ck_estacao_monitoramento_ativo` CHECK (`ativo` IN (0, 1)),
  CONSTRAINT `ck_estacao_monitoramento_latitude` CHECK (latitude BETWEEN -90 AND 90),
  CONSTRAINT `ck_estacao_monitoramento_longitude` CHECK (longitude BETWEEN -180 AND 180)
) ENGINE=InnoDB;

CREATE TABLE `tipo_sensor` (
  `id_tipo_sensor` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_tipo_sensor`),
  CONSTRAINT `uq_tipo_sensor_1` UNIQUE (`codigo`),
  CONSTRAINT `ck_tipo_sensor_codigo_conteudo` CHECK (CHAR_LENGTH(TRIM(`codigo`)) > 0),
  CONSTRAINT `ck_tipo_sensor_nome_conteudo` CHECK (CHAR_LENGTH(TRIM(`nome`)) > 0),
  CONSTRAINT `ck_tipo_sensor_ativo` CHECK (`ativo` IN (0, 1))
) ENGINE=InnoDB;

CREATE TABLE `sensor` (
  `id_sensor` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo_patrimonial` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `id_tipo_sensor` INT UNSIGNED NOT NULL,
  `numero_serie` VARCHAR(80) NULL DEFAULT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_sensor`),
  CONSTRAINT `uq_sensor_1` UNIQUE (`codigo_patrimonial`),
  CONSTRAINT `ck_sensor_codigo_patrimonial_conteudo` CHECK (CHAR_LENGTH(TRIM(`codigo_patrimonial`)) > 0),
  CONSTRAINT `ck_sensor_ativo` CHECK (`ativo` IN (0, 1))
) ENGINE=InnoDB;

CREATE TABLE `unidade_medida` (
  `id_unidade` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` VARCHAR(80) NOT NULL,
  `simbolo` VARCHAR(16) NOT NULL,
  `descricao` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id_unidade`),
  CONSTRAINT `uq_unidade_medida_1` UNIQUE (`codigo`),
  CONSTRAINT `ck_unidade_medida_codigo_conteudo` CHECK (CHAR_LENGTH(TRIM(`codigo`)) > 0),
  CONSTRAINT `ck_unidade_medida_nome_conteudo` CHECK (CHAR_LENGTH(TRIM(`nome`)) > 0),
  CONSTRAINT `ck_unidade_medida_simbolo_conteudo` CHECK (CHAR_LENGTH(TRIM(`simbolo`)) > 0)
) ENGINE=InnoDB;

CREATE TABLE `parametro_monitoramento` (
  `id_parametro` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `id_unidade` INT UNSIGNED NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_parametro`),
  CONSTRAINT `uq_parametro_monitoramento_1` UNIQUE (`codigo`),
  CONSTRAINT `ck_parametro_monitoramento_codigo_conteudo` CHECK (CHAR_LENGTH(TRIM(`codigo`)) > 0),
  CONSTRAINT `ck_parametro_monitoramento_nome_conteudo` CHECK (CHAR_LENGTH(TRIM(`nome`)) > 0),
  CONSTRAINT `ck_parametro_monitoramento_ativo` CHECK (`ativo` IN (0, 1))
) ENGINE=InnoDB;

CREATE TABLE `tipo_sensor_parametro` (
  `id_tipo_sensor` INT UNSIGNED NOT NULL,
  `id_parametro` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_tipo_sensor`, `id_parametro`)
) ENGINE=InnoDB;

CREATE TABLE `instalacao_sensor` (
  `id_instalacao` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_sensor` INT UNSIGNED NOT NULL,
  `id_estacao` INT UNSIGNED NOT NULL,
  `inicio_em` DATETIME(3) NOT NULL,
  `fim_em` DATETIME(3) NULL DEFAULT NULL,
  `id_usuario_instalacao` INT UNSIGNED NOT NULL,
  `id_usuario_retirada` INT UNSIGNED NULL DEFAULT NULL,
  `observacao` VARCHAR(500) NULL DEFAULT NULL,
  PRIMARY KEY (`id_instalacao`),
  CONSTRAINT `uq_instalacao_sensor_1` UNIQUE (`id_sensor`, `inicio_em`),
  CONSTRAINT `ck_instalacao_sensor_intervalo` CHECK (fim_em IS NULL OR fim_em > inicio_em),
  CONSTRAINT `ck_instalacao_sensor_retirada` CHECK ((fim_em IS NULL AND id_usuario_retirada IS NULL) OR (fim_em IS NOT NULL AND id_usuario_retirada IS NOT NULL))
) ENGINE=InnoDB;

CREATE TABLE `regra_monitoramento` (
  `id_regra` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_estacao` INT UNSIGNED NOT NULL,
  `id_parametro` INT UNSIGNED NOT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_regra`),
  CONSTRAINT `uq_regra_monitoramento_1` UNIQUE (`id_estacao`, `id_parametro`),
  CONSTRAINT `ck_regra_monitoramento_ativo` CHECK (`ativo` IN (0, 1))
) ENGINE=InnoDB;

CREATE TABLE `versao_regra_monitoramento` (
  `id_versao` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_regra` INT UNSIGNED NOT NULL,
  `numero_versao` INT UNSIGNED NOT NULL,
  `limite_inferior` DECIMAL(14,6) NULL DEFAULT NULL,
  `limite_superior` DECIMAL(14,6) NULL DEFAULT NULL,
  `prioridade` VARCHAR(7) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `inicio_em` DATETIME(3) NOT NULL,
  `fim_em` DATETIME(3) NULL DEFAULT NULL,
  `id_usuario_configuracao` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_versao`),
  CONSTRAINT `uq_versao_regra_monitoramento_1` UNIQUE (`id_regra`, `numero_versao`),
  CONSTRAINT `ck_versao_regra_monitoramento_prioridade_conteudo` CHECK (CHAR_LENGTH(TRIM(`prioridade`)) > 0),
  CONSTRAINT `ck_versao_regra_monitoramento_numero` CHECK (numero_versao > 0),
  CONSTRAINT `ck_versao_regra_monitoramento_limites` CHECK ((limite_inferior IS NOT NULL OR limite_superior IS NOT NULL) AND (limite_inferior IS NULL OR limite_superior IS NULL OR limite_inferior < limite_superior)),
  CONSTRAINT `ck_versao_regra_monitoramento_prioridade` CHECK (prioridade IN ('ATENCAO', 'CRITICO')),
  CONSTRAINT `ck_versao_regra_monitoramento_intervalo` CHECK (fim_em IS NULL OR fim_em > inicio_em)
) ENGINE=InnoDB;

CREATE TABLE `alerta` (
  `id_alerta` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_versao_abertura` INT UNSIGNED NOT NULL,
  `aberto_em` DATETIME(3) NOT NULL,
  `id_usuario_abertura` INT UNSIGNED NOT NULL,
  `reconhecido_em` DATETIME(3) NULL DEFAULT NULL,
  `id_usuario_reconhecimento` INT UNSIGNED NULL DEFAULT NULL,
  `encerrado_em` DATETIME(3) NULL DEFAULT NULL,
  `id_usuario_encerramento` INT UNSIGNED NULL DEFAULT NULL,
  `motivo_encerramento` VARCHAR(500) NULL DEFAULT NULL,
  `id_ocorrencia` BIGINT UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`id_alerta`),
  CONSTRAINT `ck_alerta_reconhecimento` CHECK ((reconhecido_em IS NULL AND id_usuario_reconhecimento IS NULL) OR (reconhecido_em IS NOT NULL AND id_usuario_reconhecimento IS NOT NULL AND reconhecido_em >= aberto_em)),
  CONSTRAINT `ck_alerta_encerramento` CHECK ((encerrado_em IS NULL AND id_usuario_encerramento IS NULL AND motivo_encerramento IS NULL) OR (encerrado_em IS NOT NULL AND id_usuario_encerramento IS NOT NULL AND motivo_encerramento IS NOT NULL AND CHAR_LENGTH(TRIM(motivo_encerramento)) > 0 AND reconhecido_em IS NOT NULL AND encerrado_em >= reconhecido_em))
) ENGINE=InnoDB;

CREATE TABLE `evidencia_alerta` (
  `id_documento_mongo` CHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `id_leitura` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `id_alerta` BIGINT UNSIGNED NOT NULL,
  `id_versao_avaliacao` INT UNSIGNED NOT NULL,
  `origem` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_documento_mongo`, `id_leitura`),
  CONSTRAINT `ck_evidencia_alerta_id_documento_mongo_conteudo` CHECK (CHAR_LENGTH(TRIM(`id_documento_mongo`)) > 0),
  CONSTRAINT `ck_evidencia_alerta_id_leitura_conteudo` CHECK (CHAR_LENGTH(TRIM(`id_leitura`)) > 0),
  CONSTRAINT `ck_evidencia_alerta_origem` CHECK (`origem` IN (0, 1)),
  CONSTRAINT `ck_evidencia_alerta_objectid` CHECK (REGEXP_LIKE(id_documento_mongo, '^[0-9a-f]{24}$', 'c'))
) ENGINE=InnoDB;

CREATE TABLE `ocorrencia` (
  `id_ocorrencia` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `titulo` VARCHAR(160) NOT NULL,
  `descricao` TEXT NOT NULL,
  `aberta_em` DATETIME(3) NOT NULL,
  `id_usuario_abertura` INT UNSIGNED NOT NULL,
  `tratamento_iniciado_em` DATETIME(3) NULL DEFAULT NULL,
  `id_usuario_tratamento` INT UNSIGNED NULL DEFAULT NULL,
  `concluida_em` DATETIME(3) NULL DEFAULT NULL,
  `id_usuario_conclusao` INT UNSIGNED NULL DEFAULT NULL,
  `justificativa_conclusao` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id_ocorrencia`),
  CONSTRAINT `ck_ocorrencia_titulo_conteudo` CHECK (CHAR_LENGTH(TRIM(`titulo`)) > 0),
  CONSTRAINT `ck_ocorrencia_descricao_conteudo` CHECK (CHAR_LENGTH(TRIM(`descricao`)) > 0),
  CONSTRAINT `ck_ocorrencia_tratamento` CHECK ((tratamento_iniciado_em IS NULL AND id_usuario_tratamento IS NULL) OR (tratamento_iniciado_em IS NOT NULL AND id_usuario_tratamento IS NOT NULL AND tratamento_iniciado_em >= aberta_em)),
  CONSTRAINT `ck_ocorrencia_conclusao` CHECK ((concluida_em IS NULL AND id_usuario_conclusao IS NULL AND justificativa_conclusao IS NULL) OR (concluida_em IS NOT NULL AND id_usuario_conclusao IS NOT NULL AND justificativa_conclusao IS NOT NULL AND CHAR_LENGTH(TRIM(justificativa_conclusao)) > 0 AND tratamento_iniciado_em IS NOT NULL AND concluida_em >= tratamento_iniciado_em))
) ENGINE=InnoDB;

CREATE TABLE `ocorrencia_corpo_hidrico` (
  `id_ocorrencia` BIGINT UNSIGNED NOT NULL,
  `id_corpo_hidrico` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_ocorrencia`, `id_corpo_hidrico`)
) ENGINE=InnoDB;

CREATE TABLE `ocorrencia_estacao` (
  `id_ocorrencia` BIGINT UNSIGNED NOT NULL,
  `id_estacao` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_ocorrencia`, `id_estacao`)
) ENGINE=InnoDB;

CREATE TABLE `ocorrencia_sensor` (
  `id_ocorrencia` BIGINT UNSIGNED NOT NULL,
  `id_sensor` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_ocorrencia`, `id_sensor`)
) ENGINE=InnoDB;

CREATE TABLE `acao_ocorrencia` (
  `id_acao` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_ocorrencia` BIGINT UNSIGNED NOT NULL,
  `descricao` TEXT NOT NULL,
  `realizada_em` DATETIME(3) NOT NULL,
  `id_usuario_responsavel` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_acao`),
  CONSTRAINT `ck_acao_ocorrencia_descricao_conteudo` CHECK (CHAR_LENGTH(TRIM(`descricao`)) > 0)
) ENGINE=InnoDB;

CREATE TABLE `manutencao` (
  `id_manutencao` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_estacao` INT UNSIGNED NULL DEFAULT NULL,
  `id_sensor` INT UNSIGNED NULL DEFAULT NULL,
  `id_ocorrencia` BIGINT UNSIGNED NULL DEFAULT NULL,
  `tipo_intervencao` VARCHAR(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `inicio_em` DATETIME(3) NOT NULL,
  `fim_em` DATETIME(3) NOT NULL,
  `descricao` TEXT NOT NULL,
  `resultado` TEXT NOT NULL,
  `id_usuario_responsavel` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_manutencao`),
  CONSTRAINT `ck_manutencao_tipo_intervencao_conteudo` CHECK (CHAR_LENGTH(TRIM(`tipo_intervencao`)) > 0),
  CONSTRAINT `ck_manutencao_descricao_conteudo` CHECK (CHAR_LENGTH(TRIM(`descricao`)) > 0),
  CONSTRAINT `ck_manutencao_resultado_conteudo` CHECK (CHAR_LENGTH(TRIM(`resultado`)) > 0),
  CONSTRAINT `ck_manutencao_alvo` CHECK ((id_estacao IS NOT NULL AND id_sensor IS NULL) OR (id_estacao IS NULL AND id_sensor IS NOT NULL)),
  CONSTRAINT `ck_manutencao_tipo` CHECK (tipo_intervencao IN ('MANUTENCAO', 'INSPECAO', 'CALIBRACAO')),
  CONSTRAINT `ck_manutencao_intervalo` CHECK (fim_em >= inicio_em),
  CONSTRAINT `ck_manutencao_sensor_calibracao` CHECK (tipo_intervencao <> 'CALIBRACAO' OR id_sensor IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE `calibracao_parametro` (
  `id_manutencao` BIGINT UNSIGNED NOT NULL,
  `id_parametro` INT UNSIGNED NOT NULL,
  `valor_referencia` DECIMAL(14,6) NOT NULL,
  `valor_observado` DECIMAL(14,6) NOT NULL,
  `conclusao` VARCHAR(500) NOT NULL,
  `ajuste_realizado` VARCHAR(500) NULL DEFAULT NULL,
  PRIMARY KEY (`id_manutencao`, `id_parametro`),
  CONSTRAINT `ck_calibracao_parametro_conclusao_conteudo` CHECK (CHAR_LENGTH(TRIM(`conclusao`)) > 0)
) ENGINE=InnoDB;

CREATE TABLE `resumo_diario_monitoramento` (
  `id_estacao` INT UNSIGNED NOT NULL,
  `id_parametro` INT UNSIGNED NOT NULL,
  `dia_utc` DATE NOT NULL,
  `quantidade_validas` INT UNSIGNED NOT NULL,
  `soma` DECIMAL(26,6) NULL DEFAULT NULL,
  `minimo` DECIMAL(14,6) NULL DEFAULT NULL,
  `maximo` DECIMAL(14,6) NULL DEFAULT NULL,
  `consolidado_em` DATETIME(3) NOT NULL,
  PRIMARY KEY (`id_estacao`, `id_parametro`, `dia_utc`),
  CONSTRAINT `ck_resumo_diario_monitoramento_valores` CHECK ((quantidade_validas = 0 AND soma IS NULL AND minimo IS NULL AND maximo IS NULL) OR (quantidade_validas > 0 AND soma IS NOT NULL AND minimo IS NOT NULL AND maximo IS NOT NULL AND minimo <= maximo))
) ENGINE=InnoDB;

CREATE TABLE `evento_auditoria` (
  `id_evento` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL,
  `ocorrido_em` DATETIME(3) NOT NULL,
  `operacao` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `alvo_relacao` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `chave_alvo_1` VARCHAR(128) NOT NULL,
  `chave_alvo_2` VARCHAR(128) NULL DEFAULT NULL,
  `chave_alvo_3` VARCHAR(128) NULL DEFAULT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  PRIMARY KEY (`id_evento`),
  CONSTRAINT `ck_evento_auditoria_operacao_conteudo` CHECK (CHAR_LENGTH(TRIM(`operacao`)) > 0),
  CONSTRAINT `ck_evento_auditoria_alvo_relacao_conteudo` CHECK (CHAR_LENGTH(TRIM(`alvo_relacao`)) > 0),
  CONSTRAINT `ck_evento_auditoria_chave_alvo_1_conteudo` CHECK (CHAR_LENGTH(TRIM(`chave_alvo_1`)) > 0),
  CONSTRAINT `ck_evento_auditoria_componentes` CHECK (chave_alvo_3 IS NULL OR chave_alvo_2 IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE `detalhe_auditoria` (
  `id_evento` BIGINT UNSIGNED NOT NULL,
  `nome_atributo` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `anterior_presente` TINYINT UNSIGNED NOT NULL,
  `posterior_presente` TINYINT UNSIGNED NOT NULL,
  `valor_anterior` TEXT NULL DEFAULT NULL,
  `valor_posterior` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id_evento`, `nome_atributo`),
  CONSTRAINT `ck_detalhe_auditoria_nome_atributo_conteudo` CHECK (CHAR_LENGTH(TRIM(`nome_atributo`)) > 0),
  CONSTRAINT `ck_detalhe_auditoria_anterior_presente` CHECK (`anterior_presente` IN (0, 1)),
  CONSTRAINT `ck_detalhe_auditoria_posterior_presente` CHECK (`posterior_presente` IN (0, 1)),
  CONSTRAINT `ck_detalhe_auditoria_presenca` CHECK ((anterior_presente = 1 OR posterior_presente = 1) AND (anterior_presente = 1 OR valor_anterior IS NULL) AND (posterior_presente = 1 OR valor_posterior IS NULL))
) ENGINE=InnoDB;

ALTER TABLE `usuario_perfil`
  ADD CONSTRAINT `fk_usuario_perfil_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`),
  ADD INDEX `ix_usuario_perfil_id_perfil` (`id_perfil`),
  ADD CONSTRAINT `fk_usuario_perfil_id_perfil` FOREIGN KEY (`id_perfil`) REFERENCES `perfil` (`id_perfil`);

ALTER TABLE `perfil_permissao`
  ADD CONSTRAINT `fk_perfil_permissao_id_perfil` FOREIGN KEY (`id_perfil`) REFERENCES `perfil` (`id_perfil`),
  ADD INDEX `ix_perfil_permissao_id_permissao` (`id_permissao`),
  ADD CONSTRAINT `fk_perfil_permissao_id_permissao` FOREIGN KEY (`id_permissao`) REFERENCES `permissao` (`id_permissao`);

ALTER TABLE `corpo_hidrico`
  ADD INDEX `ix_corpo_hidrico_id_bacia` (`id_bacia`),
  ADD CONSTRAINT `fk_corpo_hidrico_id_bacia` FOREIGN KEY (`id_bacia`) REFERENCES `bacia_hidrografica` (`id_bacia`),
  ADD INDEX `ix_corpo_hidrico_codigo_tipo_corpo` (`codigo_tipo_corpo`),
  ADD CONSTRAINT `fk_corpo_hidrico_codigo_tipo_corpo` FOREIGN KEY (`codigo_tipo_corpo`) REFERENCES `tipo_corpo_hidrico` (`codigo_tipo_corpo`);

ALTER TABLE `estacao_monitoramento`
  ADD INDEX `ix_estacao_monitoramento_id_corpo_hidrico` (`id_corpo_hidrico`),
  ADD CONSTRAINT `fk_estacao_monitoramento_id_corpo_hidrico` FOREIGN KEY (`id_corpo_hidrico`) REFERENCES `corpo_hidrico` (`id_corpo_hidrico`),
  ADD INDEX `ix_estacao_monitoramento_id_orgao` (`id_orgao`),
  ADD CONSTRAINT `fk_estacao_monitoramento_id_orgao` FOREIGN KEY (`id_orgao`) REFERENCES `orgao_responsavel` (`id_orgao`);

ALTER TABLE `sensor`
  ADD INDEX `ix_sensor_id_tipo_sensor` (`id_tipo_sensor`),
  ADD CONSTRAINT `fk_sensor_id_tipo_sensor` FOREIGN KEY (`id_tipo_sensor`) REFERENCES `tipo_sensor` (`id_tipo_sensor`);

ALTER TABLE `parametro_monitoramento`
  ADD INDEX `ix_parametro_monitoramento_id_unidade` (`id_unidade`),
  ADD CONSTRAINT `fk_parametro_monitoramento_id_unidade` FOREIGN KEY (`id_unidade`) REFERENCES `unidade_medida` (`id_unidade`);

ALTER TABLE `tipo_sensor_parametro`
  ADD CONSTRAINT `fk_tipo_sensor_parametro_id_tipo_sensor` FOREIGN KEY (`id_tipo_sensor`) REFERENCES `tipo_sensor` (`id_tipo_sensor`),
  ADD INDEX `ix_tipo_sensor_parametro_id_parametro` (`id_parametro`),
  ADD CONSTRAINT `fk_tipo_sensor_parametro_id_parametro` FOREIGN KEY (`id_parametro`) REFERENCES `parametro_monitoramento` (`id_parametro`);

ALTER TABLE `instalacao_sensor`
  ADD CONSTRAINT `fk_instalacao_sensor_id_sensor` FOREIGN KEY (`id_sensor`) REFERENCES `sensor` (`id_sensor`),
  ADD INDEX `ix_instalacao_sensor_id_estacao` (`id_estacao`),
  ADD CONSTRAINT `fk_instalacao_sensor_id_estacao` FOREIGN KEY (`id_estacao`) REFERENCES `estacao_monitoramento` (`id_estacao`),
  ADD INDEX `ix_instalacao_sensor_id_usuario_instalacao` (`id_usuario_instalacao`),
  ADD CONSTRAINT `fk_instalacao_sensor_id_usuario_instalacao` FOREIGN KEY (`id_usuario_instalacao`) REFERENCES `usuario` (`id_usuario`),
  ADD INDEX `ix_instalacao_sensor_id_usuario_retirada` (`id_usuario_retirada`),
  ADD CONSTRAINT `fk_instalacao_sensor_id_usuario_retirada` FOREIGN KEY (`id_usuario_retirada`) REFERENCES `usuario` (`id_usuario`);

ALTER TABLE `regra_monitoramento`
  ADD CONSTRAINT `fk_regra_monitoramento_id_estacao` FOREIGN KEY (`id_estacao`) REFERENCES `estacao_monitoramento` (`id_estacao`),
  ADD INDEX `ix_regra_monitoramento_id_parametro` (`id_parametro`),
  ADD CONSTRAINT `fk_regra_monitoramento_id_parametro` FOREIGN KEY (`id_parametro`) REFERENCES `parametro_monitoramento` (`id_parametro`);

ALTER TABLE `versao_regra_monitoramento`
  ADD CONSTRAINT `fk_versao_regra_monitoramento_id_regra` FOREIGN KEY (`id_regra`) REFERENCES `regra_monitoramento` (`id_regra`),
  ADD INDEX `ix_versao_regra_monitoramento_id_usuario_configuracao` (`id_usuario_configuracao`),
  ADD CONSTRAINT `fk_versao_regra_monitoramento_id_usuario_configuracao` FOREIGN KEY (`id_usuario_configuracao`) REFERENCES `usuario` (`id_usuario`);

ALTER TABLE `alerta`
  ADD INDEX `ix_alerta_id_versao_abertura` (`id_versao_abertura`),
  ADD CONSTRAINT `fk_alerta_id_versao_abertura` FOREIGN KEY (`id_versao_abertura`) REFERENCES `versao_regra_monitoramento` (`id_versao`),
  ADD INDEX `ix_alerta_id_usuario_abertura` (`id_usuario_abertura`),
  ADD CONSTRAINT `fk_alerta_id_usuario_abertura` FOREIGN KEY (`id_usuario_abertura`) REFERENCES `usuario` (`id_usuario`),
  ADD INDEX `ix_alerta_id_usuario_reconhecimento` (`id_usuario_reconhecimento`),
  ADD CONSTRAINT `fk_alerta_id_usuario_reconhecimento` FOREIGN KEY (`id_usuario_reconhecimento`) REFERENCES `usuario` (`id_usuario`),
  ADD INDEX `ix_alerta_id_usuario_encerramento` (`id_usuario_encerramento`),
  ADD CONSTRAINT `fk_alerta_id_usuario_encerramento` FOREIGN KEY (`id_usuario_encerramento`) REFERENCES `usuario` (`id_usuario`),
  ADD INDEX `ix_alerta_id_ocorrencia` (`id_ocorrencia`),
  ADD CONSTRAINT `fk_alerta_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id_ocorrencia`);

ALTER TABLE `evidencia_alerta`
  ADD INDEX `ix_evidencia_alerta_id_alerta` (`id_alerta`),
  ADD CONSTRAINT `fk_evidencia_alerta_id_alerta` FOREIGN KEY (`id_alerta`) REFERENCES `alerta` (`id_alerta`),
  ADD INDEX `ix_evidencia_alerta_id_versao_avaliacao` (`id_versao_avaliacao`),
  ADD CONSTRAINT `fk_evidencia_alerta_id_versao_avaliacao` FOREIGN KEY (`id_versao_avaliacao`) REFERENCES `versao_regra_monitoramento` (`id_versao`);

ALTER TABLE `ocorrencia`
  ADD INDEX `ix_ocorrencia_id_usuario_abertura` (`id_usuario_abertura`),
  ADD CONSTRAINT `fk_ocorrencia_id_usuario_abertura` FOREIGN KEY (`id_usuario_abertura`) REFERENCES `usuario` (`id_usuario`),
  ADD INDEX `ix_ocorrencia_id_usuario_tratamento` (`id_usuario_tratamento`),
  ADD CONSTRAINT `fk_ocorrencia_id_usuario_tratamento` FOREIGN KEY (`id_usuario_tratamento`) REFERENCES `usuario` (`id_usuario`),
  ADD INDEX `ix_ocorrencia_id_usuario_conclusao` (`id_usuario_conclusao`),
  ADD CONSTRAINT `fk_ocorrencia_id_usuario_conclusao` FOREIGN KEY (`id_usuario_conclusao`) REFERENCES `usuario` (`id_usuario`);

ALTER TABLE `ocorrencia_corpo_hidrico`
  ADD CONSTRAINT `fk_ocorrencia_corpo_hidrico_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id_ocorrencia`),
  ADD INDEX `ix_ocorrencia_corpo_hidrico_id_corpo_hidrico` (`id_corpo_hidrico`),
  ADD CONSTRAINT `fk_ocorrencia_corpo_hidrico_id_corpo_hidrico` FOREIGN KEY (`id_corpo_hidrico`) REFERENCES `corpo_hidrico` (`id_corpo_hidrico`);

ALTER TABLE `ocorrencia_estacao`
  ADD CONSTRAINT `fk_ocorrencia_estacao_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id_ocorrencia`),
  ADD INDEX `ix_ocorrencia_estacao_id_estacao` (`id_estacao`),
  ADD CONSTRAINT `fk_ocorrencia_estacao_id_estacao` FOREIGN KEY (`id_estacao`) REFERENCES `estacao_monitoramento` (`id_estacao`);

ALTER TABLE `ocorrencia_sensor`
  ADD CONSTRAINT `fk_ocorrencia_sensor_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id_ocorrencia`),
  ADD INDEX `ix_ocorrencia_sensor_id_sensor` (`id_sensor`),
  ADD CONSTRAINT `fk_ocorrencia_sensor_id_sensor` FOREIGN KEY (`id_sensor`) REFERENCES `sensor` (`id_sensor`);

ALTER TABLE `acao_ocorrencia`
  ADD INDEX `ix_acao_ocorrencia_id_ocorrencia` (`id_ocorrencia`),
  ADD CONSTRAINT `fk_acao_ocorrencia_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id_ocorrencia`),
  ADD INDEX `ix_acao_ocorrencia_id_usuario_responsavel` (`id_usuario_responsavel`),
  ADD CONSTRAINT `fk_acao_ocorrencia_id_usuario_responsavel` FOREIGN KEY (`id_usuario_responsavel`) REFERENCES `usuario` (`id_usuario`);

ALTER TABLE `manutencao`
  ADD INDEX `ix_manutencao_id_estacao` (`id_estacao`),
  ADD CONSTRAINT `fk_manutencao_id_estacao` FOREIGN KEY (`id_estacao`) REFERENCES `estacao_monitoramento` (`id_estacao`),
  ADD INDEX `ix_manutencao_id_sensor` (`id_sensor`),
  ADD CONSTRAINT `fk_manutencao_id_sensor` FOREIGN KEY (`id_sensor`) REFERENCES `sensor` (`id_sensor`),
  ADD INDEX `ix_manutencao_id_ocorrencia` (`id_ocorrencia`),
  ADD CONSTRAINT `fk_manutencao_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id_ocorrencia`),
  ADD INDEX `ix_manutencao_id_usuario_responsavel` (`id_usuario_responsavel`),
  ADD CONSTRAINT `fk_manutencao_id_usuario_responsavel` FOREIGN KEY (`id_usuario_responsavel`) REFERENCES `usuario` (`id_usuario`);

ALTER TABLE `calibracao_parametro`
  ADD CONSTRAINT `fk_calibracao_parametro_id_manutencao` FOREIGN KEY (`id_manutencao`) REFERENCES `manutencao` (`id_manutencao`),
  ADD INDEX `ix_calibracao_parametro_id_parametro` (`id_parametro`),
  ADD CONSTRAINT `fk_calibracao_parametro_id_parametro` FOREIGN KEY (`id_parametro`) REFERENCES `parametro_monitoramento` (`id_parametro`);

ALTER TABLE `resumo_diario_monitoramento`
  ADD CONSTRAINT `fk_resumo_diario_monitoramento_id_estacao` FOREIGN KEY (`id_estacao`) REFERENCES `estacao_monitoramento` (`id_estacao`),
  ADD INDEX `ix_resumo_diario_monitoramento_id_parametro` (`id_parametro`),
  ADD CONSTRAINT `fk_resumo_diario_monitoramento_id_parametro` FOREIGN KEY (`id_parametro`) REFERENCES `parametro_monitoramento` (`id_parametro`);

ALTER TABLE `evento_auditoria`
  ADD INDEX `ix_evento_auditoria_id_usuario` (`id_usuario`),
  ADD CONSTRAINT `fk_evento_auditoria_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

ALTER TABLE `detalhe_auditoria`
  ADD CONSTRAINT `fk_detalhe_auditoria_id_evento` FOREIGN KEY (`id_evento`) REFERENCES `evento_auditoria` (`id_evento`);
