import mssql from 'mssql';
import dbConnection from '../config/database';
import { CreditoSaldos } from './credito-saldos.model';
import { ForwardSaldos } from './forward-saldos.model';
import moment from 'moment';

export class CalendarioCierre {
  ano: number = 0;
  periodo: number = 0;
  mes: string = '';
  fechainicial: Date = new Date('1900-01-01');
  fechafinal: Date = new Date('1900-01-01');
  proceso: boolean = false;
  registro: boolean = false;

  constructor(calendarioCierre?: any) {
    this.ano = calendarioCierre?.ano || this.ano;
    this.periodo = calendarioCierre?.periodo || this.periodo;
    this.mes = calendarioCierre?.mes || this.mes;
    this.fechainicial = calendarioCierre?.fechainicial || this.fechainicial;
    this.fechafinal = calendarioCierre?.fechafinal || this.fechafinal;
    this.proceso = calendarioCierre?.proceso || this.proceso;
    this.registro = calendarioCierre?.registro || this.registro;
  }

  async actualizar(transaction: mssql.Transaction): Promise<{ ok: boolean; message?: any }> {
    return new Promise((resolve) => {
      transaction
        .request()
        .input('ano', mssql.Int(), this.ano)
        .input('periodo', mssql.Int(), this.periodo)
        .input('proceso', mssql.Bit(), this.proceso)
        .input('registro', mssql.Bit(), this.registro)
        .execute('sc_calendario_actualizar')
        .then(() => {
          resolve({ ok: true, message: 'Registro actualizado' });
        })
        .catch((err) => {
          console.log(err);
          resolve({ ok: false, message: err });
        });
    });
  }

  async get(transaction?: mssql.Transaction): Promise<{ ok: boolean; calendario?: CalendarioCierre; message?: any }> {
    let isTrx: boolean = true;
    let pool = await dbConnection();
    if (!transaction) {
      transaction = new mssql.Transaction(pool);
      isTrx = false;
    }
    try {
      if (!isTrx) await transaction.begin();
      let result = await new mssql.Request(transaction)
        .input('ano', mssql.Int(), this.ano)
        .input('periodo', mssql.Int(), this.periodo)
        .execute('sc_calendario_obtener');
      if (!isTrx) {
        transaction.commit();
        pool.close();
      }
      return { ok: true, calendario: result.recordset[0][0] };
    } catch (error) {
      console.log(error);
      if (!isTrx) {
        await transaction.rollback();
        pool.close();
      }
      return { ok: false, message: error };
    }
  }

  async getByAno(): Promise<{ ok: boolean; data?: CalendarioCierre[]; message?: any }> {
    let pool = await dbConnection();
    return new Promise((resolve) => {
      pool
        .request()
        .input('ano', mssql.Int(), this.ano)
        .execute('sc_calendariocierre_ano')
        .then((result) => {
          resolve({ ok: true, data: result.recordset });
        })
        .catch((err) => {
          console.log(err);
          resolve({ ok: false, message: err });
        });
    });
  }

  async obtenerActivos(trx: string): Promise<{ ok: boolean; data?: CalendarioCierre[]; message?: any }> {
    let pool = await dbConnection();
    return new Promise((resolve) => {
      pool
        .request()
        .input('trx', mssql.VarChar(10), trx)
        .execute('sc_calendario_obtenerActivos')
        .then((result) => {
          pool.close();
          resolve({ ok: true, data: result.recordset[0] });
        })
        .catch((err) => {
          pool.close();
          console.log(err);
          resolve({ ok: false, message: err });
        });
    });
  }

  async actualizarPeriodo(): Promise<{ ok: boolean; message?: any }> {
    let pool = await dbConnection();
    let transaction = new mssql.Transaction(pool);
    let creditoSaldos: CreditoSaldos = new CreditoSaldos();
    let forwardSaldos: ForwardSaldos = new ForwardSaldos();
    return new Promise(async (resolve) => {
      let result: any;
      try {
        await transaction.begin();
        if (!this.proceso) {
          result = await this.actualizarSaldos(transaction);
          if (!result.ok) throw new Error(result.message);
          result = await creditoSaldos.actualizarByAnoAndPeriodo(transaction, this.ano, this.periodo);
          if (!result.ok) throw new Error(result.message);
          result = await forwardSaldos.actualizarByAnoAndPeriodo(transaction, this.ano, this.periodo);
          if (!result.ok) throw new Error(result.message);
        }
        result = await this.actualizar(transaction);
        if (!result.ok) throw new Error(result.message);
        await transaction.commit();
        resolve({ ok: true, message: 'Actualización exitosa!' });
      } catch (err) {
        await transaction.rollback();
        resolve({ ok: false, message: err });
      }
    });
  }

  async actualizarSaldos(transaction: mssql.Transaction): Promise<{ ok: boolean; message?: any }> {
    return new Promise((resolve) => {
      transaction
        .request()
        .execute('sc_actualizar_saldos')
        .then(() => {
          resolve({ ok: true, message: 'Registros actualizados' });
        })
        .catch((err) => {
          console.log(err);
          resolve({ ok: false, message: err });
        });
    });
  }

  async validar(transaction: mssql.Transaction, ano: number, periodo: number, proceso: string): Promise<boolean> {
    let calendario: CalendarioCierre = new CalendarioCierre({ ano, periodo });
    calendario = (await calendario.get(transaction))?.calendario || new CalendarioCierre();
    return proceso == 'registro' ? calendario.registro : calendario.proceso;
  }

  async validarFecha(transaction: mssql.Transaction, fecha: string, proceso: string): Promise<boolean> {
    let calendario: CalendarioCierre = new CalendarioCierre({ ano: moment(fecha).year(), periodo: moment(fecha).month() + 1 });
    calendario = (await calendario.get(transaction))?.calendario || new CalendarioCierre();
    return proceso == 'registro' ? calendario.registro : calendario.proceso;
  }
}
