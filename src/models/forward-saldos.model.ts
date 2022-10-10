import mssql from 'mssql';

export class ForwardSaldos {
    idforward: number = 0;
    idcredito: number = 0;
    ano: number = 0;
    periodo: number = 0;
    pagos: number = 0;
    asignacion: number = 0;
    saldoinicial: number = 0;
    saldoasignacionini: number = 0;

    constructor(forwardSaldo?: any){
        this.idforward = forwardSaldo?.idforward || this.idforward;
        this.idcredito = forwardSaldo?.idcredito || this.idcredito;
        this.ano = forwardSaldo?.ano || this.ano;
        this.periodo = forwardSaldo?.periodo || this.periodo;
        this.pagos = forwardSaldo?.pagos || this.pagos;
        this.asignacion = forwardSaldo?.asignacion || this.asignacion;
        this.saldoinicial = forwardSaldo?.saldoinicial || this.saldoinicial;
        this.saldoasignacionini = forwardSaldo?.saldoasignacionini || this.saldoasignacionini;
    }

    async actualizarByAnoAndPeriodo(transaction: mssql.Transaction, ano: number, periodo: number, idForward?: number){
        return new Promise((resolve)=> {
            transaction.request()
                .input('ano', mssql.Int(), ano)
                .input('periodo', mssql.Int(), periodo)
                .input('id', mssql.Int(), idForward ? idForward : null)
                .execute('sc_forward_saldos_actualizar')
                .then(() => {
                    resolve({ ok: true, message: 'Proceso exitoso' })
                })
                .catch(err => {
                    console.log(err);
                    resolve({ ok: false, message: err })
                })
        })
    }
}