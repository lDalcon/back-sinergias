//===============================================================================
// Imports
//===============================================================================
import { Router } from 'express';
import { actualizar, asociarEmpresas, crearUsuario, listarUsuarios } from '../controllers/usuario.controller';
import validarJWT from '../middlewares/validar-jwt';

const router = Router();
//===============================================================================
// Path: api/creditos
//===============================================================================

router.get('/', validarJWT, listarUsuarios);

router.post('/', validarJWT, crearUsuario);

router.put('/', validarJWT, actualizar);

router.put('/asociarEmpresas', validarJWT, asociarEmpresas);

//===============================================================================
// Exports
//===============================================================================
export default router;
