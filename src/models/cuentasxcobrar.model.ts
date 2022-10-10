import mssql from 'mssql';
import dbConnection from '../config/database';
import { Amortizacion } from './amortizacion.model';
import { CalendarioCierre } from './calendario-cierre.model';
import { DetallePago } from './detalle-pago.model';
import { Regional } from './regional.model';
import { ValorCatalogo } from './valor-catalogo.model';

export class CuentasxCobrar {
    id: number = 0;
    ano: number = 0;
    periodo: number = 0;
    fechadesembolso: Date = new Date('1900-01-01');
    moneda: ValorCatalogo = new ValorCatalogo();
    entfinanciera: ValorCatalogo = new ValorCatalogo();
    regional: Regional = new Regional();
    lineacredito: ValorCatalogo = new ValorCatalogo();
    pagare: string = '';
    tipogarantia: ValorCatalogo = new ValorCatalogo();
    capital: number = 0;
    saldo: number = 0;
    plazo: number = 0;
    indexado: ValorCatalogo = new ValorCatalogo();
    spread: number = 0;
    tipointeres: ValorCatalogo = new ValorCatalogo();
    amortizacionk: ValorCatalogo = new ValorCatalogo();
    amortizacionint: ValorCatalogo = new ValorCatalogo();
    tasafija: number = 0;
    observaciones: string = '';
    abonos: DetallePago[] = [];
    amortizacion: Amortizacion[] = [];
    periodogracia: number = 0;
    estado: string = '';
    usuariocrea: string = '';
    fechacrea: Date = new Date('1900-01-01');
    usuariomod: string = '';
    fechamod: Date = new Date('1900-01-01');

    constructor(cuentaxCobrar?: any) {
        this.id = cuentaxCobrar?.id || this.id;
        this.ano = cuentaxCobrar?.ano || this.ano;
        this.periodo = cuentaxCobrar?.periodo || this.periodo;
        this.fechadesembolso = cuentaxCobrar?.fechadesembolso || this.fechadesembolso;
        this.moneda = new ValorCatalogo(cuentaxCobrar?.moneda) || this.moneda;
        this.entfinanciera = new ValorCatalogo(cuentaxCobrar?.entfinanciera) || this.entfinanciera;
        this.regional = new Regional(cuentaxCobrar?.regional) || this.regional;
        this.lineacredito = new ValorCatalogo(cuentaxCobrar?.lineacredito) || this.lineacredito;
        this.pagare = cuentaxCobrar?.pagare || this.pagare;
        this.tipogarantia = new ValorCatalogo(cuentaxCobrar?.tipogarantia) || this.tipogarantia;
        this.capital = cuentaxCobrar?.capital || this.capital;
        this.saldo = cuentaxCobrar?.saldo || this.saldo;
        this.plazo = cuentaxCobrar?.plazo || this.plazo;
        this.indexado = new ValorCatalogo(cuentaxCobrar?.indexado) || this.indexado;
        this.spread = cuentaxCobrar?.spread || this.spread;
        this.tipointeres = new ValorCatalogo(cuentaxCobrar?.tipointeres) || this.tipointeres;
        this.amortizacionk = new ValorCatalogo(cuentaxCobrar?.amortizacionk) || this.amortizacionk;
        this.amortizacionint = new ValorCatalogo(cuentaxCobrar?.amortizacionint) || this.amortizacionint;
        this.tasafija = cuentaxCobrar?.tasafija || this.tasafija;
        this.observaciones = cuentaxCobrar?.observaciones || this.observaciones;
        this.abonos = cuentaxCobrar?.abonos || this.abonos;
        this.amortizacion = cuentaxCobrar?.amortizacion || this.amortizacion;
        this.periodogracia = cuentaxCobrar?.periodogracia || this.periodogracia;
        this.estado = cuentaxCobrar?.estado || this.estado;
        this.usuariocrea = cuentaxCobrar?.usuariocrea || this.usuariocrea;
        this.fechacrea = cuentaxCobrar?.fechacrea || this.fechacrea;
        this.usuariomod = cuentaxCobrar?.usuariomod || this.usuariomod;
        this.fechamod = cuentaxCobrar?.fechamod || this.fechamod;
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
            let calendario: CalendarioCierre = new CalendarioCierre({ano: this.fechadesembolso.getFullYear(), periodo: this.fechadesembolso.getMonth() + 1});
            calendario = (await calendario.get(transaction))?.calendario || new CalendarioCierre();
            if (!calendario.registro ) throw new Error('El mes se encuentra cerrado para registros.');
            await new mssql.Request(transaction)
                .input('fechadesembolso', mssql.Date(), this.fechadesembolso)
                .input('moneda', mssql.Int(), this.moneda.id)
                .input('entfinanciera', mssql.Int(), this.entfinanciera.id)
                .input('regional', mssql.Int(), this.regional.id)
                .input('lineacredito', mssql.Int(), this.lineacredito.id)
                .input('pagare', mssql.VarChar(50), this.pagare)
                .input('tipogarantia', mssql.Int(), this.tipogarantia.id)
                .input('capital', mssql.Numeric(18, 2), this.capital)
                .input('saldo', mssql.Numeric(18, 2), this.saldo)
                .input('plazo', mssql.Int(), this.plazo)
                .input('indexado', mssql.Int(), this.indexado.id)
                .input('spread', mssql.Numeric(6, 2), this.spread)
                .input('tipointeres', mssql.Int(), this.tipointeres.id)
                .input('amortizacionk', mssql.Int(), this.amortizacionk.id)
                .input('amortizacionint', mssql.Int(), this.amortizacionint.id)
                .input('usuariocrea', mssql.VarChar(50), this.usuariocrea)
                .input('periodogracia', mssql.Int(), this.periodogracia)
                .input('amortizacion', mssql.VarChar(mssql.MAX), JSON.stringify(this.amortizacion))
                .execute('sc_credito_guardar')
            if (!isTrx) {
                transaction.commit();
                pool.close();
            }
            return { ok: true, message: 'Credito creado' }
        } catch (error) {
            console.log(error)
            if (!isTrx) {
                await transaction.rollback();
                pool.close();
            }
            return { ok: false, message: error?.['message'] }
        }
    }
}