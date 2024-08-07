//===============================================================================
// Imports
//===============================================================================
import { NextFunction, Request, Response } from 'express';
import { validationResult } from 'express-validator';

//===============================================================================
// Funtions
//===============================================================================
const validarCampos = (req: Request, res: Response, next: NextFunction) => {
  const errores = validationResult(req);
  if (!errores.isEmpty()) {
    return res.status(400).json({
      ok: false,
      message: errores.mapped()
    });
  }
  next();
};

//===============================================================================
// Exports
//===============================================================================
export default validarCampos;
