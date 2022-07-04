//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { crearForward, listarForward } from "../controllers/forward.controller";

import validarJWT from "../middlewares/validar-jwt";

const router = Router();
//===============================================================================
// Path: api/creditos
//===============================================================================

router.get('/', validarJWT, listarForward);

// router.get('/:id', validarJWT, obtenerCredito);

// router.get('/:pagare/:entfinanciera', validarJWT, validarPagare);

router.post('/', validarJWT, crearForward);

//===============================================================================
// Exports
//===============================================================================
export default router;