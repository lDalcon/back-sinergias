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

