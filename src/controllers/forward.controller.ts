//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from 'express';
import { CierreForward } from '../models/cierre-forward.model';
import { CreditoForward } from '../models/credito-forward.model';
import { Forward } from '../models/forward.model';
import { Usuario } from '../models/usuario.model';

//===============================================================================
// Funtions
//===============================================================================
export const crearForward = async (req: Request, res: Response) => {
  let forward: Forward = new Forward(req.body);
  let usuario: Usuario = req['usrtoken'];
  forward.usuariocrea = usuario.nick;
  let result = await forward.guardar();
  if (!result.ok) return res.status(400).json(result);
  return res.status(200).json(result);
};

export const actualizarForward = async (req: Request, res: Response) => {
  let forward: Forward = new Forward(req.body);
  let usuario: Usuario = req['usrtoken'];
  forward.usuariomod = usuario.nick;
  let result = await forward.actualizar();
  if (!result.ok) return res.status(400).json(result);
  return res.status(200).json(result);
};

export const listarForward = async (req: Request, res: Response) => {
  let forward: Forward = new Forward();
  forward.usuariocrea = req['usrtoken']['nick'];
  await forward
    .listar(req.query)
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};

export const obtenerForward = async (req: Request, res: Response) => {
  let forward: Forward = new Forward(req.params);
  await forward
    .obtener()
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};

export const asignarCredito = async (req: Request, res: Response) => {
  let creditoForward: CreditoForward = new CreditoForward(req.body);
  let usuario: Usuario = req['usrtoken'];
  creditoForward.usuariocrea = usuario.nick;
  await creditoForward
    .asignarCredito()
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};

export const cerrar = async (req: Request, res: Response) => {
  let cierreForward: CierreForward = new CierreForward(req.body);
  let usuario: Usuario = req['usrtoken'];
  cierreForward.usuario = usuario.nick;
  await new Forward()
    .procesarCierre(cierreForward)
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};

export const editarCreditoForward = async (req: Request, res: Response) => {
  let data = req.body;
  let usuario: Usuario = req['usrtoken'];
  data.usuario = usuario.nick;
  await new CreditoForward()
    .procesarEdicion(data)
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};
