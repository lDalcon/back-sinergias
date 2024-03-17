ALTER TABLE credito
ADD aval1 VARCHAR(150) DEFAULT '' NOT NULL

ALTER TABLE credito
ADD aval2 VARCHAR(150) DEFAULT '' NOT NULL

ALTER TABLE credito
ADD aval3 VARCHAR(150) DEFAULT '' NOT NULL

GO;

ALTER PROCEDURE [dbo].[sc_credito_guardar]
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
    @observaciones NVARCHAR(MAX),
    @idsolicitud INT = -1,
    @aval1 VARCHAR(150) = '',
    @aval2 VARCHAR(150) = '',
    @aval3 VARCHAR(150) = ''
AS
   DECLARE @id INT;
   DECLARE @ano INT = YEAR(@fechadesembolso);
   DECLARE @periodo INT = MONTH(@fechadesembolso);

   EXEC sc_obtenerconsecutivo 'OBLIGACION', @id OUTPUT;

   INSERT INTO credito VALUES
   (
        @id,
        @ano,
        @periodo,
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
        @observaciones,
        @idsolicitud,
        @aval1,
        @aval2,
        @aval3
   )

   EXEC sc_credito_saldos_actualizar @ano, @periodo, @id

   IF @idsolicitud != -1
        UPDATE solicitud SET desembolso = (SELECT ISNULL(SUM(capital), 0) FROM credito WHERE credito.idsolicitud = solicitud.id AND credito.estado != 'ANULADO')
        WHERE solicitud.id = @idsolicitud
GO

ALTER PROCEDURE [dbo].[sc_credito_actualizar]
    @id INT,
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
    @usuariomod VARCHAR(50),
	@tasafija NUMERIC(8,6),
	@periodogracia INT,
    @amortizacion VARCHAR(MAX),
    @observaciones NVARCHAR(MAX),
    @aval1 VARCHAR(150) = '',
    @aval2 VARCHAR(150) = '',
    @aval3 VARCHAR(150) = ''
AS
    DECLARE @ano INT = YEAR(@fechadesembolso);
    DECLARE @periodo INT = MONTH(@fechadesembolso);
    
    UPDATE credito SET
        fechadesembolso = @fechadesembolso,
        moneda = @moneda,
        entfinanciera = @entfinanciera,
        regional = @regional,
        lineacredito = @lineacredito,
        pagare = @pagare,
        tipogarantia = @tipogarantia,
        capital = @capital,
        plazo = @plazo,
        indexado = @indexado,
        spread = @spread,
        tipointeres = @tipointeres,
        amortizacionk = @amortizacionk,
        amortizacionint = @amortizacionint,
        usuariomod = @usuariomod,
        fechamod = GETDATE(),
        tasafija = @tasafija,
        periodogracia = @periodogracia,
        amortizacion = @amortizacion,
        observaciones = @observaciones,
        aval1 = @aval1,
        aval2 = @aval2,
        aval3 = @aval3
    WHERE
        id = @id
	EXEC sc_actualizar_saldos -1, @id
    EXEC sc_credito_saldos_actualizar @ano, @periodo, @id
GO


CREATE PROCEDURE sc_empresa_listar
AS
    SELECT
        nit as nit,
        razonsocial as razonsocial,
        cluster as cluster,
        config as config
    FROM
        empresa
    ORDER BY razonsocial ASC
GO

ALTER   PROCEDURE [dbo].[sc_reporte_consolidado]
	@ano INT,
	@periodo INT,
    @nick VARCHAR(50)
AS
	DECLARE @trmprom NUMERIC(18,2)
	DECLARE @trmcierre NUMERIC(18,2)

	SELECT @trmcierre = CAST((SELECT valor FROM macroeconomicos WHERE tipo = 'TRM' AND fecha = (SELECT MAX(FECHA) FROM macroeconomicos WHERE ano = @ano AND periodo = @periodo AND  tipo = 'TRM')) AS NUMERIC(18,2))
	SELECT @trmprom = CAST((SELECT AVG(valor) FROM macroeconomicos WHERE tipo = 'TRM' AND ano = @ano AND periodo = @periodo) AS NUMERIC(18,2))
	
    SELECT 
        credito_saldos.ano AS [ano],
        credito_saldos.periodo AS [periodo],
		empresa.razonsocial AS [razonsocial],
		empresa.cluster AS [cluster],
        regional.nombre AS [regional],
        credito_saldos.id AS [idcredito],
        CONVERT(VARCHAR(10), credito.fechadesembolso, 103) AS [fechadesembolso],
		credito.plazo AS [plazo],
        moneda.descripcion AS [moneda],
        lineacredito.descripcion AS [lineacredito],
        tipogarantia.descripcion AS [tipogarantia],
        credito.aval1 AS [aval1],
        credito.aval2 AS [aval2],
        credito.aval3 AS [aval3],
        entfinanciera.descripcion AS [entfinanciera],
		entfinanciera.tipo AS [tipo],
        amortizacionint.descripcion AS [amortizacionint],
        amortizacionk.descripcion AS [amortizacionk],
        indexado.descripcion AS [indexado],
        tasaInicial.spreadEA AS [spread],
        tasaInicial.tasaIdxEA AS [tasa],
        tasaInicial.tasaEA AS [tasaEA],
		tasaPer.tasaIdxEA AS [tasaPer],
        tasaPer.tasaEA AS [tasaEAPer],
		trmdesembolso.valor AS [trmdesembolso],
        @trmcierre AS [trmcierre],
        @trmprom AS [trmprom],
        credito.capital AS [capital],
        credito_saldos.abonoscapital AS [abonoscapital],
        credito_saldos.interespago AS [interespago],
        credito_saldos.saldokinicial AS [saldokinicial],
        credito_saldos.saldokinicial - credito_saldos.abonoscapital  AS [saldokfinal],
        (credito_saldos.saldokinicial - credito_saldos.abonoscapital) * CASE moneda WHEN '501' THEN @trmcierre ELSE 1 END  AS [saldofinalcop],
		--CASE moneda WHEN '501' THEN credito.capital - credito.saldoasignacion ELSE 0 END AS [cobertura],
		CASE moneda 
			WHEN '501' THEN ISNULL((SELECT SUM(saldofinal) FROM forward_saldos WHERE forward_saldos.ano = credito_saldos.ano and forward_saldos.periodo = credito_saldos.periodo and forward_saldos.idcredito = credito_saldos.id), 0)
			ELSE 0 END 
		AS [cobertura],
		(
			SELECT 
				SUM(devaluacioncr * saldoforward) / SUM(saldoforward)
			FROM 
				dc_forward
			WHERE
				dc_forward.ano = credito_saldos.ano
				AND dc_forward.periodo = credito_saldos.periodo
				AND dc_forward.idcredito = credito_saldos.id
		) as [devaluacioncr]

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

		LEFT JOIN v_credito_tasa tasaInicial
		ON tasaInicial.id = credito_saldos.id
		AND tasaInicial.nper = 0

		LEFT JOIN v_credito_tasa tasaPer
		ON tasaPer.ano = credito_saldos.ano
		AND tasaPer.periodo = credito_saldos.periodo
		AND tasaPer.id = credito_saldos.id
		AND tasaPer.nper = (SELECT MAX(nper) FROM v_credito_tasa A WHERE A.ano = tasaPer.ano AND A.periodo = tasaPer.periodo AND A.id = tasaPer.id)
	
    WHERE
        credito_saldos.ano = @ano
        AND credito_saldos.periodo = @periodo
GO


