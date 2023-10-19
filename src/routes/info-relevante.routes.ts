//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import validarJWT from "../middlewares/validar-jwt";
import { borrarDia, guardarInfoRelevante, listarInfoRelevante, listarInfoRelevanteDia, procesarInfoRelevante } from "../controllers/info-relevante.controller";
const router = Router();
//===============================================================================
// Path: api/creditos
//===============================================================================

router.get('/', validarJWT, listarInfoRelevante);

router.get('/dia', validarJWT, listarInfoRelevanteDia);

router.post('/', validarJWT, guardarInfoRelevante)

router.post('/procesar', validarJWT, procesarInfoRelevante)

router.delete('/', validarJWT, borrarDia)


//===============================================================================
// Exports
//===============================================================================
export default router;