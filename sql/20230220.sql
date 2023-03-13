USE SINERGIAS_DB
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[solicitud]') AND type in (N'U'))
	DROP TABLE [dbo].[solicitud]
GO

CREATE TABLE solicitud (
    id INT NOT NULL,
    ano INT NOT NULL,
    periodo INT NOT NULL,
    fechareq DATE NOT NULL,
    moneda INT NOT NULL,
    entfinanciera INT,
    regional INT NOT NULL,
    lineacredito INT,
    tipogarantia INT,
    capital NUMERIC(18,2) NOT NULL,
    plazo INT NOT NULL,
    indexado INT,
    spread NUMERIC(8,6),
    tasa NUMERIC(8,6),
    tipointeres INT,
    amortizacionk INT,
    amortizacionint INT,
    observaciones NVARCHAR(MAX),
    idcredito INT,
    estado VARCHAR(20),
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
    FOREIGN KEY (idcredito) REFERENCES credito(id)
)

DELETE controlconcecutivos WHERE documento = 'SOLICITUD'
INSERT INTO controlconcecutivos VALUES
('SOLICITUD', 0)


IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_solicitud_guardar') 
	DROP PROCEDURE [dbo].[sc_solicitud_guardar]
GO

CREATE PROCEDURE sc_solicitud_guardar
    @fechareq DATE,
    @moneda INT,
    @regional INT,
    @capital NUMERIC(18,2),
    @plazo INT,
    @observaciones NVARCHAR(MAX),
    @usuariocrea VARCHAR(50),
    @id INT OUTPUT
AS
    EXEC sc_obtenerconsecutivo 'SOLICITUD', @id OUTPUT;

    INSERT INTO solicitud 
    (
        id,
        ano,
        periodo,
        fechareq,
        moneda,
        regional,
        capital,
        plazo,
        observaciones,
        estado,
        usuariocrea,
        usuariomod,
        fechacrea,
        fechamod
    )
    VALUES
    (
        @id,
        YEAR(GETDATE()),
        MONTH(GETDATE()),
        @fechareq,
        @moneda,
        @regional,
        @capital,
        @plazo,
        @observaciones,
        'ESTUDIO',
        @usuariocrea,
        @usuariocrea,
        GETDATE(),
        GETDATE()
    )
GO

UPDATE menu SET opciones = '[
    {
        "label": "Admin",
        "items": [
            {
                "label": "Usuarios",
                "icon": "pi pi-fw pi-user",
                "routerLink": [
                    "/admin/usuarios"
                ]
            },
            {
                "label": "Catalogos",
                "icon": "pi pi-fw pi-book",
                "routerLink": [
                    "/admin/catalogos"
                ]
            },
            {
                "label": "Macroeconómicos",
                "icon": "pi pi-fw pi-chart-line",
                "routerLink": [
                    "/admin/macroeconomicos"
                ]
            },
            {
                "label": "Calendario",
                "icon": "pi pi-fw pi-calendar",
                "routerLink": [
                    "/admin/calendario"
                ]
            }
        ]
    },
    {
        "label": "Dashboard",
        "items": [
            {
                "label": "Gerencial",
                "icon": "pi pi-fw pi-chart-pie",
                "routerLink": [
                    "/dashboard/gerencia"
                ]
            },
            {
                "label": "Financiero",
                "icon": "pi pi-fw pi-chart-bar",
                "routerLink": [
                    "/dashboard/financiero"
                ]
            }
        ]
    },
    {
        "label": "Financiero",
        "items": [
            {
                "label": "Solicitudes",
                "icon": "pi pi-fw pi-inbox",
                "routerLink": [
                    "/financiero/solicitudes"
                ]
            },
            {
                "label": "Obligaciones",
                "icon": "pi pi-fw pi-credit-card",
                "routerLink": [
                    "/financiero/obligaciones"
                ]
            },
            {
                "label": "Forward",
                "icon": "pi pi-fw pi-dollar",
                "routerLink": [
                    "/financiero/forward"
                ]
            },
            {
                "label": "Dif. en Cambio",
                "icon": "pi pi-fw pi-wallet",
                "routerLink": [
                    "/financiero/diferenciacambio"
                ]
            }
        ]
    }
]' WHERE role = 'ADMIN'


UPDATE menu SET opciones = '[
    {
        "label": "Dashboard",
        "items": [
            {
                "label": "Financiero",
                "icon": "pi pi-fw pi-chart-bar",
                "routerLink": [
                    "/dashboard/financiero"
                ]
            }
        ]
    },
    {
        "label": "Financiero",
        "items": [
            {
                "label": "Solicitudes",
                "icon": "pi pi-fw pi-inbox",
                "routerLink": [
                    "/financiero/solicitudes"
                ]
            },
            {
                "label": "Obligaciones",
                "icon": "pi pi-fw pi-credit-card",
                "routerLink": [
                    "/financiero/obligaciones"
                ]
            },
            {
                "label": "Forward",
                "icon": "pi pi-fw pi-dollar",
                "routerLink": [
                    "/financiero/forward"
                ]
            },
            {
                "label": "Dif. en Cambio",
                "icon": "pi pi-fw pi-wallet",
                "routerLink": [
                    "/financiero/diferenciacambio"
                ]
            }
        ]
    }
]' WHERE role = 'TESORERIA'


IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_solicitud_listar') 
	DROP PROCEDURE [dbo].[sc_solicitud_listar]
GO

CREATE PROCEDURE sc_solicitud_listar
    @nick VARCHAR(50),
    @regional INT = NULL,
    @estado VARCHAR(20) = NULL
AS

    SELECT
        solicitud.id AS [id],
        solicitud.ano AS [ano],
        solicitud.fechareq AS [fechareq],
        moneda.descripcion AS [moneda],
        regional.nombre AS [regional],
        solicitud.capital AS [capital],
        solicitud.plazo AS [plazo],
        solicitud.estado AS [estado],
        solicitud.usuariocrea AS [usuariocrea],
        solicitud.fechacrea AS [fechacrea],
        solicitud.usuariomod AS [usuariomod],
        solicitud.fechamod AS [fechamod]
    FROM
        solicitud

        INNER JOIN valorcatalogo AS moneda
        ON solicitud.moneda = moneda.id

        INNER JOIN regional AS regional
        ON solicitud.regional = regional.id

    WHERE
        regional.id in (SELECT idregional FROM usuario_regional WHERE nick = @nick AND idregional = ISNULL(@regional, idregional))
        AND solicitud.estado = ISNULL(@estado, solicitud.estado)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_solicitud_obtener') 
	DROP PROCEDURE [dbo].[sc_solicitud_obtener]
GO

CREATE PROCEDURE sc_solicitud_obtener
    @id INT
AS
    SELECT
        solicitud.id AS [id],
        solicitud.ano AS [ano],
        solicitud.periodo AS [periodo],
        solicitud.fechareq AS [fechareq],
        moneda.id AS [moneda.id],
        moneda.ctgid AS [moneda.ctgid],
        moneda.descripcion AS [moneda.descripcion],
        moneda.config AS [moneda.config],
        entfinanciera.id AS [entfinanciera.id],
        entfinanciera.ctgid AS [entfinanciera.ctgid],
        entfinanciera.descripcion AS [entfinanciera.descripcion],
        entfinanciera.config AS [entfinanciera.config],
        regional.id AS [regional.id],
        regional.nit AS [regional.nit],
        regional.nombre AS [regional.nombre],
        regional.config AS [regional.config],
        lineacredito.id AS [lineacredito.id],
        lineacredito.ctgid AS [lineacredito.ctgid],
        lineacredito.descripcion AS [lineacredito.descripcion],
        lineacredito.config AS [lineacredito.config],
        tipogarantia.id AS [tipogarantia.id],
        tipogarantia.ctgid AS [tipogarantia.ctgid],
        tipogarantia.descripcion AS [tipogarantia.descripcion],
        tipogarantia.config AS [tipogarantia.config],
        solicitud.capital AS [capital],
        solicitud.plazo AS [plazo],
        indexado.id AS [indexado.id],
        indexado.ctgid AS [indexado.ctgid],
        indexado.descripcion AS [indexado.descripcion],
        indexado.config AS [indexado.config],
        solicitud.spread AS [spread],
        tipointeres.id AS [tipointeres.id],
        tipointeres.ctgid AS [tipointeres.ctgid],
        tipointeres.descripcion AS [tipointeres.descripcion],
        tipointeres.config AS [tipointeres.config],
        amortizacionk.id AS [amortizacionk.id],
        amortizacionk.ctgid AS [amortizacionk.ctgid],
        amortizacionk.descripcion AS [amortizacionk.descripcion],
        amortizacionk.config AS [amortizacionk.config],
        amortizacionint.id AS [amortizacionint.id],
        amortizacionint.ctgid AS [amortizacionint.ctgid],
        amortizacionint.descripcion AS [amortizacionint.descripcion],
        amortizacionint.config AS [amortizacionint.config],
        solicitud.observaciones AS [observaciones],
        solicitud.estado AS [estado],
        solicitud.usuariocrea AS [usuariocrea],
        solicitud.fechacrea AS [fechacrea],
        solicitud.usuariomod AS [usuariomod],
        solicitud.fechamod AS [fechamod]
    FROM
        solicitud

        INNER JOIN valorcatalogo AS moneda
        ON solicitud.moneda = moneda.id

        LEFT JOIN valorcatalogo AS entfinanciera
        ON solicitud.entfinanciera = entfinanciera.id

        INNER JOIN regional AS regional
        ON solicitud.regional = regional.id
        
        LEFT JOIN valorcatalogo AS lineacredito
        ON solicitud.lineacredito = lineacredito.id

        LEFT JOIN valorcatalogo AS tipogarantia
        ON solicitud.tipogarantia = tipogarantia.id

        LEFT JOIN valorcatalogo AS indexado
        ON solicitud.indexado = indexado.id

        LEFT JOIN valorcatalogo AS tipointeres
        ON solicitud.tipointeres = tipointeres.id

        LEFT JOIN valorcatalogo AS amortizacionk
        ON solicitud.amortizacionk = amortizacionk.id

        LEFT JOIN valorcatalogo AS amortizacionint
        ON solicitud.amortizacionint = amortizacionint.id

    WHERE
        solicitud.id = @id
    FOR JSON PATH
GO

