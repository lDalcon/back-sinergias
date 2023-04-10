import mssql from 'mssql';
import dbConnection from "../config/database";
import { Regional } from "./regional.model";
import { ValorCatalogo } from "./valor-catalogo.model";

export class CuentaBancaria {
    id: number = 0
    regional: Regional = new Regional();
    tipocuenta: ValorCatalogo = new ValorCatalogo();
    entfinancienta: ValorCatalogo = new ValorCatalogo();
    ncuenta: string = '';
    moneda: ValorCatalogo = new ValorCatalogo();
    fechaapertura: Date = new Date('1900-01-01');
    estado: boolean = true;

    constructor(cuentabancaria?: any){
        this.id = cuentabancaria?.id || this.id;
        this.regional = new Regional(cuentabancaria?.regional) || this.regional;
        this.tipocuenta = new ValorCatalogo(cuentabancaria?.tipocuenta) || this.tipocuenta;
        this.entfinancienta = new ValorCatalogo(cuentabancaria?.entfinancienta) || this.entfinancienta;
        this.ncuenta = cuentabancaria?.ncuenta || this.ncuenta ;
        this.moneda = new ValorCatalogo(cuentabancaria?.moneda) || this.moneda;
        this.fechaapertura = cuentabancaria?.fechaapertura || this.fechaapertura   ;
        this.estado = cuentabancaria?.estado;
    }

    async guardar(transaction?: mssql.Transaction){
        let isTrx: boolean = true;
        let pool = await dbConnection();
        if (!transaction) {
            transaction = new mssql.Transaction(pool);
            isTrx = false;
        }
        try {
            if (!isTrx) await transaction.begin();
            await new mssql.Request(transaction)
                .input('regional', mssql.Int(), this.regional.id)
                .input('tipocuenta', mssql.Int(), this.tipocuenta.id)
                .input('entfinancienta', mssql.Int(), this.entfinancienta.id)
                .input('ncuenta', mssql.VarChar(100), this.ncuenta)
                .input('moneda', mssql.Int(), this.moneda.id)
                .input('fechaapertura', mssql.Date(), this.fechaapertura)
                .execute('sc_cuentasbancarias_crear')
            if (!isTrx) {
                transaction.commit();
                pool.close();
            }
            return { ok: true, message: 'Cuenta creada' }
        } catch (error) {
            console.log(error)
            if (!isTrx) {
                await transaction.rollback();
                pool.close();
            }
            return { ok: false, message: error }
        }
    }
}