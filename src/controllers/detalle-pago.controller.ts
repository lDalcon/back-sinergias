//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from 'express';
import { DetallePago } from '../models/detalle-pago.model';
import { Usuario } from '../models/usuario.model';

//===============================================================================
// Funtions
//===============================================================================

export const procesarDetallePago = async (req: Request, res: Response) => {
  let detallePago: DetallePago = new DetallePago();
  let pagos: DetallePago[] = req.body;
  let usuario: Usuario = req['usrtoken'];
  await detallePago
    .procesarDetallePago(pagos, usuario.nick)
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};

export const reversarPago = async (req: Request, res: Response) => {
  let detallePago = new DetallePago(req.body);
  let usuario: Usuario = req['usrtoken'];
  await detallePago
    .procesarReverso(usuario.nick)
    .then((result) => {
      if (!result.ok) return res.status(400).json(result);
      return res.status(200).json(result);
    })
    .catch((err) => res.status(500).json({ ok: false, message: err }));
};
