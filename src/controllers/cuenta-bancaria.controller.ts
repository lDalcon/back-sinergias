//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from "express";
import { CuentaBancaria } from "../models/cuenta-bancaria.model";

//===============================================================================
// Funtions
//===============================================================================
export const crearCuentaBancaria = async (req: Request, res: Response) => {
    let cuentaBancaria: CuentaBancaria = new CuentaBancaria(req.body);
    cuentaBancaria.guardar()
        .then(result => {
            if (!result.ok) return res.status(400).json(result);
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}