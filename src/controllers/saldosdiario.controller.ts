//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from "express";
import { SaldosDiario } from "../models/saldosdiarios.model";
import { Usuario } from "../models/usuario.model";
//===============================================================================
// Funtions
//===============================================================================
export const guardarSaldosDiario = async (req: Request, res: Response) => {
    let saldosdiario: SaldosDiario = new SaldosDiario(req.body);
    let usuario: Usuario = req['usrtoken']
    saldosdiario.usuariocrea = usuario.nick;
    saldosdiario.guardar()
        .then(result => {
            if (!result.ok) return res.status(400).json(result);
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}

export const procesarSaldosDiaro = async (req: Request, res: Response) => {
    let saldosdiario: SaldosDiario = new SaldosDiario();
    let usuario: Usuario = req['usrtoken']
    saldosdiario.procesar(req.body, usuario.nick)
        .then(result => {
            if (!result.ok) return res.status(400).json(result);
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}

export const listarSaldos = async (req: Request, res: Response) => {
    let saldosdiario: SaldosDiario = new SaldosDiario();
    saldosdiario.listar(req.query)
        .then(result => {
            if (!result.ok) return res.status(400).json(result);
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}

export const listarSaldosDia = async (req: Request, res: Response) => {
    let saldosdiario: SaldosDiario = new SaldosDiario();
    saldosdiario.listarDia(req.query)
        .then(result => {
            if (!result.ok) return res.status(400).json(result);
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}

export const borrarDia = async (req: Request, res: Response) => {
    let saldosdiario: SaldosDiario = new SaldosDiario();
    saldosdiario.borrarDia(req.body)
        .then(result => {
            if (!result.ok) return res.status(400).json(result);
            return res.status(200).json(result)
        })
        .catch(err => res.status(500).json({ ok: false, message: err }))
}


