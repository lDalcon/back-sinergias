//===============================================================================
// Imports
//===============================================================================
import { Router } from 'express';
import validarJWT from '../middlewares/validar-jwt';
import {
  borrarDia,
  guardarSaldosDiario,
  listarSaldos,
  listarSaldosDia,
  procesarSaldosDiaro
} from '../controllers/saldosdiario.controller';

const router = Router();
//===============================================================================
// Path: api/creditos
//===============================================================================

router.get('/', validarJWT, listarSaldos);

router.get('/dia', validarJWT, listarSaldosDia);

router.post('/', validarJWT, guardarSaldosDiario);

router.post('/procesar', validarJWT, procesarSaldosDiaro);

router.delete('/', validarJWT, borrarDia);

//===============================================================================
// Exports
//===============================================================================
export default router;
