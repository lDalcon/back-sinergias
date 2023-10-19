//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from "express";
import { Usuario } from "../models/usuario.model";
import { InfoRelevante } from "../models/info-relevante.model";
//===============================================================================
// Funtions
//===============================================================================
export const guardarInfoRelevante = async (req: Request, res: Response) => {
    let inforelevante: InfoRelevante = new InfoRelevante(req.body);
    let usuario: Usuario = req['usrtoken']
    inforelevante.usuariocrea = usuario.nick;
    inforelevante.guardar()
        .then(result => {
            if (!result.ok) return res.status(400).json(result);
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}

export const procesarInfoRelevante = async (req: Request, res: Response) => {
    let inforelevante: InfoRelevante = new InfoRelevante();
    let usuario: Usuario = req['usrtoken']
    inforelevante.procesar(req.body, usuario.nick)
        .then(result => {
            if (!result.ok) return res.status(400).json(result);
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}

export const listarInfoRelevante = async (req: Request, res: Response) => {
    let inforelevante: InfoRelevante = new InfoRelevante();
    inforelevante.listar(req.query)
        .then(result => {
            if (!result.ok) return res.status(400).json(result);
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}

export const listarInfoRelevanteDia = async (req: Request, res: Response) => {
    let inforelevante: InfoRelevante = new InfoRelevante();
    inforelevante.listarDia(req.query)
        .then(result => {
            if (!result.ok) return res.status(400).json(result);
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}

export const borrarDia = async (req: Request, res: Response) => {
    let infoRelevante: InfoRelevante = new InfoRelevante();
    infoRelevante.borrarDia(req.body)
        .then(result => {
            if (!result.ok) return res.status(400).json(result);
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}