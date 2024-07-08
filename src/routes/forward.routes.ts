//===============================================================================
// Imports
//===============================================================================
import { Router } from 'express';
import {
  actualizarForward,
  asignarCredito,
  cerrar,
  crearForward,
  editarCreditoForward,
  listarForward,
  obtenerForward
} from '../controllers/forward.controller';

import validarJWT from '../middlewares/validar-jwt';

const router = Router();
//===============================================================================
// Path: api/forward
//===============================================================================

router.get('/:id', validarJWT, obtenerForward);
router.get('/', validarJWT, listarForward);
router.post('/', validarJWT, crearForward);
router.post('/asignarCredito', validarJWT, asignarCredito);
router.post('/cerrar', validarJWT, cerrar);
router.put('/', validarJWT, actualizarForward);
router.put('/liberar', validarJWT, editarCreditoForward);

//===============================================================================
// Exports
//===============================================================================
export default router;
