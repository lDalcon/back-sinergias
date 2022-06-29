import mssql from 'mssql';
import dbConnection from '../database';
import bcrypt from 'bcrypt'
import { Menu } from './menu.model';

export class Usuario {
    nick: string = '';
    nombres: string = '';
    apellidos: string = '';
    password: string = '';
    menu: Menu = new Menu();
    estado: boolean = true;

    constructor(usuario?: any) {
        this.nick = usuario?.nick || this.nick;
        this.nombres = usuario?.nombres || this.nombres;
        this.apellidos = usuario?.apellidos || this.apellidos;
        this.password = usuario?.password || this.password;
        this.estado = usuario?.estado || this.estado;
        if (typeof (usuario?.menu?.opciones) === 'string') usuario.menu.opciones = JSON.parse(usuario.menu.opciones);
        this.menu = usuario?.menu || this.menu;
    }

    async guardar(): Promise<{ ok: boolean, message: any }> {
        const password = bcrypt.hashSync(this.password, bcrypt.genSaltSync());
        let pool = await dbConnection();
        return new Promise((resolve, reject) => {
            pool.request()
                .input('nick', mssql.VarChar(50), this.nick)
                .input('nombres', mssql.VarChar(100), this.nombres)
                .input('apellidos', mssql.VarChar(100), this.apellidos)
                .input('password', mssql.VarChar(4000), password)
                .input('role', mssql.VarChar(50), this.menu.role)
                .execute('sc_usuario_crear')
                .then(() => {
                    pool.close();
                    resolve({ ok: true, message: 'Usuario creado' })
                })
                .catch(err => {
                    console.log(err);
                    pool.close();
                    resolve({ ok: false, message: err })
                })
        });
    }

    async login(): Promise<{ ok: boolean, usuario?: Usuario, message?: any }> {
        let pool = await dbConnection();
        return new Promise((resolve, reject) => {
            pool.request()
                .input('nick', mssql.VarChar(100), this.nick)
                .execute('sc_usuario_login')
                .then(result => {
                    pool.close();
                    let usuario: Usuario = new Usuario(result.recordset[0][0]);
                    if (bcrypt.compareSync(this.password, usuario.password)) {
                        usuario.password = '';
                        resolve({ ok: true, usuario })
                    } else {
                        resolve({ ok: false, message: 'Los datos de sesion son incorrectos' })
                    }
                })
                .catch(err => {
                    pool.close();
                    console.log(err);
                    resolve({ ok: false, message: err })
                })
        });
    }

    async getAll(): Promise<{ ok: boolean, data?: Usuario[], message?: any }> {
        let pool = await dbConnection();
        return new Promise((resolve, reject) => {
            pool.request()
                .execute('sc_usuario_listar')
                .then(result => {
                    pool.close();
                    let usuarios: Usuario[] = result.recordset[0][0];
                    resolve({ ok: true, data: usuarios });
                })
                .catch(err => {
                    pool.close();
                    console.log(err);
                    resolve({ ok: false, message: err })
                })
        });
    }

}