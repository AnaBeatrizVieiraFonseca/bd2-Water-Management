// Executar no mongosh apos a insercao manual pelo Compass.
db = db.getSiblingDB('recursos_hidricos');

{
    // 1. Registrar um diagnostico com insertOne, preservando o exemplo se ja existir.
    const individual = {
        estacao_codigo: 'EST-02', sensor_codigo: 'EST-02-TEMP',
        registrado_em: ISODate('2025-01-15T15:00:00.000Z'),
        equipamento: { bateria_pct: 16, sinal_dbm: -88 },
        origem: { canal: 'DEMONSTRACAO_INSERCAO' }
    };
    if (!db.telemetria.findOne({ sensor_codigo: individual.sensor_codigo,
        registrado_em: individual.registrado_em, 'origem.canal': 'DEMONSTRACAO_INSERCAO' })) {
        db.telemetria.insertOne(individual);
    }

    // 2. Preparar 18 diagnosticos de equipamentos em estacoes distintas.
    const diagnosticos = [
        { estacao_codigo: 'EST-03', sensor_codigo: 'EST-03-OXIG', equipamento: { bateria_pct: 45, sinal_dbm: -75 } },
        { estacao_codigo: 'EST-04', sensor_codigo: 'EST-04-PH', equipamento: { bateria_pct: 12, sinal_dbm: -92 } },
        { estacao_codigo: 'EST-05', sensor_codigo: 'EST-05-NIV', equipamento: { bateria_pct: 76, sinal_dbm: -62 } },
        { estacao_codigo: 'EST-06', sensor_codigo: 'EST-06-TURB', equipamento: { bateria_pct: 52, sinal_dbm: -81 } },
        { estacao_codigo: 'EST-07', sensor_codigo: 'EST-07-TEMP', equipamento: { bateria_pct: 18, sinal_dbm: -89 } },
        { estacao_codigo: 'EST-08', sensor_codigo: 'EST-08-PH', equipamento: { bateria_pct: 92, sinal_dbm: -58 } },
        { estacao_codigo: 'EST-09', sensor_codigo: 'EST-09-OXIG', equipamento: { bateria_pct: 9, sinal_dbm: -94 } },
        { estacao_codigo: 'EST-10', sensor_codigo: 'EST-10-NIV', equipamento: { bateria_pct: 44, sinal_dbm: -77 } },
        { estacao_codigo: 'EST-11', sensor_codigo: 'EST-11-TURB', equipamento: { bateria_pct: 61, sinal_dbm: -71 } },
        { estacao_codigo: 'EST-12', sensor_codigo: 'EST-12-TEMP', equipamento: { bateria_pct: 27, sinal_dbm: -86 } },
        { estacao_codigo: 'EST-13', sensor_codigo: 'EST-13-PH', equipamento: { bateria_pct: 83, sinal_dbm: -64 } },
        { estacao_codigo: 'EST-14', sensor_codigo: 'EST-14-OXIG', equipamento: { bateria_pct: 35, sinal_dbm: -83 } },
        { estacao_codigo: 'EST-15', sensor_codigo: 'EST-15-NIV', equipamento: { bateria_pct: 14, sinal_dbm: -91 } },
        { estacao_codigo: 'EST-16', sensor_codigo: 'EST-16-TURB', equipamento: { bateria_pct: 70, sinal_dbm: -68 } },
        { estacao_codigo: 'EST-17', sensor_codigo: 'EST-17-TEMP', equipamento: { bateria_pct: 56, sinal_dbm: -74 } },
        { estacao_codigo: 'EST-18', sensor_codigo: 'EST-18-PH', equipamento: { bateria_pct: 22, sinal_dbm: -87 } },
        { estacao_codigo: 'EST-19', sensor_codigo: 'EST-19-OXIG', equipamento: { bateria_pct: 95, sinal_dbm: -55 } },
        { estacao_codigo: 'EST-20', sensor_codigo: 'EST-20-NIV', equipamento: { bateria_pct: 39, sinal_dbm: -79 } }
    ];
    const novos = [];

    // 3. Completar os campos comuns e selecionar somente exemplos ainda nao cadastrados.
    for (const diagnostico of diagnosticos) {
        diagnostico.registrado_em = ISODate('2025-01-15T15:00:00.000Z');
        diagnostico.origem = { canal: 'DEMONSTRACAO_INSERCAO' };
        if (!db.telemetria.findOne({ sensor_codigo: diagnostico.sensor_codigo,
            registrado_em: diagnostico.registrado_em, 'origem.canal': 'DEMONSTRACAO_INSERCAO' })) {
            novos.push(diagnostico);
        }
    }

    // 4. Inserir os diagnosticos selecionados com insertMany().
    if (novos.length > 0) {
        db.telemetria.insertMany(novos);
    }
}

// 5. Conferir os 20 exemplos: um manual, um insertOne e 18 insertMany.
printjson(db.telemetria.find(
    { 'origem.canal': 'DEMONSTRACAO_INSERCAO' },
    { _id: 0, estacao_codigo: 1, sensor_codigo: 1, registrado_em: 1, equipamento: 1 }
).sort({ estacao_codigo: 1 }).toArray());

printjson({
    registros_demonstrativos: db.telemetria.countDocuments({ 'origem.canal': 'DEMONSTRACAO_INSERCAO' }),
    total_telemetria: db.telemetria.countDocuments({})
});
