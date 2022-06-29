//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from "express";
import { Credito } from "../models/credito.model";

//===============================================================================
// Funtions
//===============================================================================
export const crearCredito = async (req: Request, res: Response) => {
    let credito: Credito = new Credito(req.body);
    let result = await credito.guardar();
    if (!result.ok) return res.status(400).json(result);
    return res.status(200).json(result)
}

export const simularCredito = async (req: Request, res: Response) => {
    let credito: Credito = new Credito(req.body);
    await credito.simular();
    return res.status(200).json({ok: true, data: credito})
}

