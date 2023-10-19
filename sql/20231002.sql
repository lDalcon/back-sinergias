IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_macroeconomico_guardar') 
	DROP PROCEDURE [dbo].[sc_macroeconomico_guardar]
GO

CREATE PROCEDURE sc_macroeconomico_guardar
    @fecha DATE,
    @tipo VARCHAR(50),
    @valor NUMERIC(18,6),
    @unidad VARCHAR(5)
AS
    DECLARE @existe INT

    SELECT 
        @existe = COUNT(*)
    FROM
        macroeconomicos WITH(NOLOCK)
    WHERE
        fecha = @fecha
        AND tipo = @tipo
    
    IF @existe > 0
        UPDATE macroeconomicos SET
            valor = @valor
        WHERE
            fecha = @fecha
            AND tipo = @tipo
    ELSE
        INSERT INTO macroeconomicos VALUES
        (YEAR(@fecha), MONTH(@fecha), @fecha, @tipo, @valor, @unidad)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_saldos_diario_borrar') 
	DROP PROCEDURE [dbo].[sc_saldos_diario_borrar]
GO

CREATE PROCEDURE sc_saldos_diario_borrar
    @regional INT,
    @fecha DATE
AS
    DELETE saldosdiario
    WHERE
        fecha = @fecha
        AND idcuenta IN (SELECT id FROM cuentasbancarias WHERE regional = @regional)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_inforelevante_borrar') 
	DROP PROCEDURE [dbo].[sc_inforelevante_borrar]
GO

CREATE PROCEDURE sc_inforelevante_borrar
    @regional INT,
    @fecha DATE
AS
    DELETE inforelevante
    WHERE
        fecha = @fecha
        AND regional = @regional
GO