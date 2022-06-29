//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { getById } from "../controllers/catalogo.controller";
import validarJWT from "../middlewares/validar-jwt";
const router = Router();
//===============================================================================
// Path: api/catalogo
//===============================================================================

router.get('/:id', validarJWT, getById);

//===============================================================================
// Exports
//===============================================================================
export default router;