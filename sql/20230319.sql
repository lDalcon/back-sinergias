USE SINERGIAS_DB
GO

ALTER TABLE detallepago
ADD seqid INT 
GO

ALTER TABLE detalleforward
ADD seqid INT 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_deltallepago_reversar') 
	DROP PROCEDURE [dbo].[sc_deltallepago_reversar]
GO

CREATE PROCEDURE sc_deltallepago_reversar
    @nick VARCHAR(50),
    @seq INT,
	@fecha DATE
AS
    INSERT INTO detallepago
	SELECT
		YEAR(@fecha),
		MONTH(@fecha),
		@fecha,
		idcredito,
		tipopago,
		formapago,
		trm,
		valor * -1,
		'REVERSADO',
		@nick,
		GETDATE(),
		@nick,
		GETDATE(),
		@seq
	FROM detallepago
	WHERE seq = @seq

	UPDATE detallepago SET seqid = @@IDENTITY
	WHERE seq = @seq
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_detalleforward_reversar') 
	DROP PROCEDURE [dbo].[sc_detalleforward_reversar]
GO

CREATE PROCEDURE sc_detalleforward_reversar
    @nick VARCHAR(50),          
    @seq INT,
	@fecha DATE
AS
	DECLARE @seqid INT
	
	SELECT @seqid = seqid FROM detallepago WHERE seq = @seq

    INSERT INTO detalleforward
	SELECT
		@seqid,
		YEAR(@fecha),
		MONTH(@fecha),
		@fecha,
		idforward,
		tipopago,
		formapago,
		trm,
		valor * -1,
		'REVERSADO',
		@nick,
		GETDATE(),
		@nick,
		GETDATE(),
		seqpago,
        @seq
	FROM detalleforward
	WHERE seq = @seq

	UPDATE detalleforward SET seqid = @seqid
	WHERE seq = @seq
GO


IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_credito_obtener') 
	DROP PROCEDURE [dbo].[sc_credito_obtener]
GO

CREATE PROCEDURE sc_credito_obtener
    @id INT = NULL,
    @pagare VARCHAR(50) = NULL,
    @entfinanciera INT = NULL,
    @moneda INT = NULL,
    @saldoasignacion NUMERIC(18,2) = NULL
AS
    SELECT
        credito.id AS [id],
        credito.ano AS [ano],
        credito.periodo AS [periodo],
        credito.fechadesembolso AS [fechadesembolso],
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
        credito.pagare AS [pagare],
        tipogarantia.id AS [tipogarantia.id],
        tipogarantia.ctgid AS [tipogarantia.ctgid],
        tipogarantia.descripcion AS [tipogarantia.descripcion],
        tipogarantia.config AS [tipogarantia.config],
        credito.capital AS [capital],
        credito.saldo AS [saldo],
        credito.plazo AS [plazo],
        indexado.id AS [indexado.id],
        indexado.ctgid AS [indexado.ctgid],
        indexado.descripcion AS [indexado.descripcion],
        indexado.config AS [indexado.config],
        credito.spread AS [spread],
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
        credito.saldoasignacion AS [saldoasignacion],
        credito.observaciones AS [observaciones],
        credito.estado AS [estado],
        credito.usuariocrea AS [usuariocrea],
        credito.fechacrea AS [fechacrea],
        credito.usuariomod AS [usuariomod],
        credito.fechamod AS [fechamod],
        (
            SELECT
                A.seq AS [seq],
                forward.id AS [id],
                entfinanciera.descripcion AS [entfinanciera],
                A.valorasignado + ISNULL(B.valorasignado, 0) AS [valorasignado],
                A.saldoasignacion + ISNULL(B.saldoasignacion, 0)AS [saldoasignacion],
                forward.tasaspot AS [tasaspot],
                forward.tasaforward AS [tasaforward], 
                forward.fechacumplimiento AS [fechacumplimiento],
                A.fechacrea AS [fechacrea],
                A.estado AS [estado]
            FROM
                creditoforward A

                INNER JOIN forward
                ON A.idforward = forward.id

                INNER JOIN valorcatalogo
                ON forward.entfinanciera = valorcatalogo.id

                LEFT JOIN creditoforward B
                ON A.seq = B.seqid

            WHERE
                A.idcredito = credito.id
                AND A.seqid IS NULL
            FOR JSON PATH
        )AS [forwards],
        (
            SELECT
                detallepago.seq AS [seq],
                detallepago.ano AS [ano],
                detallepago.periodo AS [periodo],
                detallepago.fechapago AS [fechapago],
                detallepago.idcredito AS [idcredito],
                ISNULL(detalleforward.idforward, 0) AS [idforward],
                detallepago.tipopago AS [tipopago],
                CASE WHEN detalleforward.formapago IS NULL
                    THEN detallepago.formapago
                    ELSE CONCAT(detalleforward.formapago, ' - ', detalleforward.idforward) END
                AS [formapago],
                detallepago.trm AS [trm],
                detallepago.valor AS [valor],
                detallepago.estado AS [estado],
                detallepago.usuariocrea AS [usuariocrea],
                detallepago.fechacrea AS [fechacrea],
                detallepago.usuariomod AS [usuariomod],
                detallepago.fechamod AS [fechamod],
				detalleforward.seqpago AS [seqpago]
            FROM
                detallepago

                LEFT JOIN detalleforward
                ON detallepago.seq = detalleforward.seq

            WHERE
                detallepago.idcredito = credito.id
				AND detallepago.seqid is null
            ORDER BY detallepago.SEQ ASC
            FOR JSON PATH
        ) AS [pagos],
		credito.periodogracia AS [periodogracia],
		credito.tasafija AS [tasa]
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

    WHERE
        credito.id = ISNULL(@id, credito.id)
        AND credito.pagare = ISNULL(@pagare, credito.pagare)
        AND credito.entfinanciera = ISNULL(@entfinanciera, credito.entfinanciera)
        AND moneda.id = ISNULL(@moneda, moneda.id)
        AND credito.saldoasignacion >= ISNULL(@saldoasignacion, credito.saldoasignacion)
    FOR JSON PATH
