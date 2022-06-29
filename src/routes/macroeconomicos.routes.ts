//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { getByDateAndType } from "../controllers/macroeconomicos.controller";
import validarJWT from "../middlewares/validar-jwt";
const router = Router();
//===============================================================================
// Path: api/macroeconomicos
//===============================================================================

router.get('/:date/:type', validarJWT, getByDateAndType);

//===============================================================================
// Exports
//===============================================================================
export default router;