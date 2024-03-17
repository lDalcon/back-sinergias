DECLARE @ano INT = 2024
DECLARE @periodo INT = 2
DECLARE @fechainicial DATE = DATEFROMPARTS(@ano, @periodo, 1)
DECLARE @fechafinal DATE = eomonth(@fechainicial)
DECLARE @fechadia DATE = @fechainicial

DELETE credito_saldos WHERE ANO = @ano AND periodo = @periodo AND saldokinicial = 0 AND abonoscapital = 0 AND interespago = 0


DECLARE @resumencredito TABLE(
    idcredito int,
    nit varchar(50),
    empresa varchar(100),
    regional varchar(100),
    saldoinicial numeric(18, 2),
    moneda varchar(50),
    fechadesembolso DATE,
    trmdesembolso numeric(18, 2),
    tipodeuda varchar(50)
)

DECLARE @detallesaldos TABLE(
    idcredito int,
    fecha DATE,
    saldoinicial numeric(18, 2),
    movimientos numeric(18, 2),
    saldofinal numeric(18, 2)
)

INSERT INTO @resumencredito
SELECT
    credito.id,
    empresa.nit,
    empresa.razonsocial,
    regional.nombre,
    saldokinicial,
    moneda.descripcion,
    credito.fechadesembolso,
    0,
    v_entfinanciera_tipo.tipo
FROM 
    credito_saldos

    LEFT JOIN credito
    ON credito_saldos.id = credito.id

    LEFT JOIN regional
    ON credito.regional = regional.id

    LEFT JOIN empresa
    ON empresa.nit = regional.nit
    
    LEFT JOIN v_entfinanciera_tipo
    ON credito.entfinanciera = v_entfinanciera_tipo.id

    LEFT JOIN valorcatalogo moneda
    ON credito.moneda = moneda.id

WHERE
    credito_saldos.ano = @ano
    AND credito_saldos.periodo = @periodo

UPDATE @resumencredito SET
    trmdesembolso = isnull((SELECT valor FROM macroeconomicos where macroeconomicos.fecha = fechadesembolso and macroeconomicos.tipo = 'TRM'), -1)
WHERE
    moneda = 'DOLAR (USD)'

-- Cursor para recorrer cada uno de los créditos

DECLARE @idcredito INT;
DECLARE @saldoinicial numeric(18,2);

DECLARE cursorcredito CURSOR FOR
SELECT idcredito, saldoinicial
FROM @resumencredito;

-- Abrir el cursor
OPEN cursorcredito;

-- Iniciar el recorrido
FETCH NEXT FROM cursorcredito INTO @idcredito, @saldoinicial;

-- Iniciar un bucle para recorrer los registros
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @fechadia = @fechainicial
    DECLARE @saldo numeric(18, 2) = @saldoinicial
    WHILE @fechadia <= @fechafinal
    BEGIN
        --PRINT 'Credito: ' + cast(@idcredito as varchar(10)) + ', Fecha: ' + cast(@fechadia as varchar(20));

        DECLARE @movimiento NUMERIC(18,2) = (SELECT isnull(SUM(valor),0) FROM detallepago WHERE idcredito = @idcredito and fechapago = @fechadia )
        INSERT INTO @detallesaldos VALUES
        (@idcredito, @fechadia, @saldo, @movimiento, @saldo - @movimiento)
        
        SET @saldo = @saldo - @movimiento

        -- Avanzar al siguiente día
        SET @fechadia = DATEADD(DAY, 1, @fechadia);
    END;

    -- Obtener el siguiente registro
    FETCH NEXT FROM cursorcredito INTO @idcredito, @saldoinicial;
END;

-- Cerrar y liberar el cursor
CLOSE cursorcredito;
DEALLOCATE cursorcredito;

SELECT 
    A.*,
    B.fecha,
    B.saldoinicial,
    B.movimientos,
    B.saldofinal 
FROM 
    @resumencredito A
    
    INNER JOIN @detallesaldos B
    ON A.idcredito = B.idcredito

