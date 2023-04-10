USE Sinergias_db
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cuentasbancarias]') AND type in (N'U'))
	DROP TABLE [dbo].[cuentasbancarias]
GO

CREATE TABLE [dbo].[cuentasbancarias] (
    id INT IDENTITY(1, 1),
    regional INT NOT NULL,
    tipocuenta INT NOT NULL,
    entfinanciera INT NOT NULL,
    ncuenta VARCHAR(100) NOT NULL,
    moneda INT NOT NULL,
    fechaapertura DATE,
    estado BIT,
    PRIMARY KEY (id),
    FOREIGN KEY (regional) REFERENCES regional(id),
    FOREIGN KEY (tipocuenta) REFERENCES valorcatalogo(id),
    FOREIGN KEY (entfinanciera) REFERENCES valorcatalogo(id),
    FOREIGN KEY (moneda) REFERENCES valorcatalogo(id),
    CONSTRAINT u_cuenta UNIQUE (ncuenta, entfinanciera)
)

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_cuentasbancarias_crear') 
	DROP PROCEDURE [dbo].[sc_cuentasbancarias_crear]
GO

CREATE PROCEDURE sc_cuentasbancarias_crear
    @regional INT,
    @tipocuenta INT,
    @entfinanciera INT,
    @ncuenta VARCHAR(100),
    @moneda INT,
    @fechaapertura DATE
AS
    INSERT INTO cuentasbancarias VALUES
        (
            @regional,
            @tipocuenta,
            @entfinanciera,
            @ncuenta,
            @moneda,
            @fechaapertura,
            1
        )
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[saldosdiario]') AND type in (N'U'))
	DROP TABLE [dbo].[saldosdiario]
GO

CREATE TABLE [dbo].[saldosdiario] (
    seq INT IDENTITY(1, 1),
    idcuenta INT NOT NULL,
    fecha DATE NOT NULL,
    valor NUMERIC(18, 2) NOT NULL,
    usuariocrea VARCHAR(50),
    fechacrea DATETIME NOT NULL,
    usuariomod VARCHAR(50),
    fechamod DATETIME NOT NULL,
    FOREIGN KEY (usuariocrea) REFERENCES usuarios(nick),
    FOREIGN KEY (usuariomod) REFERENCES usuarios(nick),
)

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_saldosdiario_crear_actualizar') 
	DROP PROCEDURE [dbo].[sc_saldosdiario_crear_actualizar]
GO

CREATE PROCEDURE sc_saldosdiario_crear_actualizar
    @idcuenta INT,
    @fecha DATE,
    @valor NUMERIC(18, 2),
    @nick VARCHAR(50)
AS
    DECLARE @existe INT
    
    SELECT @existe = COUNT(*) FROM saldosdiario WHERE idcuenta = @idcuenta AND fecha = @fecha

    IF @existe < 1
        INSERT INTO saldosdiario VALUES
        (
            @idcuenta,
            @fecha,
            @valor,
            @nick,
            GETDATE(),
            @nick,
            GETDATE()
        )
    ELSE
        UPDATE saldosdiario SET
            valor = @valor,
            usuariomod = @nick,
            fechamod = GETDATE()
        WHERE
            idcuenta = @idcuenta 
            AND fecha = @fecha
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_saldosdiario_listar') 
	DROP PROCEDURE [dbo].[sc_saldosdiario_listar]
GO

CREATE PROCEDURE sc_saldosdiario_listar
    @fechainicial DATE,
    @fechafinal DATE,
    @nick VARCHAR(50),
    @regional INT
AS
    DELETE listafechas
    WHILE @fechaInicial <= @fechaFinal
        BEGIN
            INSERT INTO listafechas 
            VALUES (
                @fechaInicial, 
                (SELECT COUNT(*) FROM cuentasbancarias WHERE regional = @regional AND fechaapertura <= @fechainicial), 
                (SELECT COUNT(*) FROM cuentasbancarias INNER JOIN saldosdiario ON cuentasbancarias.id = saldosdiario.idcuenta AND saldosdiario.fecha = @fechainicial WHERE regional = @regional AND fechaapertura <= @fechainicial), 
                ''
                );
            SET @fechaInicial = DATEADD(DAY, 1, @fechaInicial);
        END

    UPDATE listafechas 
    SET estado = CASE 
	WHEN ndatos = 0 THEN 'PENDIENTE'
	WHEN ncuentas = ndatos THEN 'OK'
	ELSE 'PARCIAL' END
    
    SELECT * FROM listafechas FOR JSON PATH
GO

