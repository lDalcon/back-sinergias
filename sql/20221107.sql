USE Sinergias_db
GO

ALTER TABLE forward
ADD observaciones NVARCHAR(MAX) 
GO

CREATE TABLE logtrx (
    objeto VARCHAR(20) NOT NULL,
    idObjeto INT NOT NULL,
    fecha DATETIME NOT NULL,
    accion VARCHAR(10) NOT NULL,
    valorprevio NVARCHAR(MAX),
    valoractiualizado NVARCHAR(MAX) NOT NULL,
    usuario VARCHAR(50),
    FOREIGN KEY (usuario) REFERENCES usuarios(nick)
)
GO

CREATE OR ALTER TRIGGER tr_credito_log 
    ON credito FOR INSERT, UPDATE
AS
    DECLARE @row INT = (SELECT COUNT(*) FROM inserted)

    IF @row = 1
        BEGIN
            DECLARE @valorprevio NVARCHAR(MAX) = (SELECT * FROM deleted FOR JSON PATH);
            DECLARE @valoractiualizado NVARCHAR(MAX) = (SELECT * FROM inserted FOR JSON PATH);
            DECLARE @usuario VARCHAR(50) = (SELECT usuariomod FROM inserted)
            DECLARE @id INT = (SELECT id FROM inserted)
            DECLARE @accion VARCHAR(10) = (CASE WHEN @valorprevio IS NULL THEN 'Crear' ELSE 'Actualizar' END)

            EXEC sc_logtrx_guardar 'CREDITO', @id, @accion, @valorprevio, @valoractiualizado, @usuario
        END
    ELSE
        EXEC sc_logtrx_guardar 'credito', -1, 'Actualizar', '', '', 'ADMIN';
GO

CREATE OR ALTER TRIGGER tr_forward_log 
    ON forward FOR INSERT, UPDATE
AS
    DECLARE @row INT = (SELECT COUNT(*) FROM inserted)

    IF @row = 1
        BEGIN
            DECLARE @valorprevio NVARCHAR(MAX) = (SELECT * FROM deleted FOR JSON PATH);
            DECLARE @valoractiualizado NVARCHAR(MAX) = (SELECT * FROM inserted FOR JSON PATH);
            DECLARE @usuario VARCHAR(50) = (SELECT usuariomod FROM inserted)
            DECLARE @id INT = (SELECT id FROM inserted)
            DECLARE @accion VARCHAR(10) = (CASE WHEN @valorprevio IS NULL THEN 'Crear' ELSE 'Actualizar' END)

            EXEC sc_logtrx_guardar 'FORWARD', @id, @accion, @valorprevio, @valoractiualizado, @usuario;
        END
    ELSE
        EXEC sc_logtrx_guardar 'forward', -1, 'Actualizar', '', '', 'ADMIN';
GO

CREATE OR ALTER TRIGGER tr_creditoforward_log 
    ON creditoforward FOR INSERT, UPDATE
AS
    DECLARE @row INT = (SELECT COUNT(*) FROM inserted)

    IF @row = 1
        BEGIN
            DECLARE @valorprevio NVARCHAR(MAX) = (SELECT * FROM deleted FOR JSON PATH);
            DECLARE @valoractiualizado NVARCHAR(MAX) = (SELECT * FROM inserted FOR JSON PATH);
            DECLARE @usuario VARCHAR(50) = (SELECT usuariomod FROM inserted)
            DECLARE @id INT = (SELECT seq FROM inserted)
            DECLARE @accion VARCHAR(10) = (CASE WHEN @valorprevio IS NULL THEN 'Crear' ELSE 'Actualizar' END)

            EXEC sc_logtrx_guardar 'CREDITOFORWARD', @id, @accion, @valorprevio, @valoractiualizado, 'ADMIN';
        END;
    ELSE
        EXEC sc_logtrx_guardar 'creditoforward', -1, 'Actualizar', '', '', 'ADMIN';
GO
