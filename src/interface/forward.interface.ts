export interface IForward {
    id: number;
    ano: number;
    periodo: number;
    fechaoperacion: string;
    fechacumplimiento: string;
    entfinanciera: string;
    regional: string;
    valorusd: number;
    tasaspot: number;
    devaluacion: number;
    tasaforward: number;
    valorcop: number;
    saldoasignacion: number;
    estado: string;
    usuariocrea: string;
    fechacrea: Date;
    usuariomod: string;
    fechamod: Date;
}