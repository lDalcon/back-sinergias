export class Empresa {
    nit: string = '';
    razonsocial: string = '';
    cluster: string = '';
    config: any;

    constructor(empresa?: any) {
        this.nit = empresa?.nit || this.nit;
        this.razonsocial = empresa?.razonsocial || this.razonsocial;
        this.cluster = empresa?.cluster || this.cluster;
        if (typeof (empresa?.config) === 'string') empresa.config = JSON.parse(empresa.config);
        this.config = empresa?.config || this.config;
    }
}