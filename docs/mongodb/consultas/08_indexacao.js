db = db.getSiblingDB('recursos_hidricos');

// Consultar as coletas de uma estacao em um dia, em ordem de horario.
{
    const filtro = {
        estacao_codigo: 'EST-01',
        coletado_em: {
            $gte: ISODate('2025-01-15T00:00:00Z'),
            $lt: ISODate('2025-01-16T00:00:00Z')
        }
    };
    const campos = { _id: 0, mensagem_codigo: 1, coletado_em: 1, recebido_em: 1 };
    const nomeIndice = 'ix_medicoes_estacao_data';
    const existente = db.medicoes.getIndexes().some(indice => indice.name === nomeIndice);

    // 1. Guardar a medicao anterior somente quando o indice ainda nao existe.
    if (!existente) {
        const antes = db.medicoes.find(filtro, campos)
            .sort({ coletado_em: 1 }).explain('executionStats');
        print('ANTES de criar o indice');
        printjson({
            documentos_retornados: antes.executionStats.nReturned,
            documentos_examinados: antes.executionStats.totalDocsExamined,
            chaves_examinadas: antes.executionStats.totalKeysExamined,
            tempo_ms: antes.executionStats.executionTimeMillis
        });
        printjson(antes.queryPlanner.winningPlan);

        // 2. Indexar igualdade por estacao, seguida do intervalo e ordenacao por data.
        db.medicoes.createIndex(
            { estacao_codigo: 1, coletado_em: 1 },
            { name: nomeIndice }
        );
    } else {
        print('O indice ja existe. Esta execucao nao representa uma medicao anterior a sua criacao.');
    }

    // 3. Repetir exatamente a mesma consulta e comparar os documentos examinados.
    const depois = db.medicoes.find(filtro, campos)
        .sort({ coletado_em: 1 }).explain('executionStats');
    print('COM o indice disponivel');
    printjson({
        documentos_retornados: depois.executionStats.nReturned,
        documentos_examinados: depois.executionStats.totalDocsExamined,
        chaves_examinadas: depois.executionStats.totalKeysExamined,
        tempo_ms: depois.executionStats.executionTimeMillis
    });
    printjson(depois.queryPlanner.winningPlan);
}
