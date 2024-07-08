export class ValorCatalogo {
  id: number = -1;
  ctgid: string = '';
  descripcion: string = '';
  config: any;

  constructor(valorCatalogo?: any) {
    this.id = valorCatalogo?.id || this.id;
    this.ctgid = valorCatalogo?.ctgid || this.ctgid;
    this.descripcion = valorCatalogo?.descripcion || this.descripcion;
    if (typeof valorCatalogo?.config === 'string') valorCatalogo.config = JSON.parse(valorCatalogo.config);
    this.config = valorCatalogo?.config || this.config;
  }
}
