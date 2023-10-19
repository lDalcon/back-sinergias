import mssql from 'mssql';
import dbConnection from '../config/database';

export class SaldosDiario {
    seq: number = 0;
    idcuenta: number = 0;
    fecha: Date = new Date('1900-01-01');
    valor: number = 0;
    usuariocrea: string = '';
    fechacrea: Date = new Date('1900-01-01');
    usuariomod: string = '';
    fechamod: Date = new Date('1900-01-01');

    constructor(saldosdiario?: any) {
        this.seq = saldosdiario?.seq || this.seq;
        this.idcuenta = saldosdiario?.idcuenta || this.idcuenta;
        this.fecha = saldosdiario?.fecha || this.fecha;
        this.valor = saldosdiario?.valor || this.valor;
        this.usuariocrea = saldosdiario?.usuariocrea || this.usuariocrea;
        this.fechacrea = saldosdiario?.fechacrea || this.fechacrea;
        this.usuariomod = saldosdiario?.usuariomod || this.usuariomod;
        this.fechamod = saldosdiario?.fechamod || this.fechamod;
    }

    async guardar(transaction?: mssql.Transaction): Promise<{ ok: boolean, message?: string }> {
        let isTrx: boolean = true;
        let pool = await dbConnection();
        if (!transaction) {
            transaction = new mssql.Transaction(pool);
            isTrx = false;
        }
        try {
            if (!isTrx) await transaction.begin()
            await new mssql.Request(transaction)
                .input('idcuenta', mssql.Int(), this.idcuenta)
                .input('fecha', mssql.Date(), this.fecha)
                .input('valor', mssql.Numeric(28,2), this.valor)
                .input('nick', mssql.VarChar(50), this.usuariocrea)
                .execute('sc_saldosdiario_crear_actualizar')
            if (!isTrx) transaction.commit();
            pool.close();
            return { ok: true, message: 'Registro procesado' }
        } catch (error) {
            console.log(error)
            if (!isTrx) await transaction.rollback();
            pool.close();
            return { ok: false, message: error?.['message'] }
        }
    }

    async listar(params: any): Promise<{ ok: boolean, data?: any[], message?: string }> {
        let pool = await dbConnection();
        return new Promise((resolve) => {
            pool.request()
                .input('fechainicial', mssql.Date(), params.fechainicial)
                .input('fechafinal', mssql.Date(), params.fechafinal)
                .input('regional', mssql.VarChar(20), params.regional)
                .execute('sc_saldosdiario_listar')
                .then(result => {
                    pool.close();
                    if(!result.recordset[0]) resolve({ok: false, message: 'No existen cuentas por diligenciar.'});
                    resolve({ ok: true, data: result.recordset[0] })
                })
                .catch(err => {
                    console.log(err);
                    pool.close();
                    resolve({ ok: false, message: err })
                })
        });
    }

    async listarDia(params: any): Promise<{ ok: boolean, data?: any[], message?: string }> {
        let pool = await dbConnection();
        return new Promise((resolve) => {
            pool.request()
                .input('fecha', mssql.Date(), params.fecha)
                .input('regional', mssql.VarChar(20), params.regional)
                .execute('sc_saldosdiario_listardia')
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

    async procesar(saldosdiario: SaldosDiario[], nick: string): Promise<{ ok: boolean, message?: any }> {
        let pool = await dbConnection();
        let transaction = new mssql.Transaction(pool);
        try {
            await transaction.begin();
            for (let i = 0; i < saldosdiario.length; i++) {
                saldosdiario[i].usuariocrea = nick;
                let saldo = new SaldosDiario(saldosdiario[i])
                let res = await saldo.guardar(transaction);
                if (!res.ok) throw new Error('Error al procesar saldo');
            }
            await transaction.commit();
            pool.close()
            return { ok: true, message: 'Proceso exitoso.' }
        } catch (error) {
            await transaction.rollback();
            pool.close()
            return { ok: false, message: error }
        }
    }

    async borrarDia( params: any): Promise<{ ok: boolean, message?: any }>{
        let pool = await dbConnection();
        return new Promise((resolve) => {
            pool.request()
                .input('fecha', mssql.Date(), params.fecha)
                .input('regional', mssql.Int(), params.regional)
                .execute('sc_saldos_diario_borrar')
                .then(() => {
                    pool.close();
                    resolve({ ok: true, message: 'Datos borrados correctamente.' })
                })
                .catch(err => {
                    console.log(err);
                    pool.close();
                    resolve({ ok: false, message: err })
                })
        });
    }
}