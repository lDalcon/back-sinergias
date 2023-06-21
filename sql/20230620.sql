IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_credito_anular') 
	DROP PROCEDURE [dbo].[sc_credito_anular]
GO

CREATE PROCEDURE sc_credito_anular
	@id INT,
	@nick VARCHAR(50)
AS
	BEGIN
		UPDATE credito SET 
			estado = 'ANULADO',
			saldo = 0,
			saldoasignacion = 0,
			usuariomod = @nick,
			fechamod = GETDATE()
		WHERE
			id = @id

		DELETE credito_saldos
		WHERE
			id = @id
	END
GO