import mssql from 'mssql';
import dbConnection from "../database";
import { Amortizacion } from './amortizacion.model';
import { MacroEconomicos } from './macroeconomicos.model';
import { Regional } from './regional.model';
import { ValorCatalogo } from './valor-catalogo.model';

export class Credito {
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
    modindexado: string = '';
    tasa: number = 0;
    usuariocrea: string = '';
    fechacrea: Date = new Date('1900-01-01');
    usuariomod: string = '';
    fechamod: Date = new Date('1900-01-01');
    amortizacion: Amortizacion[] = [];

    constructor(credito?: any) {
        this.id = credito?.id || this.id;
        this.ano = credito?.ano || this.ano;
        this.periodo = credito?.periodo || this.periodo;
        this.fechadesembolso = credito?.fechadesembolso || this.fechadesembolso;
        this.moneda = credito?.moneda || this.moneda;
        this.entfinanciera = credito?.entfinanciera || this.entfinanciera;
        this.regional = credito?.regional || this.regional;
        this.lineacredito = credito?.lineacredito || this.lineacredito;
        this.pagare = credito?.pagare || this.pagare;
        this.tipogarantia = credito?.tipogarantia || this.tipogarantia;
        this.capital = credito?.capital || this.capital;
        this.saldo = credito?.saldo || this.saldo;
        this.plazo = credito?.plazo || this.plazo;
        this.indexado = credito?.indexado || this.indexado;
        this.spread = credito?.spread || this.spread;
        this.tipointeres = credito?.tipointeres || this.tipointeres;
        this.amortizacionk = credito?.amortizacionk || this.amortizacionk;
        this.amortizacionint = credito?.amortizacionint || this.amortizacionint;
        this.modindexado = credito?.modindexado || this.modindexado;
        this.tasa = credito?.tasa || this.tasa;
        this.usuariocrea = credito?.usuariocrea || this.usuariocrea;
        this.fechacrea = credito?.fechacrea || this.fechacrea;
        this.usuariomod = credito?.usuariomod || this.usuariomod;
        this.fechamod = credito?.fechamod || this.fechamod;
        this.amortizacion = credito?.amortizacion || this.amortizacion;
    }

    async guardar() {
        let pool = await dbConnection();
        let transaction = new mssql.Transaction(pool);
        try {
            await transaction.begin();
            await new mssql.Request(transaction)
                .input('ano', mssql.Int(), this.ano)
                .input('periodo', mssql.Int(), this.periodo)
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
                .input('modindexado', mssql.Int(), this.modindexado)
                .input('usuariocrea', mssql.VarChar(50), this.usuariocrea)
                .execute('sc_credito_guardar')
            transaction.commit();
            return { ok: true, message: 'Credito creado' }
        } catch (error) {
            console.log(error)
            await transaction.rollback();
            return { ok: false, message: error }
        }
    }

    async simular() {
        let macroeconomico = new MacroEconomicos();
        macroeconomico.tipo = this.indexado.descripcion;
        macroeconomico.fecha = this.fechadesembolso;
        let tasa: number = (await macroeconomico.getByDateAndType())?.macroeconomicos?.valor || 0;
        let spreadEA: number = this.convertirTasaEA(this.spread, this.tipointeres.config);
        this.amortizacion = [];
        this.amortizacion.push({
            nper: 0,
            fechaPeriodo: new Date(this.fechadesembolso),
            tasaIdxEA: tasa / 100,
            spreadEA: spreadEA,
            tasaEA: (1 + tasa / 100) * (1 + spreadEA) - 1,
            saldoCapital: this.capital,
            valorInteres: 0,
            abonoCapital: 0,
            pagoTotal: 0,
            interesCausado: 0,
            actualizaIdx: false
        })
        for (let i = 1; i <= this.plazo; i++) {
            let fechaPeriodo: Date = new Date(new Date(this.amortizacion[i - 1].fechaPeriodo).setDate(this.amortizacion[i - 1].fechaPeriodo.getDate() + 30))
            if (i % this.indexado.config.nper === 0) {
                macroeconomico.fecha = fechaPeriodo;
                tasa = (await macroeconomico.getByDateAndType())?.macroeconomicos?.valor || 0
            }
            this.amortizacion.push({
                nper: i,
                fechaPeriodo: fechaPeriodo,
                tasaIdxEA: tasa / 100,
                spreadEA: spreadEA,
                tasaEA: (1 + tasa / 100) * (1 + spreadEA) - 1,
                saldoCapital: this.capital,
                valorInteres: this.calcularInteresPagado(i, (1 + tasa / 100) * (1 + spreadEA) - 1),
                abonoCapital: 0,
                pagoTotal: 0,
                interesCausado: this.calcularInteresCausado((1 + tasa / 100) * (1 + spreadEA) - 1),
                actualizaIdx: i % this.indexado.config.nper === 0 ? true : false
            })
        }
    }


    private calcularInteresPagado(ncuota: number, tasaEA: number): number {
        let interesPagado: number = 0;
        let tasaEM = Math.pow(1 + tasaEA, 1 / 12) - 1;
        switch (this.amortizacionint.descripcion) {
            case 'AL VENCIMIENTO':
                if (ncuota != this.plazo) interesPagado = 0;
                else interesPagado = this.saldo * tasaEM * this.plazo;
                break;

            default:
                break;
        }
        return interesPagado;
    }

    private calcularInteresCausado(tasaEA: number): number {
        let tasaEM = Math.pow(1 + tasaEA, 1 / 12) - 1;
        return this.saldo * tasaEM;
    }


    private convertirTasaEA(tasa: number, config: any) {
        let tasaPeriodica, tasaVencida: number = 0;
        if (config.par === 'EFECTIVA') tasaPeriodica = Math.pow((1 + tasa / 100), (1 / config.nper)) - 1
        else tasaPeriodica = (tasa / 100) / config.nper;
        switch (config.par) {
            case 'ANTICIPADA':
                tasaVencida = tasaPeriodica / (1 - tasaPeriodica);
                break;
            case 'EFECTIVA':
                tasaVencida = Math.pow((1 + tasa / 100), (1 / config.nper)) - 1
                break;
            default:
                tasaVencida = tasaPeriodica;
                break;
        }
        return Math.pow(1 + tasaVencida, config.nper) - 1;
    }
}