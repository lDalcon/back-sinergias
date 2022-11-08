//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { actualizarForward, asignarCredito, crearForward, listarForward, obtenerForward } from "../controllers/forward.controller";

import validarJWT from "../middlewares/validar-jwt";

const router = Router();
//===============================================================================
// Path: api/creditos
//===============================================================================

router.get('/', validarJWT, listarForward);

router.get('/:id', validarJWT, obtenerForward);

router.post('/', validarJWT, crearForward);

router.put('/', validarJWT, actualizarForward);

router.post('/asignarCredito', validarJWT, asignarCredito);

//===============================================================================
// Exports
//===============================================================================
export default router;