//===============================================================================
// Imports
//===============================================================================
import { Request, Response } from "express";
import { Empresa } from "../models/empresa.model";

//===============================================================================
// Funtions
//===============================================================================
export const getAll = async (req: Request, res: Response) => {
  let empresa: Empresa = new Empresa();
  empresa.getAll().then(result => {
      if(result.ok) return res.status(200).json(result);
      return res.status(400).json(result)
  })
  .catch(err => {
      return res.status(500).json({ok: false, message: err})
  })
}

