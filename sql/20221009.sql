USE SINERGIAS_DB
GO

UPDATE credito SET amortizacion = '{"amortizacion":[]}'

ALTER TABLE credito
ADD observaciones NVARCHAR(MAX) DEFAULT ''

INSERT INTO valorcatalogo VALUES
('ENTFIN', 'ECU ITALCOL', '{"tipo": "Vinculado"}')

