import dbConnection from "../database";
import mssql from "mssql";

export class Regional {
    id: string = '';
    nit: string = '';
    nombre: string = '';
    config: any;

    constructor(regional?: any) {
        this.id = regional?.id || this.id;
        this.nit = regional?.nit || this.nit;
        this.nombre = regional?.nombre || this.nombre;
        if (typeof (regional?.config) === 'string') regional.config = JSON.parse(regional.config);
        this.config = regional?.config || this.config;
    }

    async getByNit(): Promise<{ ok: boolean, regionales?: Regional[], message?: any }> {
        let pool = await dbConnection();
        return new Promise((resolve, reject) => {
            pool.request()
                .input('nit', mssql.VarChar(15), this.nit)
                .execute('sc_getReginalByNit')
                .then(result => {
                    pool.close();
                    let regionales: Regional[] = [];
                    result.recordset.forEach(reg => {
                        regionales.push(new Regional(reg))
                    })
                    resolve({ ok: true, regionales });
                })
                .catch(err => {
                    pool.close();
                    console.log(err);
                    resolve({ ok: false, message: err })
                })
        });
    }
}