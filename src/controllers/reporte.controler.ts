//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from 'express';
import { Reporte } from '../models/reporte.model';
import { Usuario } from '../models/usuario.model';

//===============================================================================
// Funtions
//===============================================================================
export const reporteConsolidado = async (req: Request, res: Response) => {
  let reporte = new Reporte();
  let usuario: Usuario = req['usrtoken'];
  await reporte
    .reporteConsolidado(req.query['ano'], req.query['periodo'], usuario.nick)
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};

export const diferenciaCambio = async (req: Request, res: Response) => {
  let reporte = new Reporte();
  await reporte
    .diferenciaCambio(req.body)
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};

export const infoRegistroSolicitud = async (req: Request, res: Response) => {
  let reporte = new Reporte();
  await reporte
    .infoRegistroSolicitud(+req.params['regional'])
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};
