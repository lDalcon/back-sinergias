//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from "express";
import { CalendarioCierre } from "../models/calendario-cierre.model";

//===============================================================================
// Funtions
//===============================================================================
export const obtenerActivos = async (req: Request, res: Response) => {
    let calendario: CalendarioCierre = new CalendarioCierre();
    calendario.obtenerActivos(req.params['trx'])
        .then(result => {
            if(!result.ok) return res.status(400).json(result)
            else return res.status(200).json(result);
        })
        .catch(err => res.status(500).json({ok: false, message: err}))
}

