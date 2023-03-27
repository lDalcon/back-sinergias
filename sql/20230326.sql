USE Sinergias_db
GO
--UPDATE menu SET opciones = '[{"items": [{"icon": "pi pi-fw pi-user", "label": "Usuarios", "routerLink": ["/admin/usuarios"]}, {"icon": "pi pi-fw pi-calendar", "label": "Calendario", "routerLink": ["/admin/calendario"]}], "label": "Admin"}, {"items": [{"icon": "pi pi-fw pi-chart-pie", "label": "Gerencial", "routerLink": ["/dashboard/gerencia"]}, {"icon": "pi pi-fw pi-chart-bar", "label": "Financiero", "routerLink": ["/dashboard/financiero"]}], "label": "Dashboard"}, {"items": [{"icon": "pi pi-fw pi-file", "label": "Solicitudes", "routerLink": ["/financiero/solicitudes"]}, {"icon": "pi pi-fw pi-credit-card", "label": "Obligaciones", "routerLink": ["/financiero/obligaciones"]}, {"icon": "pi pi-fw pi-dollar", "label": "Forward", "routerLink": ["/financiero/forward"]}, {"icon": "pi pi-fw pi-wallet", "label": "Dif. en Cambio", "routerLink": ["/financiero/diferenciacambio"]}], "label": "Financiero"}]'
--WHERE role = 'ADMIN'

--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[solicitud]') AND type in (N'U'))
--	DROP TABLE [dbo].[solicitud]
--GO

--CREATE TABLE solicitud (
--    id INT NOT NULL,
--    ano INT NOT NULL,
--    periodo INT NOT NULL,
--    fechareq DATE NOT NULL,
--    moneda INT NOT NULL,
--    regional INT NOT NULL,
--    capital NUMERIC(18,2) NOT NULL,
--    desembolso NUMERIC(18,2) NOT NULL,
--    desistido NUMERIC(18,2) NOT NULL,
--    plazo INT NOT NULL,
--    observaciones NVARCHAR(MAX),
--    estado VARCHAR(20),
--    usuariocrea VARCHAR(50),
--    fechacrea DATETIME NOT NULL,
--    usuariomod VARCHAR(50),
--    fechamod DATETIME NOT NULL,
--    PRIMARY KEY (id),
--    FOREIGN KEY (moneda) REFERENCES valorcatalogo(id),
--    FOREIGN KEY (regional) REFERENCES regional(id),
--    FOREIGN KEY (usuariocrea) REFERENCES usuarios(nick),
--    FOREIGN KEY (usuariomod) REFERENCES usuarios(nick),
--)
--GO

--ALTER TABLE credito
--ADD idsolicitud INT DEFAULT -1

--INSERT INTO controlconcecutivos VALUES
--('SOLICITUDES', '0' )


--IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_credito_guardar') 
--	DROP PROCEDURE [dbo].[sc_credito_guardar]
--GO

--CREATE PROCEDURE sc_credito_guardar
--    @fechadesembolso DATE,
--    @moneda INT,
--    @entfinanciera INT,
--    @regional INT,
--    @lineacredito INT,
--    @pagare VARCHAR(50),
--    @tipogarantia INT,
--    @capital NUMERIC(18,2),
--    @saldo NUMERIC(18,2),
--    @plazo INT,
--    @indexado INT,
--    @spread NUMERIC(6,2),
--    @tipointeres INT,
--    @amortizacionk INT,
--    @amortizacionint INT,
--    @saldoasignacion NUMERIC(18,2),
--    @estado VARCHAR(20),
--    @usuariocrea VARCHAR(50),
--	@tasafija NUMERIC(8,6),
--	@periodogracia INT,
--    @amortizacion VARCHAR(MAX),
--    @observaciones NVARCHAR(MAX),
--    @idsolicitud INT = -1
--AS
--    DECLARE @id INT;
--    DECLARE @ano INT = YEAR(@fechadesembolso);
--    DECLARE @periodo INT = MONTH(@fechadesembolso);

--    EXEC sc_obtenerconsecutivo 'OBLIGACION', @id OUTPUT;

--    INSERT INTO credito VALUES
--    (
--        @id,
--        @ano,
--        @periodo,
--        @fechadesembolso,
--        @moneda,
--        @entfinanciera,
--        @regional,
--        @lineacredito,
--        @pagare,
--        @tipogarantia,
--        @capital,
--        @saldo,
--        @plazo,
--        @indexado,
--        @spread,
--        @tipointeres,
--        @amortizacionk,
--        @amortizacionint,
--        @saldoasignacion,
--        @estado,
--        @usuariocrea,
--        GETDATE(),
--        @usuariocrea,
--        GETDATE(),
--		@periodogracia,
--		@tasafija,
--        @amortizacion,
--        @observaciones,
--        @idsolicitud
--    )

--    EXEC sc_credito_saldos_actualizar @ano, @periodo, @id
--GO

