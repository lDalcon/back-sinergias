//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { crearCredito, listarCreditos, simularCredito } from "../controllers/credito.controller";
import validarJWT from "../middlewares/validar-jwt";

const router = Router();
//===============================================================================
// Path: api/creditos
//===============================================================================

router.get('/', validarJWT, listarCreditos);

router.post('/', validarJWT, crearCredito);

router.post('/simular', validarJWT, simularCredito)


//===============================================================================
// Exports
//===============================================================================
export default router;