import mssql from 'mssql';
import dbConnection from '../config/database';
import bcrypt from 'bcrypt';
import { Menu } from './menu.model';
import { Regional } from './regional.model';

export class Usuario {
  nick: string = '';
  nombres: string = '';
  apellidos: string = '';
  password: string = '';
  email: string = '';
  menu: Menu = new Menu();
  regionales: Regional[] = [];
  estado: boolean = true;

  constructor(usuario?: any) {
    this.nick = usuario?.nick || this.nick;
    this.nombres = usuario?.nombres || this.nombres;
    this.apellidos = usuario?.apellidos || this.apellidos;
    this.password = usuario?.password || this.password;
    this.email = usuario?.email || this.email;
    if (typeof usuario?.menu?.opciones === 'string') usuario.menu.opciones = JSON.parse(usuario.menu.opciones);
    this.menu = usuario?.menu || this.menu;
    if (usuario?.regionales) usuario.regionales.forEach((regional) => (regional = new Regional(regional)));
    this.regionales = usuario?.regionales || this.regionales;
    this.estado = usuario?.estado;
  }

  async guardar(): Promise<{ ok: boolean; message: any }> {
    const password = bcrypt.hashSync(this.password, bcrypt.genSaltSync());
    let pool = await dbConnection();
    return new Promise((resolve, reject) => {
      pool
        .request()
        .input('nick', mssql.VarChar(50), this.nick)
        .input('nombres', mssql.VarChar(100), this.nombres)
        .input('apellidos', mssql.VarChar(100), this.apellidos)
        .input('password', mssql.VarChar(4000), password)
        .input('email', mssql.VarChar(100), this.email)
        .input('role', mssql.VarChar(50), this.menu.role)
        .execute('sc_usuario_crear')
        .then(() => {
          pool.close();
          resolve({ ok: true, message: 'Usuario creado' });
        })
        .catch((err) => {
          console.log(err);
          pool.close();
          resolve({ ok: false, message: err });
        });
    });
  }

  async actualizar(): Promise<{ ok: boolean; message: string }> {
    let pool = await dbConnection();
    return new Promise((resolve, reject) => {
      pool
        .request()
        .input('nick', mssql.VarChar(50), this.nick)
        .input('nombres', mssql.VarChar(100), this.nombres)
        .input('apellidos', mssql.VarChar(100), this.apellidos)
        .input('email', mssql.VarChar(100), this.email)
        .input('role', mssql.VarChar(50), this.menu.role)
        .input('estado', mssql.Bit(), this.estado)
        .execute('sc_usuario_actualizar')
        .then(() => {
          pool.close();
          resolve({ ok: true, message: 'Usuario actualizado' });
        })
        .catch((err) => {
          console.log(err);
          pool.close();
          resolve({ ok: false, message: err });
        });
    });
  }

  async login(): Promise<{ ok: boolean; usuario?: Usuario; message?: any }> {
    let pool = await dbConnection();
    return new Promise((resolve, reject) => {
      pool
        .request()
        .input('nick', mssql.VarChar(100), this.nick)
        .execute('sc_usuario_login')
        .then((result) => {
          pool.close();
          let usuario: Usuario = new Usuario(result.recordset[0][0]);
          if (bcrypt.compareSync(this.password, usuario.password)) {
            usuario.password = '';
            resolve({ ok: true, usuario });
          } else {
            resolve({ ok: false, message: 'Los datos de sesion son incorrectos' });
          }
        })
        .catch((err) => {
          pool.close();
          console.log(err);
          resolve({ ok: false, message: err });
        });
    });
  }

  async listar(): Promise<{ ok: boolean; data?: Usuario[]; message?: any }> {
    let pool = await dbConnection();
    return new Promise((resolve, reject) => {
      pool
        .request()
        .execute('sc_usuario_listar')
        .then((result) => {
          pool.close();
          result.recordset[0].forEach((usuario) => {
            if (usuario.regionales === '[]') usuario.regionales = [];
            usuario.regionales.forEach((regional) => {
              regional = new Regional(regional);
            });
          });
          resolve({ ok: true, data: result.recordset[0] });
        })
        .catch((err) => {
          pool.close();
          console.log(err);
          resolve({ ok: false, message: err });
        });
    });
  }

  async asociarEmpresas(): Promise<{ ok: boolean; message: any }> {
    let pool = await dbConnection();
    let transaction = new mssql.Transaction(pool);
    return new Promise(async (resolve, reject) => {
      try {
        await transaction.begin();
        await this.borrarUsuarioRegionalByNick(transaction);
        for (let i = 0; i < this.regionales.length; i++) {
          await this.agregarUsuariorRegional(transaction, this.regionales[i].id);
        }
        await transaction.commit();
        resolve({ ok: true, message: 'Transacciones realizadas' });
      } catch (error) {
        console.log(error);
        await transaction.rollback();
        resolve({ ok: false, message: error });
      }
    });
  }

  async borrarUsuarioRegionalByNick(transaction: mssql.Transaction) {
    try {
      await transaction.request().input('nick', mssql.VarChar(50), this.nick).execute('sc_usuarioregional_delete');
    } catch (error) {
      console.log(error);
      throw new Error('Error al eliminar usuario regional');
    }
  }

  async agregarUsuariorRegional(transaction: mssql.Transaction, idRegional: string) {
    try {
      await transaction
        .request()
        .input('nick', mssql.VarChar(50), this.nick)
        .input('idregional', mssql.Int(), +idRegional)
        .execute('sc_usuarioregional_add');
    } catch (error) {
      console.log(error);
      throw new Error('Error al eliminar usuario regional');
    }
  }
}
