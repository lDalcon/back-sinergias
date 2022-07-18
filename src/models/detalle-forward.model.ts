import mssql from 'mssql';
import dbConnection from '../database';

export class DetalleForward {
    seq: number = 0;
    ano: number = 0;
    periodo: number = 0;
    fechapago: Date = new Date('1900-01-01');
    idforward: number = 0;
    tipopago: string = '';
    formapago: string = '';
    trm: number = 0;
    valor: number = 0;
    estado: string = '';
    usuariocrea: string = '';
    fechacrea: Date = new Date('1900-01-01');
    usuariomod: string = '';
    fechamod: Date = new Date('1900-01-01');

    constructor(detalleForward?: any) {
        this.seq = detalleForward?.seq || this.seq;
        this.ano = detalleForward?.ano || this.ano;
        this.periodo = detalleForward?.periodo || this.periodo;
        this.fechapago = detalleForward?.fechapago || this.fechapago;
        this.idforward = detalleForward?.idforward || this.idforward;
        this.tipopago = detalleForward?.tipopago || this.tipopago;
        this.formapago = detalleForward?.formapago || this.formapago;
        this.trm = detalleForward?.trm || this.trm;
        this.valor = detalleForward?.valor || this.valor;
        this.estado = detalleForward?.estado || this.estado;
        this.usuariocrea = detalleForward?.usuariocrea || this.usuariocrea;
        this.fechacrea = detalleForward?.fechacrea || this.fechacrea;
        this.usuariomod = detalleForward?.usuariomod || this.usuariomod;
        this.fechamod = detalleForward?.fechamod || this.fechamod;
    }

    async guardar(transaction: mssql.Transaction): Promise<{ ok: boolean, message?: any }> {
        return new Promise((resolve, reject) => {
            transaction.request()
                .input('seq', mssql.Int(), this.seq)
                .input('fechapago', mssql.Date(), this.fechapago)
                .input('idforward', mssql.Int(), this.idforward)
                .input('tipopago', mssql.VarChar(200), this.tipopago)
                .input('formapago', mssql.VarChar(200), this.formapago)
                .input('trm', mssql.Numeric(18, 2), this.trm)
                .input('valor', mssql.Numeric(18, 2), this.valor)
                .input('usuariocrea', mssql.VarChar(50), this.usuariocrea)
                .execute('sc_detalleforward_crear')
                .then(() => {
                    resolve({ ok: true, message: 'Registro creado' })
                })
                .catch(err => {
                    console.log(err);
                    reject({ ok: false, message: err })
                })
        })
    }

}