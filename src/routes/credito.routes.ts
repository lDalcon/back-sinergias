//===============================================================================
// Imports
//===============================================================================
import { Router } from "express";
import { actualizar, crearCredito, listarCreditos, obtenerCredito, simularCredito, validarPagare } from "../controllers/credito.controller";
import validarJWT from "../middlewares/validar-jwt";

const router = Router();
//===============================================================================
// Path: api/creditos
//===============================================================================

router.get('/', validarJWT, listarCreditos);

router.get('/:id', validarJWT, obtenerCredito);

router.get('/:pagare/:entfinanciera', validarJWT, validarPagare);

router.post('/', validarJWT, crearCredito);

router.put('/', validarJWT, actualizar);

router.post('/simular', validarJWT, simularCredito)

// router.post('/actualizarAmortizacion', validarJWT, actualizarAmortizacion)


//===============================================================================
// Exports
//===============================================================================
export default router;