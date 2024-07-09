import { Parametros } from '../interface/parametros.interface';
import mssql, { IProcedureResult } from 'mssql';
import { ForwardSaldos } from './forward-saldos.model';
import { CreditoSaldos } from './credito-saldos.model';
import moment from 'moment';
import { IDcForward } from '../interface/dc-forward.interface';
import { devaluation, round } from '../util/general.util';

export class DiferenciaCambio {
  constructor() {}

  async procesarDiferenciaCambio(parametros: Parametros, transaction: mssql.Transaction) {
    try {
      const { nick, nit, fecha } = parametros;
      const creditoSaldos = new CreditoSaldos();
      const forwardSaldos = new ForwardSaldos();
      const ano = moment(parametros.fecha).year();
      const periodo = moment(parametros.fecha).month() + 1;
      // Actualizar saldos
      let response = await creditoSaldos.actualizarByAnoAndPeriodo(transaction, ano, periodo);
      if (!response.ok) throw response.message;
      response = await forwardSaldos.actualizarByAnoAndPeriodo(transaction, ano, periodo);
      if (!response.ok) throw response.message;
      await this.createInfoCredito(transaction, fecha, nick, nit);
      await this.createInfoForward(transaction, parametros);
      await this.createConsolidado(transaction, parametros);
    } catch (error) {
      console.log(error);
      throw error;
    }
  }

  async createInfoCredito(transaction: mssql.Transaction, fecha: string, nick?: string, nit?: string) {
    await transaction
      .request()
      .input('fecha', mssql.Date(), fecha)
      .input('nick', mssql.VarChar(50), nick ?? null)
      .input('nit', mssql.VarChar(15), nit ?? null)
      .execute('sc_dc_credito');
  }

  async createInfoForward(transaction: mssql.Transaction, parametros: Parametros) {
    const { nick, nit, fecha } = parametros;
    const { recordset: forwarAsociados } = await transaction
      .request()
      .input('fecha', mssql.Date(), fecha)
      .input('nick', mssql.VarChar(50), nick ?? null)
      .input('nit', mssql.VarChar(15), nit ?? null)
      .execute('sc_dc_get_forward_asociados');
    const { recordset: forwarSinAsociar } = await transaction
      .request()
      .input('fecha', mssql.Date(), fecha)
      .input('nick', mssql.VarChar(50), nick ?? null)
      .input('nit', mssql.VarChar(15), nit ?? null)
      .execute('sc_dc_get_forward_sin_asociar');
    const forwards: IDcForward[] = [...forwarAsociados, ...forwarSinAsociar].filter(
      (x: IDcForward) => x.saldoforward > 0
    );
    for (const fwd of forwards) {
      fwd.diftasa = round((fwd.trmdesembolso ? fwd.trmdesembolso : fwd.tasaspot) - fwd.tasaforward, 2);
      fwd.totaldifcambio = round(fwd.diftasa * fwd.saldoforward, 2);
      fwd.difxdia = round(
        fwd.totaldifcambio /
          (fwd.idcredito == 0 ? fwd.dias : moment(fwd.fechacumplimiento).diff(fwd.fechadesembolso, 'day')),
        2
      );
      fwd.diascausados =
        fwd.idcredito === 0
          ? moment(fecha).diff(fwd.fechaoperacion, 'day')
          : moment(fecha).diff(fwd.fechadesembolso, 'day');
      fwd.difacumulada = round(fwd.diascausados * fwd.difxdia, 2);
      fwd.difxcausar = round(fwd.totaldifcambio - fwd.difacumulada, 2);
      fwd.devaluacioncr =
        fwd.idcredito === 0 ? 0 : round(devaluation(fwd.tasaforward, fwd.tasadeuda, fwd.diascausados), 4);
    }
    await transaction.request().query(`
      INSERT INTO dc_forward VALUES 
      ${forwards.map(
        (fwd) =>
          `(${fwd.ano}, ${fwd.periodo}, ${fwd.idforward}, ${fwd.idcredito}, '${fwd.regional}', '${fwd.entfinanciera}', '${fwd.lineacreadito}', ${fwd.valorusd}, '${fwd.fechaoperacion}', '${fwd.fechacumplimiento}', ${fwd.dias}, ${fwd.tasaspot}, ${fwd.devaluacion}, ${fwd.tasaforward}, ${fwd.valorcop}, ${fwd.saldoforward}, ${fwd.saldoforwardcop}, ${fwd.tasadeuda}, ${fwd.fechadesembolso ? `'${fwd.fechadesembolso}'` : null}, ${fwd.diftasa}, ${fwd.totaldifcambio}, ${fwd.difxdia}, ${fwd.diascausados}, ${fwd.difacumulada}, ${fwd.difxcausar}, ${fwd.devaluacioncr} )\n`
      )}`);
  }

  async createConsolidado(transaction: mssql.Transaction, parametros: Parametros) {
    const { nick, nit, fecha } = parametros;
    await transaction
      .request()
      .input('fecha', mssql.Date(), fecha)
      .input('nick', mssql.VarChar(50), nick ?? null)
      .input('nit', mssql.VarChar(15), nit ?? null)
      .execute('sc_dc_consolidado');
  }
}
