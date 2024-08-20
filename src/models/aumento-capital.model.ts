import mssql from 'mssql';
import dbConnection from '../config/database';
import { CalendarioCierre } from './calendario-cierre.model';
import moment from 'moment';

export class AumentoCapital {
  seq: number = 0;
  ano: number = 0;
  periodo: number = 0;
  idcredito: number = 0;
  fecha: string = '';
  tipo: string = '';
  valor: number = 0;
  observacion: string = '';
  estado: string = 'ACTIVO';
  usuariocrea: string = '';
  fechacrea: string = '';
  seqrv?: number;

  constructor(aumentoCapital?: any) {
    this.ano = aumentoCapital?.ano || this.ano;
    this.periodo = aumentoCapital?.periodo || this.periodo;
    this.idcredito = aumentoCapital?.idcredito || this.idcredito;
    this.fecha = aumentoCapital?.fecha || this.fecha;
    this.tipo = aumentoCapital?.tipo || this.tipo;
    this.valor = aumentoCapital?.valor || this.valor;
    this.observacion = aumentoCapital?.observacion || this.observacion;
    this.estado = aumentoCapital?.estado || this.estado;
    this.usuariocrea = aumentoCapital?.usuariocrea || this.usuariocrea;
    this.fechacrea = aumentoCapital?.fechacrea || this.fechacrea;
    this.seq = aumentoCapital?.seq || this.seq;
    this.seqrv = aumentoCapital?.seqrv || this.seqrv;
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
      let isOpen = await new CalendarioCierre().validarFecha(transaction, this.fecha, 'registro');
      if(!isOpen) throw new Error(`El mes se encuentra cerrado para registros.`);
      await new mssql.Request(transaction)
        .input('fecha', mssql.Date(), this.fecha)
        .input('idcredito', mssql.Int(), this.idcredito)
        .input('tipo', mssql.VarChar(), this.tipo)
        .input('valor', mssql.Numeric(18, 2), this.valor)
        .input('estado', mssql.VarChar(10), this.estado)
        .input('observacion', mssql.VarChar(500), this.observacion)
        .input('usuariocrea', mssql.VarChar(50), this.usuariocrea)
        .execute('sc_aumento_capital_guardar');
      if (!isTrx) {
        transaction.commit();
        pool.close();
      }
      return { ok: true, message: 'Aumento Creado' };
    } catch (error: any) {
      console.log(error);
      if (!isTrx) {
        await transaction.rollback();
        pool.close();
      }
      return { ok: false, message: error['message'] };
    }
  }

  async listar(query: any, transaction?: mssql.Transaction) {
    let isTrx: boolean = true;
    let pool = await dbConnection();
    if (!transaction) {
      transaction = new mssql.Transaction(pool);
      isTrx = false;
    }
    try {
      if (!isTrx) await transaction.begin();
      const response = await new mssql.Request(transaction)
        .input('idcredito', mssql.Int(), query.idcredito)
        .execute('sc_aumento_capital_listar');
      if (!isTrx) {
        transaction.commit();
        pool.close();
      }
      return { ok: true, data: response.recordset };
    } catch (error: any) {
      console.log(error);
      if (!isTrx) {
        await transaction.rollback();
        pool.close();
      }
      return { ok: false, message: error['message'] };
    }
  }
}
