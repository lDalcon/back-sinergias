//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { procesarDetallePago, reversarPago } from "../controllers/detalle-pago.controller";
import validarJWT from "../middlewares/validar-jwt";

const router = Router();
//===============================================================================
// Path: api/detallepago
//===============================================================================

router.post('/', validarJWT, procesarDetallePago);

router.delete('/', validarJWT, reversarPago)

//===============================================================================
// Exports
//===============================================================================
export default router;