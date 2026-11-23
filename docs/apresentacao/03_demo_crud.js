// Cole no mongosh do Compass. Não altera a base recursos_hidricos.
// O identificador de execução limita atualização/exclusão aos documentos deste ensaio.
{
    const origem = db.getSiblingDB('recursos_hidricos');
    const ensaio = db.getSiblingDB('recursos_hidricos_apresentacao');
    if (!ensaio.getCollectionNames().includes('telemetria_ensaio')) {
        const modelo = origem.getCollectionInfos({ name: 'telemetria' })[0];
        if (!modelo) throw new Error('Carregue a base original antes do ensaio.');
        ensaio.createCollection('telemetria_ensaio', {
            validator: modelo.options.validator,
            validationLevel: 'strict', validationAction: 'error'
        });
    }
    const colecao = ensaio.telemetria_ensaio;
    const execucao = new ObjectId().toString();
    const criar = (sensor, bateria) => ({
        estacao_codigo: 'EST-01', sensor_codigo: sensor,
        registrado_em: ISODate('2025-07-01T07:00:00Z'),
        equipamento: { bateria_pct: bateria, sinal_dbm: -90 },
        origem: { canal: 'ENSAIO_APRESENTACAO', execucao: execucao }
    });
    print('1. insertOne: um diagnóstico');
    colecao.insertOne(criar('DEMO-TURB', 15));
    print('2. insertMany: dois diagnósticos');
    colecao.insertMany([criar('DEMO-PH', 80), criar('DEMO-NIV', 10)]);
    const filtro = { 'origem.execucao': execucao };
    printjson(colecao.find(filtro).toArray());
    print('3. updateMany + $set: classificar bateria baixa');
    printjson(colecao.updateMany({ ...filtro, 'equipamento.bateria_pct': { $lt: 20 } },
        { $set: { 'analise.situacao': 'INSPECAO_SOLICITADA' } }));
    printjson(colecao.find(filtro, { _id: 0, sensor_codigo: 1, equipamento: 1, analise: 1 }).toArray());
    print('4. deleteOne: remover somente o diagnóstico DEMO-TURB deste ensaio');
    printjson(colecao.deleteOne({ ...filtro, sensor_codigo: 'DEMO-TURB' }));
    print('5. deleteMany: retirar os dois documentos restantes desta execução');
    printjson(colecao.deleteMany(filtro));
    printjson({ documentos_desta_execucao_restantes: colecao.countDocuments(filtro) });
}
