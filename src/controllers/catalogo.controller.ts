//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from "express";
import { Catalogo } from "../models/catalogo.model";

//===============================================================================
// Funtions
//===============================================================================
export const getById = async (req: Request, res: Response) => {
    let catalogo: Catalogo = new Catalogo();
    catalogo.id = req.params.id;
    let result = await catalogo.getById();
    if (!result.ok) return res.status(400).json(result);
    return res.status(200).json({
        ok: true, 
        data: result.catalogo
    })
}

