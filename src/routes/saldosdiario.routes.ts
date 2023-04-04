//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import validarJWT from "../middlewares/validar-jwt";
import { guardarSaldosDiario, listarSaldos } from "../controllers/saldosdiario.controller";

const router = Router();
//===============================================================================
// Path: api/creditos
//===============================================================================

router.get('/', validarJWT, listarSaldos);

router.post('/', validarJWT, guardarSaldosDiario)


//===============================================================================
// Exports
//===============================================================================
export default router;