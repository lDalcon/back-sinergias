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
app.use('/api/auth', AuthRoute);
app.use('/api/macroeconomicos', MacroEconomicosRoute);
app.use('/api/catalogo', CatalogoRoute);
app.use('/api/regional', RegionalRoute);
app.use('/api/credito', CreditoRoute);
app.use('/api/forward', ForwardRoute);
app.use('/api/usuario', UsuarioRoute);
app.get('*', (req: Request, res: Response) => {
    res.sendFile( path.resolve( __dirname, 'public/index.html' ) );
});

export default app;