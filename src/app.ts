import express from "express";
import morgan from "morgan";
import cors from 'cors';
import AuthRoute from './routes/auth.routes'
import MacroEconomicosRoute from './routes/macroeconomicos.routes'
import CatalogoRoute from './routes/catalogo.routes'
import RegionalRoute from './routes/regional.routes'
import CreditoRoute from './routes/credito.routes'

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

export default app;