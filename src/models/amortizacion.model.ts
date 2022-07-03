export class Amortizacion {
    nper: number = -1;
    fechaPeriodo: Date = new Date('1900-01-01');
    tasaIdxEA: number = 0;
    spreadEA: number = 0;
    tasaEA: number = 0;
    saldoCapital: number = 0;
    valorInteres: number = 0;
    abonoCapital: number = 0;
    pagoTotal: number = 0;
    interesCausado: number = 0;
    actualizaIdx: boolean = false;

    constructor(amortizacion?: any) {
        this.nper = amortizacion?.nper || this.nper;
        this.fechaPeriodo = new Date(amortizacion?.fechaPeriodo) || this.fechaPeriodo;
        this.tasaIdxEA = amortizacion?.tasaIdxEA || this.tasaIdxEA;
        this.spreadEA = amortizacion?.spreadEA || this.spreadEA;
        this.tasaEA = amortizacion?.tasaEA || this.tasaEA;
        this.saldoCapital = amortizacion?.saldoCapital || this.saldoCapital;
        this.valorInteres = amortizacion?.valorInteres || this.valorInteres;
        this.abonoCapital = amortizacion?.abonoCapital || this.abonoCapital;
        this.pagoTotal = amortizacion?.pagoTotal || this.pagoTotal;
        this.interesCausado = amortizacion?.interesCausado || this.interesCausado;
        this.actualizaIdx = amortizacion?.actualizaIdx || this.actualizaIdx;
    }

}