//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { procesarDetallePago } from "../controllers/detalle-pago.controller";
import validarJWT from "../middlewares/validar-jwt";

const router = Router();
//===============================================================================
// Path: api/detallepago
//===============================================================================

router.post('/', validarJWT, procesarDetallePago);



//===============================================================================
// Exports
//===============================================================================
export default router;