GO

CREATE OR ALTER PROCEDURE sc_credito_actualizarsaldo
    @id INT,
    @valorpago NUMERIC(18,2)
AS
    UPDATE credito
    SET
        saldo = saldo - @valorpago,
		estado = (CASE saldo - @valorpago WHEN 0 THEN 'PAGO' ELSE 'ACTIVO' END)
    WHERE
        id = @id    
GO


CREATE OR ALTER PROCEDURE [dbo].[sc_forward_listar]
    @nick VARCHAR(50),
    @saldo NUMERIC(18,2) = -1,
    @saldoasignacion NUMERIC(18,2) = -1,
    @regional INT = NULL
AS
    SELECT
        forward.id AS [id],
        forward.ano AS [ano],
        forward.fechaoperacion AS [fechaoperacion],
        forward.fechacumplimiento AS [fechacumplimiento],
        entfinanciera.descripcion AS [entfinanciera],
        regional.nombre AS [regional],
        forward.valorusd AS [valorusd], 
        forward.tasaspot AS [tasaspot],
        forward.devaluacion AS [devaluacion],
        forward.tasaforward AS [tasaforward],
        forward.valorcop AS [valorcop],
        forward.saldoasignacion AS [saldoasignacion],
        forward.saldo AS [saldo],
		forward.observaciones AS [observaciones],
        forward.estado AS [estado],
        forward.usuariocrea AS [usuariocrea],
        forward.fechacrea AS [fechacrea],
        forward.usuariomod AS [usuariomod],
        forward.fechamod AS [fechamod]  
    FROM
        forward

        INNER JOIN valorcatalogo AS entfinanciera
        ON forward.entfinanciera = entfinanciera.id

        INNER JOIN regional AS regional
        ON forward.regional = regional.id
  
    WHERE
        saldo >= @saldo
        AND saldoasignacion >= @saldoasignacion
        AND regional.id in (SELECT idregional FROM usuario_regional WHERE nick = @nick AND idregional = ISNULL(@regional, idregional))
GO

CREATE OR ALTER PROCEDURE sc_forward_actualizarsaldo
    @id INT,
    @seq INT,
    @valorPago NUMERIC(18,2),
	@nick VARCHAR(50)
AS
    UPDATE forward
    SET
        saldo = saldo - @valorPago,
		usuariomod = @nick,
		fechamod = GETDATE()
    WHERE
        id = @id
    
    UPDATE creditoforward
    SET
        saldoasignacion = saldoasignacion - @valorPago,
		usuariomod = @nick,
		fechamod = GETDATE()
    WHERE
        seq = @seq
GO

CREATE OR ALTER VIEW [dbo].[v_credito_tasa]
AS
    SELECT 
        id,
        YEAR(fechaPeriodo) AS [ano],
        MONTH(fechaPeriodo) AS [periodo],
        fechaPeriodo,
		nper,
        tasaEA,
		spreadEA,
		tasaIdxEA,
		interesCausado
    FROM 
        credito
        CROSS APPLY OPENJSON(amortizacion,'$.amortizacion')
        WITH (
            nper INT '$.nper',
            tasaEA NUMERIC(8,5) '$.tasaEA',
			spreadEA NUMERIC(8,5) '$.spreadEA',
            tasaIdxEA NUMERIC(8,5) '$.tasaIdxEA',
            fechaPeriodo DATE '$.fechaPeriodo',
            interescausado NUMERIC(18,2) '$.interesCausado'
        )
GO

CREATE OR ALTER PROCEDURE [dbo].[sc_credito_saldos_actualizar]
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

UPDATE detalleforward SET seqpago = '921' WHERE seq = '2800'
UPDATE detalleforward SET seqpago = '1185' WHERE seq = '4654'
UPDATE detalleforward SET seqpago = '972' WHERE seq = '2658'
UPDATE detalleforward SET seqpago = '1153' WHERE seq = '2531'
UPDATE detalleforward SET seqpago = '911' WHERE seq = '2629'
UPDATE detalleforward SET seqpago = '1207' WHERE seq = '4640'
UPDATE detalleforward SET seqpago = '1213' WHERE seq = '3281'
UPDATE detalleforward SET seqpago = '894' WHERE seq = '2788'
UPDATE detalleforward SET seqpago = '429' WHERE seq = '2902'
UPDATE detalleforward SET seqpago = '1369' WHERE seq = '4752'
UPDATE detalleforward SET seqpago = '959' WHERE seq = '2671'
UPDATE detalleforward SET seqpago = '1199' WHERE seq = '5289'
UPDATE detalleforward SET seqpago = '425' WHERE seq = '2897'

EXEC sc_actualizar_saldos
