CREATE OR ALTER PROCEDURE sc_dc_get_forward_asociados
    @fecha DATE,
    @nick VARCHAR(50) = NULL,
    @nit VARCHAR(15) = NULL
AS
DECLARE @regionales TABLE (regional VARCHAR(150))

IF @nick IS NULL AND @nit IS NULL
            BEGIN
    INSERT INTO @regionales
    SELECT nombre
    FROM regional
END

IF @nick IS NULL 
            BEGIN
    INSERT INTO @regionales
    SELECT nombre
    FROM regional
    WHERE nit = @nit
END
IF @nit IS NULL
            BEGIN
    INSERT INTO @regionales
    SELECT nombre
    FROM regional
        INNER JOIN usuario_regional
        ON regional.id = usuario_regional.idregional
            AND usuario_regional.nick = @nick
END
IF @nit IS NOT NULL AND @nick IS NOT NULL
            BEGIN
    INSERT INTO @regionales
    SELECT nombre
    FROM regional
        INNER JOIN usuario_regional
        ON regional.id = usuario_regional.idregional
            AND usuario_regional.nick = @nick
    WHERE nit = @nit
END

DELETE dc_forward
        WHERE
            ano = YEAR(@fecha)
    AND periodo = MONTH(@fecha)
    AND regional in (SELECT regional
    FROM @regionales)

SELECT DISTINCT
    YEAR(@fecha) AS [ano],
    MONTH(@fecha) AS [periodo],
    forward_saldos.idforward AS [idforward],
    forward_saldos.idcredito AS [idcredito],
    regional.nombre AS [regional],
    entfinanciera.descripcion AS [entfinanciera],
    lineacredito.tipo AS [lineacreadito],
    forward.valorusd AS [valorusd],
    CONVERT( VARCHAR(10) ,forward.fechaoperacion, 112) AS [fechaoperacion],
    CONVERT( VARCHAR(10) ,forward.fechacumplimiento, 112) AS [fechacumplimiento],
    forward.dias AS [dias],
    forward.tasaspot AS [tasaspot],
    forward.devaluacion AS [devaluacion],
    forward.tasaforward AS [tasaforward],
    forward.valorcop AS [valorcop],
    CAST(forward_saldos.saldofinal AS NUMERIC(18,2)) AS [saldoforward],
    0 AS [saldoforwardcop],
    ISNULL(trm.valor, 0) AS [tasadeuda],
    CONVERT( VARCHAR(10) ,credito.fechadesembolso, 112) AS [fechadesembolso],
    trm.valor as [trmdesembolso],
    0 AS [diftasa],
    0 AS [totaldifcambio],
    0 AS [difxdia],
    0 AS [diascausados],
    0 AS [difacumulada],
    0 AS [difxcausar],
    0 AS [devaluacioncr]
FROM
    forward_saldos

    INNER JOIN forward
    ON forward_saldos.idforward = forward.id

    LEFT JOIN regional
    ON regional.id = forward.regional

    LEFT JOIN valorcatalogo AS	entfinanciera
    ON entfinanciera.id = forward.entfinanciera

    LEFT JOIN credito
    ON forward_saldos.idcredito = credito.id

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
    AND credito.lineacredito != 641 -- Linea especial
    AND regional.nombre in (SELECT regional
    FROM @regionales)
GO

/*==========================================================================================================================*/

CREATE OR ALTER PROCEDURE sc_dc_get_forward_sin_asociar
    @fecha DATE,
    @nick VARCHAR(50) = NULL,
    @nit VARCHAR(15) = NULL
AS
DECLARE @regionales TABLE (regional VARCHAR(150))

IF @nick IS NULL AND @nit IS NULL
            BEGIN
    INSERT INTO @regionales
    SELECT nombre
    FROM regional
END

IF @nick IS NULL 
            BEGIN
    INSERT INTO @regionales
    SELECT nombre
    FROM regional
    WHERE nit = @nit
END
IF @nit IS NULL
            BEGIN
    INSERT INTO @regionales
    SELECT nombre
    FROM regional
        INNER JOIN usuario_regional
        ON regional.id = usuario_regional.idregional
            AND usuario_regional.nick = @nick
END
IF @nit IS NOT NULL AND @nick IS NOT NULL
            BEGIN
    INSERT INTO @regionales
    SELECT nombre
    FROM regional
        INNER JOIN usuario_regional
        ON regional.id = usuario_regional.idregional
            AND usuario_regional.nick = @nick
    WHERE nit = @nit
END

DELETE dc_forward
        WHERE
            ano = YEAR(@fecha)
    AND periodo = MONTH(@fecha)
    AND regional in (SELECT regional
    FROM @regionales)

SELECT DISTINCT
    YEAR(@fecha) AS [ano],
    MONTH(@fecha) AS [periodo],
    forward_saldos.idforward AS [idforward],
    forward_saldos.idcredito AS [idcredito],
    regional.nombre AS [regional],
    entfinanciera.descripcion AS [entfinanciera],
    'GIRO FINANCIADO' AS [lineacreadito],
    forward.valorusd AS [valorusd],
    CONVERT(VARCHAR(10), forward.fechaoperacion, 112) AS [fechaoperacion],
    CONVERT(VARCHAR(10), forward.fechacumplimiento, 112) AS [fechacumplimiento],
    forward.dias AS [dias],
    forward.tasaspot AS [tasaspot],
    forward.devaluacion / 100 AS [devaluacion],
    forward.tasaforward AS [tasaforward],
    forward.valorcop AS [valorcop],
    CAST(forward_saldos.saldofinal AS NUMERIC(18,2)) AS [saldoforward],
    CAST(forward.tasaforward * (forward_saldos.saldofinal) AS NUMERIC(18,2)) AS [saldoforwardcop],
    CAST(0.00 AS NUMERIC(18,2)) AS [tasadeuda],
    NULL AS [fechadesembolso],
    0 as [trmdesembolso],
    0 AS [diftasa],
    0 AS [totaldifcambio],
    0 AS [difxdia],
    0 AS [diascausados],
    0 AS [difacumulada],
    0 AS [difxcausar],
    0 AS [devaluacioncr]
FROM
    forward_saldos

    INNER JOIN forward
    ON forward_saldos.idforward = forward.id

    LEFT JOIN regional
    ON regional.id = forward.regional

    LEFT JOIN valorcatalogo AS	entfinanciera
    ON entfinanciera.id = forward.entfinanciera

WHERE
		forward_saldos.ano = YEAR(@fecha)
    AND forward_saldos.periodo = MONTH(@fecha)
    AND forward_saldos.idcredito = 0
    AND regional.nombre in (SELECT regional
    FROM @regionales)

GO