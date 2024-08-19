//===============================================================================
// Imports
//===============================================================================
import { Router } from 'express';
import validarJWT from '../middlewares/validar-jwt';
import { crearAumentoCapital } from '../controllers/aumento-capital.controller';

const router = Router();
//===============================================================================
// Path: api/aumento-capital
//===============================================================================
router.post('/', validarJWT, crearAumentoCapital);


//===============================================================================
// Exports
//===============================================================================
export default router;
