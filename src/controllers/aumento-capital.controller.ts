//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from 'express';
import { Usuario } from '../models/usuario.model';
import { AumentoCapital } from '../models/aumento-capital.model';
//===============================================================================
// Funtions
//===============================================================================
export const crearAumentoCapital = async (req: Request, res: Response) => {
  let aumentoCapital: AumentoCapital = new AumentoCapital(req.body);
  let usuario: Usuario = req['usrtoken'];
  aumentoCapital.usuariocrea = usuario.nick;
  let result = await aumentoCapital.guardar();
  if (!result.ok) return res.status(400).json(result);
  return res.status(200).json(result);
};
