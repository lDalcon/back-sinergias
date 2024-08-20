ALTER PROCEDURE [dbo].[sc_credito_listar]
    @nick VARCHAR(50),
    @regional INT = NULL,
    @lineacredito INT = NULL,
    @estado VARCHAR(20) = NULL
AS
    SELECT
        credito.id AS [id],
        credito.ano AS [ano],
        credito.fechadesembolso AS [fechadesembolso],
        moneda.descripcion AS [moneda],
        entfinanciera.descripcion AS [entfinanciera],
        regional.nombre AS [regional],
        lineacredito.descripcion AS [lineacredito],
        credito.pagare AS [pagare],
        tipogarantia.descripcion AS [tipogarantia],
        credito.capital AS [capital],
        credito.saldo AS [saldo],
        credito.plazo AS [plazo],
        indexado.descripcion AS [indexado],
        credito.spread AS [spread],
        v_credito_tasa.tasaEA AS [tasaEA],
        tipointeres.descripcion AS [tipointeres],
        amortizacionk.descripcion AS [amortizacionk],
        amortizacionint.descripcion AS [amortizacionint],
        credito.saldoasignacion AS [saldoasignacion],
        credito.estado AS [estado],
        credito.usuariocrea AS [usuariocrea],
        credito.fechacrea AS [fechacrea],
        credito.usuariomod AS [usuariomod],
        credito.fechamod AS [fechamod]
    FROM
        credito

        INNER JOIN valorcatalogo AS moneda
        ON credito.moneda = moneda.id

        INNER JOIN valorcatalogo AS entfinanciera
        ON credito.entfinanciera = entfinanciera.id

        INNER JOIN regional AS regional
        ON credito.regional = regional.id
        
        INNER JOIN valorcatalogo AS lineacredito
        ON credito.lineacredito = lineacredito.id

        INNER JOIN valorcatalogo AS tipogarantia
        ON credito.tipogarantia = tipogarantia.id

        INNER JOIN valorcatalogo AS indexado
        ON credito.indexado = indexado.id

        INNER JOIN valorcatalogo AS tipointeres
        ON credito.tipointeres = tipointeres.id

        INNER JOIN valorcatalogo AS amortizacionk
        ON credito.amortizacionk = amortizacionk.id

        INNER JOIN valorcatalogo AS amortizacionint
        ON credito.amortizacionint = amortizacionint.id

        LEFT JOIN v_credito_tasa
        ON credito.id = v_credito_tasa.id
        AND credito.plazo = v_credito_tasa.nper
    
    WHERE
        regional.id in (SELECT idregional FROM usuario_regional WHERE nick = @nick AND idregional = ISNULL(@regional, idregional))
        AND credito.lineacredito = ISNULL(@lineacredito, credito.lineacredito)
        AND credito.estado = ISNULL(@estado, credito.estado)
GO

DROP TABLE [dbo].[aumentocapital]
GO
CREATE TABLE [dbo].[aumentocapital](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ano] [int] NOT NULL,
	[periodo] [int] NOT NULL,
	[idcredito] [int] NOT NULL,
	[fecha] [date] NOT NULL,
    [tipo] [varchar](15) NOT NULL,
	[valor] [numeric](18, 2) NOT NULL,
	[estado] [varchar](10) NOT NULL,
	[observacion] [varchar](500) NULL,
	[usuariocrea] [varchar](50) NOT NULL,
	[fechacrea] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[aumentocapital]  WITH CHECK ADD FOREIGN KEY([idcredito])
REFERENCES [dbo].[credito] ([id])
GO
ALTER TABLE [dbo].[aumentocapital]  WITH CHECK ADD FOREIGN KEY([usuariocrea])
REFERENCES [dbo].[usuarios] ([nick])
GO

