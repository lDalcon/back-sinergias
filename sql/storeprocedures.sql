
USE Sinergias_db
GO
/* Procedimientos */

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_usuario_crear') 
	DROP PROCEDURE [dbo].[sc_usuario_crear]
GO

CREATE PROCEDURE sc_usuario_crear
    @nick VARCHAR(50),
    @nombres VARCHAR(100),
    @apellidos VARCHAR(100),
    @password VARCHAR(4000),
    @email VARCHAR(100),
    @role VARCHAR(50)
AS
    INSERT INTO usuarios 
    VALUES (@nick, @nombres, @apellidos, @password, @email, @role, 1)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_usuario_login') 
	DROP PROCEDURE [dbo].[sc_usuario_login]
GO

CREATE PROCEDURE sc_usuario_login
    @nick VARCHAR(50)
AS
    SELECT
        nick as [nick],
        nombres as [nombres],
        apellidos as [apellidos],
        password as [password],
        menu.role as [menu.role],
        opciones as [menu.opciones],
        ISNULL((
            SELECT
                regional.id AS [id],
                regional.nit AS [nit],
                regional.nombre AS [nombre],
                regional.estado AS [estado],
                regional.config AS [config]
            FROM
                usuario_regional

                INNER JOIN regional
                ON regional.id = usuario_regional.idregional
                AND regional.estado = 1
            WHERE
                usuario_regional.nick = usuarios.nick
            ORDER BY regional.nombre ASC
            FOR JSON PATH
        ),'[]') as [regionales]
    FROM
        usuarios

        INNER JOIN menu
        ON usuarios.role = menu.role

    WHERE
        nick = @nick
        AND estado = 1
    FOR JSON PATH
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_usuario_listar') 
	DROP PROCEDURE [dbo].[sc_usuario_listar]
GO

CREATE PROCEDURE sc_usuario_listar
AS
      SELECT
        nick as [nick],
        nombres as [nombres],
        apellidos as [apellidos],
        '' as [password],
        email as [email],
        menu.role as [menu.role],
        '[]' as [menu.opciones],
        ISNULL((
            SELECT
                regional.id AS [id],
                regional.nit AS [nit],
                regional.nombre AS [nombre],
                regional.estado AS [estado],
                regional.config AS [config]
            FROM
                usuario_regional

                INNER JOIN regional
                ON regional.id = usuario_regional.idregional
                AND regional.estado = 1
            WHERE
                usuario_regional.nick = usuarios.nick
            FOR JSON PATH
        ),'[]') as [regionales],
        estado as [estado]
    FROM
        usuarios

        INNER JOIN menu
        ON usuarios.role = menu.role
    
    FOR JSON PATH
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_usuario_actualizar') 
	DROP PROCEDURE [dbo].[sc_usuario_actualizar]
GO

CREATE PROCEDURE sc_usuario_actualizar
    @nick VARCHAR(50),
    @nombres VARCHAR(100),
    @apellidos VARCHAR(100),
    @email VARCHAR(100),
    @role VARCHAR(50),
    @estado BIT
AS
    UPDATE usuarios SET
        nombres = @nombres,
        apellidos = @apellidos,
        email = @email,
        role = @role,
        estado = @estado
    WHERE
        nick = @nick
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_obtenerconsecutivo') 
	DROP PROCEDURE [dbo].[sc_obtenerconsecutivo]
GO

CREATE PROCEDURE sc_obtenerconsecutivo
    @documento VARCHAR(50),
    @consecutivo INT OUTPUT
AS
    BEGIN
        SELECT
           @consecutivo = concecutivo + 1
        FROM
            controlconcecutivos
        WHERE
            documento = @documento
        
        UPDATE controlconcecutivos 
        SET concecutivo = @consecutivo
    WHERE documento = @documento
    END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_getCatalogoById') 
	DROP PROCEDURE [dbo].[sc_getCatalogoById]
GO

CREATE PROCEDURE sc_getCatalogoById
    @id VARCHAR(10)
AS
    SELECT
        catalogo.id AS [id],
        catalogo.descripcion AS [descripcion],
        catalogo.config AS [config],
        valorcatalogo.id as [id],
        valorcatalogo.ctgid as [ctgid],
        valorcatalogo.descripcion as [descripcion],
        valorcatalogo.config as [config]
    FROM
        catalogo

        INNER JOIN valorcatalogo
        ON catalogo.id = valorcatalogo.ctgid

    WHERE
        catalogo.id = @id
    ORDER BY valorcatalogo.descripcion
    FOR JSON AUTO
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_regional_listar') 
	DROP PROCEDURE [dbo].[sc_regional_listar]
GO

CREATE PROCEDURE sc_regional_listar
AS
    SELECT
        id as id,
        nit as nit,
        nombre as nombre,
        config as config,
        estado as estado
    FROM
        regional
    ORDER BY nombre ASC
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_getReginalByNit') 
	DROP PROCEDURE [dbo].[sc_getReginalByNit]
GO

CREATE PROCEDURE sc_getReginalByNit
    @nit VARCHAR(15)
AS
    SELECT
        id as id,
        nit as nit,
        nombre as nombre,
        config as config,
        estado as estado
    FROM
        regional
    WHERE
        nit = @nit
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_getMacroeconomicosByDate') 
	DROP PROCEDURE [dbo].[sc_getMacroeconomicosByDate]
GO

CREATE PROCEDURE sc_getMacroeconomicosByDate
    @date DATE
AS
    SELECT
        ano as ano,
        periodo as periodo,
        fecha as fecha,
        tipo as tipo,
        valor as valor,
        unidad as unidad
    FROM
        macroeconomicos
    WHERE
        fecha = @date
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_getMacroeconomicosByDateAndType') 
	DROP PROCEDURE [dbo].[sc_getMacroeconomicosByDateAndType]
GO

CREATE PROCEDURE sc_getMacroeconomicosByDateAndType
    @date DATE,
    @type VARCHAR(50)
AS
    SELECT TOP 1
        ano as ano,
        periodo as periodo,
        fecha as fecha,
        tipo as tipo,
        valor as valor,
        unidad as unidad
    FROM
        macroeconomicos
    WHERE
        fecha <= @date
        AND tipo = @type
    ORDER BY fecha DESC
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_credito_guardar') 
	DROP PROCEDURE [dbo].[sc_credito_guardar]
GO

CREATE PROCEDURE sc_credito_guardar
    @fechadesembolso DATE,
    @moneda INT,
    @entfinanciera INT,
    @regional INT,
    @lineacredito INT,
    @pagare VARCHAR(50),
    @tipogarantia INT,
    @capital NUMERIC(18,2),
    @saldo NUMERIC(18,2),
    @plazo INT,
    @indexado INT,
    @spread NUMERIC(6,2),
    @tipointeres INT,
    @amortizacionk INT,
    @amortizacionint INT,
    @saldoasignacion NUMERIC(18,2),
    @estado VARCHAR(20),
    @usuariocrea VARCHAR(50),
	@tasafija NUMERIC(8,6),
	@periodogracia INT,
    @amortizacion VARCHAR(MAX),
    @observaciones NVARCHAR(MAX)
