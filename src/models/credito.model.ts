import mssql from 'mssql';
import dbConnection from '../database';
import { ICredito } from '../interface/credito.interface';
import { Amortizacion } from './amortizacion.model';
import { DetallePago } from './detalle-pago.model';
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
    saldoasignacion: number = 0;
    estado: string = '';
    tasa: number = 0;
    usuariocrea: string = '';
    fechacrea: Date = new Date('1900-01-01');
    usuariomod: string = '';
    fechamod: Date = new Date('1900-01-01');
    amortizacion: Amortizacion[] = [];
    forwards: any[] = [];
    pagos: DetallePago[] = [];

    constructor(credito?: any) {
        this.id = credito?.id || this.id;
        this.ano = credito?.ano || this.ano;
        this.periodo = credito?.periodo || this.periodo;
        this.fechadesembolso = credito?.fechadesembolso || this.fechadesembolso;
        this.moneda = new ValorCatalogo(credito?.moneda) || this.moneda;
        this.entfinanciera = new ValorCatalogo(credito?.entfinanciera) || this.entfinanciera;
        this.regional = new Regional(credito?.regional) || this.regional;
        this.lineacredito = new ValorCatalogo(credito?.lineacredito) || this.lineacredito;
        this.pagare = credito?.pagare || this.pagare;
        this.tipogarantia = new ValorCatalogo(credito?.tipogarantia) || this.tipogarantia;
        this.capital = credito?.capital || this.capital;
        this.saldo = credito?.saldo || this.saldo;
        this.plazo = credito?.plazo || this.plazo;
        this.indexado = new ValorCatalogo(credito?.indexado) || this.indexado;
        this.spread = credito?.spread || this.spread;
        this.tipointeres = new ValorCatalogo(credito?.tipointeres) || this.tipointeres;
        this.amortizacionk = new ValorCatalogo(credito?.amortizacionk) || this.amortizacionk;
        this.amortizacionint = new ValorCatalogo(credito?.amortizacionint) || this.amortizacionint;
        this.saldoasignacion = credito?.saldoasignacion || this.saldoasignacion;
        this.estado = credito?.estado || this.estado;
        this.tasa = credito?.tasa || this.tasa;
        this.usuariocrea = credito?.usuariocrea || this.usuariocrea;
        this.fechacrea = credito?.fechacrea || this.fechacrea;
        this.usuariomod = credito?.usuariomod || this.usuariomod;
        this.fechamod = credito?.fechamod || this.fechamod;
        this.amortizacion = credito?.amortizacion || this.amortizacion;
        this.forwards = credito?.forwards || this.forwards;
        this.pagos = credito?.pagos || this.pagos;
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
                .input('saldoasignacion', mssql.Numeric(18, 2), this.saldoasignacion)
                .input('usuariocrea', mssql.VarChar(50), this.usuariocrea)
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
            return { ok: false, message: error }
        }
    }

    async listar(filtro?: any): Promise<{ ok: boolean, data?: ICredito[], message?: string }> {
        let pool = await dbConnection();
        return new Promise((resolve, reject) => {
            pool.request()
                .input('nick', mssql.VarChar(50), this.usuariocrea)
                .input('saldo', mssql.Int(), filtro?.saldo || -1)
                .execute('sc_credito_listar')
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

    async obtener(): Promise<{ ok: boolean, data?: Credito, message?: string }> {
        let pool = await dbConnection();
        return new Promise((resolve, reject) => {
            pool.request()
                .input('id', mssql.Int(), this.id)
                .execute('sc_credito_obtener')
                .then(result => {
                    pool.close();
                    resolve({ ok: true, data: new Credito(result.recordset[0][0]) })
                })
                .catch(err => {
                    console.log(err);
                    pool.close();
                    resolve({ ok: false, message: err })
                })
        });
    }

    async obtenerTrx(transaction: mssql.Transaction): Promise<{ ok: boolean, data?: Credito, message?: string }> {
        return new Promise((resolve, reject) => {
            transaction.request()
                .input('id', mssql.Int(), this.id)
                .execute('sc_credito_obtener')
                .then(result => {
                    resolve({ ok: true, data: new Credito(result.recordset[0][0]) })
                })
                .catch(err => {
                    console.log(err);
                    resolve({ ok: false, message: err })
                })
        });
    }

    async validarPagare(): Promise<{ ok: boolean, message?: string }> {
        let pool = await dbConnection();
        return new Promise((resolve, reject) => {
            pool.request()
                .input('pagare', mssql.VarChar(50), this.pagare)
                .input('entfinanciera', mssql.Int(), this.entfinanciera.id)
                .execute('sc_credito_obtener')
                .then(result => {
                    pool.close();
                    if (result.recordset[0]?.length > 0) {
                        let credito: Credito = new Credito(result.recordset[0][0])
                        resolve({ ok: false, message: `El pagaré ${credito.pagare} ya se encuenta asociado a la obligacion #${credito.id}` })
                    }
                    resolve({ ok: true, message: 'Pagaré disponible' })
                })
                .catch(err => {
                    console.log(err);
                    pool.close();
                    resolve({ ok: false, message: err })
                })
        });
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
            let amortizacion = new Amortizacion();
            amortizacion.nper = i;
            amortizacion.fechaPeriodo = fechaPeriodo;
            amortizacion.tasaIdxEA = tasa / 100;
            amortizacion.spreadEA = spreadEA;
            amortizacion.tasaEA = (1 + tasa / 100) * (1 + spreadEA) - 1;
            amortizacion.abonoCapital = this.calcularAbonoCapital(i);
            amortizacion.saldoCapital = this.amortizacion[i - 1].saldoCapital - amortizacion.abonoCapital;
            amortizacion.valorInteres = this.calcularInteresPagado(i, (1 + tasa / 100) * (1 + spreadEA) - 1);
            amortizacion.pagoTotal = amortizacion.abonoCapital + amortizacion.valorInteres;
            amortizacion.interesCausado = this.calcularInteresCausado(i, (1 + tasa / 100) * (1 + spreadEA) - 1);
            amortizacion.actualizaIdx = i % this.indexado.config.nper === 0 ? true : false;
            this.amortizacion.push(amortizacion);
            if (this.amortizacionint.config.nper != -1 && i % this.amortizacionint.config.nper === 0) {
                macroeconomico.fecha = fechaPeriodo;
                tasa = (await macroeconomico.getByDateAndType())?.macroeconomicos?.valor || 0
            }
        }
    }

    async actualizarSaldoAsignacion(valorAsignado: number, transaction: mssql.Transaction) {
        try {
            await transaction.request()
                .input('id', mssql.Int(), this.id)
                .input('valorasignado', mssql.Numeric(18, 2), valorAsignado)
                .execute('sc_credito_actualizarsaldoasginacion')
        } catch (error) {
            console.log(error);
            throw new Error('Error al actualizar el saldo del crédito');
        }
    }
    
    async actualizarSaldo(idCredito: number, valorPago: number, transaction: mssql.Transaction) {
        try {
            await transaction.request()
                .input('id', mssql.Int(), idCredito)
                .input('valorPago', mssql.Numeric(18, 2), valorPago)
                .execute('sc_credito_actualizarsaldo')
        } catch (error) {
            console.log(error);
            throw new Error('Error al actualizar el saldo del crédito');
        }
    }

    private calcularInteresPagado(ncuota: number, tasaEA: number): number {
        let tasaEM = Math.pow(1 + tasaEA, 1 / 12) - 1;
        if (this.amortizacionint.config.nper === -1) return ncuota === this.plazo ? tasaEM * this.amortizacion[ncuota - 1].saldoCapital * this.plazo : 0;
        if (ncuota % this.amortizacionint.config.nper === 0) return tasaEM * this.amortizacion[ncuota - 1].saldoCapital * this.amortizacionint.config.nper;
        return 0;
    }

    private calcularInteresCausado(ncuota: number, tasaEA: number): number {
        let tasaEM = Math.pow(1 + tasaEA, 1 / 12) - 1;
        return this.amortizacion[ncuota - 1].saldoCapital * tasaEM;
    }

    private calcularAbonoCapital(ncuota: number): number {
        if (this.amortizacionk.config.nper === -1) return ncuota === this.plazo ? this.saldo : 0;
        if (ncuota % this.amortizacionk.config.nper === 0) return (this.amortizacion[ncuota - 1].saldoCapital / (this.plazo - ncuota + this.amortizacionk.config.nper)) * this.amortizacionk.config.nper
        return 0;
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