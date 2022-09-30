import mssql from 'mssql';
import dbConnection from "../config/database";

export class CalendarioCierre {
    ano: number = 0;
    periodo: number = 0;
    mes: string = '';
    fechainicial: Date = new Date('1900-01-01');
    fechafinal: Date = new Date('1900-01-01');
    proceso: boolean = false;
    registro: boolean = false;

    constructor(calendarioCierre?:any){
        this.ano = calendarioCierre?.ano || this.ano;
        this.periodo = calendarioCierre?.periodo || this.periodo;
        this.mes = calendarioCierre?.mes || this.mes;
        this.fechainicial = calendarioCierre?.fechainicial || this.fechainicial;
        this.fechafinal = calendarioCierre?.fechafinal || this.fechafinal;
        this.proceso = calendarioCierre?.proceso || this.proceso;
        this.registro = calendarioCierre?.registro || this.registro;
    }

    async actualizar(): Promise<{ ok: boolean, message?: any }> {
        let pool = await dbConnection();
        return new Promise((resolve, reject) => {
            pool.request()
                .input('ano', mssql.Int(), this.ano)
                .input('periodo', mssql.Int(), this.periodo)
                .input('proceso', mssql.Bit(), this.proceso)
                .input('registro', mssql.Bit(), this.registro)
                .execute('sc_calendario_actualizar')
                .then(result => {
                    console.log(result)
                    pool.close();
                    resolve({ ok: true, message: 'Registro actualizado' })                    
                })
                .catch(err => {
                    pool.close();
                    console.log(err);
                    resolve({ ok: false, message: err })
                })
        });
    }

    async get(transaction?: mssql.Transaction): Promise<{ ok: boolean, calendario?: CalendarioCierre, message?: any }> {
        let isTrx: boolean = true;
        let pool = await dbConnection();
        if (!transaction) {
            transaction = new mssql.Transaction(pool);
            isTrx = false;
        }
        try {
            if (!isTrx) await transaction.begin();
            let result = await new mssql.Request(transaction)
                .input('ano', mssql.Int(), this.ano)
                .input('periodo', mssql.Int(), this.periodo)
                .execute('sc_calendario_obtener')
            if (!isTrx) {
                transaction.commit();
                pool.close();
            }
            return { ok: true, calendario: result.recordset[0][0] }
        } catch (error) {
            console.log(error)
            if (!isTrx) {
                await transaction.rollback();
                pool.close();
            }
            return { ok: false, message: error }
        }
    }

    async obtenerActivos(trx: string) :Promise<{ ok: boolean, data?: CalendarioCierre[], message?: any }>{
        let pool = await dbConnection();
        return new Promise((resolve, reject) => {
            pool.request()
                .input('trx', mssql.VarChar(10), trx)
                .execute('sc_calendario_obtenerActivos')
                .then(result => {
                    pool.close();
                    resolve({ ok: true, data: result.recordset[0] })                    
                })
                .catch(err => {
                    pool.close();
                    console.log(err);
                    resolve({ ok: false, message: err })
                })
        });
    }
}