INSERT INTO menu VALUES
(
    'DEUDASALDOSINFOFINCONS',
    '[
	{
		"items": [
			{
				"icon": "pi pi-fw pi-chart-pie",
				"label": "Gerencial",
				"routerLink": [
					"/dashboard/gerencia"
				]
			},
			{
				"icon": "pi pi-fw pi-chart-bar",
				"label": "Financiero",
				"routerLink": [
					"/dashboard/financiero"
				]
			}
		],
		"label": "Dashboard"
	},
	{
		"items": [
			{
				"icon": "pi pi-fw pi-credit-card",
				"label": "Obligaciones",
				"routerLink": [
					"/financiero/obligaciones"
				]
			},
			{
				"icon": "pi pi-fw pi-dollar",
				"label": "Forward",
				"routerLink": [
					"/financiero/forward"
				]
			},
			{
				"icon": "pi pi-fw pi-wallet",
				"label": "Dif. en Cambio",
				"routerLink": [
					"/financiero/diferenciacambio"
				]
			},
			{
				"icon": "pi pi-fw pi-calendar",
				"label": "Saldos Diarios",
				"routerLink": [
					"/financiero/saldosdiario"
				]
			},
			{
				"icon": "pi pi-fw pi-database",
				"label": "Info. Relevante",
				"routerLink": [
					"/financiero/inforelevante"
				]
			},
			{
                "icon": "pi pi-fw pi-building",
                "label": "Crédito Constructor",
                "routerLink": [
                    "/financiero/constructor"
                ]
            }
		],
		"label": "Financiero"
	}
]'
)

UPDATE menu SET opciones = '[
    {
        "items": [
            {
                "icon": "pi pi-fw pi-user",
                "label": "Usuarios",
                "routerLink": [
                    "/admin/usuarios"
                ]
            },
            {
                "icon": "pi pi-fw pi-calendar",
                "label": "Calendario",
                "routerLink": [
                    "/admin/calendario"
                ]
            },
            {
                "icon": "pi pi-fw pi-dollar",
                "label": "Macroeconomicos",
                "routerLink": [
                    "/admin/macroeconomicos"
                ]
            }
        ],
        "label": "Admin"
    },
    {
        "items": [
            {
                "icon": "pi pi-fw pi-chart-pie",
                "label": "Gerencial",
                "routerLink": [
                    "/dashboard/gerencia"
                ]
            },
            {
                "icon": "pi pi-fw pi-chart-bar",
                "label": "Financiero",
                "routerLink": [
                    "/dashboard/financiero"
                ]
            }
        ],
        "label": "Dashboard"
    },
    {
        "items": [
            {
                "icon": "pi pi-fw pi-file",
                "label": "Solicitudes",
                "routerLink": [
                    "/financiero/solicitudes"
                ]
            },
            {
                "icon": "pi pi-fw pi-credit-card",
                "label": "Obligaciones",
                "routerLink": [
                    "/financiero/obligaciones"
                ]
            },
            {
                "icon": "pi pi-fw pi-dollar",
                "label": "Forward",
                "routerLink": [
                    "/financiero/forward"
                ]
            },
            {
                "icon": "pi pi-fw pi-wallet",
                "label": "Dif. en Cambio",
                "routerLink": [
                    "/financiero/diferenciacambio"
                ]
            },
            {
                "icon": "pi pi-fw pi-calendar",
                "label": "Saldos Diarios",
                "routerLink": [
                    "/financiero/saldosdiario"
                ]
            },
            {
                "icon": "pi pi-fw pi-database",
                "label": "Info. Relevante",
                "routerLink": [
                    "/financiero/inforelevante"
                ]
            },
            {
                "icon": "pi pi-fw pi-building",
                "label": "Crédito Constructor",
                "routerLink": [
                    "/financiero/constructor"
                ]
            }
        ],
        "label": "Financiero"
    }
]' WHERE role = 'ADMIN'
GO

CREATE OR ALTER PROCEDURE sc_aumento_capital_guardar
    @fecha DATE,
    @idcredito INT,
    @tipo VARCHAR(15),
    @valor NUMERIC(18,2),
    @estado VARCHAR(10),
    @observacion VARCHAR(500),
    @usuariocrea VARCHAR(50)
AS
    DECLARE @ano INT = YEAR(@fecha);
    DECLARE @periodo INT = MONTH(@fecha);
    INSERT INTO aumentocapital 
    ( 
        ano,
        periodo,
        idcredito,
        fecha,
        tipo,
        valor,
        estado,
        observacion,
        usuariocrea,
        fechacrea
    )
    VALUES
    (
        @ano,
        @periodo,
        @idcredito,
        @fecha,
        @tipo,
        @valor,
        @estado,
        @observacion,
        @usuariocrea,
        GETDATE()
    )

    EXEC sc_actualizar_saldos NULL, @idcredito
    EXEC sc_credito_saldos_actualizar @ano, @periodo, @idcredito;
