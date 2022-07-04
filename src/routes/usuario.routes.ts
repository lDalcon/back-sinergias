//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { crearUsuario, listarUsuarios } from "../controllers/usuario.controller";
import validarJWT from "../middlewares/validar-jwt";

const router = Router();
//===============================================================================
// Path: api/creditos
//===============================================================================

router.get('/', validarJWT, listarUsuarios);

// router.get('/:id', validarJWT, obtenerCredito);

// router.get('/:pagare/:entfinanciera', validarJWT, validarPagare);

router.post('/', validarJWT, crearUsuario);

//===============================================================================
// Exports
//===============================================================================
export default router;