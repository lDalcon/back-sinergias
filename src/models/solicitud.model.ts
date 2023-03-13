import mssql from 'mssql';
import dbConnection from '../config/database';
import { Regional } from './regional.model';
import { ValorCatalogo } from './valor-catalogo.model';

export class Solicitud {
    id: number = 0;
    ano: number = 0;
    periodo: number = 0;
    fechareq: Date = new Date('1900-01-01');
    moneda: ValorCatalogo = new ValorCatalogo();
    entfinanciera?: ValorCatalogo;
    regional: Regional = new Regional();
    lineacredito?: ValorCatalogo;
    tipogarantia?: ValorCatalogo;
    capital: number = 0;
    plazo: number = 0;
    indexado?: ValorCatalogo;
    spread: number = 0;
    tasa: number = 0;
    tipointeres?: ValorCatalogo;
    amortizacionk?: ValorCatalogo;
    amortizacionint?: ValorCatalogo;
    observaciones: string = '';
    idcredito: number = -1;
    estado: string = '';
    usuariocrea: string = '';
    fechacrea: Date = new Date('1900-01-01');
    usuariomod: string = '';
    fechamod: Date = new Date('1900-01-01');

    constructor(solicitud?: any) {
        this.id = solicitud?.id || this.id;
        this.ano = solicitud?.ano || this.ano;
        this.periodo = solicitud?.periodo || this.periodo;
        this.fechareq = solicitud?.fechareq || this.fechareq;
        this.moneda = new ValorCatalogo(solicitud?.moneda) || this.moneda;
        this.entfinanciera = new ValorCatalogo(solicitud?.entfinanciera) || this.entfinanciera;
        this.regional = new Regional(solicitud?.regional) || this.regional;
        this.lineacredito = new ValorCatalogo(solicitud?.lineacredito) || this.lineacredito;
        this.tipogarantia = new ValorCatalogo(solicitud?.tipogarantia) || this.tipogarantia;
        this.capital = solicitud?.capital || this.capital;
        this.plazo = solicitud?.plazo || this.plazo;
        this.indexado = new ValorCatalogo(solicitud?.indexado) || this.indexado;
        this.spread = solicitud?.spread || this.spread;
        this.tasa = solicitud?.tasa || this.tasa;
        this.tipointeres = new ValorCatalogo(solicitud?.tipointeres) || this.tipointeres;
        this.amortizacionk = new ValorCatalogo(solicitud?.amortizacionk) || this.amortizacionk;
        this.amortizacionint = new ValorCatalogo(solicitud?.amortizacionint) || this.amortizacionint;
        this.observaciones = solicitud?.observaciones || this.observaciones;
        this.idcredito = solicitud?.idcredito || this.idcredito;
        this.estado = solicitud?.estado || this.estado;
        this.usuariocrea = solicitud?.usuariocrea || this.usuariocrea;
        this.fechacrea = solicitud?.fechacrea || this.fechacrea;
        this.usuariomod = solicitud?.usuariomod || this.usuariomod;
        this.fechamod = solicitud?.fechamod || this.fechamod;
    }

    async guardar(): Promise<{ ok: boolean, message?: any, data?: any }> {
        return new Promise(async (resolve) => {
            let pool = await dbConnection();
            pool.request()
                .input('fechareq', mssql.Date(), this.fechareq)
                .input('moneda', mssql.Int(), this.moneda.id)
                .input('regional', mssql.Int(), this.regional.id)
                .input('capital', mssql.Numeric(18, 2), this.capital)
                .input('plazo', mssql.Int(), this.plazo)
                .input('observaciones', mssql.NVarChar(mssql.MAX), this.observaciones)
                .input('usuariocrea', mssql.VarChar(50), this.usuariocrea)
                .output('id', mssql.Int())
                .execute('sc_solicitud_guardar')
                .then(result => {
                    pool.close();
                    resolve({ ok: true, message: `Solicitud registrada (${result.output['id']})` })
                })
                .catch(err => {
                    console.log(err);
                    pool.close();
                    resolve({ ok: false, message: err })
                })
        })
    }

    async listar(filtro?: any): Promise<{ ok: boolean, data?: any[], message?: string }> {
        let pool = await dbConnection();
        return new Promise((resolve) => {
            pool.request()
                .input('nick', mssql.VarChar(50), this.usuariocrea)
                .input('regional', mssql.Int(), filtro?.regional || null)
                .input('estado', mssql.VarChar(20), filtro?.estado || null)
                .execute('sc_solicitud_listar')
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

    async obtener(): Promise<{ ok: boolean, data?: Solicitud, message?: string }> {
        let pool = await dbConnection();
        return new Promise((resolve) => {
            pool.request()
                .input('id', mssql.Int(), this.id)
                .execute('sc_solicitud_obtener')
                .then(result => {
                    console.log(result)
                    pool.close();
                    resolve({ ok: true, data: new Solicitud(result.recordset[0][0]) })
                })
                .catch(err => {
                    console.log(err);
                    pool.close();
                    resolve({ ok: false, message: err })
                })
        });
    }
}