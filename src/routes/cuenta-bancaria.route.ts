//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import validarJWT from "../middlewares/validar-jwt";
import { crearCuentaBancaria } from "../controllers/cuenta-bancaria.controller";
const router = Router();
//===============================================================================
// Path: api/cuentabancaria
//===============================================================================

router.post('/', validarJWT, crearCuentaBancaria);

//===============================================================================
// Exports
//===============================================================================
export default router;