--ALTER VIEW [dbo].[v_credito_tasa]
--AS
--    SELECT 
--		id,
--		YEAR(fechaPeriodo) AS [ano],
--		MONTH(fechaPeriodo) AS [periodo],
--		fechaPeriodo,
--		nper,
--		tasaEA,
--		spreadEA,
--		tasaIdxEA,
--		interesCausado,
--		abonoCapital,
--		valorInteres
--    FROM 
--        credito
--        CROSS APPLY OPENJSON(amortizacion,'$.amortizacion')
--        WITH (
--            nper INT '$.nper',
--            tasaEA NUMERIC(8,5) '$.tasaEA',
--			  spreadEA NUMERIC(8,5) '$.spreadEA',
--            tasaIdxEA NUMERIC(8,5) '$.tasaIdxEA',
--            fechaPeriodo DATE '$.fechaPeriodo',
--            interescausado NUMERIC(18,2) '$.interesCausado',
--            abonoCapital NUMERIC(18,2) '$.abonoCapital',
--            valorInteres NUMERIC(18,2) '$.valorInteres'
--        )
--GO

--IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_reporte_infoRegistroSolicitud') 
--	DROP PROCEDURE [dbo].[sc_reporte_infoRegistroSolicitud]
--GO

--CREATE PROCEDURE sc_reporte_infoRegistroSolicitud
--	@regional INT
--AS
--	DECLARE @tmp TABLE (tipo VARCHAR(100), saldocop NUMERIC(18,2), saldousd NUMERIC(18,2), vencimientocop NUMERIC(18,2), vencimientousd NUMERIC(18,2))
	
--	/* Saldos */
--	INSERT INTO @tmp
--	SELECT 
--		lineacredito.descripcion AS [tipo], 
--		SUM(credito.saldo * (CASE credito.moneda WHEN 500 THEN 1 ELSE 0 END)) AS [saldocop],
--		SUM(credito.saldo * (CASE credito.moneda WHEN 500 THEN 0 ELSE 1 END)) AS [saldousd],
--		SUM(ISNULL(v_credito_tasa.abonoCapital, 0) * (CASE credito.moneda WHEN 500 THEN 1 ELSE 0 END)) AS [vencimientocop],
--		SUM(ISNULL(v_credito_tasa.abonoCapital, 0) * (CASE credito.moneda WHEN 500 THEN 0 ELSE 1 END)) AS [vencimientousd]
--	FROM
--		credito

--		INNER JOIN valorcatalogo AS lineacredito
--		ON credito.lineacredito = lineacredito.id

--		LEFT JOIN v_credito_tasa
--		ON credito.id = v_credito_tasa.id
--		AND v_credito_tasa.ano = YEAR(GETDATE())
--		AND v_credito_tasa.periodo = MONTH(GETDATE())

--	WHERE
--		credito.regional = @regional
--	GROUP BY
--		lineacredito.descripcion

--	/* Pagos */
--	--INSERT INTO @tmp
--	--SELECT
--	--	lineacredito.descripcion AS [tipo], 
--	--	0,
--	--	0,
--	--	SUM(detallepago.valor * (CASE credito.moneda WHEN 500 THEN -1 ELSE 0 END)) AS [vencimientocop],
--	--	SUM(detallepago.valor * (CASE credito.moneda WHEN 500 THEN 0 ELSE -1 END)) AS [vencimientousd]
--	--FROM
--	--	detallepago
		
--	--	INNER JOIN credito
--	--	ON detallepago.idcredito = credito.id

--	--	INNER JOIN valorcatalogo AS lineacredito
--	--	ON credito.lineacredito = lineacredito.id

--	--	INNER JOIN v_credito_tasa
--	--	ON credito.id = v_credito_tasa.id
--	--	AND v_credito_tasa.ano = YEAR(GETDATE())
--	--	AND v_credito_tasa.periodo = MONTH(GETDATE())
--	--WHERE
--	--	credito.regional = @regional
--	--GROUP BY
--	--	lineacredito.descripcion

--	SELECT
--		tipo,
--		SUM(saldocop) saldocop,
--		SUM(saldousd) saldousd,
--		SUM(vencimientocop) vencimientocop,
--		SUM(vencimientousd) vencimientousd
--	FROM 
--		@tmp
--	GROUP BY
--		tipo

--GO


--IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_solicitud_guardar') 
--	DROP PROCEDURE [dbo].[sc_solicitud_guardar]
--GO

--CREATE PROCEDURE sc_solicitud_guardar
--    @fechareq DATE,
--    @moneda INT,
--    @regional INT,
--    @capital NUMERIC(18,2),
--    @plazo INT,
--    @observaciones NVARCHAR(MAX),
--    @usuariocrea VARCHAR(50),
--    @id INT OUTPUT
--AS
	
--    EXEC sc_obtenerconsecutivo 'SOLICITUDES', @id OUTPUT;

--    INSERT INTO solicitud 
--    (
--        id,
--        ano,
--        periodo,
--        fechareq,
--        moneda,
--        regional,
--        capital,
--		desembolso,
--		desistido,
--        plazo,
--        observaciones,
--        estado,
--        usuariocrea,
--        usuariomod,
--        fechacrea,
--        fechamod
--    )
--    VALUES
--    (
--        @id,
--        YEAR(GETDATE()),
--        MONTH(GETDATE()),
--        @fechareq,
--        @moneda,
--        @regional,
--        @capital,
--		0,
--		0,
--        @plazo,
--        @observaciones,
--        'ESTUDIO',
--        @usuariocrea,
--        @usuariocrea,
--        GETDATE(),
--        GETDATE()
--    )
--GO


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