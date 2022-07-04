//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from "express";
import { Forward } from "../models/forward.model";
import { Usuario } from "../models/usuario.model";

//===============================================================================
// Funtions
//===============================================================================
export const crearForward = async (req: Request, res: Response) => {
    let forward: Forward = new Forward(req.body);
    let usuario: Usuario = req['usrtoken']
    forward.usuariocrea = usuario.nick;
    let result = await forward.guardar();
    if (!result.ok) return res.status(400).json(result);
    return res.status(200).json(result)
}

export const listarForward = async (req: Request, res: Response) => {
    let forward: Forward = new Forward();
    await forward.listar()
        .then(result => {
            if (!result.ok) return res.status(400).json(result)
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}

