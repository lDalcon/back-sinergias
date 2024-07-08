import mssql from 'mssql';

export class CierreForward {
  ano: number = 0;
  periodo: number = 0;
  id: number = 0;
  valor: number = 0;
  observaciones: string = '';
  fecha: Date = new Date('1900-01-01');
  usuario: string = '';

  constructor(cierreForward?: any) {
    this.ano = cierreForward?.ano || this.ano;
    this.periodo = cierreForward?.periodo || this.periodo;
    this.id = cierreForward?.id || this.id;
    this.valor = cierreForward?.valor || this.valor;
    this.observaciones = cierreForward?.observaciones || this.observaciones;
    this.usuario = cierreForward?.usuario || this.usuario;
  }

  async guardar(transaction: mssql.Transaction) {
    await new mssql.Request(transaction)
      .input('ano', mssql.Int(), this.ano)
      .input('periodo', mssql.Int(), this.periodo)
      .input('id', mssql.Int(), this.id)
      .input('valor', mssql.Numeric(18, 2), this.valor)
      .input('observaciones', mssql.VarChar(200), this.observaciones)
      .input('usuario', mssql.VarChar(50), this.usuario)
      .execute('sc_cierreforward_guardar');
  }
}
