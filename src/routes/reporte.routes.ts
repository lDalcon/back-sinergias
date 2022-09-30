//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { diferenciaCambio, reporteConsolidado } from "../controllers/reporte.controler";
import validarJWT from "../middlewares/validar-jwt";

const router = Router();
//===============================================================================
// Path: api/creditos
//===============================================================================

router.get('/', validarJWT, reporteConsolidado);

router.post('/diferenciacambio', validarJWT, diferenciaCambio)

//===============================================================================
// Exports
//===============================================================================
export default router;