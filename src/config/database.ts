import mssql from 'mssql';
import dotenv from 'dotenv';

dotenv.config();

const dbConnection = (): Promise<mssql.ConnectionPool> => {
    return new Promise((resolve, reject) => {
        let pool = new mssql.ConnectionPool({
            user: process.env.DB_USER || '',
            password: process.env.DB_PASSWORD || '',
            server: process.env.DB_SERVER || '',
            database: process.env.DB_NAME || '',
            parseJSON: true,
            options: {
                encrypt: true,
                enableArithAbort: true,
                trustServerCertificate: true
            }
        })
        pool.connect((err) => err ? reject(err) : resolve(pool));
    })
}

export default dbConnection;