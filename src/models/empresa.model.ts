import dbConnection from '../config/database';
import mssql from 'mssql';

export class Empresa {
  nit: string = '';
  razonsocial: string = '';
  cluster: string = '';
  config: any;

  constructor(empresa?: any) {
    this.nit = empresa?.nit || this.nit;
    this.razonsocial = empresa?.razonsocial || this.razonsocial;
    this.cluster = empresa?.cluster || this.cluster;
    if (typeof empresa?.config === 'string') empresa.config = JSON.parse(empresa.config);
    this.config = empresa?.config || this.config;
  }

  async getAll(): Promise<{ ok: boolean; data?: Empresa[]; message?: any }> {
    let pool = await dbConnection();
    return new Promise((resolve) => {
      pool
        .request()
        .execute('sc_empresa_listar')
        .then((result) => {
          let empresas: Empresa[] = [];
          result.recordset.forEach((reg) => {
            empresas.push(new Empresa(reg));
          });
          resolve({ ok: true, data: empresas });
        })
        .catch((err) => {
          resolve({ ok: false, message: err });
        })
        .finally(() => {
          pool.close();
        });
    });
  }
}
