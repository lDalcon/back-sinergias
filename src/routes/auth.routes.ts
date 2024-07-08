//===============================================================================
// Imports
//===============================================================================
import { Router } from 'express';
import { check } from 'express-validator';
import validarCampos from '../middlewares/validar-campos';
import login from '../controllers/auth.controller';
const router = Router();
//===============================================================================
// Path: api/auth
//===============================================================================

router.post(
  '/',
  [
    check('nick', 'El nick es obligatorio').not().isEmpty(),
    check('password', 'La contraseña es obligatoria').not().isEmpty(),
    validarCampos
  ],
  login
);

//===============================================================================
// Exports
//===============================================================================
export default router;
