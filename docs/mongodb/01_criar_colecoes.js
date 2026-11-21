db = db.getSiblingDB('recursos_hidricos');

// 1. Coletas por estação e horário, com as leituras dos sensores incorporadas.
db.createCollection('medicoes', {
    validator: {
        $jsonSchema: {
            bsonType: 'object',
            required: ['mensagem_codigo', 'estacao_codigo', 'coletado_em', 'recebido_em', 'leituras'],
            properties: {
                _id: { bsonType: 'objectId' },
                mensagem_codigo: { bsonType: 'string', pattern: '^[A-Za-z0-9_-]{1,80}$' },
                estacao_codigo: { bsonType: 'string', pattern: '^[A-Z0-9_-]{1,20}$' },
                coletado_em: { bsonType: 'date' },
                recebido_em: { bsonType: 'date' },
                leituras: {
                    bsonType: 'array',
                    minItems: 1,
                    items: {
                        bsonType: 'object',
                        required: ['id_leitura', 'sensor_codigo', 'parametro_codigo', 'unidade', 'valor', 'valida'],
                        properties: {
                            id_leitura: { bsonType: 'string', pattern: '^[A-Za-z0-9_-]{1,40}$' },
                            sensor_codigo: { bsonType: 'string', pattern: '^[A-Z0-9_-]{1,20}$' },
                            parametro_codigo: { enum: ['TEMPERATURA', 'PH', 'OXIGENIO', 'TURBIDEZ', 'NIVEL'] },
                            unidade: { enum: ['°C', '1', 'mg/L', 'NTU', 'm'] },
                            valor: { bsonType: 'decimal' },
                            valida: { bsonType: 'bool' },
                            motivo_invalidade: { enum: ['ERRO_SENSOR', 'VALOR_FORA_FAIXA_TECNICA', 'FORMATO_INVALIDO'] }
                        }
                    }
                }
            }
        }
    },
    validationLevel: 'strict',
    validationAction: 'error'
});

db.medicoes.createIndex(
    { mensagem_codigo: 1 },
    { unique: true, name: 'uq_medicoes_mensagem' }
);

// 2. Diagnósticos dos equipamentos, separados das medições da água.
db.createCollection('telemetria', {
    validator: {
        $jsonSchema: {
            bsonType: 'object',
            required: ['estacao_codigo', 'sensor_codigo', 'registrado_em', 'equipamento'],
            properties: {
                _id: { bsonType: 'objectId' },
                estacao_codigo: { bsonType: 'string', pattern: '^[A-Z0-9_-]{1,20}$' },
                sensor_codigo: { bsonType: 'string', pattern: '^[A-Z0-9_-]{1,20}$' },
                registrado_em: { bsonType: 'date' },
                equipamento: {
                    bsonType: 'object',
                    required: ['bateria_pct', 'sinal_dbm'],
                    properties: {
                        bateria_pct: { bsonType: ['int', 'long', 'double', 'decimal'], minimum: 0, maximum: 100 },
                        sinal_dbm: { bsonType: ['int', 'long', 'double', 'decimal'], maximum: 0 },
                        temperatura_interna_c: { bsonType: ['int', 'long', 'double', 'decimal'] },
                        firmware: { bsonType: 'string', minLength: 1 }
                    }
                }
            }
        }
    },
    validationLevel: 'strict',
    validationAction: 'error'
});

// 3. Eventos de recebimento, validação e integração das mensagens.
db.createCollection('logs_ingestao', {
    validator: {
        $jsonSchema: {
            bsonType: 'object',
            required: ['mensagem_codigo', 'registrado_em', 'etapa', 'resultado'],
            properties: {
                _id: { bsonType: 'objectId' },
                mensagem_codigo: { bsonType: 'string', pattern: '^[A-Za-z0-9_-]{1,80}$' },
                registrado_em: { bsonType: 'date' },
                etapa: { enum: ['INGESTAO', 'INTEGRACAO'] },
                resultado: { enum: ['ACEITA', 'REJEITADA', 'DUPLICADA', 'CONFLITO', 'PROCESSADA', 'PENDENTE', 'SEM_REGRA', 'ERRO'] },
                documento_medicao_id: { bsonType: 'objectId' },
                motivo: { bsonType: 'string', minLength: 1 },
                origem: { bsonType: 'object' },
                payload_original: { bsonType: ['object', 'string'] }
            }
        }
    },
    validationLevel: 'strict',
    validationAction: 'error'
});
