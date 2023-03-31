import mssql from 'mssql';
import dbConnection from '../config/database';
import sendEmailNotification from '../helpers/notificacion';
import { EmailNotification } from './email-notification.model';
import { Regional } from './regional.model';
import { ValorCatalogo } from './valor-catalogo.model';

export class Solicitud {
    id: number = 0;
    ano: number = 0;
    periodo: number = 0;
    fechareq: Date = new Date('1900-01-01');
    moneda: ValorCatalogo = new ValorCatalogo();
    regional: Regional = new Regional();
    capital: number = 0;
    desembolso: number = 0;
    desistido: number = 0;
    plazo: number = 0;
    observaciones: string = '';
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
        this.regional = new Regional(solicitud?.regional) || this.regional;
        this.capital = solicitud?.capital || this.capital;
        this.desembolso = solicitud?.desembolso || this.desembolso;
        this.desistido = solicitud?.desistido || this.desistido;
        this.plazo = solicitud?.plazo || this.plazo;
        this.observaciones = solicitud?.observaciones || this.observaciones;
        this.estado = solicitud?.estado || this.estado;
        this.usuariocrea = solicitud?.usuariocrea || this.usuariocrea;
        this.fechacrea = solicitud?.fechacrea || this.fechacrea;
        this.usuariomod = solicitud?.usuariomod || this.usuariomod;
        this.fechamod = solicitud?.fechamod || this.fechamod;
    }

    async guardar(): Promise<{ ok: boolean, message?: any, data?: any }> {
        return new Promise(async (resolve) => {
            let pool = await dbConnection();
            try {
                let result = await pool.request()
                    .input('fechareq', mssql.Date(), this.fechareq)
                    .input('moneda', mssql.Int(), this.moneda.id)
                    .input('regional', mssql.Int(), this.regional.id)
                    .input('capital', mssql.Numeric(18, 2), this.capital)
                    .input('plazo', mssql.Int(), this.plazo)
                    .input('observaciones', mssql.NVarChar(mssql.MAX), this.observaciones)
                    .input('usuariocrea', mssql.VarChar(50), this.usuariocrea)
                    .output('id', mssql.Int())
                    .execute('sc_solicitud_guardar')
                if (result.output) {
                    const formatter = new Intl.NumberFormat('en-US', {
                        style: 'currency',
                        currency: 'USD',
                        minimumFractionDigits: 2
                    });
                    let notification = new EmailNotification(
                        { name: 'Damian Duarte', email: 'damianleo1991@hotmail.com' },
                        [{ name: 'Damian Duarte', email: 'tecnologia@grupodespensa.co' }, { name: 'Daniel Bossa', email: 'danielbossa@italcol.com' }],
                        `Solicitud ${result.output['id']}`,
                        `<html><head></head><body><p>Se registro la solicitud # ${result.output['id']} para la compañia ${this.regional.nombre} por valor de ${this.moneda.config.prefix} ${formatter.format(this.capital)}</p></body></html>`)
                    let respNotification = await sendEmailNotification(notification);
                    let resp = { ok: true, message: '' };
                    if (respNotification.ok) resp.message = `La solicitud ${result.output['id']} fue registrada y notificada a los destinatarios`
                    else resp.message = `La solicitud ${result.output['id']} fue registrada, pero no pudo ser notificada`
                    pool.close();
                    resolve(resp);
                }
            } catch (error) {
                pool.close();
                resolve({ ok: false, message: error })
            }
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