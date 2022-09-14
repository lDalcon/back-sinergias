USE Sinergias_db;
GO

/* Tablas */

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usuarios]') AND type in (N'U'))
	DROP TABLE [dbo].[usuarios]
GO

CREATE TABLE [dbo].[usuarios] (
    nick VARCHAR(50) PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    password VARCHAR(4000) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL,
    estado BIT DEFAULT 1
)

INSERT INTO usuarios VALUES ('ADMIN', 'Damian', 'Duarte', '$2a$10$LeVpe8Dx4R0vWgWJfT1ueO9g/aOov1jLI94kGiwO2MqSl5EKGu6qe','damianleo1991@hotmail.com', 'ADMIN', 1)

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[menu]') AND type in (N'U'))
	DROP TABLE [dbo].[menu]
GO

CREATE TABLE [dbo].[menu](
    role VARCHAR(50) NOT NULL UNIQUE,
    opciones VARCHAR(MAX) NOT NULL
)

DELETE menu
INSERT INTO menu VALUES
('ADMIN', '[{"label":"Admin","items":[{"label":"Usuarios","icon":"pi pi-fw pi-user","routerLink":["/admin/usuarios"]},{"label":"Catalogos","icon":"pi pi-fw pi-book","routerLink":["/admin/catalogos"]},{"label":"Macroeconómicos","icon":"pi pi-fw pi-chart-line","routerLink":["/admin/macroeconomicos"]}]},{"label":"Dashboard","items":[{"label":"Gerencial","icon":"pi pi-fw pi-chart-pie","routerLink":["/dashboard/gerencia"]},{"label":"Financiero","icon":"pi pi-fw pi-chart-bar","routerLink":["/dashboard/financiero"]}]},{"label":"Financiero","items":[{"label":"Obligaciones","icon":"pi pi-fw pi-credit-card","routerLink":["/financiero/obligaciones"]},{"label":"Forward","icon":"pi pi-fw pi-dollar","routerLink":["/financiero/forward"]}]}]'),
('TESORERIA', '[{"label":"Dashboard","items":[{"label":"Financiero","icon":"pi pi-fw pi-chart-bar","routerLink":["/dashboard/financiero"]}]},{"label":"Financiero","items":[{"label":"Obligaciones","icon":"pi pi-fw pi-credit-card","routerLink":["/financiero/obligaciones"]},{"label":"Forward","icon":"pi pi-fw pi-dollar","routerLink":["/financiero/forward"]}]}]')

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[controlconcecutivos]') AND type in (N'U'))
	DROP TABLE [dbo].[controlconcecutivos]
GO

CREATE TABLE controlconcecutivos (
    documento VARCHAR(50) PRIMARY KEY,
    concecutivo INT NOT NULL,
)

INSERT INTO controlconcecutivos VALUES
('OBLIGACION', 0),
('FORWARD', 0)

