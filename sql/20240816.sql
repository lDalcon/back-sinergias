ALTER PROCEDURE [dbo].[sc_credito_listar]
    @nick VARCHAR(50),
    @regional INT = NULL,
    @lineacredito INT = NULL,
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
        v_credito_tasa.tasaEA AS [tasaEA],
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

        LEFT JOIN v_credito_tasa
        ON credito.id = v_credito_tasa.id
        AND credito.plazo = v_credito_tasa.nper
    
    WHERE
        regional.id in (SELECT idregional FROM usuario_regional WHERE nick = @nick AND idregional = ISNULL(@regional, idregional))
        AND credito.lineacredito = ISNULL(@lineacredito, credito.lineacredito)
        AND credito.estado = ISNULL(@estado, credito.estado)
GO

DROP TABLE [dbo].[aumentocapital]
GO
CREATE TABLE [dbo].[aumentocapital](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ano] [int] NOT NULL,
	[periodo] [int] NOT NULL,
	[idcredito] [int] NOT NULL,
	[fecha] [date] NOT NULL,
    [tipo] [varchar](15) NOT NULL,
	[valor] [numeric](18, 2) NOT NULL,
	[moneda] [int] NOT NULL,
	[observacion] [varchar](500) NULL,
	[usuariocrea] [varchar](50) NOT NULL,
	[fechacrea] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[aumentocapital]  WITH CHECK ADD FOREIGN KEY([idcredito])
REFERENCES [dbo].[credito] ([id])
GO
ALTER TABLE [dbo].[aumentocapital]  WITH CHECK ADD FOREIGN KEY([usuariocrea])
REFERENCES [dbo].[usuarios] ([nick])
GO