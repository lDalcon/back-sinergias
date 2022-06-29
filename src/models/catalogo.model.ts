import mssql from 'mssql';
import dbConnection from "../database";
import { ValorCatalogo } from "./valor-catalogo.model";

export class Catalogo {
    id: string = ''
    descripcion: string = ''
    config: any;
    valorcatalogo: ValorCatalogo[] = [];

    constructor(catalogo?: any) {
        this.id = catalogo?.id || this.id;
        this.descripcion = catalogo?.descripcion || this.descripcion;
        if (typeof (catalogo?.config) === 'string') catalogo.config = JSON.parse(catalogo.config);
        this.config = catalogo?.config || this.config;
        this.valorcatalogo = catalogo?.valorcatalogo || this.valorcatalogo;
        this.valorcatalogo.forEach(valor => {
            if (typeof (valor.config) === 'string') valor.config = JSON.parse(valor.config)
        });
    }

    async getById(): Promise<{ ok: boolean, catalogo?: Catalogo, message?: any }> {
        let pool = await dbConnection();
        return new Promise((resolve, reject) => {
            pool.request()
                .input('id', mssql.VarChar(100), this.id)
                .execute('sc_getCatalogoById')
                .then(result => {
                    pool.close();
                    if (result.recordset[0]) resolve({ ok: true, catalogo: new Catalogo(result.recordset[0][0]) })
                    else resolve({ ok: false, message: 'El catalogo no existe' })
                })
                .catch(err => {
                    pool.close();
                    console.log(err);
                    resolve({ ok: false, message: err })
                })
        });
    }
}


