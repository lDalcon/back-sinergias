import mssql from 'mssql';
import dbConnection from '../database';
import { Credito } from './credito.model';
import { CreditoSaldos } from './credxito-saldos.model';
import { DetalleForward } from './detalle-forward.model';
import { Forward } from './forward.model';

export class DetallePago {
    seq: number = 0;
    ano: number = 0;
    periodo: number = 0;
    fechapago: Date = new Date('1900-01-01');
    idcredito: number = 0;
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

    constructor(detallePago?: any) {
        this.seq = detallePago?.seq || this.seq;
        this.ano = detallePago?.ano || this.ano;
        this.periodo = detallePago?.periodo || this.periodo;
        this.fechapago = detallePago?.fechapago || this.fechapago;
        this.idcredito = detallePago?.idcredito || this.idcredito;
        this.idforward = detallePago?.idforward || this.idforward;
        this.tipopago = detallePago?.tipopago || this.tipopago;
        this.formapago = detallePago?.formapago || this.formapago;
        this.trm = detallePago?.trm || this.trm;
        this.valor = detallePago?.valor || this.valor;
        this.estado = detallePago?.estado || this.estado;
        this.usuariocrea = detallePago?.usuariocrea || this.usuariocrea;
        this.fechacrea = detallePago?.fechacrea || this.fechacrea;
        this.usuariomod = detallePago?.usuariomod || this.usuariomod;
        this.fechamod = detallePago?.fechamod || this.fechamod;
    }

    async guardar(transaction: mssql.Transaction): Promise<{ ok: boolean, seq?: number, message?: any }> {
        return new Promise((resolve, reject) => {
            transaction.request()
                .input('fechapago', mssql.Date(), this.fechapago)
                .input('idcredito', mssql.Int(), this.idcredito)
                .input('tipopago', mssql.VarChar(200), this.tipopago)
                .input('formapago', mssql.VarChar(200), this.formapago)
                .input('trm', mssql.Numeric(18, 2), this.trm)
                .input('valor', mssql.Numeric(18, 2), this.valor)
                .input('usuariocrea', mssql.VarChar(50), this.usuariocrea)
                .output('seq', mssql.Int())
                .execute('sc_detallepago_crear')
                .then(result => {
                    resolve({ ok: true, seq: result.output.seq })
                })
                .catch(err => {
                    console.log(err);
                    resolve({ ok: false, message: err })
                })
        })
    }

    async procesarDetallePago(pagos: DetallePago[], nick: string): Promise<{ ok: boolean, message: any }> {
        let pool = await dbConnection();
        let transaction = new mssql.Transaction(pool);
        return new Promise(async (resolve, reject) => {
            try {
                let fechaPago: Date = new Date(pagos[0].fechapago);
                await transaction.begin();
                for (let i = 0; i < pagos.length; i++) {
                    pagos[i].usuariocrea = nick;
                    let detallePago: DetallePago = new DetallePago(pagos[i]);
                    let result = await detallePago.guardar(transaction);
                    if (result.seq) pagos[i].seq = result.seq;
                    else throw new Error('Error al obtener el id detalle pago.');
                    await new Credito().actualizarSaldo(detallePago.idcredito, detallePago.valor, transaction)
                    if (detallePago.idforward != 0) {
                        let detalleForward: DetalleForward = new DetalleForward(pagos[i])
                        await detalleForward.guardar(transaction);
                        await new Forward().actualizarSaldo(detallePago.idforward, detallePago.valor, transaction)
                    }
                }
                await new CreditoSaldos().actualizarByAnoAndPeriodo(transaction, fechaPago.getFullYear(), fechaPago.getMonth() + 1, pagos[0].idcredito );
                await transaction.commit();
                resolve({ ok: true, message: 'Transacciones realizadas' })
            } catch (error) {
                console.log(error)
                await transaction.rollback();
                resolve({ ok: false, message: error })
            }
        })
    }
}