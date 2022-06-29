//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { crearCredito, simularCredito } from "../controllers/credito.controller";
import validarJWT from "../middlewares/validar-jwt";

const router = Router();
//===============================================================================
// Path: api/creditos
//===============================================================================

router.post('/', validarJWT, crearCredito);

router.post('/simular', validarJWT, simularCredito)


//===============================================================================
// Exports
//===============================================================================
export default router;