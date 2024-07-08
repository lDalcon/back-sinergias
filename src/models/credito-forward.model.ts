import mssql from 'mssql';
import dbConnection from '../config/database';
import { CalendarioCierre } from './calendario-cierre.model';
import { Credito } from './credito.model';
import { ForwardSaldos } from './forward-saldos.model';
import { Forward } from './forward.model';

export class CreditoForward {
  seq: number = 0;
  ano: number = 0;
  periodo: number = 0;
  idcredito: number = 0;
  credito: Credito = new Credito();
  idforward: number = 0;
  forward: Forward = new Forward();
  valorasignado: number = 0;
  estado: string = '';
  justificacion: string = '';
  usuariocrea: string = '';
  fechacrea: Date = new Date('1900-01-01');
  usuariomod: string = '';
  fechamod: Date = new Date('1900-01-01');

  constructor(creditoforward?: any) {
    this.seq = creditoforward?.seq || this.seq;
    this.ano = creditoforward?.ano || this.ano;
    this.periodo = creditoforward?.periodo || this.periodo;
    this.idcredito = creditoforward?.idcredito || this.idcredito;
    this.credito = new Credito(creditoforward?.credito) || this.credito;
    this.idforward = creditoforward?.idforward || this.idforward;
    this.forward = new Forward(creditoforward?.forward) || this.forward;
    this.valorasignado = creditoforward?.valorasignado || this.valorasignado;
    this.estado = creditoforward?.estado || this.estado;
    this.justificacion = creditoforward?.justificacion || this.justificacion;
    this.usuariocrea = creditoforward?.usuariocrea || this.usuariocrea;
    this.fechacrea = new Date(creditoforward?.fechacrea) || this.fechacrea;
    this.usuariomod = creditoforward?.usuariomod || this.usuariomod;
    this.fechamod = new Date(creditoforward?.fechamod) || this.fechamod;
  }

  async guardar(transaction: mssql.Transaction) {
    await transaction
      .request()
      .input('ano', mssql.Int(), this.ano)
      .input('periodo', mssql.Int(), this.periodo)
      .input('idcredito', mssql.Int(), this.idcredito)
      .input('idforward', mssql.Int(), this.idforward)
      .input('valorasignado', mssql.Numeric(18, 2), this.valorasignado)
      .input('usuariocrea', mssql.VarChar(50), this.usuariocrea)
      .input('estado', mssql.VarChar(50), null)
      .execute('sc_creditoforward_crear');
  }

  async asignarCredito(): Promise<{ ok: boolean; message: any }> {
    let pool = await dbConnection();
    let transaction = new mssql.Transaction(pool);
    return new Promise(async (resolve) => {
      try {
        await transaction.begin();
        let calendario: CalendarioCierre = new CalendarioCierre({ ano: this.ano, periodo: this.periodo });
        calendario = (await calendario.get(transaction))?.calendario || new CalendarioCierre();
        if (!calendario.registro) throw new Error('El mes se encuentra cerrado para registros.');
        await this.obtenerDatos(transaction);
        await this.guardar(transaction);
        await this.credito.actualizarSaldoAsignacion(this.valorasignado, transaction);
        await this.forward.actualizarSaldoAsignacion(this.valorasignado, transaction);
        await new ForwardSaldos().actualizarByAnoAndPeriodo(transaction, this.ano, this.periodo, this.forward.id);
        await transaction.commit();
        resolve({ ok: true, message: 'Proceso realizado' });
      } catch (err) {
        transaction.rollback();
        resolve({ ok: false, message: err });
      }
    });
  }

  async procesarEdicion(data: any) {
    let pool = await dbConnection();
    let transaction = new mssql.Transaction(pool);
    try {
      await transaction.begin();
      let calendario = new CalendarioCierre();
      let isOpen = await calendario.validar(transaction, data.ano, data.periodo, 'registro');
      if (!isOpen) throw new Error('El periodo se encuentra cerrado para registros');
      await this.editar(transaction, data);
      let forward = (await new Forward().obtenerTrx(transaction, data.idforward))?.data || new Forward();
      if (forward.id == 0) throw new Error('Forward no encontrado');
      forward.saldoasignacion += data.valor;
      forward.usuariomod = data.usuario;
      await forward.actualizar(transaction, false);
      let credito = (await new Credito().obtenerTrx(transaction, data.idcredito))?.data || new Credito();
      if (credito.id == 0) throw new Error('El crédito no fue encontrado');
      credito.saldoasignacion += data.valor;
      await credito.actualizar(transaction, false);
      await new ForwardSaldos().actualizarByAnoAndPeriodo(transaction, data.ano, data.periodo, data.idforward);
      await transaction.commit();
      await pool.close();
      return { ok: true, message: `Forward actualizado` };
    } catch (error) {
      console.log(error);
      await transaction.rollback();
      await pool.close();
      return { ok: false, message: error };
    }
  }

  async editar(transaction: mssql.Transaction, data: any) {
    await transaction
      .request()
      .input('seq', mssql.Int(), data.seq)
      .input('ano', mssql.Int(), data.ano)
      .input('periodo', mssql.Int(), data.periodo)
      .input('valor', mssql.Numeric(18, 2), data.valor)
      .input('justificacion', mssql.VarChar(500), data.justificacion)
      .input('usuario', mssql.VarChar(50), data.usuario)
      .execute('sc_creditoforward_editar');
  }

  private async obtenerDatos(transaction: mssql.Transaction) {
    this.credito.id = this.idcredito;
    this.credito = (await this.credito.obtenerTrx(transaction)).data || new Credito();
    if (this.credito.id === 0) throw new Error('Error al obtener credito');
    if (this.credito.estado != 'ACTIVO') throw new Error(`El crédito no se encuentra ACTIVO (${this.credito.estado})`);
    if (this.credito.saldoasignacion <= 0) throw new Error(`El crédito no cuenta con saldo para asignar`);
    this.forward.id = this.idforward;
    this.forward = (await this.forward.obtenerTrx(transaction)).data || new Forward();
    if (this.forward.id === 0) throw new Error('Error al obtener forward');
    if (this.forward.estado != 'ACTIVO') throw new Error(`El forward no se encuentra ACTIVO (${this.forward.estado})`);
    if (this.forward.saldoasignacion <= 0) throw new Error(`El forward no cuenta con saldo para asignar`);
  }
}
