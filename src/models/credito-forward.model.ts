import mssql from 'mssql';
import dbConnection from '../database';
import { Credito } from './credito.model';
import { Forward } from './forward.model';

export class CreditoForward {
    seq: number = 0;
    ano: number = 0;
    periodo: number = 0;
    idcredito: number = 0;
    credito: Credito = new Credito();
    idforward: number = 0;
    forward: Forward = new Forward();
    valorasignado: number = 0;
    estado: string = ''
    justificacion: string = ''
    usuariocrea: string = ''
    fechacrea: Date = new Date('1900-01-01')
    usuariomod: string = ''
    fechamod: Date = new Date('1900-01-01')

    constructor(creditoforward?: any) {
        this.seq = creditoforward?.seq || this.seq;
        this.ano = creditoforward?.ano || this.ano;
        this.periodo = creditoforward?.periodo || this.periodo;
        this.idcredito = creditoforward?.idcredito || this.idcredito;
        this.credito = new Credito(creditoforward?.credito) || this.credito;
        this.idforward = creditoforward?.idforward || this.idforward;
        this.forward = new Forward(creditoforward?.forward) || this.forward;
        this.valorasignado = creditoforward?.valorasignado || this.valorasignado;
        this.estado = creditoforward?.estado || this.estado;
        this.justificacion = creditoforward?.justificacion || this.justificacion;
        this.usuariocrea = creditoforward?.usuariocrea || this.usuariocrea;
        this.fechacrea = new Date(creditoforward?.fechacrea) || this.fechacrea;
        this.usuariomod = creditoforward?.usuariomod || this.usuariomod;
        this.fechamod = new Date(creditoforward?.fechamod) || this.fechamod;
    }

    async guardar(transaction: mssql.Transaction): Promise<{ ok: boolean, message: string }> {
        return new Promise((resolve, reject) => {
            transaction.request()
                .input('idcredito', mssql.Int(), this.idcredito)
                .input('idforward', mssql.Int(), this.idforward)
                .input('valorasignado', mssql.Numeric(18, 2), this.valorasignado)
                .input('usuariocrea', mssql.VarChar(50), this.usuariocrea)
                .input('estado', mssql.VarChar(50), null)
                .execute('sc_creditoforward_crear')
                .then(result => {
                    console.log(result.recordset)
                    resolve({ ok: true, message: 'Credito asignado' })
                })
                .catch(err => {
                    console.log(err);
                    reject({ ok: false, message: err })
                })
        });
    }

    async asignarCredito(): Promise<{ ok: boolean, message: any }> {
        let pool = await dbConnection();
        let transaction = new mssql.Transaction(pool);
        return new Promise(async (resolve, reject) => {
            try {
                await transaction.begin();
                await this.obtenerDatos(transaction);
                await this.guardar(transaction);
                await this.credito.actualizarSaldoAsignacion(this.valorasignado, transaction);
                await this.forward.actualizarSaldoAsignacion(this.valorasignado, transaction);
                await transaction.commit();
                resolve({ ok: true, message: 'Proceso realizado' })
            } catch (err) {
                transaction.rollback()
                resolve({ ok: false, message: err })
            }
        })
    }

    private async obtenerDatos(transaction: mssql.Transaction) {
        this.credito.id = this.idcredito;
        this.credito = (await this.credito.obtenerTrx(transaction)).data || new Credito();
        if (this.credito.id === 0) throw new Error('Error al obtener credito');
        if (this.credito.estado != 'ACTIVO') throw new Error(`El crédito no se encuentra ACTIVO (${this.credito.estado})`);
        if (this.credito.saldoasignacion <= 0) throw new Error(`El crédito no cuenta con saldo para asignar`);
        this.forward.id = this.idforward;
        this.forward = (await this.forward.obtenerTrx(transaction)).data || new Forward();
        if (this.forward.id === 0) throw new Error('Error al obtener forward');
        if (this.forward.estado != 'ACTIVO') throw new Error(`El forward no se encuentra ACTIVO (${this.forward.estado})`);
        if (this.forward.saldoasignacion <= 0) throw new Error(`El forward no cuenta con saldo para asignar`);
    }
}