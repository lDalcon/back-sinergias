//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from 'express';
import { Regional } from '../models/regional.model';
//===============================================================================
// Funtions
//===============================================================================
export const getAll = async (req: Request, res: Response) => {
  let regional: Regional = new Regional();
  regional
    .getAll()
    .then((result) => {
      if (result.ok) return res.status(200).json(result);
      return res.status(400).json(result);
    })
    .catch((err) => {
      return res.status(500).json({ ok: false, message: err });
    });
};

export const getByNit = async (req: Request, res: Response) => {
  let regional: Regional = new Regional();
  regional.nit = req.params.nit;
  let result = await regional.getByNit();
  if (!result.ok) return res.status(400).json(result);
  return res.status(200).json({
    ok: true,
    data: result.regionales
  });
};