AS
    DECLARE @id INT;

    EXEC sc_obtenerconsecutivo 'OBLIGACION', @id OUTPUT;

    INSERT INTO credito VALUES
    (
        @id,
        YEAR(@fechadesembolso),
        MONTH(@fechadesembolso),
        @fechadesembolso,
        @moneda,
        @entfinanciera,
        @regional,
        @lineacredito,
        @pagare,
        @tipogarantia,
        @capital,
        @saldo,
        @plazo,
        @indexado,
        @spread,
        @tipointeres,
        @amortizacionk,
        @amortizacionint,
        @saldoasignacion,
        @estado,
        @usuariocrea,
        GETDATE(),
        @usuariocrea,
        GETDATE(),
		@periodogracia,
		@tasafija,
        @amortizacion,
        @observaciones
    )
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_credito_listar') 
	DROP PROCEDURE [dbo].[sc_credito_listar]
GO

CREATE PROCEDURE sc_credito_listar
    @nick VARCHAR(50),
    @regional INT = NULL,
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
    
    WHERE
        regional.id in (SELECT idregional FROM usuario_regional WHERE nick = @nick AND idregional = ISNULL(@regional, idregional))
        AND credito.estado = ISNULL(@estado, credito.estado)
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
                creditoforward.seq AS [seq],
                forward.id AS [id],
                entfinanciera.descripcion AS [entfinanciera],
                creditoforward.valorasignado AS [valorasignado],
                creditoforward.saldoasignacion AS [saldoasignacion],
                forward.tasaspot AS [tasaspot],
                forward.tasaforward AS [tasaforward], 
                forward.fechacumplimiento AS [fechacumplimiento],
                creditoforward.fechacrea AS [fechacrea],
                creditoforward.estado AS [estado]
            FROM
                creditoforward

                INNER JOIN forward
                ON creditoforward.idforward = forward.id

                INNER JOIN valorcatalogo
                ON forward.entfinanciera = valorcatalogo.id

            WHERE
                creditoforward.idcredito = credito.id
            FOR JSON PATH
        )AS [forwards],
        (
            SELECT
                detallepago.seq AS [seq],
                detallepago.ano AS [ano],
                detallepago.periodo AS [periodo],
                detallepago.fechapago AS [fechapago],
                detallepago.idcredito AS [idcredito],
                detallepago.tipopago AS [tipopago],
                detallepago.formapago AS [formapago],
                detallepago.trm AS [trm],
                detallepago.valor AS [valor],
                detallepago.estado AS [estado],
                detallepago.usuariocrea AS [usuariocrea],
                detallepago.fechacrea AS [fechacrea],
                detallepago.usuariomod AS [usuariomod],
                detallepago.fechamod AS [fechamod]
            FROM
                detallepago
            WHERE
                detallepago.idcredito = credito.id
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

CREATE OR ALTER PROCEDURE sc_forward_guardar
    @fechaoperacion DATE,
    @fechacumplimiento DATE,
    @entfinanciera INT,
    @regional INT,
    @valorusd NUMERIC(18,2),
    @tasaspot NUMERIC(18,2),
    @devaluacion NUMERIC(6,5),
    @tasaforward NUMERIC(18,2),
    @valorcop NUMERIC(18,2),
    @estado VARCHAR(20),
    @usuariocrea VARCHAR(50)
AS
    DECLARE @id INT;

    EXEC sc_obtenerconsecutivo 'FORWARD', @id OUTPUT;

    INSERT INTO forward VALUES
    (
        @id,
        YEAR(@fechaoperacion),
        MONTH(@fechaoperacion),
        @fechaoperacion,
        @fechacumplimiento,
        @entfinanciera,
        @regional,
        @valorusd,
        @tasaspot,
        @devaluacion,
        @tasaforward,
        @valorcop,
        @valorusd,
        @valorusd,
        'ACTIVO',
        @usuariocrea,
        GETDATE(),
        @usuariocrea,
        GETDATE(),
		DATEDIFF(DAY, @fechaoperacion, @fechacumplimiento)
    )
GO

CREATE OR ALTER PROCEDURE sc_forward_listar
    @nick VARCHAR(50),
    @saldo INT = -1,
    @saldoasignacion INT = -1,
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


CREATE OR ALTER PROCEDURE sc_forward_obtener
    @id INT
AS
    SELECT
        forward.id AS [id],
        forward.ano AS [ano],
        forward.fechaoperacion AS [fechaoperacion],
        forward.fechacumplimiento AS [fechacumplimiento],
        entfinanciera.id AS [entfinanciera.id],
        entfinanciera.ctgid AS [entfinanciera.ctgid],
        entfinanciera.descripcion AS [entfinanciera.descripcion],
        entfinanciera.config AS [entfinanciera.config],
        regional.id AS [regional.id],
        regional.nit AS [regional.nit],
        regional.nombre AS [regional.nombre],
        regional.config AS [regional.config],
        forward.valorusd AS [valorusd], 
        forward.tasaspot AS [tasaspot],
        forward.devaluacion AS [devaluacion],
        forward.tasaforward AS [tasaforward],
        forward.valorcop AS [valorcop],
        forward.saldoasignacion AS [saldoasignacion],
        forward.estado AS [estado],
        forward.usuariocrea AS [usuariocrea],
        forward.fechacrea AS [fechacrea],
        forward.usuariomod AS [usuariomod],
        forward.fechamod AS [fechamod],
        (
            SELECT
                creditoforward.seq AS [seq],
                credito.id AS [id],
                entfinanciera.descripcion AS [entfinanciera],
                creditoforward.valorasignado AS [valorasignado],
                creditoforward.saldoasignacion AS [saldoasignacion],
                credito.fechadesembolso AS [fechadesembolso],
                creditoforward.fechacrea AS [fechacrea],
                creditoforward.estado AS [estado]
            FROM
                creditoforward

                INNER JOIN credito
                ON creditoforward.idcredito = credito.id

                INNER JOIN valorcatalogo AS entfinanciera
                ON credito.entfinanciera = entfinanciera.id

            WHERE
                creditoforward.idforward = forward.id
            FOR JSON PATH
        ) AS creditos            
    FROM
        forward

        INNER JOIN valorcatalogo AS entfinanciera
        ON forward.entfinanciera = entfinanciera.id

        INNER JOIN regional AS regional
        ON forward.regional = regional.id

    WHERE
        forward.id = @id
    FOR JSON PATH
GO

CREATE OR ALTER PROCEDURE sc_creditoforward_crear
    @ano INT,
    @periodo INT,
    @idcredito INT,
    @idforward INT,
    @valorasignado NUMERIC(18,2),
    @usuariocrea VARCHAR(50),
    @estado VARCHAR(20) = NULL
AS
    INSERT INTO creditoforward VALUES
        (
            @ano,
            @periodo,
            @idcredito,
            @idforward,
            @valorasignado,
            @valorasignado,
            ISNULL(@estado, 'ACTIVO'),
            '',
            @usuariocrea,
            GETDATE(),
            @usuariocrea,
            GETDATE()
        )
GO

CREATE OR ALTER PROCEDURE sc_credito_actualizarsaldoasginacion
    @id INT,
    @valorasignado NUMERIC(18,2)
AS
    UPDATE credito
    SET
        saldoasignacion = saldoasignacion - @valorasignado
    WHERE
        id = @id
GO

CREATE OR ALTER PROCEDURE sc_forward_actualizarsaldoasginacion
    @id INT,
    @valorasignado NUMERIC(18,2)
AS
    UPDATE forward
    SET
        saldoasignacion = saldoasignacion - @valorasignado
    WHERE
        id = @id
GO

CREATE OR ALTER PROCEDURE sc_detallepago_crear
    @fechapago DATE,
    @idcredito INT,
    @tipopago VARCHAR(200),
    @formapago VARCHAR(200),
    @trm NUMERIC(18,2),
    @valor NUMERIC(18,2),
    @usuariocrea VARCHAR(50),
    @seq INT OUTPUT
AS
    INSERT INTO detallepago VALUES
    (
        YEAR(@fechapago),
        MONTH(@fechapago),
        @fechapago,
        @idcredito,
        @tipopago,
        @formapago,
        @trm,
        @valor,
        'ACTIVO',
        @usuariocrea,
        GETDATE(),
        @usuariocrea,
        GETDATE()
    )

    SELECT @seq = @@IDENTITY
GO

CREATE OR ALTER PROCEDURE sc_detalleforward_crear
    @seq INT,
    @fechapago DATE,
    @idforward INT,
    @tipopago VARCHAR(200),
    @formapago VARCHAR(200),
    @trm NUMERIC(18,2),
    @valor NUMERIC(18,2),
    @usuariocrea VARCHAR(50)
AS
    INSERT INTO detalleforward VALUES
    (
        @seq,
        YEAR(@fechapago),
        MONTH(@fechapago),
        @fechapago,
        @idforward,
        @tipopago,
        @formapago,
        @trm,
        @valor,
        'ACTIVO',
        @usuariocrea,
        GETDATE(),
        @usuariocrea,
        GETDATE()
    )
GO

CREATE OR ALTER PROCEDURE sc_forward_actualizarsaldo
    @id INT,
    @seq INT,
    @valorPago NUMERIC(18,2)
AS
    UPDATE forward
    SET
        saldo = saldo - @valorPago
    WHERE
        id = @id
    
    UPDATE creditoforward
    SET
        saldoasignacion = saldoasignacion - @valorPago
    WHERE
        seq = @seq
GO

CREATE OR ALTER PROCEDURE sc_credito_actualizarsaldo
    @id INT,
    @valorpago NUMERIC(18,2)
AS
    UPDATE credito
    SET
        saldo = saldo - @valorpago
    WHERE
        id = @id
GO

CREATE OR ALTER PROCEDURE sc_credito_saldos_actualizar
    @ano INT,
    @periodo INT,
    @id INT = NULL
AS
	DECLARE @anoanterior INT
	DECLARE @periodoanterior INT
    DELETE credito_saldos
	WHERE 
		ano = @ano 
		AND periodo = @periodo 
		AND id = ISNULL(@id, id)

	SELECT @periodoanterior = CASE @periodo WHEN 1 THEN 12 ELSE @periodo - 1 END
	SELECT @anoanterior = CASE @periodo WHEN 1 THEN @ano - 1  ELSE @ano END

    INSERT INTO credito_saldos
		SELECT
			id,
			@ano,
			@periodo,
			(SELECT ISNULL(SUM(valor),0) FROM detallepago WHERE ano = @ano AND periodo = @periodo AND tipopago = 'Capital' AND detallepago.idcredito = credito_saldos.id ),
			(SELECT ISNULL(SUM(valor),0) FROM detallepago WHERE ano = @ano AND periodo = @periodo AND tipopago = 'Interes' AND detallepago.idcredito = credito_saldos.id ),
			0,
			0,
			credito_saldos.saldokinicial - credito_saldos.abonoscapital
		FROM
			credito_saldos
		WHERE
			ano = @anoanterior
			AND periodo = @periodoanterior
			AND id = ISNULL(@id, id)


	INSERT INTO credito_saldos
		SELECT 
			id,
			@ano,
			@periodo,
			(SELECT ISNULL(SUM(valor),0) FROM detallepago WHERE ano = @ano AND periodo = @periodo AND tipopago = 'Capital' AND detallepago.idcredito = credito.id ),
			(SELECT ISNULL(SUM(valor),0) FROM detallepago WHERE ano = @ano AND periodo = @periodo AND tipopago = 'Interes' AND detallepago.idcredito = credito.id ),
			0,
			0,
			credito.capital
		FROM 
			credito
		WHERE
			ano = @ano
			AND periodo = @periodo
			AND id = ISNULL(@id, id)

	DELETE credito_saldos
	WHERE
		ano = @ano
		AND periodo = @periodo
		AND saldokinicial = 0
		AND abonoscapital = 0
		AND interespago = 0
GO


IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_usuarioregional_delete') 
	DROP PROCEDURE [dbo].[sc_usuarioregional_delete]
GO

CREATE OR ALTER PROCEDURE sc_usuarioregional_delete
    @nick VARCHAR(50)
AS
    DELETE usuario_regional
    WHERE nick = @nick
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_usuarioregional_add') 
	DROP PROCEDURE [dbo].[sc_usuarioregional_add]
GO

CREATE OR ALTER PROCEDURE sc_usuarioregional_add
    @nick VARCHAR(50),
    @idregional INT
AS
    INSERT INTO usuario_regional VALUES (@nick, @idregional)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_reporte_consolidado') 
	DROP PROCEDURE [dbo].[sc_reporte_consolidado]
GO

CREATE OR ALTER PROCEDURE sc_reporte_consolidado
	@ano INT,
	@periodo INT,
    @nick VARCHAR(50)
AS
	DECLARE @trmprom NUMERIC(18,2)
	DECLARE @trmcierre NUMERIC(18,2)

	SELECT @trmcierre = CAST((SELECT valor FROM macroeconomicos WHERE tipo = 'TRM' AND fecha = (SELECT MAX(FECHA) FROM macroeconomicos WHERE ano = @ano AND periodo = @periodo)) AS NUMERIC(18,2))
	SELECT @trmprom = CAST((SELECT AVG(valor) FROM macroeconomicos WHERE tipo = 'TRM' AND ano = @ano AND periodo = @periodo) AS NUMERIC(18,2))
	
    SELECT 
        credito_saldos.ano AS [ano],
        credito_saldos.periodo AS [periodo],
		empresa.razonsocial AS [razonsocial],
		empresa.cluster AS [cluster],
        regional.nombre AS [regional],
        credito_saldos.id AS [idcredito],
        CONVERT(VARCHAR(10), credito.fechadesembolso, 103) AS [fechadesembolso],
        moneda.descripcion AS [moneda],
        lineacredito.descripcion AS [lineacredito],
        entfinanciera.descripcion AS [entfinanciera],
		entfinanciera.tipo AS [tipo],
        amortizacionint.descripcion AS [amortizacionint],
        amortizacionk.descripcion AS [amortizacionk],
        indexado.descripcion AS [indexado],
        credito.spread AS [spread],
        (
            SELECT 
                valor 
            FROM 
                macroeconomicos A
            WHERE
                A.tipo = indexado.descripcion
                AND A.fecha = credito.fechadesembolso
        ) AS [tasa],
		CASE moneda WHEN '501' THEN trmdesembolso.valor ELSE 0 END AS [trmdesembolso],
        @trmcierre AS [trmcierre],
        @trmprom AS [trmprom],
        credito.capital AS [capital],
        credito_saldos.abonoscapital AS [abonoscapital],
        credito_saldos.interespago AS [interespago],
        credito_saldos.saldokinicial AS [saldokinicial],
        credito_saldos.saldokinicial - credito_saldos.abonoscapital  AS [saldokfinal],
        (credito_saldos.saldokinicial - credito_saldos.abonoscapital) * CASE moneda WHEN '501' THEN @trmcierre ELSE 1 END  AS [saldofinalcop],
		CASE moneda WHEN '501' THEN credito.capital - credito.saldoasignacion ELSE 0 END AS [cobertura]
    FROM 
        credito_saldos

        INNER JOIN credito
        ON credito_saldos.id = credito.id

        INNER JOIN valorcatalogo AS moneda
        ON credito.moneda = moneda.id

        INNER JOIN v_entfinanciera_tipo AS entfinanciera
        ON credito.entfinanciera = entfinanciera.id

		INNER JOIN regional AS regional
        ON credito.regional = regional.id
		
		INNER JOIN empresa AS empresa
		ON regional.nit = empresa.nit
        
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

        LEFT JOIN macroeconomicos AS trmdesembolso
        ON trmdesembolso.tipo = 'TRM'
        AND trmdesembolso.fecha = credito.fechadesembolso

        INNER JOIN usuario_regional
        ON usuario_regional.idregional = regional.id
        AND usuario_regional.nick = @nick

    WHERE
        credito_saldos.ano = @ano
        AND credito_saldos.periodo = @periodo
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_forward_saldos_actualizar') 
	DROP PROCEDURE [dbo].[sc_forward_saldos_actualizar]
GO

CREATE PROCEDURE sc_forward_saldos_actualizar
    @ano INT,
    @periodo INT,
    @id INT = NULL
AS
	DECLARE @anoanterior INT
	DECLARE @periodoanterior INT

    SELECT @periodoanterior = CASE @periodo WHEN 1 THEN 12 ELSE @periodo - 1 END
    SELECT @anoanterior = CASE @periodo WHEN 1 THEN @ano - 1  ELSE @ano END

    DECLARE @TEMP AS TABLE (
        idforward INT NOT NULL,
        idcredito INT NOT NULL,
        ano INT NOT NULL,
        periodo INT NOT NULL,
        pagos NUMERIC(18,2) NOT NULL,
        asignacion NUMERIC(18,2) NOT NULL,
        saldoinicial NUMERIC(18,2) NOT NULL,
        saldoasignacioni NUMERIC(18,2) NOT NULL
    )

    DELETE forward_saldos
    WHERE
        idforward = ISNULL(@id, idforward)
        AND ano = @ano
        AND periodo = @periodo

    /* Forwards del mes anterior */

    INSERT INTO @TEMP
        SELECT
            forward_saldos.idforward,
            forward_saldos.idcredito,
            @ano,
            @periodo,
            (
                SELECT 
                    ISNULL(SUM(detalleforward.valor),0) 
                FROM detalleforward 
                    INNER JOIN detallepago
                    ON detalleforward.seq = detallepago.seq
                WHERE 
                    detalleforward.ano = @ano 
                    AND detalleforward.periodo = @periodo 
                    AND detalleforward.idforward = forward_saldos.idforward
                    AND detallepago.idcredito = forward_saldos.idcredito
                    AND detallepago.formapago = 'FORWARD'
            ),
            (
                SELECT
                    ISNULL(SUM(valorasignado),0)
                FROM
                    creditoforward A
                WHERE
                    A.ano = @ano
                    AND A.periodo = @periodo
                    AND A.idforward = forward_saldos.idforward
            ),
            forward_saldos.saldoinicial - forward_saldos.pagos,
            forward_saldos.saldoasignacioni - forward_saldos.asignacion
        FROM
            forward_saldos
        WHERE
            ano = @anoanterior
            AND periodo = @periodoanterior
            AND forward_saldos.idforward = ISNULL(@id, forward_saldos.idforward)

    /* Forwards del mes */
    INSERT INTO @TEMP
        SELECT
            id,
            0,
            @ano,
            @periodo,
            0,
            (
                SELECT
                    ISNULL(SUM(valorasignado),0)
                FROM
                    creditoforward A
                WHERE
                    A.ano = @ano
                    AND A.periodo = @periodo
                    AND A.idforward = forward.id
            ),
            0,
            forward.valorusd
        FROM 
            forward
        WHERE
            forward.id = ISNULL(@id, forward.id)
            AND forward.ano = @ano
            AND forward.periodo = @periodo

    /* Forward Asociados en el mes*/

    INSERT INTO @TEMP
        SELECT
            creditoforward.idforward,
            creditoforward.idcredito,
            @ano,
            @periodo,
            (
                SELECT 
                    ISNULL(SUM(detalleforward.valor),0) 
                FROM detalleforward 
                    INNER JOIN detallepago
                    ON detalleforward.seq = detallepago.seq
                WHERE 
                    detalleforward.ano = @ano 
                    AND detalleforward.periodo = @periodo 
                    AND detalleforward.idforward = creditoforward.idforward
                    AND detallepago.idcredito = creditoforward.idcredito
                    AND detallepago.formapago = 'FORWARD'
            ),
            0,
            SUM(creditoforward.valorasignado),
            0
        FROM
            creditoforward
        WHERE
            creditoforward.idforward = ISNULL(@id, creditoforward.idforward)
            AND ano = @ano
            AND periodo = @periodo
        GROUP BY
            creditoforward.idforward,
            creditoforward.idcredito


    INSERT INTO forward_saldos
    SELECT * FROM @TEMP
    WHERE
        saldoasignacioni + saldoinicial <> 0
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_dc_forward') 
	DROP PROCEDURE [dbo].[sc_dc_forward]
GO

CREATE PROCEDURE sc_dc_forward
	@fecha DATE,
	@nick VARCHAR(50) = NULL,
    @nit VARCHAR(15) = NULL
AS
	DECLARE @regionales TABLE (regional VARCHAR(150))

    IF @nick IS NULL AND @nit IS NULL
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional
        END
    
    IF @nick IS NULL 
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional WHERE nit = @nit
        END
    IF @nit IS NULL
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional 
            INNER JOIN usuario_regional 
            ON regional.id = usuario_regional.idregional
            AND usuario_regional.nick = @nick
        END
    IF @nit IS NOT NULL AND @nick IS NOT NULL
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional 
            INNER JOIN usuario_regional 
            ON regional.id = usuario_regional.idregional
            AND usuario_regional.nick = @nick
			WHERE nit = @nit
        END
    
    DELETE dc_forward
    WHERE
        ano = YEAR(@fecha)
        AND periodo = MONTH(@fecha)
        AND regional in (SELECT regional FROM @regionales)

    INSERT INTO dc_forward
    SELECT DISTINCT
        YEAR(@fecha) AS [ano],
        MONTH(@fecha) AS [periodo],
        forward_saldos.idforward AS [idforward],
        forward_saldos.idcredito AS [idcredito],
		regional.nombre AS [regional],
		entfinanciera.descripcion AS [entfinanciera],
        lineacredito.tipo AS [lineacreadito],
		forward.valorusd AS [valorusd],
		forward.fechaoperacion AS [fechaoperacion],
		forward.fechacumplimiento AS [fechacumplimiento],
		forward.dias AS [dias],
		forward.tasaspot AS [tasaspot],
		forward.devaluacion AS [devaluacion],
		forward.tasaforward AS [tasaforward],
		forward.valorcop AS [valorcop],
		CAST(forward_saldos.saldoinicial - forward_saldos.pagos AS NUMERIC(18,2)) AS [saldoforward],
		CAST(forward.tasaforward * (forward_saldos.saldoinicial - forward_saldos.pagos) AS NUMERIC(18,2)) AS [saldoforwardcop],
		ISNULL(trm.valor, 0) AS [tasadeuda],
		credito.fechadesembolso AS [fechadesembolso],
		CAST(trm.valor - forward.tasaforward AS NUMERIC(18,2)) AS [diftasa],
		CAST((ISNULL(trm.valor, forward.tasaspot) - forward.tasaforward)*(forward_saldos.saldoinicial - forward_saldos.pagos) AS NUMERIC(18,2)) AS [totaldifcambio],
		CAST(((ISNULL(trm.valor, forward.tasaspot) - forward.tasaforward)*(forward_saldos.saldoinicial - forward_saldos.pagos)) / forward.dias AS NUMERIC(18,2)) AS [difxdia],
		DATEDIFF(DAY, forward.fechaoperacion, @fecha ) AS [diascausados],
		DATEDIFF(DAY, forward.fechaoperacion, @fecha ) * (((ISNULL(trm.valor, forward.tasaspot) - forward.tasaforward)*(forward_saldos.saldoinicial - forward_saldos.pagos)) / forward.dias) AS [difacumulada],
		CAST(((ISNULL(trm.valor, forward.tasaspot) - forward.tasaforward)*(forward_saldos.saldoinicial - forward_saldos.pagos)) - (DATEDIFF(DAY, forward.fechaoperacion, @fecha ) * (((ISNULL(trm.valor, forward.tasaspot) - forward.tasaforward)*(forward_saldos.saldoinicial - forward_saldos.pagos)) / forward.dias)) AS NUMERIC(18,2)) AS [difxcausar]
	FROM
		forward_saldos

		INNER JOIN forward
		ON forward_saldos.idforward = forward.id

		LEFT JOIN regional
		ON regional.id = forward.regional

		LEFT JOIN valorcatalogo AS	entfinanciera
		ON entfinanciera.id = forward.entfinanciera

		LEFT JOIN creditoforward
		ON forward_saldos.idforward = creditoforward.idforward

		LEFT JOIN credito
		ON creditoforward.idcredito = credito.id

        INNER JOIN v_lineacredito_tipo AS lineacredito
        ON credito.lineacredito = lineacredito.id

		LEFT JOIN macroeconomicos AS trm
		ON trm.ano = credito.ano
		AND trm.periodo = credito.periodo
		AND trm.fecha = credito.fechadesembolso
		AND trm.tipo = 'TRM'

	WHERE
		forward_saldos.ano = YEAR(@fecha)
		AND forward_saldos.periodo = MONTH(@fecha)
        AND forward_saldos.idcredito <> 0
		AND regional.nombre in (SELECT regional FROM @regionales)

    INSERT INTO dc_forward
	SELECT DISTINCT
        YEAR(@fecha) AS [ano],
        MONTH(@fecha) AS [periodo],
		forward_saldos.idforward AS [idforward],
        forward_saldos.idcredito AS [idcredito],
        regional.nombre AS [regional],
		entfinanciera.descripcion AS [entfinanciera],
        'GIRO FINANCIADO' AS [lineacreadito],
		forward.valorusd AS [valorusd],
		forward.fechaoperacion AS [fechaoperacion],
		forward.fechacumplimiento AS [fechacumplimiento],
		forward.dias AS [dias],
		forward.tasaspot AS [tasaspot],
		forward.devaluacion / 100 AS [devaluacion],
		forward.tasaforward AS [tasaforward],
		forward.valorcop AS [valorcop],
		CAST(forward_saldos.saldoasignacioni - forward_saldos.asignacion AS NUMERIC(18,2)) AS [saldoforward],
		CAST(forward.tasaforward * (forward_saldos.saldoasignacioni - forward_saldos.asignacion) AS NUMERIC(18,2)) AS [saldoforwardcop],
		CAST(0.00 AS NUMERIC(18,2)) AS [tasadeuda],
		NULL AS [fechadesembolso],
		CAST(forward.tasaspot - forward.tasaforward AS NUMERIC(18,2))  AS [diftasa],
		CAST((forward.tasaspot - forward.tasaforward) * (forward_saldos.saldoasignacioni - forward_saldos.asignacion) AS NUMERIC(18,2))  AS [totaldifcambio],
		CAST(((forward.tasaspot - forward.tasaforward) * (forward_saldos.saldoasignacioni - forward_saldos.asignacion)) / forward.dias AS NUMERIC(18,2))  AS [difxdia],
		DATEDIFF(DAY, forward.fechaoperacion, @fecha ) AS [diascausados],
		DATEDIFF(DAY, forward.fechaoperacion, @fecha ) * (((forward.tasaspot - forward.tasaforward) * (forward_saldos.saldoasignacioni - forward_saldos.asignacion)) / forward.dias) AS [difacumulada],
		CAST((( forward.tasaspot - forward.tasaforward) * (forward_saldos.saldoasignacioni - forward_saldos.asignacion))-(DATEDIFF(DAY, forward.fechaoperacion, @fecha ) * (((forward.tasaspot - forward.tasaforward)*(forward_saldos.saldoinicial - forward_saldos.pagos)) / forward.dias)) AS NUMERIC(18,2)) AS [difxcausar]
	FROM
		forward_saldos

		INNER JOIN forward
		ON forward_saldos.idforward = forward.id

		LEFT JOIN regional
		ON regional.id = forward.regional

		LEFT JOIN valorcatalogo AS	entfinanciera
		ON entfinanciera.id = forward.entfinanciera

		LEFT JOIN creditoforward
		ON forward_saldos.idforward = creditoforward.idforward

	WHERE
		forward_saldos.ano = YEAR(@fecha)
		AND forward_saldos.periodo = MONTH(@fecha)
        AND forward_saldos.idcredito = 0
		AND regional.nombre in (SELECT regional FROM @regionales)

    DELETE dc_forward
    WHERE
        saldoforward = 0
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_dc_credito') 
	DROP PROCEDURE [dbo].[sc_dc_credito]
GO

CREATE PROCEDURE sc_dc_credito
	@ano INT,
	@periodo INT,
	@nick VARCHAR(50) = NULL,
    @nit VARCHAR(15) = NULL
AS
    DECLARE @regionales TABLE (regional VARCHAR(150))

    IF @nick IS NULL AND @nit IS NULL
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional
        END
    
    IF @nick IS NULL 
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional WHERE nit = @nit
        END
    IF @nit IS NULL
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional 
            INNER JOIN usuario_regional 
            ON regional.id = usuario_regional.idregional
            AND usuario_regional.nick = @nick
        END
    IF @nit IS NOT NULL AND @nick IS NOT NULL
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional 
            INNER JOIN usuario_regional 
            ON regional.id = usuario_regional.idregional
            AND usuario_regional.nick = @nick
			WHERE nit = @nit
        END

    DELETE dc_credito
    WHERE
        ano = @ano
        AND periodo = @periodo
        AND regional in (SELECT regional FROM @regionales)
    
    INSERT INTO dc_credito
    SELECT
        @ano AS [ano],
        @periodo AS [periodo],
        credito_saldos.id AS [idcredito],
        empresa.razonsocial AS [razonsocial],
        regional.nombre AS [regional],
        credito.pagare AS [pagare],
        lineacreadito.descripcion AS [lineacredito],
        entfinanciera.descripcion AS [entfinanciera],
        credito.capital AS [capital],
        credito.fechadesembolso AS [fechadesembolso],
        credito.plazo AS [plazo],
        CAST(credito_saldos.saldokinicial - credito_saldos.abonoscapital AS numeric(18,2)) AS [saldo]
    FROM 
        credito_saldos

        INNER JOIN credito
        ON credito_saldos.id = credito.id

        INNER JOIN regional
        ON credito.regional = regional.id

        INNER JOIN empresa
        ON empresa.nit = regional.nit

        INNER JOIN valorcatalogo AS lineacreadito
        ON credito.lineacredito = lineacreadito.id

        INNER JOIN valorcatalogo AS entfinanciera
        ON credito.entfinanciera = entfinanciera.id

    WHERE
        credito_saldos.ano = @ano
        AND credito_saldos.periodo = @periodo
        AND moneda = 501
		AND regional.nombre in (SELECT regional FROM @regionales)        

    
    DELETE dc_credito
    WHERE
        saldo = 0
GO


IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_dc_resumen_credito') 
	DROP PROCEDURE [dbo].[sc_dc_resumen_credito]
GO

CREATE PROCEDURE sc_dc_resumen_credito
	@fecha DATE,
	@trmcierre NUMERIC(18,2),
	@nick VARCHAR(50) = NULL,
    @nit VARCHAR(15) = NULL
AS
	DECLARE @regionales TABLE (regional VARCHAR(150))

    IF @nick IS NULL AND @nit IS NULL
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional
        END
    
    IF @nick IS NULL 
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional WHERE nit = @nit
        END
    IF @nit IS NULL
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional 
            INNER JOIN usuario_regional 
            ON regional.id = usuario_regional.idregional
            AND usuario_regional.nick = @nick
        END
    IF @nit IS NOT NULL AND @nick IS NOT NULL
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional 
            INNER JOIN usuario_regional 
            ON regional.id = usuario_regional.idregional
            AND usuario_regional.nick = @nick
			WHERE nit = @nit
        END
	DELETE dc_resumen_credito
	WHERE
		ano = YEAR(@fecha)
		AND periodo = MONTH(@fecha)
        AND regional in (SELECT regional FROM @regionales)

	INSERT INTO dc_resumen_credito
	SELECT
		dc_credito.ano AS [ano],
		dc_credito.periodo AS [periodo],
		dc_credito.idcredito AS [idcredito],
		dc_credito.lineacredito AS [lineacredito],
		dc_credito.regional AS [regional],
		dc_credito.pagare AS [pagare],
		dc_credito.fechadesembolso AS [fechadesembolso],
		dc_credito.plazo * 30 AS [dias],
		trm.valor AS [trmdesmbolso],
		dc_credito.saldo AS [saldocredito],
		CAST(dc_credito.saldo * trm.valor AS numeric(18,2)) AS [saldocoptrmdesmbolso],
		(SELECT ISNULL(SUM(dc_forward.saldoforward),0)FROM dc_forward WHERE dc_credito.ano = dc_forward.ano AND dc_credito.periodo = dc_forward.periodo AND dc_forward.idcredito = dc_credito.idcredito) AS [saldoforward],
		dc_credito.saldo - (SELECT ISNULL(SUM(dc_forward.saldoforward),0)FROM dc_forward WHERE dc_credito.ano = dc_forward.ano AND dc_credito.periodo = dc_forward.periodo AND dc_forward.idcredito = dc_credito.idcredito) AS [deudanocubierta],
		(SELECT ISNULL(SUM(dc_forward.saldoforwardcop),0)FROM dc_forward WHERE dc_credito.ano = dc_forward.ano AND dc_credito.periodo = dc_forward.periodo AND dc_forward.idcredito = dc_credito.idcredito) AS [saldoforwardcop],
		CAST(0 AS NUMERIC(18,2)) AS [tasafwdprom],
		CAST(0 AS NUMERIC(18,2)) AS [diftasa],
		CAST(0 AS NUMERIC(18,2)) AS [difcambiodeudacubierta],
		CAST(0 AS NUMERIC(18,2)) AS [difcambiodeudanocubierta],
		CAST(0 AS NUMERIC(18,2)) AS [difcambiodeudanocubiertaacum],
		CAST(0 AS NUMERIC(18,2)) AS [totaldifcambio],
		CAST(0 AS NUMERIC(18,2)) AS [difcambioxdia],
		CAST(0 AS NUMERIC(18,2)) AS [diasalcierre],
		CAST(0 AS NUMERIC(18,2)) AS [difcambioacum]
	FROM
		dc_credito

		LEFT JOIN macroeconomicos AS trm
		ON fechadesembolso = trm.fecha
		AND tipo = 'TRM'

	WHERE
		dc_credito.ano = YEAR(@fecha)
		AND dc_credito.periodo = MONTH(@fecha)
		AND dc_credito.regional IN (SELECT regional FROM @regionales)

	
	UPDATE dc_resumen_credito SET
		tasafwdprom = CASE saldoforward WHEN 0 THEN 0 ELSE CAST(saldoforwardcop / saldoforward AS NUMERIC(18,2)) END

	UPDATE dc_resumen_credito SET
		diftasa = CASE saldoforward WHEN 0 THEN 0 ELSE CAST(trmdesmbolso - tasafwdprom AS NUMERIC(18,2)) END

	UPDATE dc_resumen_credito SET
		difcambiodeudacubierta = CAST(saldoforward * diftasa AS NUMERIC(18,2)),
		difcambiodeudanocubierta = CAST((trmdesmbolso - @trmcierre) * deudanocubierta AS numeric(18,2)),
		diasalcierre = DATEDIFF(DAY, fechadesembolso, @fecha)

	UPDATE dc_resumen_credito SET
		difcambiodeudanocubiertaacum = CAST((diasalcierre/dias) * difcambiodeudanocubierta AS numeric(18,2))

	UPDATE dc_resumen_credito SET
		totaldifcambio = CAST(difcambiodeudacubierta + difcambiodeudanocubierta AS numeric(18,2))

	UPDATE dc_resumen_credito SET
		difcambioxdia = CAST(totaldifcambio / dias AS numeric(18,2))

	UPDATE dc_resumen_credito SET
		difcambioacum = IIF(diasalcierre > dias, totaldifcambio, CAST(diasalcierre * difcambioxdia AS NUMERIC(18,2)))
GO


IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_dc_consolidado') 
	DROP PROCEDURE [dbo].[sc_dc_consolidado]
GO

CREATE PROCEDURE sc_dc_consolidado
	@fecha DATE,
	@nick VARCHAR(50) = NULL,
    @nit VARCHAR(15) = NULL
AS
	DECLARE @trmcierre NUMERIC(18,2)
	DECLARE @ano INT
	DECLARE @periodo INT
	DECLARE @anoanterior INT
	DECLARE @periodoanterior INT
	DECLARE @regionales TABLE (regional VARCHAR(150))

	SET @ano = YEAR(@fecha)
	SET @periodo = MONTH(@fecha)
    SET @periodoanterior = (CASE @periodo WHEN 1 THEN 12 ELSE @periodo - 1 END)
    SET @anoanterior = (CASE @periodo WHEN 1 THEN @ano - 1  ELSE @ano END)
	
	IF @nick IS NULL AND @nit IS NULL
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional
        END
    IF @nick IS NULL 
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional WHERE nit = @nit
        END
    IF @nit IS NULL
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional 
            INNER JOIN usuario_regional 
            ON regional.id = usuario_regional.idregional
            AND usuario_regional.nick = @nick
        END
    IF @nit IS NOT NULL AND @nick IS NOT NULL
        BEGIN
            INSERT INTO @regionales
            SELECT nombre FROM regional 
            INNER JOIN usuario_regional 
            ON regional.id = usuario_regional.idregional
            AND usuario_regional.nick = @nick
			WHERE nit = @nit
        END
        
	SELECT 
		@trmcierre = valor, 
		@ano = ano, 
		@periodo = periodo 
	FROM 
		macroeconomicos 
	WHERE 
		tipo = 'TRM' 
		AND fecha = @fecha;
	
	EXEC sc_dc_credito @ano, @periodo, @nick, @nit;
	EXEC sc_dc_forward @fecha, @nick, @nit;
	EXEC sc_dc_resumen_credito @fecha, @trmcierre, @nick, @nit;

	SELECT DISTINCT * INTO #TEMP FROM (
		SELECT DISTINCT ano, periodo, regional, lineacredito FROM dc_credito WHERE ano = @ano AND periodo = @periodo
		UNION ALL
		SELECT DISTINCT ano, periodo, regional, lineacredito FROM dc_forward WHERE ano = @ano AND periodo = @periodo
	) AS TMP

	DELETE dc_consolidado
	WHERE
		ano = @ano
		AND periodo = @periodo
		AND regional IN (SELECT regional FROM @regionales)

	INSERT INTO dc_consolidado
	SELECT DISTINCT
		ano,
		periodo,
		regional,
		lineacredito,
		(SELECT ISNULL(SUM(dc_credito.saldo), 0) FROM dc_credito WHERE #TEMP.ano = dc_credito.ano AND #TEMP.periodo = dc_credito.periodo AND #TEMP.regional = dc_credito.regional AND #TEMP.lineacredito = dc_credito.lineacredito) AS [deudausd],
		(SELECT ISNULL(SUM(dc_resumen_credito.deudanocubierta), 0) FROM dc_resumen_credito WHERE #TEMP.ano = dc_resumen_credito.ano AND #TEMP.periodo = dc_resumen_credito.periodo AND #TEMP.regional = dc_resumen_credito.regional AND #TEMP.lineacredito = dc_resumen_credito.lineacredito) AS [deudanocubierta],
		(SELECT ISNULL(SUM(dc_resumen_credito.difcambiodeudanocubierta), 0) FROM dc_resumen_credito WHERE #TEMP.ano = dc_resumen_credito.ano AND #TEMP.periodo = dc_resumen_credito.periodo AND #TEMP.regional = dc_resumen_credito.regional AND #TEMP.lineacredito = dc_resumen_credito.lineacredito) AS [difcambiodeudanocubierta],
		CAST(0 AS numeric(18,2)) AS [difcambiomesanterior],
		CAST(0 AS numeric(18,2)) AS [difcambiomesactual],
		CAST((SELECT ISNULL(SUM(dc_forward.saldoforward),0) FROM dc_forward WHERE #TEMP.ano = dc_forward.ano AND #TEMP.periodo = dc_forward.periodo AND #TEMP.regional = dc_forward.regional AND #TEMP.lineacredito = dc_forward.lineacredito) AS NUMERIC(18,2)) AS [forward],
		CAST((SELECT ISNULL(SUM(dc_forward.totaldifcambio),0) FROM dc_forward WHERE #TEMP.ano = dc_forward.ano AND #TEMP.periodo = dc_forward.periodo AND #TEMP.regional = dc_forward.regional AND #TEMP.lineacredito = dc_forward.lineacredito) AS NUMERIC(18,2)) AS [dicambiototalfwd],
		CAST((SELECT ISNULL(SUM(dc_forward.difacumulada),0) FROM dc_forward WHERE #TEMP.ano = dc_forward.ano AND #TEMP.periodo = dc_forward.periodo AND #TEMP.regional = dc_forward.regional AND #TEMP.lineacredito = dc_forward.lineacredito) AS NUMERIC(18,2)) AS [dicambiototalacumfwd],
		CAST(0 AS numeric(18,2)) AS [difcambiomesanteriorfw],
		CAST(0 AS numeric(18,2)) AS [difcambiomesactualfw],
		CAST(0 AS numeric(18,2)) AS [difcambiototalacum],
		CAST(0 AS numeric(18,2)) AS [difcambiototalacummesanterior],
		CAST(0 AS numeric(18,2)) AS [difcambiototalacummesactual]
	FROM
		#TEMP
	WHERE
        regional IN (SELECT regional FROM @regionales)
	
	UPDATE A SET
		difcambiomesanterior = ISNULL(B.difcambiodeudanocubierta, 0),
		difcambiomesanteriorfw = ISNULL(B.dicambiototalacumfwd, 0)
	FROM
		dc_consolidado A

		LEFT JOIN dc_consolidado B
		ON A.regional = B.regional
		AND A.lineacredito = B.lineacredito
		AND B.ano = @anoanterior
		AND B.periodo = @periodoanterior

	WHERE
		A.ano = @ano
		AND A.periodo = @periodo

	UPDATE dc_consolidado SET
		difcambiomesactual = difcambiodeudanocubierta - difcambiomesanterior,
		difcambiomesactualfw = dicambiototalacumfwd - difcambiomesanteriorfw
	WHERE
		ano = @ano
		AND periodo = @periodo

	UPDATE dc_consolidado SET
		difcambiototalacum = difcambiodeudanocubierta + dicambiototalacumfwd,
		difcambiototalacummesanterior = difcambiomesanterior + difcambiomesanteriorfw
	WHERE
		ano = @ano
		AND periodo = @periodo

	UPDATE dc_consolidado SET
		difcambiototalacummesactual = difcambiototalacum - difcambiototalacummesanterior
	WHERE
		ano = @ano
		AND periodo = @periodo
GO


IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_calendario_actualizar') 
	DROP PROCEDURE [dbo].[sc_calendario_actualizar]
GO

CREATE PROCEDURE sc_calendario_actualizar
    @ano INT,
    @periodo INT,
    @proceso BIT,
    @registro BIT
AS
    UPDATE calendario_cierre SET
        proceso = @proceso,
        registro = @registro
    WHERE
        ano = @ano
        AND periodo = @periodo
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_calendario_obtener') 
	DROP PROCEDURE [dbo].[sc_calendario_obtener]
GO

CREATE PROCEDURE sc_calendario_obtener
    @ano INT,
    @periodo INT
AS
    SELECT
        *
    FROM
        calendario_cierre
    WHERE
        ano = @ano
        AND periodo = @periodo
    FOR JSON PATH
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_calendario_obtenerActivos') 
	DROP PROCEDURE [dbo].[sc_calendario_obtenerActivos]
GO

CREATE PROCEDURE sc_calendario_obtenerActivos
    @trx VARCHAR(10)
AS
    IF @trx = 'proceso'
        BEGIN
            SELECT
                *
            FROM 
                calendario_cierre
            WHERE
                proceso = 1
            FOR JSON PATH
        END

    IF @trx = 'registro'
        BEGIN
            SELECT
                *
            FROM 
                calendario_cierre
            WHERE
                registro = 1
            FOR JSON PATH
        END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_dc_obtener') 
	DROP PROCEDURE [dbo].[sc_dc_obtener]
GO

CREATE PROCEDURE sc_dc_obtener
    @ano INT,
    @periodo INT,
    @nick VARCHAR(50) = NULL,
    @nit VARCHAR(50) = NULL
AS
    DECLARE @regionales TABLE (regional VARCHAR(150));
    
    INSERT INTO @regionales
    SELECT nombre FROM regional 
    INNER JOIN usuario_regional 
    ON regional.id = usuario_regional.idregional
    AND usuario_regional.nick = ISNULL(@nick, usuario_regional.nick)
    WHERE regional.nit = ISNULL(@nit, regional.nit)
    SELECT
        (
            SELECT
                *
            FROM
                dc_forward
            WHERE
                dc_forward.ano = @ano
                AND dc_forward.periodo = @periodo
                AND dc_forward.regional IN (SELECT regional FROM @regionales)
            FOR JSON PATH
        ) AS [dc_forward],
        (
            SELECT
                *
            FROM
                dc_credito
            WHERE
                dc_credito.ano = @ano
                AND dc_credito.periodo = @periodo
                AND dc_credito.regional IN (SELECT regional FROM @regionales)
            FOR JSON PATH
        ) AS [dc_credito],
        (
            SELECT
                *
            FROM
                dc_resumen_credito
            WHERE
                dc_resumen_credito.ano = @ano
                AND dc_resumen_credito.periodo = @periodo
                AND dc_resumen_credito.regional IN (SELECT regional FROM @regionales)
            FOR JSON PATH
        ) AS [dc_resumen_credito],
        (
            SELECT
                *
            FROM
                dc_consolidado
            WHERE
                dc_consolidado.ano = @ano
                AND dc_consolidado.periodo = @periodo
                AND dc_consolidado.regional IN (SELECT regional FROM @regionales)
            FOR JSON PATH
        ) AS [dc_consolidado]
    FOR JSON PATH
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_deuda_consolidado') 
	DROP PROCEDURE [dbo].[sc_deuda_consolidado]
GO

CREATE OR ALTER PROCEDURE sc_deuda_consolidado
	@fecha DATE
AS
	DECLARE @ano INT
	DECLARE @periodo INT
	DECLARE @trmcierre NUMERIC(18,2)

	SELECT 
		@trmcierre = valor, 
		@ano = ano, 
		@periodo = periodo 
	FROM 
		macroeconomicos 
	WHERE 
		tipo = 'TRM' 
		AND fecha = @fecha;

	DELETE deuda_consolidado
	WHERE
		ano = @ano
		AND periodo = @periodo

	INSERT INTO deuda_consolidado
	SELECT 
		credito_saldos.ano AS [ano],
		credito_saldos.periodo AS [periodo],
		UPPER(calendario_cierre.mes) AS [mes],
		empresa.razonsocial AS [empresa],
		v_entfinanciera.descripcion AS [entfinanciera],
		v_lineacredito_tipo.descripcion AS [lineacredito],
		moneda.descripcion AS [moneda],
		SUM (credito_saldos.saldokinicial - credito_saldos.abonoscapital) AS [saldomonedaoriginal],
		CASE credito.moneda
			WHEN '500' THEN SUM (credito_saldos.saldokinicial - credito_saldos.abonoscapital)
			WHEN '501' THEN SUM (credito_saldos.saldokinicial - credito_saldos.abonoscapital) * @trmcierre
		END AS [saldocop],
		0 AS [tasapromedio],
		0 AS [devaluacionpromedio],
		CASE credito.moneda
			WHEN '500' THEN 0
			WHEN '501' THEN @trmcierre
		END AS [trmcierre]
	FROM 
		credito_saldos

		INNER JOIN calendario_cierre
		ON credito_saldos.ano = calendario_cierre.ano
		AND credito_saldos.periodo = calendario_cierre.periodo

		INNER JOIN credito
		ON credito_saldos.id = credito.id

		INNER JOIN regional
		ON credito.regional = regional.id

		INNER JOIN empresa 
		ON regional.nit = empresa.nit

		INNER JOIN v_entfinanciera
		ON credito.entfinanciera = v_entfinanciera.id

		INNER JOIN v_lineacredito_tipo
		ON credito.lineacredito = v_lineacredito_tipo.id

		INNER JOIN valorcatalogo AS moneda
		ON credito.moneda = moneda.id

	WHERE
		credito_saldos.ano = @ano
		AND credito_saldos.periodo = @periodo
	GROUP BY
		credito_saldos.ano,
		calendario_cierre.mes,
		empresa.razonsocial,
		v_entfinanciera.descripcion,
		v_lineacredito_tipo.descripcion,
		moneda.descripcion,
		credito.moneda,
		credito_saldos.tasapromedio,
		credito_saldos.periodo
	ORDER BY
		credito_saldos.periodo ASC
GO


IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_deuda_consolidado_obtener') 
	DROP PROCEDURE [dbo].[sc_deuda_consolidado_obtener]
GO

CREATE PROCEDURE sc_deuda_consolidado_obtener
    @ano INT,
    @periodo INT = NULL
AS
    SELECT
        *
    FROM
        deuda_consolidado
    WHERE
        ano = @ano
        AND periodo = ISNULL(@periodo, periodo)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_calendariocierre_ano') 
	DROP PROCEDURE [dbo].[sc_calendariocierre_ano]
GO

CREATE PROCEDURE sc_calendariocierre_ano
    @ano INT
AS
    SELECT
        *
    FROM
        calendario_cierre
    WHERE
        ano = @ano
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_credito_actualizarestado') 
	DROP PROCEDURE [dbo].[sc_credito_actualizarestado]
GO

CREATE PROCEDURE sc_credito_actualizarestado
    @id INT,
    @estado VARCHAR(20)
AS
    UPDATE credito
    SET estado = @estado
    WHERE id = @id
GO

-- UPDATE CALENDARIO_CIERRE SET PROCESO = 0 WHERE ANO = 2022 AND PERIODO = 8

-- SELECT * FROM dc_consolidado

-- EXEC sc_dc_obtener '2022', '8', 'ADMIN'

-- EXEC sc_dc_consolidado '2022-08-31', NULL, NULL;

-- DELETE dc_forward WHERE periodo = 8
-- DELETE dc_credito WHERE periodo = 8
-- DELETE dc_resumen_credito WHERE periodo = 8
-- DELETE dc_consolidado WHERE periodo = 8

-- SELECT * FROM dc_forward WHERE periodo = 8
-- SELECT * FROM dc_credito WHERE periodo = 8
-- SELECT * FROM dc_resumen_credito WHERE periodo = 8
-- SELECT * FROM dc_consolidado WHERE periodo = 8


--delete dc_consolidado where ano = 2022 and periodo = 9