/* No tocar ni por el chiras

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[macroeconomicos]') AND type in (N'U'))
	DROP TABLE [dbo].[macroeconomicos]
GO

CREATE TABLE macroeconomicos (
    ano INT NOT NULL,
    periodo INT NOT NULL,
    fecha DATE NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    valor NUMERIC(18,6) NOT NULL,
    unidad VARCHAR(5) NOT NULL,
    PRIMARY KEY(ano, periodo, fecha, tipo)
)


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[catalogo]') AND type in (N'U'))
	DROP TABLE [dbo].[catalogo]
GO

CREATE TABLE catalogo (
    id VARCHAR(10),
    descripcion VARCHAR(100),
    config NVARCHAR(MAX) DEFAULT '{}',
    PRIMARY KEY (id)
)


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[valorcatalogo]') AND type in (N'U'))
	DROP TABLE [dbo].[valorcatalogo]
GO

CREATE TABLE valorcatalogo (
    id INT IDENTITY(500,1),
    ctgid VARCHAR(10),
    descripcion VARCHAR(200),
    config NVARCHAR(MAX) DEFAULT '{}',
    PRIMARY KEY (id),
    FOREIGN KEY (ctgid) REFERENCES catalogo(id)
)

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[empresa]') AND type in (N'U'))
	DROP TABLE [dbo].[empresa]
GO

CREATE TABLE empresa (
    nit VARCHAR(15) NOT NULL,
    razonsocial VARCHAR(150) NOT NULL,
    cluster VARCHAR(150) NOT NULL,
    config NVARCHAR(MAX) DEFAULT '{}',
    PRIMARY KEY(nit)
)

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[regional]') AND type in (N'U'))
	DROP TABLE [dbo].[regional]
GO

CREATE TABLE regional (
    id INT IDENTITY(100,1),
    nit VARCHAR(15),
    nombre VARCHAR(150) NOT NULL,
    estado BIT DEFAULT 1,
    config NVARCHAR(MAX) DEFAULT '{}',
    PRIMARY KEY (id),
    FOREIGN KEY (nit) REFERENCES empresa(nit)
)

*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[credito]') AND type in (N'U'))
	DROP TABLE [dbo].[credito]
GO

CREATE TABLE credito (
    id INT NOT NULL,
    ano INT NOT NULL,
    periodo INT NOT NULL,
    fechadesembolso DATE NOT NULL,
    moneda INT NOT NULL,
    entfinanciera INT NOT NULL,
    regional INT NOT NULL,
    lineacredito INT NOT NULL,
    pagare VARCHAR(50) NOT NULL,
    tipogarantia INT NOT NULL,
    capital NUMERIC(18,2) NOT NULL,
    saldo NUMERIC(18,2) NOT NULL,
    plazo INT NOT NULL,
    indexado INT NOT NULL,
    spread NUMERIC(8,6) NOT NULL,
    tipointeres INT NOT NULL,
    amortizacionk INT NOT NULL,
    amortizacionint INT NOT NULL,
    saldoasignacion NUMERIC(18,2) NOT NULL,
    estado VARCHAR(20) DEFAULT 'ACTIVO',
    usuariocrea VARCHAR(50),
    fechacrea DATETIME NOT NULL,
    usuariomod VARCHAR(50),
    fechamod DATETIME NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (moneda) REFERENCES valorcatalogo(id),
    FOREIGN KEY (entfinanciera) REFERENCES valorcatalogo(id),
    FOREIGN KEY (regional) REFERENCES regional(id),
    FOREIGN KEY (lineacredito) REFERENCES valorcatalogo(id),
    FOREIGN KEY (tipogarantia) REFERENCES valorcatalogo(id),
    FOREIGN KEY (indexado) REFERENCES valorcatalogo(id),
    FOREIGN KEY (tipointeres) REFERENCES valorcatalogo(id),
    FOREIGN KEY (amortizacionk) REFERENCES valorcatalogo(id),
    FOREIGN KEY (amortizacionint) REFERENCES valorcatalogo(id),
    FOREIGN KEY (usuariocrea) REFERENCES usuarios(nick),
    FOREIGN KEY (usuariomod) REFERENCES usuarios(nick),
    CONSTRAINT U_Pagare UNIQUE (pagare, entfinanciera)
)

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[forward]') AND type in (N'U'))
	DROP TABLE [dbo].[forward]
GO

CREATE TABLE forward (
    id INT NOT NULL,
    ano INT NOT NULL,
    periodo INT NOT NULL,
    fechaoperacion DATE NOT NULL,
    fechacumplimiento DATE NOT NULL,
    entfinanciera INT NOT NULL,
    regional INT NOT NULL,
    valorusd NUMERIC(18,2) NOT NULL,
    tasaspot NUMERIC(18,2) NOT NULL,
    devaluacion NUMERIC(6,5) NOT NULL,
    tasaforward NUMERIC(18,2) NOT NULL,
    valorcop NUMERIC(18,2) NOT NULL,
    saldoasignacion NUMERIC(18,2) NOT NULL,
    saldo NUMERIC(18,2) NOT NULL,
    estado VARCHAR(20) DEFAULT 'ACTIVO',
    usuariocrea VARCHAR(50),
    fechacrea DATETIME NOT NULL,
    usuariomod VARCHAR(50),
    fechamod DATETIME NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (entfinanciera) REFERENCES valorcatalogo(id),
    FOREIGN KEY (regional) REFERENCES regional(id),
    FOREIGN KEY (usuariocrea) REFERENCES usuarios(nick),
    FOREIGN KEY (usuariomod) REFERENCES usuarios(nick)
)

/* 20220710*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[creditoforward]') AND type in (N'U'))
	DROP TABLE [dbo].[creditoforward]
GO

CREATE TABLE creditoforward (
    seq INT IDENTITY(1,1),
    ano INT NOT NULL,
    periodo INT NOT NULL,
    idcredito INT NOT NULL,
    idforward INT NOT NULL,
    valorasignado NUMERIC(18,2),
    saldoasignacion NUMERIC(18,2) NOT NULL,
    estado VARCHAR(20) DEFAULT 'ACTIVO',
    justificacion VARCHAR(500),
    usuariocrea VARCHAR(50),
    fechacrea DATETIME NOT NULL,
    usuariomod VARCHAR(50),
    fechamod DATETIME NOT NULL,
    FOREIGN KEY (idcredito) REFERENCES credito(id),
    FOREIGN KEY (idforward) REFERENCES forward(id),
    FOREIGN KEY (usuariocrea) REFERENCES usuarios(nick),
    FOREIGN KEY (usuariomod) REFERENCES usuarios(nick)
)

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[detallepago]') AND type in (N'U'))
	DROP TABLE [dbo].[detallepago]
GO

CREATE TABLE detallepago (
    seq INT IDENTITY(1,1) PRIMARY KEY,
    ano INT NOT NULL,
    periodo INT NOT NULL,
    fechapago DATE NOT NULL,
    idcredito INT NOT NULL,
    tipopago VARCHAR(200) NOT NULL,
    formapago VARCHAR(200) NOT NULL,
    trm NUMERIC(18,2) NOT NULL,
    valor NUMERIC(18,2),
    estado VARCHAR(20) DEFAULT 'ACTIVO',
    usuariocrea VARCHAR(50),
    fechacrea DATETIME NOT NULL,
    usuariomod VARCHAR(50),
    fechamod DATETIME NOT NULL,
    FOREIGN KEY (idcredito) REFERENCES credito(id),
    FOREIGN KEY (usuariocrea) REFERENCES usuarios(nick),
    FOREIGN KEY (usuariomod) REFERENCES usuarios(nick)
)

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[detalleforward]') AND type in (N'U'))
	DROP TABLE [dbo].[detalleforward]
GO

CREATE TABLE detalleforward (
    seq INT NOT NULL,
    ano INT NOT NULL,
    periodo INT NOT NULL,
    fechapago DATE NOT NULL,
    idforward INT NOT NULL,
    tipopago VARCHAR(200) NOT NULL,
    formapago VARCHAR(200) NOT NULL,
    trm NUMERIC(18,2) NOT NULL,
    valor NUMERIC(18,2),
    estado VARCHAR(20) DEFAULT 'ACTIVO',
    usuariocrea VARCHAR(50),
    fechacrea DATETIME NOT NULL,
    usuariomod VARCHAR(50),
    fechamod DATETIME NOT NULL,
    FOREIGN KEY (seq) REFERENCES detallepago(seq),
    FOREIGN KEY (idforward) REFERENCES forward(id),
    FOREIGN KEY (usuariocrea) REFERENCES usuarios(nick),
    FOREIGN KEY (usuariomod) REFERENCES usuarios(nick)
)

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[credito_saldos]') AND type in (N'U'))
	DROP TABLE [dbo].[credito_saldos]
GO

CREATE TABLE credito_saldos (
    id INT NOT NULL,
    ano INT NOT NULL,
    periodo INT NOT NULL,
    abonoscapital NUMERIC(18,2) NOT NULL,
    interespago NUMERIC(18,2) NOT NULL,
    interescausado NUMERIC(18,2) NOT NULL,
    tasapromedio NUMERIC(6,6) NOT NULL,
    saldokinicial NUMERIC(18,2) NOT NULL,
    PRIMARY KEY(id, ano, periodo),
    FOREIGN KEY (id) REFERENCES credito(id)
)

GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usuario_regional]') AND type in (N'U'))
	DROP TABLE [dbo].[usuario_regional]
GO

CREATE TABLE usuario_regional (
    nick VARCHAR(50) NOT NULL,
    idregional INT
    PRIMARY KEY(nick, idregional),
    FOREIGN KEY (nick) REFERENCES usuarios(nick),
    FOREIGN KEY (idregional) REFERENCES regional(id)
)

GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[diferenciacambio]') AND type in (N'U'))
	DROP TABLE [dbo].[diferenciacambio]
GO

CREATE TABLE diferenciacambio (
    ano INT NOT NULL,
    periodo INT NOT NULL,
    idcredito INT NOT NULL,
	regional INT NOT NULL,
	ndias INT NOT NULL,
	trmdesembolso NUMERIC(18,6) NOT NULL,
	trmcierre NUMERIC(18,6) NOT NULL,
	saldodeuda NUMERIC(18,2) NOT NULL,
	forward NUMERIC(18,2) NOT NULL,
	forwardcop NUMERIC(18,2) NOT NULL,
	saldotrmdesembolso NUMERIC(18,2) DEFAULT 0,
	deudanocubierta NUMERIC(18,2) DEFAULT 0,
	diftasa NUMERIC(18,2) NOT NULL DEFAULT 0,
	difcambiodcub NUMERIC(18,2) DEFAULT 0,
	difcambiodnocub NUMERIC(18,2) DEFAULT 0,
	totaldifcambioper NUMERIC(18,2) DEFAULT 0,
	PRIMARY KEY (ano, periodo, idcredito)
)

GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[forward_saldos]') AND type in (N'U'))
	DROP TABLE [dbo].[forward_saldos]
GO

CREATE TABLE forward_saldos (
    idforward INT NOT NULL,
    idcredito INT NOT NULL,
    ano INT NOT NULL,
    periodo INT NOT NULL,
	pagos NUMERIC(18,2) NOT NULL,
	asignacion NUMERIC(18,2) NOT NULL,
    saldoinicial NUMERIC(18,2) NOT NULL,
	saldoasignacioni NUMERIC(18,2) NOT NULL,
    PRIMARY KEY(idforward, idcredito, ano, periodo),
    FOREIGN KEY (idforward) REFERENCES forward(id)
)

GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calendario_cierre]') AND type in (N'U'))
	DROP TABLE [dbo].[calendario_cierre]
GO

CREATE TABLE calendario_cierre (
	ano INT NOT NULL,
	periodo INT NOT NULL,
	mes VARCHAR(10) NOT NULL,
	fechainicial DATE NOT NULL,
	fechafinal DATE NOT NULL,
	proceso BIT DEFAULT 0,
	registro BIT DEFAULT 0,
	PRIMARY KEY (ano, periodo)
)

--INSERT INTO calendario_cierre VALUES
--(2022, 1, 'Enero', '2022-01-01', '2022-01-31', 0,0),
--(2022, 2, 'Febrero', '2022-02-01', '2022-02-28', 0,0),
--(2022, 3, 'Marzo', '2022-03-01', '2022-03-31', 0,0),
--(2022, 4, 'Abril', '2022-04-01', '2022-04-30', 0,0),
--(2022, 5, 'Mayo', '2022-05-01', '2022-05-31', 0,0),
--(2022, 6, 'Junio', '2022-06-01', '2022-06-30', 0,0),
--(2022, 7, 'Julio', '2022-07-01', '2022-07-31', 0,0),
--(2022, 8, 'Agosto', '2022-08-01', '2022-08-31', 1,1),
--(2022, 9, 'Septiembre', '2022-09-01', '2022-09-30', 1,1),
--(2022, 10, 'Octubre', '2022-10-01', '2022-10-31', 0,0),
--(2022, 11, 'Noviembre', '2022-11-01', '2022-11-30', 0,0),
--(2022, 12, 'Diciembre', '2022-12-01', '2022-12-31', 0,0),
--(2023, 1, 'Enero', '2023-01-01', '2023-01-31', 0,0),
--(2023, 2, 'Febrero', '2023-02-01', '2023-02-28', 0,0),
--(2023, 3, 'Marzo', '2023-03-01', '2023-03-31', 0,0),
--(2023, 4, 'Abril', '2023-04-01', '2023-04-30', 0,0),
--(2023, 5, 'Mayo', '2023-05-01', '2023-05-31', 0,0),
--(2023, 6, 'Junio', '2023-06-01', '2023-06-30', 0,0),
--(2023, 7, 'Julio', '2023-07-01', '2023-07-31', 0,0),
--(2023, 8, 'Agosto', '2023-08-01', '2023-08-31', 0,0),
--(2023, 9, 'Septiembre', '2023-09-01', '2023-09-30', 0,0),
--(2023, 10, 'Octubre', '2023-10-01', '2023-10-31', 0,0),
--(2023, 11, 'Noviembre', '2023-11-01', '2023-11-30', 0,0),
--(2023, 12, 'Diciembre', '2023-12-01', '2023-12-31', 0,0)

-- IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[credito_saldos]') AND type in (N'U'))
-- 	DROP TABLE [dbo].[credito_saldos]
-- GO
-- IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[detalleforward]') AND type in (N'U'))
-- 	DROP TABLE [dbo].[detalleforward]
-- GO
-- IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[detallepago]') AND type in (N'U'))
-- 	DROP TABLE [dbo].[detallepago]
-- GO
-- IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[creditoforward]') AND type in (N'U'))
-- 	DROP TABLE [dbo].[creditoforward]
-- GO
-- IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[forward]') AND type in (N'U'))
-- 	DROP TABLE [dbo].[forward]
-- GO
-- IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[credito]') AND type in (N'U'))
-- 	DROP TABLE [dbo].[credito]
-- GO
-- IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[regional]') AND type in (N'U'))
-- 	DROP TABLE [dbo].[regional]
-- GO



-- ALTER

--ALTER TABLE Forward
--ADD dias INT NOT NULL DEFAULT 0

--UPDATE forward SET DIAS = DATEDIFF(DAY, fechaoperacion, fechacumplimiento)