import mssql from 'mssql';
import dbConnection from '../config/database';
import { CalendarioCierre } from './calendario-cierre.model';

export class Reporte {

    constructor() { }

    async reporteConsolidado(ano: any, periodo: any, nick: string): Promise<{ ok: boolean, data?: any[], message?: any }> {
        let pool = await dbConnection();
        return new Promise((resolve) => {
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

    async obtenerDiferenciaCambio(parametros: Parametros): Promise<{ ok: boolean, data?: any, message?: any }> {
        let pool = await dbConnection();
        return new Promise((resolve) => {
            pool.request()
                .input('ano', mssql.Int(), parametros.fecha.getFullYear())
                .input('periodo', mssql.Int(), parametros.fecha.getMonth() + 1)
                .input('nick', mssql.VarChar(50), parametros?.nick || null)
                .input('nit', mssql.VarChar(15), parametros?.nit || null)
                .execute('sc_dc_obtener')
                .then(result => {
                    pool.close();
                    resolve({ ok: true, data: result.recordset[0] })
                })
                .catch(err => {
                    console.log(err);
                    pool.close();
                    resolve({ ok: false, message: err })
                })
        });
    }

    async diferenciaCambio(parametros: Parametros): Promise<{ ok: boolean, data?: any, message?: any }> {
        let pool = await dbConnection();
        let response: any;
        let message: string = 'Proceso exitoso!'
        let transaction = new mssql.Transaction(pool);
        parametros.fecha = new Date(parametros.fecha);
        try {
            await transaction.begin();
            let calendario: CalendarioCierre = new CalendarioCierre({ ano: parametros.fecha.getFullYear(), periodo: parametros.fecha.getMonth() + 1 });
            calendario = (await calendario.get(transaction))?.calendario || new CalendarioCierre();
            if (calendario.proceso) await this.procesarDiferenciaCambio(parametros, transaction);
            else message = 'El mes se encuetra cerrado para procesos, el reporte mostrado es histórico.';
            await transaction.commit();
            await pool.close();
            response = await this.obtenerDiferenciaCambio(parametros)
            response.message = message;
        } catch (error) {
            console.log(error);
            await transaction.rollback();
            await pool.close();
            response = { ok: false, message: error }
        }
        return response;
    }

    async procesarDiferenciaCambio(parametros: Parametros, transaction: mssql.Transaction) {
        await transaction.request()
            .input('fecha', mssql.Date(), parametros.fecha)
            .input('nick', mssql.VarChar(50), parametros?.nick || null)
            .input('nit', mssql.VarChar(15), parametros?.nit || null)
            .execute('sc_dc_consolidado')
        
    }
}

interface Parametros { fecha: Date, nick?: string, nit?: string }