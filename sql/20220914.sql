-- USE Sinergias_db

/*
* Almacenar amortizacion, proceso para actualizacion de amortizaciones.
*/
-- ALTER TABLE credito
-- ADD amortizacion VARCHAR(MAX) NOT NULL DEFAULT '{"amortizacion": []}'

-- IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aumentocapital]') AND type in (N'U'))
-- 	DROP TABLE [dbo].[aumentocapital]
-- GO

-- CREATE TABLE [dbo].[aumentocapital] (
--     id INT IDENTITY(1,1),
--     ano INT NOT NULL,
--     periodo INT NOT NULL,
--     idcredito INT NOT NULL,
--     fechadesembolso DATE NOT NULL,
--     valor NUMERIC(18,2) NOT NULL,
--     moneda INT NOT NULL,
--     observacion VARCHAR(500),
--     usuariocrea VARCHAR(50) NOT NULL,
--     fechacrea DATETIME NOT NULL,
--     FOREIGN KEY (idcredito) REFERENCES credito(id),
--     FOREIGN KEY (usuariocrea) REFERENCES usuarios(nick)
-- )

