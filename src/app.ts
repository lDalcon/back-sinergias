import express, { Request, Response } from 'express';
import morgan from 'morgan';
import cors from 'cors';
import AuthRoute from './routes/auth.routes'
import MacroEconomicosRoute from './routes/macroeconomicos.routes'
import CatalogoRoute from './routes/catalogo.routes'
import RegionalRoute from './routes/regional.routes'
import CreditoRoute from './routes/credito.routes'
import ForwardRoute from './routes/forward.routes'
import UsuarioRoute from './routes/usuario.routes'
import DetallePagoRoute from './routes/detalle-pago.routes'
import ReporteRoute from './routes/reporte.routes'
import CalendarioRoute from './routes/calendario-cierre.routes'
import SolicitudRoute from './routes/solicitud.route'
import SaldosDiario from './routes/saldosdiario.routes'
import CuentaBancaria from './routes/cuenta-bancaria.route'
import path from 'path';

//=========================================================
// Init
//=========================================================
const app = express();

//=========================================================
// Settings
//=========================================================

app.set('port', process.env.PORT || 3000);

//=========================================================
// Middlewares
//=========================================================
app.use(morgan('dev'));
app.use(cors())
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

//=========================================================
// Routes
//=========================================================
app.use(express.static('public'));
app.use('/api/auth', AuthRoute);
app.use('/api/macroeconomicos', MacroEconomicosRoute);
app.use('/api/catalogo', CatalogoRoute);
app.use('/api/regional', RegionalRoute);
app.use('/api/credito', CreditoRoute);
app.use('/api/forward', ForwardRoute);
app.use('/api/usuario', UsuarioRoute);
app.use('/api/detallepago', DetallePagoRoute);
app.use('/api/reporte', ReporteRoute);
app.use('/api/calendario', CalendarioRoute);
app.use('/api/solicitud', SolicitudRoute);
app.use('/api/saldosdiario', SaldosDiario);
app.use('/api/cuentabancaria', CuentaBancaria);
app.get('*', (req: Request, res: Response) => {
    res.sendFile(path.resolve(__dirname, 'public/index.html'));
});

export default app;