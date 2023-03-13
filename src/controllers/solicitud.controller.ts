//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from "express";
import { Solicitud } from "../models/solicitud.model";
import { Usuario } from "../models/usuario.model";

//===============================================================================
// Funtions
//===============================================================================
export const crearSolicitud = async (req: Request, res: Response) => {
    let solicitud: Solicitud = new Solicitud(req.body);
    let usuario: Usuario = req['usrtoken']
    solicitud.usuariocrea = usuario.nick;
    solicitud.guardar()
        .then(result => {
            if (!result.ok) return res.status(400).json(result);
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}

export const listarSolicitudes = async (req: Request, res: Response) => {
    let solicitud: Solicitud = new Solicitud();
    solicitud.usuariocrea = req['usrtoken']['nick']
    await solicitud.listar(req.query)
        .then(result => {
            if (!result.ok) return res.status(400).json(result)
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}

export const obtenerSolicitud = async (req: Request, res: Response) => {
    let solicitud: Solicitud = new Solicitud(req.params);
    solicitud.obtener()
        .then(result => {
            if (!result.ok) return res.status(400).json(result);
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}