//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from 'express';
import generarJWT from '../helpers/jwt';
import { Usuario } from '../models/usuario.model';
//===============================================================================
// Funtions
//===============================================================================
const login = async (req: Request, res: Response) => {
  let usuario: Usuario = new Usuario(req.body);
  let token: string = '';
  let result = await usuario.login();
  if (!result.ok) return res.status(400).json(result);
  token = await generarJWT(result?.usuario || new Usuario());
  return res.status(200).json({
    ok: true,
    data: result.usuario,
    token
  });
};

//===============================================================================
// Exports
//===============================================================================
export default login;
