db = db.getSiblingDB('recursos_hidricos');

// 1. Quais coletas foram registradas na EST-01 em 15/01/2025, em ordem de coleta?
print('Consulta 1');
printjson(db.medicoes.find(
    { estacao_codigo: 'EST-01', coletado_em: {
        $gte: ISODate('2025-01-15T00:00:00Z'), $lt: ISODate('2025-01-16T00:00:00Z')
    } },
    { _id: 0, mensagem_codigo: 1, coletado_em: 1, recebido_em: 1 }
).sort({ coletado_em: 1 }).toArray());

// 2. Quais foram as dez primeiras coletas da EST-01 com turbidez valida acima de 45 NTU durante a vigencia desse limite?
print('Consulta 2');
printjson(db.medicoes.find(
    { estacao_codigo: 'EST-01',
      coletado_em: { $gte: ISODate('2025-01-01T00:00:00Z'), $lt: ISODate('2025-07-01T08:00:00Z') },
      leituras: { $elemMatch: { parametro_codigo: 'TURBIDEZ', valida: true, valor: { $gt: NumberDecimal('45') } } } },
    { _id: 0, mensagem_codigo: 1, coletado_em: 1,
      leituras: { $elemMatch: { parametro_codigo: 'TURBIDEZ', valida: true, valor: { $gt: NumberDecimal('45') } } } }
).sort({ coletado_em: 1 }).limit(10).toArray());

// 3. Quais sao as dez coletas mais recentes com pelo menos uma leitura marcada como erro de sensor?
print('Consulta 3');
printjson(db.medicoes.find(
    { leituras: { $elemMatch: { valida: false, motivo_invalidade: 'ERRO_SENSOR' } } },
    { _id: 0, estacao_codigo: 1, coletado_em: 1,
      leituras: { $elemMatch: { valida: false, motivo_invalidade: 'ERRO_SENSOR' } } }
).sort({ coletado_em: -1, estacao_codigo: 1 }).limit(10).toArray());

// 4. Quais coletas da EST-03 feitas em 31/03/2025 foram recebidas somente no dia seguinte?
print('Consulta 4');
printjson(db.medicoes.find(
    { $and: [
        { estacao_codigo: 'EST-03' },
        { coletado_em: { $gte: ISODate('2025-03-31T00:00:00Z'), $lt: ISODate('2025-04-01T00:00:00Z') } },
        { recebido_em: { $gte: ISODate('2025-04-01T00:00:00Z'), $lt: ISODate('2025-04-02T00:00:00Z') } }
    ] },
    { _id: 0, mensagem_codigo: 1, coletado_em: 1, recebido_em: 1 }
).sort({ recebido_em: 1 }).toArray());

// 5. Quais sao os dez diagnosticos com menor bateria, abaixo de 20%, para priorizar a triagem?
print('Consulta 5');
printjson(db.telemetria.find(
    { 'equipamento.bateria_pct': { $lt: 20 } },
    { _id: 0, estacao_codigo: 1, sensor_codigo: 1, registrado_em: 1, equipamento: 1 }
).sort({ 'equipamento.bateria_pct': 1, registrado_em: -1, sensor_codigo: 1 }).limit(10).toArray());

// 6. Quais dez diagnosticos mais recentes indicam bateria de pelo menos 50%, mas sinal inferior a -85 dBm?
print('Consulta 6');
printjson(db.telemetria.find(
    { 'equipamento.bateria_pct': { $gte: 50 }, 'equipamento.sinal_dbm': { $lt: -85 } },
    { _id: 0, estacao_codigo: 1, sensor_codigo: 1, registrado_em: 1,
      'equipamento.bateria_pct': 1, 'equipamento.sinal_dbm': 1 }
).sort({ registrado_em: -1, sensor_codigo: 1 }).limit(10).toArray());

// 7. Quais dez diagnosticos mais recentes de novembro/2025 reportaram firmware 1.1.0?
print('Consulta 7');
printjson(db.telemetria.find(
    { registrado_em: { $gte: ISODate('2025-11-01T00:00:00Z'), $lt: ISODate('2025-12-01T00:00:00Z') },
      'equipamento.firmware': '1.1.0' },
    { _id: 0, estacao_codigo: 1, sensor_codigo: 1, registrado_em: 1,
      'equipamento.firmware': 1, 'equipamento.temperatura_interna_c': 1 }
).sort({ registrado_em: -1, sensor_codigo: 1 }).limit(10).toArray());

// 8. Quais foram os vinte primeiros eventos de ausencia de pacote na simulacao?
print('Consulta 8');
printjson(db.logs_ingestao.find(
    { etapa: 'INGESTAO', resultado: 'REJEITADA', 'origem.evento': 'FALHA_TRANSMISSAO' },
    { _id: 0, mensagem_codigo: 1, registrado_em: 1, resultado: 1, motivo: 1 }
).sort({ registrado_em: 1, mensagem_codigo: 1 }).limit(20).toArray());

// 9. Qual foi o registro de recebimento e o documento associado a coleta EST-01 de 01/07/2025 as 07h UTC?
print('Consulta 9');
printjson(db.logs_ingestao.find(
    { mensagem_codigo: 'EST-01_20250701T070000Z', etapa: 'INGESTAO', resultado: 'ACEITA' },
    { _id: 0, mensagem_codigo: 1, registrado_em: 1, documento_medicao_id: 1, resultado: 1 }
).sort({ registrado_em: 1 }).toArray());

// 10. Quais sao os vinte eventos de integracao mais recentes com erro, pendencia ou ausencia de regra?
print('Consulta 10');
printjson(db.logs_ingestao.find(
    { etapa: 'INTEGRACAO', $or: [
        { resultado: 'ERRO' }, { resultado: 'PENDENTE' }, { resultado: 'SEM_REGRA' }
    ] },
    { _id: 0, mensagem_codigo: 1, registrado_em: 1, resultado: 1, motivo: 1, documento_medicao_id: 1 }
).sort({ registrado_em: -1, mensagem_codigo: 1 }).limit(20).toArray());
