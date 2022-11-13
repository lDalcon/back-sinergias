USE Sinergias_db
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[forward_saldos]') AND type in (N'U'))
	DROP TABLE [dbo].[forward_saldos]
GO

CREATE TABLE forward_saldos (
	idforward INT NOT NULL,
	idcredito INT NOT NULL,
	ano INT NOT NULL,
	periodo INT NOT NULL,
	saldoinicial NUMERIC(18,2) NOT NULL,
	movimiento NUMERIC(18,2) NOT NULL,
	saldofinal NUMERIC(18,2) NOT NULL,
	PRIMARY KEY(idforward, idcredito, ano, periodo),
	FOREIGN KEY (idforward) REFERENCES forward(id)
)

UPDATE creditoforward SET estado = 'ACTIVO', justificacion = '' WHERE seq = 1357

EXEC sc_actualizar_saldos
EXEC sc_forward_saldos_actualizar '2022', '1'
EXEC sc_forward_saldos_actualizar '2022', '2'
EXEC sc_forward_saldos_actualizar '2022', '3'
EXEC sc_forward_saldos_actualizar '2022', '4'
EXEC sc_forward_saldos_actualizar '2022', '5'
EXEC sc_forward_saldos_actualizar '2022', '6'
EXEC sc_forward_saldos_actualizar '2022', '7'
EXEC sc_forward_saldos_actualizar '2022', '8'
EXEC sc_forward_saldos_actualizar '2022', '9'
EXEC sc_forward_saldos_actualizar '2022', '10'
EXEC sc_forward_saldos_actualizar '2022', '11'