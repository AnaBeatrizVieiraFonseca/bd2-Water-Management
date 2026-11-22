db = db.getSiblingDB('recursos_hidricos');

// 1. Marcar os diagnósticos de demonstração com bateria abaixo de 20% para inspeção.
printjson(db.telemetria.updateMany(
    { 'origem.canal': 'DEMONSTRACAO_INSERCAO', 'equipamento.bateria_pct': { $lt: 20 } },
    { $set: {
        'analise.situacao': 'INSPECAO_SOLICITADA',
        'analise.motivo': 'Bateria abaixo de 20% no diagnóstico.'
    } }
));

// 2. Acrescentar uma observação ao diagnóstico específico do sensor de temperatura.
printjson(db.telemetria.updateOne(
    {
        'origem.canal': 'DEMONSTRACAO_INSERCAO',
        sensor_codigo: 'EST-02-TEMP',
        registrado_em: ISODate('2025-01-15T15:00:00.000Z')
    },
    { $set: { 'analise.observacao': 'Verificar alimentação na próxima visita técnica.' } }
));

// 3. Classificar os exemplos com sinal inferior a -85 dBm para verificacao de comunicacao.
printjson(db.telemetria.updateMany(
    { 'origem.canal': 'DEMONSTRACAO_INSERCAO', 'equipamento.sinal_dbm': { $lt: -85 } },
    { $set: { 'analise.comunicacao': 'VERIFICAR_SINAL' } }
));

// 4. Priorizar a inspecao do equipamento com bateria abaixo de 10%.
printjson(db.telemetria.updateOne(
    { 'origem.canal': 'DEMONSTRACAO_INSERCAO', sensor_codigo: 'EST-09-OXIG',
      'equipamento.bateria_pct': { $lt: 10 } },
    { $set: { 'analise.prioridade': 'ALTA', 'analise.observacao': 'Verificar bateria e comunicacao com prioridade.' } }
));

// 5. Classificar os exemplos com bateria e sinal adequados aos criterios desta demonstracao.
printjson(db.telemetria.updateMany(
    { 'origem.canal': 'DEMONSTRACAO_INSERCAO',
      'equipamento.bateria_pct': { $gte: 50 }, 'equipamento.sinal_dbm': { $gte: -80 } },
    { $set: { 'analise.situacao': 'SEM_INTERVENCAO_NESTA_TRIAGEM' } }
));

// 6. Consultar os diagnósticos classificados, preservando os valores originalmente registrados.
printjson(db.telemetria.find(
    { 'origem.canal': 'DEMONSTRACAO_INSERCAO', 'analise.situacao': 'INSPECAO_SOLICITADA' },
    { _id: 0, sensor_codigo: 1, equipamento: 1, analise: 1 }
).sort({ 'equipamento.bateria_pct': 1 }).toArray());

// 7. Remover somente o diagnóstico de ensaio da EST-20, após sua conferência.
printjson(db.telemetria.deleteOne({
    'origem.canal': 'DEMONSTRACAO_INSERCAO',
    sensor_codigo: 'EST-20-NIV',
    registrado_em: ISODate('2025-01-15T15:00:00.000Z')
}));

// 8. Remover dois exemplos de ensaios concluidos usando deleteMany e um filtro restrito.
printjson(db.telemetria.deleteMany({
    'origem.canal': 'DEMONSTRACAO_INSERCAO',
    sensor_codigo: { $in: ['EST-18-PH', 'EST-19-OXIG'] },
    registrado_em: ISODate('2025-01-15T15:00:00.000Z')
}));
