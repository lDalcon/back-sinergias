USE Sinergias_db
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_getTasaUVR') 
	DROP PROCEDURE [dbo].[sc_getTasaUVR]
GO

CREATE PROCEDURE sc_getTasaUVR
	@fechaDesembolso DATE,
	@fechaPeriodo DATE,
	@tasa NUMERIC(18,6) OUTPUT
AS
	SELECT 
		@tasa = AVG(valor)
	FROM 
		macroeconomicos
	WHERE
		tipo = 'UVR Variacion'
		AND fecha BETWEEN @fechaDesembolso AND @fechaPeriodo
GO