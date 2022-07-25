import mssql from 'mssql';
import dbConnection from '../database';

export class Reporte {


    constructor() {

    }

    async reporteConsolidado(ano: any, periodo: any, nick: string): Promise<{ ok: boolean, data?: any[], message?: any }> {
        let pool = await dbConnection();
        return new Promise((resolve, reject) => {
            pool.request()
                .input('ano', mssql.Int(), ano)
                .input('periodo', mssql.Int(), periodo)
                .input('nick', mssql.VarChar(50), nick)
                .execute('sc_reporte_consolidado')
                .then(result => {
                    pool.close();
                    resolve({ ok: true, data: result.recordset })
                })
                .catch(err => {
                    console.log(err);
                    pool.close();
                    resolve({ ok: false, message: err })
                })
        });
    }

}