GO


ALTER  PROCEDURE [dbo].[sc_credito_saldos_actualizar]
    @ano INT,
    @periodo INT,
    @id INT = NULL
AS
	DECLARE @anoanterior INT
	DECLARE @periodoanterior INT
	DECLARE @temp TABLE (
		id INT,
		ano INT,
		periodo INT,
		abonoscapital NUMERIC(18,2),
		interespago NUMERIC(18,2),
		interescausado NUMERIC(18,2),
		tasapromedio NUMERIC(18,2),
		saldokinicial NUMERIC(18,2)
	)

    DELETE credito_saldos
	WHERE 
		ano = @ano 
		AND periodo = @periodo 
		AND id = ISNULL(@id, id)

	SELECT @periodoanterior = CASE @periodo WHEN 1 THEN 12 ELSE @periodo - 1 END
	SELECT @anoanterior = CASE @periodo WHEN 1 THEN @ano - 1  ELSE @ano END

	/* Saldos Iniciales */

	INSERT INTO @temp
		SELECT
			credito_saldos.id,
			@ano,
			@periodo,
			0,
			0,
			0,
			0,
			credito_saldos.saldokinicial - credito_saldos.abonoscapital
		FROM
			credito_saldos           
		WHERE
			credito_saldos.ano = @anoanterior
			AND credito_saldos.periodo = @periodoanterior
			AND credito_saldos.id = ISNULL(@id, credito_saldos.id)

	/* Creditos del Mes */

    INSERT INTO @temp
		SELECT 
			credito.id,
			@ano,
			@periodo,
			0,
			0,
			0,
			0,
			credito.capital
		FROM 
			credito
		WHERE
			credito.ano = @ano
			AND credito.periodo = @periodo
			AND credito.id = ISNULL(@id, credito.id)

	/* Pagos Capital registrados del mes */

	INSERT INTO @temp
		SELECT
			detallepago.idcredito,
			@ano,
			@periodo,
			detallepago.valor,
			0,
			0,
			0,
			0
		FROM
			detallepago
		WHERE
			detallepago.ano = @ano
			AND detallepago.periodo = @periodo
			AND detallepago.tipopago = 'Capital'
			AND detallepago.idcredito = ISNULL(@id, idcredito)
	
	/* Pagos Interes registrados del mes */

	INSERT INTO @temp
		SELECT
			detallepago.idcredito,
			@ano,
			@periodo,
			0,
			detallepago.valor,
			ISNULL((SELECT TOP 1 interescausado FROM v_credito_tasa WHERE v_credito_tasa.id = detallepago.idcredito AND fechaPeriodo <= EOMONTH(CONCAT(@ano,'-',@periodo, '-', '01')) ORDER by fechaPeriodo desc), -1),
			ISNULL((SELECT TOP 1 tasaEA FROM v_credito_tasa WHERE v_credito_tasa.id = detallepago.idcredito AND fechaPeriodo <= EOMONTH(CONCAT(@ano,'-',@periodo, '-', '01')) ORDER by fechaPeriodo desc), -1),
			0
		FROM
			detallepago

		WHERE
			detallepago.ano = @ano
			AND detallepago.periodo = @periodo
			AND detallepago.tipopago = 'Interes'
			AND detallepago.idcredito = ISNULL(@id, idcredito)

    /* Aumentos de capital del mes*/

    INSERT INTO @temp
        SELECT
            aumentocapital.idcredito,
            @ano,
            @periodo,
            aumentocapital.valor * -1,
            0,
            0,
            0,
            0
        FROM
            aumentocapital
        WHERE
            aumentocapital.ano = @ano
            AND aumentocapital.periodo = @periodo
            AND aumentocapital.idcredito = ISNULL(@id, idcredito)

    /* Consolidado*/

    INSERT INTO credito_saldos
		SELECT
			id,
			ano,
			periodo,
			SUM(abonoscapital),
			SUM(interespago),
			SUM(interescausado),
			SUM(tasapromedio),
			SUM(saldokinicial)
		FROM
			@temp
		GROUP BY
			id,
			ano,
			periodo
GO

CREATE OR ALTER PROCEDURE sc_aumento_capital_listar
    @idcredito INT
AS 
    SELECT 
        * 
    FROM 
        aumentocapital 
    WHERE 
        idcredito = @idcredito
GO