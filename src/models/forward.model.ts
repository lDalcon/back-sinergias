import mssql from 'mssql';
import dbConnection from "../config/database";
import { IForward } from '../interface/forward.interface';
import { CalendarioCierre } from './calendario-cierre.model';
import { CierreForward } from './cierre-forward.model';
import { DetalleForward } from './detalle-forward.model';
import { ForwardSaldos } from './forward-saldos.model';
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
    saldo: number = 0;
    creditos: any[] = [];
    estado: string = ''
    usuariocrea: string = ''
    fechacrea: Date = new Date('1900-01-01');
    usuariomod: string = ''
    fechamod: Date = new Date('1900-01-01');
    observaciones: string = '';
    dias: number = 0;

    constructor(forward?: any) {
        this.id = forward?.id || this.id;
        this.ano = forward?.ano || this.ano;
        this.periodo = forward?.periodo || this.periodo;
        this.fechaoperacion = new Date(forward?.fechaoperacion) || this.fechaoperacion;
        this.fechacumplimiento = new Date(forward?.fechacumplimiento) || this.fechacumplimiento;
        this.entfinanciera = new ValorCatalogo(forward?.entfinanciera) || this.entfinanciera;
        this.regional = new Regional(forward?.regional) || this.regional;
        this.valorusd = forward?.valorusd || this.valorusd;
        this.tasaspot = forward?.tasaspot || this.tasaspot;
        this.devaluacion = forward?.devaluacion || this.devaluacion;
        this.tasaforward = forward?.tasaforward || this.tasaforward;
        this.valorcop = forward?.valorcop || this.valorcop;
        this.saldoasignacion = forward?.saldoasignacion || this.saldoasignacion;
        this.saldo = forward?.saldo || this.saldo;
        this.creditos = forward?.creditos || this.creditos;
        this.estado = forward?.estado || this.estado;
        this.usuariocrea = forward?.usuariocrea || this.usuariocrea;
        this.fechacrea = forward?.fechacrea || this.fechacrea;
        this.usuariomod = forward?.usuariomod || this.usuariomod;
        this.fechamod = forward?.fechamod || this.fechamod;
        this.observaciones = forward?.observaciones || this.observaciones;
        this.dias = forward?.dias || this.dias;
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
            let calendario: CalendarioCierre = new CalendarioCierre({ ano: this.fechaoperacion.getFullYear(), periodo: this.fechaoperacion.getMonth() + 1 });
            calendario = (await calendario.get(transaction))?.calendario || new CalendarioCierre();
            if (!calendario.registro) throw new Error('El mes se encuentra cerrado para registros.');
            console.log(this)
            await new mssql.Request(transaction)
                .input('fechaoperacion', mssql.Date(), this.fechaoperacion)
                .input('fechacumplimiento', mssql.Date(), this.fechacumplimiento)
                .input('entfinanciera', mssql.Int(), this.entfinanciera.id)
                .input('regional', mssql.Int(), this.regional.id)
                .input('valorusd', mssql.Numeric(18, 2), this.valorusd)
                .input('tasaspot', mssql.Numeric(18, 2), this.tasaspot)
                .input('devaluacion', mssql.Numeric(8, 5), this.devaluacion)
                .input('tasaforward', mssql.Numeric(18, 2), this.tasaforward)
                .input('valorcop', mssql.Numeric(18, 2), this.valorcop)
                .input('estado', mssql.VarChar(20), this.estado)
                .input('usuariocrea', mssql.VarChar(50), this.usuariocrea)
                .input('observaciones', mssql.NVarChar(mssql.MAX), this.observaciones)
                .execute('sc_forward_guardar')
            if (!isTrx) {
                await transaction.commit();
            }
            pool.close();
            return { ok: true, message: 'Forward creado' }
        } catch (error) {
            console.log(error)
            if (!isTrx) {
                await transaction.rollback();
            }
            pool.close();
            return { ok: false, message: error?.['message'] }
        }
    }

    async actualizar(transaction?: mssql.Transaction, validarPeriodo: boolean = true) {
        let isTrx: boolean = true;
        let pool = await dbConnection();
        if (!transaction) {
            transaction = new mssql.Transaction(pool);
            isTrx = false;
        }
        try {
            if (!isTrx) await transaction.begin();
            if(validarPeriodo){
                let calendario: CalendarioCierre = new CalendarioCierre({ ano: this.fechaoperacion.getFullYear(), periodo: this.fechaoperacion.getMonth() + 1 });
                calendario = (await calendario.get(transaction))?.calendario || new CalendarioCierre();
                if (!calendario.registro) throw new Error('El mes se encuentra cerrado para registros.');
            }
            await new mssql.Request(transaction)
                .input('id', mssql.Int(), this.id)
                .input('fechaoperacion', mssql.Date(), this.fechaoperacion)
                .input('fechacumplimiento', mssql.Date(), this.fechacumplimiento)
                .input('entfinanciera', mssql.Int(), this.entfinanciera.id)
                .input('regional', mssql.Int(), this.regional.id)
                .input('valorusd', mssql.Numeric(18, 2), this.valorusd)
                .input('tasaspot', mssql.Numeric(18, 2), this.tasaspot)
                .input('devaluacion', mssql.Numeric(8, 5), this.devaluacion)
                .input('tasaforward', mssql.Numeric(18, 2), this.tasaforward)
                .input('valorcop', mssql.Numeric(18, 2), this.valorcop)
                .input('estado', mssql.VarChar(20), this.estado)
                .input('usuariomod', mssql.VarChar(50), this.usuariomod)
                .input('observaciones', mssql.NVarChar(mssql.MAX), this.observaciones)
                .execute('sc_forward_actualizar')
            if (!isTrx) {
                await transaction.commit();
            }
            pool.close();
            return { ok: true, message: 'Forward Actualizado' }
        } catch (error) {
            console.log(error)
            if (!isTrx) {
                await transaction.rollback();
            }
            pool.close();
            return { ok: false, message: error?.['message'] }
        }
    }

    async procesarCierre(cierreForward: CierreForward) {
        let pool = await dbConnection();
        let transaction = new mssql.Transaction(pool);
        try {
            await transaction.begin();
            let isOpen: boolean = await new CalendarioCierre().validar(transaction, cierreForward.ano, cierreForward.periodo, 'registro')
            if (!isOpen) throw new Error('El periodo se encuentra cerrado para registros');
            let forward = (await this.obtenerTrx(transaction, cierreForward.id)).data || new Forward();
            let error = this.validarCierre(forward);
            if(error.length > 0) throw new Error(`${error.join('. ')}`);
            await cierreForward.guardar(transaction);
            forward.saldo = 0;
            forward.estado = 'CERRADO';
            let result = await forward.actualizar(transaction, false);
            if (!result.ok) throw new Error(result.message);
            result = await new ForwardSaldos().actualizarByAnoAndPeriodo(transaction, cierreForward.ano, cierreForward.periodo, cierreForward.id);
            if (!result.ok) throw new Error(result.message);
            await transaction.commit();
            await pool.close();
            return {ok: true, message: 'Forward cerrado correctamente!'}
        } catch (error) {
            await transaction.rollback();
            await pool.close();
            return {ok: false, message: error}
        }
    }

    async listar(filtro?: any): Promise<{ ok: boolean, data?: IForward[], message?: string }> {
        let pool = await dbConnection();
        return new Promise((resolve) => {
            pool.request()
                .input('nick', mssql.VarChar(50), this.usuariocrea)
                .input('saldo', mssql.Numeric(18,2), filtro?.saldo || -1)
                .input('saldoasignacion', mssql.Numeric(18,2), filtro?.saldoasignacion || -1)
                .input('regional', mssql.Int(), filtro?.regional || null)
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

    async obtener(): Promise<{ ok: boolean, data?: Forward, message?: string }> {
        let pool = await dbConnection();
        return new Promise((resolve) => {
            pool.request()
                .input('id', mssql.Int(), this.id)
                .execute('sc_forward_obtener')
                .then(result => {
                    pool.close();
                    resolve({ ok: true, data: new Forward(result.recordset[0][0]) })
                })
                .catch(err => {
                    console.log(err);
                    pool.close();
                    resolve({ ok: false, message: err })
                })
        });
    }

    async obtenerTrx(transaction: mssql.Transaction, id?: number): Promise<{ ok: boolean, data?: Forward, message?: string }> {
        return new Promise((resolve) => {
            transaction.request()
                .input('id', mssql.Int(), id || this.id)
                .execute('sc_forward_obtener')
                .then(result => {
                    resolve({ ok: true, data: new Forward(result.recordset[0][0]) })
                })
                .catch(err => {
                    console.log(err);
                    resolve({ ok: false, message: err })
                })
        });
    }

    async actualizarSaldoAsignacion(valorAsignado: number, transaction: mssql.Transaction) {
        try {
            await transaction.request()
                .input('id', mssql.Int(), this.id)
                .input('valorasignado', mssql.Numeric(18, 2), valorAsignado)
                .execute('sc_forward_actualizarsaldoasginacion')
        } catch (error) {
            console.log(error);
            throw new Error('Error al actualizar el saldo del crédito');
        }
    }

    async actualizarSaldo(detalleForward: DetalleForward, transaction: mssql.Transaction) {
        try {
            await transaction.request()
                .input('id', mssql.Int(), detalleForward.idforward)
                .input('seq', mssql.Int(), detalleForward.seqpago)
                .input('valorpago', mssql.Numeric(18, 2), detalleForward.valor)
                .input('nick', mssql.VarChar(50), detalleForward.usuariocrea)
                .execute('sc_forward_actualizarsaldo')
        } catch (error) {
            console.log(error);
            throw new Error('Error al actualizar el saldo del crédito');
        }
    }

    private validarCierre(forward: Forward): string[] {
        let error: string[] = [];
        if (forward.id == 0) error.push('Forward no encontrado');
        forward?.creditos.forEach(credito => {
            if (credito.saldoasignacion != 0) error.push(`El forward tiene un saldo ($${credito.saldoasignacion}) asociado al crédito ${credito.id}`);
        })
        return error;
    }
}