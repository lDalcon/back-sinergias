//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from 'express';
import { Usuario } from '../models/usuario.model';

//===============================================================================
// Funtions
//===============================================================================
export const crearUsuario = async (req: Request, res: Response) => {
  let usuario: Usuario = new Usuario(req.body);
  await usuario
    .guardar()
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};

export const listarUsuarios = async (req: Request, res: Response) => {
  let usuario: Usuario = new Usuario(req.body);
  await usuario
    .listar()
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};

export const actualizar = async (req: Request, res: Response) => {
  let usuario: Usuario = new Usuario(req.body);
  await usuario
    .actualizar()
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};

export const asociarEmpresas = async (req: Request, res: Response) => {
  let usuario: Usuario = new Usuario(req.body);
  await usuario
    .asociarEmpresas()
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};
