import mssql from 'mssql';
import dbConnection from '../config/database';
import { ValorCatalogo } from './valor-catalogo.model';

export class AumentoCapital {
  ano: number = 0;
  periodo: number = 0;
  idcredito: number = 0;
  fecha: Date = new Date('1900-01-01');
  valor: number = 0;
  moneda: ValorCatalogo = new ValorCatalogo();
  observacion: string = '';
  usuariocrea: string = '';
  fechacrea: Date = new Date('1900-01-01');

  constructor(aumentoCapital?: any) {
    this.ano = aumentoCapital?.ano || this.ano;
    this.periodo = aumentoCapital?.periodo || this.periodo;
    this.idcredito = aumentoCapital?.idcredito || this.idcredito;
    this.fecha = aumentoCapital?.fechadesembolso || this.fecha;
    this.valor = aumentoCapital?.valor || this.valor;
    this.moneda = aumentoCapital?.moneda || this.moneda;
    this.observacion = aumentoCapital?.observacion || this.observacion;
    this.usuariocrea = aumentoCapital?.usuariocrea || this.usuariocrea;
    this.fechacrea = aumentoCapital?.fechacrea || this.fechacrea;
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
        .input('fechadesembolso', mssql.Date(), this.fecha)
        .input('moneda', mssql.Int(), this.moneda.id)
        .execute('sc_credito_guardar');
      if (!isTrx) {
        transaction.commit();
        pool.close();
      }
      return { ok: true, message: 'Credito creado' };
    } catch (error) {
      console.log(error);
      if (!isTrx) {
        await transaction.rollback();
        pool.close();
      }
      return { ok: false, message: error };
    }
  }
}
