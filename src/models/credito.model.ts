import mssql from 'mssql';
import dbConnection from '../config/database';
import { ICredito } from '../interface/credito.interface';
import { Amortizacion } from './amortizacion.model';
import { AumentoCapital } from './aumento-capital.model';
import { CalendarioCierre } from './calendario-cierre.model';
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
    periodogracia: number = 0;
    aumentocapital: AumentoCapital[] = [];
    observaciones: string = '';
    idsolicitud: number = -1;

    constructor(credito?: any) {
        this.id = credito?.id || this.id;
        this.ano = credito?.ano || this.ano;
        this.periodo = credito?.periodo || this.periodo;
        this.fechadesembolso = new Date(credito?.fechadesembolso) || this.fechadesembolso;
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
        this.amortizacion = credito?.amortizacion360 || this.amortizacion;
        this.forwards = credito?.forwards || this.forwards;
        this.pagos = credito?.pagos || this.pagos;
        this.periodogracia = credito?.periodogracia || this.periodogracia;
        this.aumentocapital = credito?.aumentocapital || this.aumentocapital;
        this.observaciones = credito?.observaciones || this.observaciones;
        this.idsolicitud = credito?.idsolicitud || this.idsolicitud;
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
            let calendario: CalendarioCierre = new CalendarioCierre({ ano: this.fechadesembolso.getFullYear(), periodo: this.fechadesembolso.getMonth() + 1 });
            calendario = (await calendario.get(transaction))?.calendario || new CalendarioCierre();
            if (!calendario.registro) throw new Error('El mes se encuentra cerrado para registros.');
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
                .input('estado', mssql.VarChar(20), this.estado)
                .input('usuariocrea', mssql.VarChar(50), this.usuariocrea)
                .input('tasafija', mssql.Numeric(8, 6), this.tasa)
                .input('periodogracia', mssql.Int(), this.periodogracia)
                .input('amortizacion', mssql.VarChar(mssql.MAX), JSON.stringify({ amortizacion: this.amortizacion }))
                .input('observaciones', mssql.NVarChar(mssql.MAX), this.observaciones)
                .input('idsolicitud', mssql.Int(), this.idsolicitud)
                .execute('sc_credito_guardar')
            if (!isTrx) {
                transaction.commit();
            }
            pool.close();
            return { ok: true, message: 'Credito creado' }
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
            if (this.estado != 'ANULADO' && validarPeriodo) {
                let calendario: CalendarioCierre = new CalendarioCierre({ ano: this.fechadesembolso.getFullYear(), periodo: this.fechadesembolso.getMonth() + 1 });
                calendario = (await calendario.get(transaction))?.calendario || new CalendarioCierre();
                if (!calendario.registro) throw new Error('El mes se encuentra cerrado para registros.');
            }
            await this.simular365Trx(transaction);
            await new mssql.Request(transaction)
                .input('id', mssql.Int(), this.id)
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
                .input('estado', mssql.VarChar(20), this.estado)
                .input('usuariomod', mssql.VarChar(50), this.usuariomod)
                .input('tasafija', mssql.Numeric(8, 6), this.tasa)
                .input('periodogracia', mssql.Int(), this.periodogracia)
                .input('amortizacion', mssql.VarChar(mssql.MAX), JSON.stringify({ amortizacion: this.amortizacion }))
                .input('observaciones', mssql.NVarChar(mssql.MAX), this.observaciones)
                .execute('sc_credito_actualizar')
            if (!isTrx) {
                transaction.commit();
            }
            pool.close();
            return { ok: true, message: 'Credito actualizado' }
        } catch (error) {
            console.log(error)
            if (!isTrx) {
                await transaction.rollback();
            }
            pool.close();
            return { ok: false, message: error?.['message'] }
        }
    }

    async anular(transaction?: mssql.Transaction, validarPeriodo: boolean = true) {
        let isTrx: boolean = true;
        let pool = await dbConnection();
        if (!transaction) {
            transaction = new mssql.Transaction(pool);
            isTrx = false;
        }
        try {
            if (!isTrx) await transaction.begin();
            if (validarPeriodo) {
                let calendario: CalendarioCierre = new CalendarioCierre({ ano: this.fechadesembolso.getFullYear(), periodo: this.fechadesembolso.getMonth() + 1 });
                calendario = (await calendario.get(transaction))?.calendario || new CalendarioCierre();
                if (!calendario.registro) throw new Error('El mes se encuentra cerrado para registros.');
            }
            await new mssql.Request(transaction)
                .input('id', mssql.Int(), this.id)
                .input('nick', mssql.VarChar(50), this.usuariocrea)
                .execute('sc_credito_anular')
            if (!isTrx) {
                transaction.commit();
            }
            pool.close();
            return { ok: true, message: 'Credito anulado' }
        } catch (error) {
            console.log(error)
            if (!isTrx) {
                await transaction.rollback();
            }
            pool.close();
            return { ok: false, message: error?.['message'] }
        }
    }

    async listar(filtro?: any): Promise<{ ok: boolean, data?: ICredito[], message?: string }> {
        let pool = await dbConnection();
        return new Promise((resolve) => {
            pool.request()
                .input('nick', mssql.VarChar(50), this.usuariocrea)
                .input('regional', mssql.Int(), filtro?.regional || null)
                .input('estado', mssql.VarChar(20), filtro?.estado || null)
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

    async obtener(transaction?: mssql.Transaction): Promise<{ ok: boolean, data?: Credito, message?: any }> {
        return new Promise(async (resolve) => {
            let isTrx: boolean = true;
            let pool = await dbConnection();
            if (!transaction) {
                transaction = new mssql.Transaction(pool);
                isTrx = false;
            }
            try {
                if (!isTrx) await transaction.begin();
                let result = await transaction.request()
                    .input('id', mssql.Int(), this.id)
                    .execute('sc_credito_obtener')
                if (!isTrx) {
                    transaction.commit();
                    pool.close();
                }
                resolve({ ok: true, data: new Credito(result.recordset[0][0]) })
            } catch (error) {
                console.log(error)
                if (!isTrx) {
                    await transaction.rollback();
                    pool.close();
                }
                resolve({ ok: true, message: error })
            }
        });
    }

    async obtenerTrx(transaction: mssql.Transaction, id?: number): Promise<{ ok: boolean, data?: Credito, message?: string }> {
        return new Promise((resolve) => {
            transaction.request()
                .input('id', mssql.Int(), id || this.id)
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
        return new Promise((resolve) => {
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

    async simular365() {
        let macroeconomico = new MacroEconomicos();
        macroeconomico.tipo = this.indexado.descripcion;
        macroeconomico.fecha = this.fechadesembolso;
        let tasa: number = 0;
        if (this.indexado.descripcion == 'TASA FIJA') tasa = this.tasa;
        else if (this.indexado.descripcion == 'UVR') tasa = await macroeconomico.getTasaUVR(this.fechadesembolso, this.fechadesembolso)
        else tasa = (await macroeconomico.getByDateAndType())?.macroeconomicos?.valor || 0;
        let spreadEA: number = this.convertirTasaEA(this.spread, this.tipointeres.config);
        this.amortizacion = [];
        this.amortizacion.push({
            nper: 0,
            fechaPeriodo: new Date(this.fechadesembolso),
            tasaIdxEA: tasa / 100,
            spreadEA: spreadEA,
            tasaEA: this.indexado.descripcion == 'UVR' ? ((tasa / 100) + spreadEA) : (1 + tasa / 100) * (1 + spreadEA) - 1,
            saldoCapital: this.capital,
            valorInteres: 0,
            abonoCapital: 0,
            pagoTotal: 0,
            interesCausado: 0,
            actualizaIdx: false
        })
        for (let i = 1; i <= this.plazo; i++) {
            let fechaPeriodo: Date = this.aumentarMes(this.fechadesembolso, i);
            if (this.indexado.descripcion == 'UVR') tasa = await macroeconomico.getTasaUVR(this.fechadesembolso, fechaPeriodo)
            let amortizacion = new Amortizacion();
            amortizacion.nper = i;
            amortizacion.fechaPeriodo = fechaPeriodo;
            amortizacion.tasaIdxEA = tasa / 100;
            amortizacion.spreadEA = spreadEA;
            amortizacion.tasaEA = this.indexado.descripcion == 'UVR' ? ((tasa / 100) + spreadEA) : (1 + tasa / 100) * (1 + spreadEA) - 1,
            amortizacion.abonoCapital = this.calcularAbonoCapital(i);
            amortizacion.saldoCapital = this.amortizacion[i - 1].saldoCapital - amortizacion.abonoCapital;
            amortizacion.valorInteres = this.calcularInteresPagado(i, (1 + tasa / 100) * (1 + spreadEA) - 1);
            amortizacion.pagoTotal = amortizacion.abonoCapital + amortizacion.valorInteres;
            amortizacion.interesCausado = this.calcularInteresCausado(i, (1 + tasa / 100) * (1 + spreadEA) - 1);
            amortizacion.actualizaIdx = i % this.indexado.config.nper === 0 ? true : false;
            this.amortizacion.push(amortizacion);
            if (this.amortizacionint.config.nper != -1 && i % this.amortizacionint.config.nper === 0) {
                macroeconomico.fecha = fechaPeriodo;
                if (this.indexado.descripcion == 'TASA FIJA') tasa = this.tasa;
                else tasa = (await macroeconomico.getByDateAndType())?.macroeconomicos?.valor || 0;
            }
        }
    }

    async simular365Trx(transaction: mssql.Transaction) {
        let macroeconomico = new MacroEconomicos();
        macroeconomico.tipo = this.indexado.descripcion;
        macroeconomico.fecha = this.fechadesembolso;
        let tasa: number = 0;
        if (this.indexado.descripcion == 'TASA FIJA') tasa = this.tasa;
        else if (this.indexado.descripcion == 'UVR') tasa = await macroeconomico.getTasaUVRTrx(transaction, this.fechadesembolso, this.fechadesembolso);
        else tasa = (await macroeconomico.getByDateAndTypeTrx(transaction))?.macroeconomicos?.valor || 0;
        let spreadEA: number = this.convertirTasaEA(this.spread, this.tipointeres.config);
        this.amortizacion = [];
        this.amortizacion.push({
            nper: 0,
            fechaPeriodo: new Date(this.fechadesembolso),
            tasaIdxEA: tasa / 100,
            spreadEA: spreadEA,
            tasaEA: this.indexado.descripcion == 'UVR' ? ((tasa / 100) + spreadEA) : (1 + tasa / 100) * (1 + spreadEA) - 1,
            saldoCapital: this.capital,
            valorInteres: 0,
            abonoCapital: 0,
            pagoTotal: 0,
            interesCausado: 0,
            actualizaIdx: false
        })
        for (let i = 1; i <= this.plazo; i++) {
            let fechaPeriodo: Date = this.aumentarMes(this.fechadesembolso, i);
            if (this.indexado.descripcion == 'UVR') tasa = await macroeconomico.getTasaUVRTrx(transaction, this.fechadesembolso, this.fechadesembolso)
            let amortizacion = new Amortizacion();
            amortizacion.nper = i;
            amortizacion.fechaPeriodo = fechaPeriodo;
            amortizacion.tasaIdxEA = tasa / 100;
            amortizacion.spreadEA = spreadEA;
            amortizacion.tasaEA = this.indexado.descripcion == 'UVR' ? ((tasa / 100) + spreadEA) : (1 + tasa / 100) * (1 + spreadEA) - 1,
            amortizacion.abonoCapital = this.calcularAbonoCapital(i);
            amortizacion.saldoCapital = this.amortizacion[i - 1].saldoCapital - amortizacion.abonoCapital;
            amortizacion.valorInteres = this.calcularInteresPagado(i, (1 + tasa / 100) * (1 + spreadEA) - 1);
            amortizacion.pagoTotal = amortizacion.abonoCapital + amortizacion.valorInteres;
            amortizacion.interesCausado = this.calcularInteresCausado(i, (1 + tasa / 100) * (1 + spreadEA) - 1);
            amortizacion.actualizaIdx = i % this.indexado.config.nper === 0 ? true : false;
            this.amortizacion.push(amortizacion);
            if (this.amortizacionint.config.nper != -1 && i % this.amortizacionint.config.nper === 0) {
                macroeconomico.fecha = fechaPeriodo;
                if (this.indexado.descripcion == 'TASA FIJA') tasa = this.tasa;
                else tasa = (await macroeconomico.getByDateAndTypeTrx(transaction))?.macroeconomicos?.valor || 0;
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

    async actualizarEstado(transaction: mssql.Transaction, id: number, estado: string) {
        await transaction.request()
            .input('id', mssql.Int(), id)
            .input('estado', mssql.VarChar(20), estado)
            .execute('sc_credito_actualizarestado')
    }

    async actualizarAmortizacion(params: any) {
        let pool = await dbConnection();
        let transaction = new mssql.Transaction(pool);
        try {
            await transaction.begin();
            let creditosActivos = await this.obtenerCreditosActivos(transaction, params);
            for (let i = 0; i < creditosActivos.length; i++) {
                let credito = (await this.obtenerTrx(transaction, creditosActivos[i].id)).data || new Credito();
                await credito.actualizar(transaction, false);
            }
            await transaction.commit();
            return { ok: true, message: 'Proceso realizado' }
        } catch (error) {
            console.log(error)
            await transaction.rollback();
            return { ok: false, message: 'Error al procesar Actualización' }
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
        let tasaPeriodica: number, tasaVencida: number = 0;
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
        return +(Math.pow(1 + tasaVencida, config.nper) - 1).toFixed(5);
    }

    private async obtenerCreditosActivos(transaction: mssql.Transaction, params: any) {
        let result = await transaction.request()
            .input('ano', mssql.Int(), params.ano)
            .input('periodo', mssql.Int(), params.periodo)
            .execute('sc_creditos_saldos_obteneractivos')
        return result.recordset
    }


    private aumentarMes(fecha: Date, nMes: number){
        let year = fecha.getFullYear();
        let month = fecha.getMonth();
        let day = fecha.getDate();
        month += nMes;
        year += Math.floor(month/12);
        month = month % 12;
        if (day > 28 && month === 1) {
            day = 0;
            month++;
        }
        return new Date(Date.UTC(year, month, day));
    }
}