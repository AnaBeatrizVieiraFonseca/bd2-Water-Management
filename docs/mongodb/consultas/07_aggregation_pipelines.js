db = db.getSiblingDB('recursos_hidricos');

// 1. Qual o resumo das leituras validas de turbidez da EST-01 em 01/07/2025?
print('Pipeline 1 - Resumo diario de turbidez');
printjson(db.medicoes.aggregate([
    { $match: {
        estacao_codigo: 'EST-01',
        coletado_em: { $gte: ISODate('2025-07-01T00:00:00Z'), $lt: ISODate('2025-07-02T00:00:00Z') }
    } },
    { $unwind: '$leituras' },
    { $match: { 'leituras.parametro_codigo': 'TURBIDEZ', 'leituras.valida': true } },
    { $group: {
        _id: {
            estacao: '$estacao_codigo', parametro: '$leituras.parametro_codigo', unidade: '$leituras.unidade',
            dia_utc: { $dateToString: { format: '%Y-%m-%d', date: '$coletado_em', timezone: 'UTC' } }
        },
        quantidade_validas: { $sum: 1 },
        soma: { $sum: '$leituras.valor' },
        minimo: { $min: '$leituras.valor' },
        maximo: { $max: '$leituras.valor' }
    } },
    { $project: {
        _id: 0, estacao: '$_id.estacao', parametro: '$_id.parametro', unidade: '$_id.unidade',
        dia_utc: '$_id.dia_utc', quantidade_validas: 1, soma: 1, minimo: 1, maximo: 1,
        media: { $round: [{ $divide: ['$soma', '$quantidade_validas'] }, 6] }
    } },
    { $sort: { estacao: 1, dia_utc: 1 } }
]).toArray());

// 2. Quais estacoes concentraram mais diagnosticos com bateria abaixo de 20% ou sinal inferior a -85 dBm na primeira semana de marco/2025?
print('Pipeline 2 - Priorizacao de verificacoes dos equipamentos');
printjson(db.telemetria.aggregate([
    { $match: {
        registrado_em: { $gte: ISODate('2025-03-01T00:00:00Z'), $lt: ISODate('2025-03-08T00:00:00Z') },
        $or: [
            { 'equipamento.bateria_pct': { $lt: 20 } },
            { 'equipamento.sinal_dbm': { $lt: -85 } }
        ]
    } },
    { $group: {
        _id: '$estacao_codigo',
        quantidade_diagnosticos: { $sum: 1 },
        sensores: { $addToSet: '$sensor_codigo' },
        menor_bateria_pct: { $min: '$equipamento.bateria_pct' },
        pior_sinal_dbm: { $min: '$equipamento.sinal_dbm' }
    } },
    { $project: {
        _id: 0, estacao: '$_id', quantidade_diagnosticos: 1,
        sensores_distintos: { $size: '$sensores' },
        sensores: 1, menor_bateria_pct: 1, pior_sinal_dbm: 1
    } },
    { $sort: { quantidade_diagnosticos: -1, estacao: 1 } }
]).toArray());
