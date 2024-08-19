import express, { Request, Response } from 'express';
import morgan from 'morgan';
import cors from 'cors';

import AuthRoute from './routes/auth.routes';
import CalendarioRoute from './routes/calendario-cierre.routes';
import CatalogoRoute from './routes/catalogo.routes';
import CreditoRoute from './routes/credito.routes';
import CuentaBancaria from './routes/cuenta-bancaria.route';
import DetallePagoRoute from './routes/detalle-pago.routes';
import EmpresaRoute from './routes/empresa.routes';
import ForwardRoute from './routes/forward.routes';
import InfoRelevante from './routes/info-relevante.routes';
import MacroEconomicosRoute from './routes/macroeconomicos.routes';
import RegionalRoute from './routes/regional.routes';
import ReporteRoute from './routes/reporte.routes';
import SaldosDiario from './routes/saldosdiario.routes';
import SolicitudRoute from './routes/solicitud.route';
import UsuarioRoute from './routes/usuario.routes';
import AumentoCapitalRoute from './routes/aumento-capital.routes';
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
app.use(cors());
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

//=========================================================
// Routes
//=========================================================
app.use(express.static('public'));
app.use('/api/auth', AuthRoute);
app.use('/api/calendario', CalendarioRoute);
app.use('/api/catalogo', CatalogoRoute);
app.use('/api/credito', CreditoRoute);
app.use('/api/cuentabancaria', CuentaBancaria);
app.use('/api/detallepago', DetallePagoRoute);
app.use('/api/empresa', EmpresaRoute);
app.use('/api/forward', ForwardRoute);
app.use('/api/inforelevante', InfoRelevante);
app.use('/api/macroeconomicos', MacroEconomicosRoute);
app.use('/api/regional', RegionalRoute);
app.use('/api/reporte', ReporteRoute);
app.use('/api/saldosdiario', SaldosDiario);
app.use('/api/solicitud', SolicitudRoute);
app.use('/api/usuario', UsuarioRoute);
app.use('/api/aumento-capital', AumentoCapitalRoute)
app.get('*', (req: Request, res: Response) => {
  res.sendFile(path.resolve(__dirname, 'public/index.html'));
});

export default app;
