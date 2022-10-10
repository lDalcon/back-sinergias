//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { actualizarPeriodo, getByAno, obtenerActivos } from "../controllers/calendario-cierre.controller";
import validarJWT from "../middlewares/validar-jwt";
const router = Router();
//===============================================================================
// Path: api/calendario
//===============================================================================
router.get(
    '/',
    [
        validarJWT
    ],
    getByAno
)

router.get(
    '/:trx',
    [
        validarJWT
    ],
    obtenerActivos
);

router.put(
    '/',
    [
        validarJWT
    ],
    actualizarPeriodo
)

//===============================================================================
// Exports
//===============================================================================
export default router;