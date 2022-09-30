//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { obtenerActivos } from "../controllers/calendario-cierre.controller";
import validarCampos from "../middlewares/validar-campos";
const router = Router();
//===============================================================================
// Path: api/calendario
//===============================================================================

router.get(
    '/:trx',
    [
        validarCampos
    ],
    obtenerActivos
);


//===============================================================================
// Exports
//===============================================================================
export default router;