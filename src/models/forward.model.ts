import mssql from 'mssql';
import dbConnection from "../database";
import { IForward } from '../interface/forward.interface';
import { Regional } from "./regional.model";
import { ValorCatalogo } from "./valor-catalogo.model";

export class Forward {
    id: number = 0;
    ano: number = 0;
    periodo: number = 0;
    fechaoperacion: Date = new Date('1900-01-01');
    fechacumplimiento: Date = new Date('1900-01-01');
    entfinanciera: ValorCatalogo = new ValorCatalogo();
    regional: Regional = new Regional();
    valorusd: number = 0;
    tasaspot: number = 0;
    devaluacion: number = 0;
    tasaforward: number = 0;
    valorcop: number = 0;
    saldoasignacion: number = 0;
    estado: string = ''
    usuariocrea: string = ''
    fechacrea: Date = new Date('1900-01-01');
    usuariomod: string = ''
    fechamod: Date = new Date('1900-01-01');

    constructor(forward?: any) {
        this.id = forward?.id || this.id;
        this.ano = forward?.ano || this.ano;
        this.periodo = forward?.periodo || this.periodo;
        this.fechaoperacion = forward?.fechaoperacion || this.fechaoperacion;
        this.fechacumplimiento = forward?.fechacumplimiento || this.fechacumplimiento;
        this.entfinanciera = new ValorCatalogo(forward?.entfinanciera) || this.entfinanciera;
        this.regional = new Regional(forward?.regional) || this.regional;
        this.valorusd = forward?.valorusd || this.valorusd;
        this.tasaspot = forward?.tasaspot || this.tasaspot;
        this.devaluacion = forward?.devaluacion || this.devaluacion;
        this.tasaforward = forward?.tasaforward || this.tasaforward;
        this.valorcop = forward?.valorcop || this.valorcop;
        this.saldoasignacion = forward?.saldoasignacion || this.saldoasignacion;
        this.estado = forward?.estado || this.estado;
        this.usuariocrea = forward?.usuariocrea || this.usuariocrea;
        this.fechacrea = forward?.fechacrea || this.fechacrea;
        this.usuariomod = forward?.usuariomod || this.usuariomod;
        this.fechamod = forward?.fechamod || this.fechamod;
    }

    async guardar(transaction?: mssql.Transaction) {
        let isTrx: boolean = true;
        let pool = await dbConnection();
        if (!transaction) {
            transaction = new mssql.Transaction(pool);
            isTrx = false;
        }
        try {
            if (!isTrx) await transaction.begin();
            await new mssql.Request(transaction)
                .input('fechaoperacion', mssql.Date(), this.fechaoperacion)
                .input('fechacumplimiento', mssql.Date(), this.fechacumplimiento)
                .input('entfinanciera', mssql.Int(), this.entfinanciera.id)
                .input('regional', mssql.Int(), this.regional.id)
                .input('valorusd', mssql.Numeric(18, 2), this.valorusd)
                .input('tasaspot', mssql.Numeric(18, 2), this.tasaspot)
                .input('devaluacion', mssql.Numeric(6, 5), this.devaluacion)
                .input('tasaforward', mssql.Numeric(18, 2), this.tasaforward)
                .input('valorcop', mssql.Numeric(18, 2), this.valorcop)
                .input('saldoasignacion', mssql.Numeric(18, 0), this.saldoasignacion)
                .input('estado', mssql.VarChar(20), this.estado)
                .input('usuariocrea', mssql.VarChar(50), this.usuariocrea)
                .execute('sc_forward_guardar')
            if (!isTrx) {
                transaction.commit();
                pool.close();
            }
            return { ok: true, message: 'Forward creado' }
        } catch (error) {
            console.log(error)
            if (!isTrx) {
                await transaction.rollback();
                pool.close();
            }
            return { ok: false, message: error }
        }
    }

    async listar(): Promise<{ ok: boolean, data?: IForward[], message?: string }> {
        let pool = await dbConnection();
        return new Promise((resolve, reject) => {
            pool.request()
                .execute('sc_forward_listar')
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