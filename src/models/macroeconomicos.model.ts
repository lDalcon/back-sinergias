import dbConnection from "../config/database";
import mssql from "mssql";

export class MacroEconomicos {
    ano: number = 0;
    periodo: number = 0;
    fecha: Date = new Date('1900-01-01');
    tipo: string = '';
    valor: number = 0;
    unidad: string = '';

    constructor(macroeconomico?: any) {
        this.ano = macroeconomico?.ano || this.ano;
        this.periodo = macroeconomico?.periodo || this.periodo;
        this.fecha = macroeconomico?.fecha || this.fecha;
        this.tipo = macroeconomico?.tipo || this.tipo;
        this.valor = macroeconomico?.valor || this.valor;
        this.unidad = macroeconomico?.unidad || this.unidad;
    }

    async getByDateAndType(): Promise<{ ok: boolean, macroeconomicos?: MacroEconomicos, message?: any }> {
        let pool = await dbConnection();
        return new Promise((resolve) => {
            pool.request()
                .input('date', mssql.Date(), this.fecha)
                .input('type', mssql.VarChar(50), this.tipo)
                .execute('sc_getMacroeconomicosByDateAndType')
                .then(result => {
                    pool.close();
                    resolve({ ok: true, macroeconomicos: new MacroEconomicos(result.recordset[0]) });
                })
                .catch(err => {
                    pool.close();
                    console.log(err);
                    resolve({ ok: false, message: err })
                })
        });
    }

    async getByDateAndTypeTrx(transaction: mssql.Transaction): Promise<{ ok: boolean, macroeconomicos?: MacroEconomicos, message?: any }> {
        return new Promise((resolve) => {
            transaction.request()
                .input('date', mssql.Date(), this.fecha)
                .input('type', mssql.VarChar(50), this.tipo)
                .execute('sc_getMacroeconomicosByDateAndType')
                .then(result => {
                    resolve({ ok: true, macroeconomicos: new MacroEconomicos(result.recordset[0]) });
                })
                .catch(err => {
                    console.log(err);
                    resolve({ ok: false, message: err })
                })
        });
    }

    async getTasaUVR(fechaDesembolso: Date, fechaPeriodo: Date): Promise<number>{
        let pool = await dbConnection();
        return new Promise((resolve) => {
            pool.request()
                .input('fechaDesembolso', mssql.Date(), fechaDesembolso)
                .input('fechaPeriodo', mssql.Date(), fechaPeriodo)
                .output('tasa', mssql.Numeric(18,6))
                .execute('sc_getTasaUVR')
                .then(result => {
                    pool.close();
                    resolve(+result.output['tasa']);
                })
                .catch(err => {
                    pool.close();
                    console.log(err);
                    resolve(-1)
                })
        });
    }

    async getTasaUVRTrx(transaction: mssql.Transaction, fechaDesembolso: Date, fechaPeriodo: Date): Promise<number>{
        return new Promise((resolve) => {
            transaction.request()
                .input('fechaDesembolso', mssql.Date(), fechaDesembolso)
                .input('fechaPeriodo', mssql.Date(), fechaPeriodo)
                .output('tasa', mssql.Numeric(18,6))
                .execute('sc_getTasaUVR')
                .then(result => {
                    resolve(+result.output['tasa']);
                })
                .catch(err => {
                    console.log(err);
                    resolve(-1)
                })
        });
    }
}