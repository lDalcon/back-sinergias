//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from "express";
import { MacroEconomicos } from "../models/macroeconomicos.model";
//===============================================================================
// Funtions
//===============================================================================
export const getByDateAndType = async (req: Request, res: Response) => {
    let macroeconomico: MacroEconomicos = new MacroEconomicos();
    macroeconomico.fecha = new Date(req.params.date);
    macroeconomico.tipo = req.params.type;
    let result = await macroeconomico.getByDateAndType();
    if (!result.ok) return res.status(400).json(result);
    return res.status(200).json({
        ok: true, 
        data: result.macroeconomicos
    })
}

