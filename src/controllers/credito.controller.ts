//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from 'express';
import { Credito } from '../models/credito.model';
import { Usuario } from '../models/usuario.model';

//===============================================================================
// Funtions
//===============================================================================
export const crearCredito = async (req: Request, res: Response) => {
  let credito: Credito = new Credito(req.body);
  let usuario: Usuario = req['usrtoken'];
  credito.usuariocrea = usuario.nick;
  let result = await credito.guardar();
  if (!result.ok) return res.status(400).json(result);
  return res.status(200).json(result);
};

export const actualizar = async (req: Request, res: Response) => {
  let credito: Credito = new Credito(req.body);
  let usuario: Usuario = req['usrtoken'];
  credito.usuariomod = usuario.nick;
  let result = await credito.actualizar();
  if (!result.ok) return res.status(400).json(result);
  return res.status(200).json(result);
};

export const anular = async (req: Request, res: Response) => {
  let credito: Credito = new Credito(req.body);
  let usuario: Usuario = req['usrtoken'];
  credito.usuariomod = usuario.nick;
  let result = await credito.anular(undefined, true);
  if (!result.ok) return res.status(400).json(result);
  return res.status(200).json(result);
};

export const simularCredito = async (req: Request, res: Response) => {
  let credito: Credito = new Credito(req.body);
  await credito.simular365();
  return res.status(200).json({ ok: true, data: credito });
};

export const listarCreditos = async (req: Request, res: Response) => {
  let credito: Credito = new Credito();
  credito.usuariocrea = req['usrtoken']['nick'];
  await credito
    .listar(req.query)
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};

export const obtenerCredito = async (req: Request, res: Response) => {
  let credito: Credito = new Credito(req.params);
  credito
    .obtener()
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};

export const validarPagare = async (req: Request, res: Response) => {
  let credito: Credito = new Credito(req.params);
  credito.entfinanciera.id = +req.params.entfinanciera;
  credito
    .validarPagare()
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};

export const actualizarAmortizacion = async (req: Request, res: Response) => {
  let credito: Credito = new Credito();
  credito
    .actualizarAmortizacion(req.body)
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};
