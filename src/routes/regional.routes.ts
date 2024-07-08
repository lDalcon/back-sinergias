//===============================================================================
// Imports
//===============================================================================
import { Router } from 'express';
import { getAll, getByNit } from '../controllers/regional.controller';
import validarJWT from '../middlewares/validar-jwt';
const router = Router();
//===============================================================================
// Path: api/regional
//===============================================================================

router.get('/', validarJWT, getAll);

router.get('/:nit', validarJWT, getByNit);

//===============================================================================
// Exports
//===============================================================================
export default router;
