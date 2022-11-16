USE SINERGIAS_DB
GO

CREATE OR ALTER VIEW v_entfinanciera_tipo
AS
    SELECT 
        id,
        ctgid,
        descripcion,
		tipo
    FROM 
        valorcatalogo

        CROSS APPLY OPENJSON(config)
        WITH (tipo VARCHAR(50) '$.tipo')
    WHERE 
        ctgid = 'ENTFIN'
GO


CREATE OR ALTER VIEW v_lineacredito_tipo
AS
    SELECT 
        id,
        ctgid,
        descripcion,
		tipo
    FROM 
        valorcatalogo

        CROSS APPLY OPENJSON(config)
        WITH (tipo VARCHAR(50) '$.tipo')
    WHERE 
        ctgid = 'LINCRE'
GO

CREATE OR ALTER VIEW v_credito_tasa
AS
    SELECT 
        id,
        YEAR(fechaPeriodo) AS [ano],
        MONTH(fechaPeriodo) AS [periodo],
        fechaPeriodo,
        tasaEA
    FROM 
        credito
        CROSS APPLY OPENJSON(amortizacion,'$.amortizacion')
        WITH (
            nper INT '$.nper',
            tasaEA NUMERIC(8,5) '$.tasaEA',
            fechaPeriodo DATE '$.fechaPeriodo'
        )
GO



