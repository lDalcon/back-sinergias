//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from "express";
import { Credito } from "../models/credito.model";
import { Usuario } from "../models/usuario.model";

//===============================================================================
// Funtions
//===============================================================================
export const crearCredito = async (req: Request, res: Response) => {
    let credito: Credito = new Credito(req.body);
    let usuario: Usuario = req['usrtoken']
    credito.usuariocrea = usuario.nick;
    let result = await credito.guardar();
    if (!result.ok) return res.status(400).json(result);
    return res.status(200).json(result)
}

export const simularCredito = async (req: Request, res: Response) => {
    let credito: Credito = new Credito(req.body);
    await credito.simular();
    return res.status(200).json({ok: true, data: credito})
}

export const listarCreditos = async (req: Request, res: Response) => {
    let credito: Credito = new Credito();
    await credito.listar().then(result => {
        if(!result.ok) return res.status(400).json(result)
        return res.status(200).json({ok: true, data: result.creditos})
    })
    .catch(err => res.status(500).json({ok:false, message: err}))
}

