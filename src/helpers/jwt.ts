//===============================================================================
// Imports
//===============================================================================
import jwt from 'jsonwebtoken';
import { Usuario } from '../models/usuario.model';
import dotenv from 'dotenv';
//===============================================================================
// Funtions
//===============================================================================
dotenv.config();

const generarJWT = (usuario: Usuario): Promise<string> => {
  return new Promise((resolve, reject) => {
    const payload = { usuario: JSON.stringify(usuario) };
    jwt.sign(payload, process.env.APP_SEED || '', { expiresIn: '12h' }, (err, token) => {
      if (err) {
        console.log(err);
        reject('No se pudo generar el JWT');
      } else {
        resolve(token || '');
      }
    });
  });
};
//===============================================================================
// Funtions
//===============================================================================
export default generarJWT;
