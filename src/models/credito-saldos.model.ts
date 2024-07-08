import mssql from 'mssql';

export class CreditoSaldos {
  id: number = 0;
  ano: number = 0;
  periodo: number = 0;
  abonoscapital: number = 0;
  interespago: number = 0;
  interescausado: number = 0;
  tasapromedio: number = 0;
  saldokinicial: number = 0;
  saldokfinal: number = 0;

  constructor(creditoSaldo?: any) {
    this.id = creditoSaldo?.id || this.id;
    this.ano = creditoSaldo?.ano || this.ano;
    this.periodo = creditoSaldo?.periodo || this.periodo;
    this.abonoscapital = creditoSaldo?.abonoscapital || this.abonoscapital;
    this.interespago = creditoSaldo?.interespago || this.interespago;
    this.interescausado = creditoSaldo?.interescausado || this.interescausado;
    this.tasapromedio = creditoSaldo?.tasapromedio || this.tasapromedio;
    this.saldokinicial = creditoSaldo?.saldokinicial || this.saldokinicial;
    this.saldokfinal = creditoSaldo?.saldokfinal || this.saldokfinal;
  }

  async actualizarByAnoAndPeriodo(
    transaction: mssql.Transaction,
    ano: number,
    periodo: number,
    idCredito?: number
  ): Promise<{ ok: boolean; message?: any }> {
    return new Promise((resolve) => {
      transaction
        .request()
        .input('ano', mssql.Int(), ano)
        .input('periodo', mssql.Int(), periodo)
        .input('id', mssql.Int(), idCredito ? idCredito : null)
        .execute('sc_credito_saldos_actualizar')
        .then(() => {
          resolve({ ok: true, message: 'Proceso exitoso' });
        })
        .catch((err) => {
          console.log(err);
          resolve({ ok: false, message: err });
        });
    });
  }
}
