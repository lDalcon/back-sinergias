//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import validarJWT from "../middlewares/validar-jwt";
import { guardarSaldosDiario, listarSaldos, listarSaldosDia, procesarSaldosDiaro } from "../controllers/saldosdiario.controller";

const router = Router();
//===============================================================================
// Path: api/creditos
//===============================================================================

router.get('/', validarJWT, listarSaldos);

router.get('/dia', validarJWT, listarSaldosDia);

router.post('/', validarJWT, guardarSaldosDiario)

router.post('/procesar', validarJWT, procesarSaldosDiaro)


//===============================================================================
// Exports
//===============================================================================
export default router;