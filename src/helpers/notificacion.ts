import { EmailNotification } from "../models/email-notification.model";
import axios from 'axios';
import dotenv from "dotenv"

const API = 'https://api.sendinblue.com/v3/';
const headers = {
    'api-key': process.env.APIKEY_SB,
    'Content-Type': 'application/json'
}
//===============================================================================
// Funtions
//===============================================================================
dotenv.config()

const sendEmailNotification = (data: EmailNotification): Promise<{ok: boolean, data?: any, message?: any}> => {
    return new Promise((resolve) => {
        axios.post(`${API}smtp/email`, data, { headers })
            .then(res => {
                console.log(res)
                resolve({ ok: true, data: res })
            })
            .catch(err => {
                console.log(err)
                resolve({ ok: false, message: err })
            })
    })
}

export default sendEmailNotification;
