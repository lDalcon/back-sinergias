//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { create, createAll, getByDateAndType } from "../controllers/macroeconomicos.controller";
import validarJWT from "../middlewares/validar-jwt";
const router = Router();
//===============================================================================
// Path: api/macroeconomicos
//===============================================================================

router.get('/:date/:type', validarJWT, getByDateAndType);

router.post('/', validarJWT, create)

router.post('/importar', validarJWT, createAll)


//===============================================================================
// Exports
//===============================================================================
export default router;