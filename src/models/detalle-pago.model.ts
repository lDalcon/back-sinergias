import mssql from 'mssql';
import dbConnection from '../config/database';
import { Credito } from './credito.model';
import { CreditoSaldos } from './credito-saldos.model';
import { DetalleForward } from './detalle-forward.model';
import { Forward } from './forward.model';
import { CalendarioCierre } from './calendario-cierre.model';
import { ForwardSaldos } from './forward-saldos.model';
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
    seqid?: number;
    seqpago?: number;

    constructor(detallePago?: any) {
        this.seq = detallePago?.seq || this.seq;
        this.ano = detallePago?.ano || this.ano;
        this.periodo = detallePago?.periodo || this.periodo;
        this.fechapago = new Date(detallePago?.fechapago) || this.fechapago;
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
        this.seqid = detallePago?.seqid;
        this.seqpago = detallePago?.seqpago;
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
        return new Promise(async (resolve) => {
            try {
                await transaction.begin();
                let fechaPago: Date = new Date(pagos[0].fechapago);
                let calendario: CalendarioCierre = new CalendarioCierre({ ano: fechaPago.getFullYear(), periodo: fechaPago.getMonth() + 1 });
                calendario = (await calendario.get(transaction))?.calendario || new CalendarioCierre();
                if (!calendario.registro) throw new Error('El mes se encuentra cerrado para registros.');
                for (let i = 0; i < pagos.length; i++) {
                    pagos[i].usuariocrea = nick;
                    let detallePago: DetallePago = new DetallePago(pagos[i]);
                    let result = await detallePago.guardar(transaction);
                    if (result.seq) pagos[i].seq = result.seq;
                    else throw new Error('Error al obtener el id detalle pago.');
                    if (detallePago.tipopago === 'Capital') await new Credito().actualizarSaldo(detallePago.idcredito, detallePago.valor, transaction)
                    if (detallePago.idforward != 0) {
                        let detalleForward: DetalleForward = new DetalleForward(pagos[i])
                        await detalleForward.guardar(transaction);
                        await new Forward().actualizarSaldo(detalleForward, transaction)
                        await new ForwardSaldos().actualizarByAnoAndPeriodo(transaction, fechaPago.getFullYear(), fechaPago.getMonth() + 1, pagos[i].idforward);
                    }
                }
                await new CreditoSaldos().actualizarByAnoAndPeriodo(transaction, fechaPago.getFullYear(), fechaPago.getMonth() + 1, pagos[0].idcredito);
                let credito = new Credito();
                credito.id = pagos[0].idcredito;
                credito = (await credito.obtener(transaction))?.data || new Credito();
                if (credito.saldo == 0) await credito.actualizarEstado(transaction, credito.id, 'PAGO');
                await transaction.commit();
                resolve({ ok: true, message: 'Transacciones realizadas' })
            } catch (error) {
                console.log(error)
                await transaction.rollback();
                resolve({ ok: false, message: error?.['message'] })
            }
        })
    }

    async procesarReverso(nick: string): Promise<{ ok: boolean, message: any }> {
        let pool = await dbConnection();
        let transaction = new mssql.Transaction(pool);
        return new Promise(async (resolve) => {
            try {
                await transaction.begin();
                let calendario: CalendarioCierre = new CalendarioCierre({ ano: this.fechapago.getFullYear(), periodo: this.fechapago.getMonth() + 1 });
                calendario = (await calendario.get(transaction))?.calendario || new CalendarioCierre();
                if (!calendario.registro) throw new Error('El mes se encuentra cerrado para registros.');
                let result = await this.reversar(transaction, nick)
                if (!result.ok) throw new Error('Error al reversar detallepago');
                if (this.tipopago === 'Capital') await new Credito().actualizarSaldo(this.idcredito, this.valor * -1, transaction)
                if (this.idforward != 0) {
                    let detalleForward: DetalleForward = new DetalleForward(this)
                    detalleForward.valor = detalleForward.valor * -1;
                    detalleForward.usuariocrea = nick;
                    result = await detalleForward.reversar(transaction, nick);
                    if (!result.ok) throw new Error('Error al reversar detalleforward');
                    await new Forward().actualizarSaldo(detalleForward, transaction)
                    await new ForwardSaldos().actualizarByAnoAndPeriodo(transaction, this.fechapago.getFullYear(), this.fechapago.getMonth() + 1, this.idforward);
                }
                result = await new CreditoSaldos().actualizarByAnoAndPeriodo(transaction, this.fechapago.getFullYear(), this.fechapago.getMonth() + 1, this.idcredito);
                if (!result.ok) throw new Error('Error al actualizar credito_saldos');
                await transaction.commit();
                resolve({ ok: true, message: `El pago ${this.seq} fue reversado` })
            } catch (error) {
                console.log(error)
                await transaction.rollback();
                resolve({ ok: false, message: error?.['message'] })
            }
        })
    }

    async reversar(transaction: mssql.Transaction, nick: string): Promise<{ ok: boolean, message?: any }> {
        return new Promise((resolve) => {
            transaction.request()
                .input('fecha', mssql.Date(), this.fechapago)
                .input('seq', mssql.Int(), this.seq)
                .input('nick', mssql.VarChar(50), nick)
                .execute('sc_deltallepago_reversar')
                .then(() => resolve({ ok: true }))
                .catch(err => {
                    console.log(err);
                    resolve({ ok: false, message: err })
                })
        })
    }

}