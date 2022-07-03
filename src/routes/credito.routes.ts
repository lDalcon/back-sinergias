//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { crearCredito, listarCreditos, obtenerCredito, simularCredito, validarPagare } from "../controllers/credito.controller";
import validarJWT from "../middlewares/validar-jwt";

const router = Router();
//===============================================================================
// Path: api/creditos
//===============================================================================

router.get('/', validarJWT, listarCreditos);

router.get('/:id', validarJWT, obtenerCredito);

router.get('/:pagare/:entfinanciera', validarJWT, validarPagare);

router.post('/', validarJWT, crearCredito);

router.post('/simular', validarJWT, simularCredito)


//===============================================================================
// Exports
//===============================================================================
export default router;