UPDATE menu SET opciones = '[{"items":[{"icon":"pi pi-fw pi-user","label":"Usuarios","routerLink":["/admin/usuarios"]},{"icon":"pi pi-fw pi-calendar","label":"Calendario","routerLink":["/admin/calendario"]}],"label":"Admin"},{"items":[{"icon":"pi pi-fw pi-chart-pie","label":"Gerencial","routerLink":["/dashboard/gerencia"]},{"icon":"pi pi-fw pi-chart-bar","label":"Financiero","routerLink":["/dashboard/financiero"]}],"label":"Dashboard"},{"items":[{"icon":"pi pi-fw pi-file","label":"Solicitudes","routerLink":["/financiero/solicitudes"]},{"icon":"pi pi-fw pi-credit-card","label":"Obligaciones","routerLink":["/financiero/obligaciones"]},{"icon":"pi pi-fw pi-dollar","label":"Forward","routerLink":["/financiero/forward"]},{"icon":"pi pi-fw pi-wallet","label":"Dif. en Cambio","routerLink":["/financiero/diferenciacambio"]},{"icon":"pi pi-fw pi-wallet","label":"Saldos Diarios","routerLink":["/financiero/saldosdiario"]}],"label":"Financiero"}]'
WHERE role = 'ADMIN'

INSERT INTO valorcatalogo VALUES
('ENTFIN',  'CREDICORP', '{"tipo": "Financiero"}')

INSERT INTO catalogo VALUES
('TIPCUE', 'Tipo de Cuenta', '{}')

INSERT INTO valorcatalogo VALUES
('TIPCUE', 'AHORROS', '{}'),
('TIPCUE', 'CORRIENTE', '{}'),
('TIPCUE', 'FIDUCIA', '{}'),
('TIPCUE', 'FONDO A LA VISTA', '{}'),
('TIPCUE', 'COMPENSACIÓN', '{}'),
('TIPCUE', 'OTRA', '{}')

INSERT INTO cuentasbancarias VALUES
('112', '610', '502', '30910000024-4', '501', '2023-01-01', '1'),
('112', '610', '509', '03931656-7', '500', '2023-01-01',  '1'),
('112', '609', '509', '39319470', '500', '2023-01-01',  '1'),
('112', '610', '523', '21125254754', '500', '2023-01-01',  '1'),
('112', '610', '506', '7369997924', '500', '2023-01-01',  '1'),
('112', '609', '506', '00730045081-9', '500', '2023-01-01',  '1'),
('112', '612', '607', '1-143835-8', '500', '2023-01-01',  '1'),
('112', '609', '502', '4-0910-3-007890', '500', '2023-01-01',  '1'),
('112', '610', '502', '06011-002324-3', '500', '2023-01-01',  '1'),
('112', '610', '509', '157-32608-3', '500', '2023-01-01',  '1'),
('112', '610', '523', '3001-020694-3', '500', '2023-01-01',  '1'),
('112', '610', '526', '197-28612-3', '500', '2023-03-01',  '1'),
('112', '610', '514', '655-03724-0', '500', '2023-01-01',  '1'),
('112', '609', '506', '0460-0048482-7', '500', '2023-02-01',  '1')

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[listafechas]') AND type in (N'U'))
	DROP TABLE [dbo].[listafechas]
GO

CREATE TABLE listafechas (
    fecha DATE,
    ncuentas INT,
    ndatos INT,
    estado VARCHAR(10)
)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_saldosdiario_listardia') 
	DROP PROCEDURE [dbo].[sc_saldosdiario_listardia]
GO

CREATE PROCEDURE sc_saldosdiario_listardia
    @fecha DATE,
    @regional INT
AS
    SELECT 
        cuentasbancarias.id [idcuenta],
        entfinanciera.descripcion [entfinanciera],
        tipocuenta.descripcion [tipocuenta],
        cuentasbancarias.ncuenta [ncuenta],
        JSON_QUERY(moneda.config) [moneda],
        @fecha [fecha],
        NULL [valor]
    FROM 
        cuentasbancarias

        INNER JOIN valorcatalogo AS entfinanciera
        ON cuentasbancarias.entfinanciera = entfinanciera.id

        INNER JOIN valorcatalogo AS moneda
        ON cuentasbancarias.moneda = moneda.id

        INNER JOIN valorcatalogo AS tipocuenta
        ON cuentasbancarias.tipocuenta = tipocuenta.id

    WHERE
        cuentasbancarias.regional = @regional
        AND @fecha <= CAST(GETDATE() AS DATE)
        AND cuentasbancarias.fechaapertura <= @fecha
        AND cuentasbancarias.estado = 1
        AND NOT EXISTS ( SELECT * FROM saldosdiario WHERE saldosdiario.fecha = @fecha AND cuentasbancarias.id = saldosdiario.idcuenta)
    FOR JSON PATH, INCLUDE_NULL_VALUES
GO