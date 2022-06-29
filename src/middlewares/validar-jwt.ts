//=========================================================
// Imports
//=========================================================
import { NextFunction, Request, Response } from 'express';
import dotenv from 'dotenv';
import jwt from 'jsonwebtoken';
//===============================================================================
// Funtions
//===============================================================================
dotenv.config();

const validarJWT = (req: Request, res: Response, next: NextFunction) => {
    const token = req.header('x-token'); 
    if (!token) return res.status(401).json({ ok: false, message: 'El token es obligatorio' })
    try {
        const value = jwt.verify(token, process.env.APP_SEED || '')
        req['usrtoken'] = JSON.parse(value['usuario']);
        next();
    } catch (error) {
        console.log(error)
        return res.status(401).json({ ok: false, message: 'Token no valido' })
    }
}

//===============================================================================
// Exports
//===============================================================================
export default validarJWT;