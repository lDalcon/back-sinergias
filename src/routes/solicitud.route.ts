//===============================================================================
// Imports
//===============================================================================
import { Router } from 'express';
import { crearSolicitud, listarSolicitudes, obtenerSolicitud } from '../controllers/solicitud.controller';
import validarJWT from '../middlewares/validar-jwt';

const router = Router();
//===============================================================================
// Path: api/solicitud
//===============================================================================

router.get('/', validarJWT, listarSolicitudes);

router.get('/:id', validarJWT, obtenerSolicitud);

router.post('/', validarJWT, crearSolicitud);

//===============================================================================
// Exports
//===============================================================================
export default router;
