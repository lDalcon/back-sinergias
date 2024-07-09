//===============================================================================
// Imports
//===============================================================================
import { Router } from 'express';
import { diferenciaCambio, infoRegistroSolicitud, reporteConsolidado } from '../controllers/reporte.controler';
import validarJWT from '../middlewares/validar-jwt';

const router = Router();
//===============================================================================
// Path: api/reporte
//===============================================================================

router.get('/', validarJWT, reporteConsolidado);

router.get('/infoRegistroSolicitud/:regional', validarJWT, infoRegistroSolicitud);

router.post('/diferenciacambio', validarJWT, diferenciaCambio);

//===============================================================================
// Exports
//===============================================================================
export default router;
