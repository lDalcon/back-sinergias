USE Sinergias_db
GO

-- -- INSERT INTO catalogo VALUES
-- -- ('INFREL', 'Información Relevante', '{}')

-- -- INSERT INTO valorcatalogo VALUES
-- -- ('INFREL', 'Facturación', '{}'),
-- -- ('INFREL', 'Inventarios', '{}'),
-- -- ('INFREL', 'Cartera', '{}'),
-- -- ('INFREL', 'Deuda Financiera', '{}')

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[inforelevante]') AND type in (N'U'))
	DROP TABLE [dbo].[inforelevante]
GO

CREATE TABLE [dbo].[inforelevante] (
    seq INT IDENTITY(1, 1),
    idconcepto INT NOT NULL,
    fecha DATE NOT NULL,
    regional INT NOT NULL,
    valor NUMERIC(18, 2) NOT NULL,
    usuariocrea VARCHAR(50),
    fechacrea DATETIME NOT NULL,
    usuariomod VARCHAR(50),
    fechamod DATETIME NOT NULL,
    FOREIGN KEY (usuariocrea) REFERENCES usuarios(nick),
    FOREIGN KEY (usuariomod) REFERENCES usuarios(nick),
    FOREIGN KEY (regional) REFERENCES regional(id)
)

-- UPDATE menu SET opciones = '[
--     {
--         "items": [
--             {
--                 "icon": "pi pi-fw pi-user",
--                 "label": "Usuarios",
--                 "routerLink": [
--                     "/admin/usuarios"
--                 ]
--             },
--             {
--                 "icon": "pi pi-fw pi-calendar",
--                 "label": "Calendario",
--                 "routerLink": [
--                     "/admin/calendario"
--                 ]
--             }
--         ],
--         "label": "Admin"
--     },
--     {
--         "items": [
--             {
--                 "icon": "pi pi-fw pi-chart-pie",
--                 "label": "Gerencial",
--                 "routerLink": [
--                     "/dashboard/gerencia"
--                 ]
--             },
--             {
--                 "icon": "pi pi-fw pi-chart-bar",
--                 "label": "Financiero",
--                 "routerLink": [
--                     "/dashboard/financiero"
--                 ]
--             }
--         ],
--         "label": "Dashboard"
--     },
--     {
--         "items": [
--             {
--                 "icon": "pi pi-fw pi-file",
--                 "label": "Solicitudes",
--                 "routerLink": [
--                     "/financiero/solicitudes"
--                 ]
--             },
--             {
--                 "icon": "pi pi-fw pi-credit-card",
--                 "label": "Obligaciones",
--                 "routerLink": [
--                     "/financiero/obligaciones"
--                 ]
--             },
--             {
--                 "icon": "pi pi-fw pi-dollar",
--                 "label": "Forward",
--                 "routerLink": [
--                     "/financiero/forward"
--                 ]
--             },
--             {
--                 "icon": "pi pi-fw pi-wallet",
--                 "label": "Dif. en Cambio",
--                 "routerLink": [
--                     "/financiero/diferenciacambio"
--                 ]
--             },
--             {
--                 "icon": "pi pi-fw pi-calendar",
--                 "label": "Saldos Diarios",
--                 "routerLink": [
--                     "/financiero/saldosdiario"
--                 ]
--             },
--             {
--                 "icon": "pi pi-fw pi-database",
--                 "label": "Info. Relevante",
--                 "routerLink": [
--                     "/financiero/inforelevante"
--                 ]
--             }
--         ],
--         "label": "Financiero"
--     }
-- ]' WHERE role = 'ADMIN'

-- UPDATE menu SET ROLE = 'DEUDA' WHERE ROLE = 'TESORERIA'

-- UPDATE menu SET opciones = 'DEUDA' WHERE ROLE = 'DEUDA'

-- INSERT INTO menu VALUES
-- ('INFOFIN', '[
-- 	{
-- 		"items": [
-- 			{
-- 				"icon": "pi pi-fw pi-database",
-- 				"label": "Info. Relevante",
-- 				"routerLink": [
-- 					"/financiero/inforelevante"
-- 				]
-- 			}
-- 		],
-- 		"label": "Financiero"
-- 	}
-- ]'),
-- ('DEUDASALDOS', '[
-- 	{
-- 		"items": [
-- 			{
-- 				"icon": "pi pi-fw pi-chart-pie",
-- 				"label": "Gerencial",
-- 				"routerLink": [
-- 					"/dashboard/gerencia"
-- 				]
-- 			},
-- 			{
-- 				"icon": "pi pi-fw pi-chart-bar",
-- 				"label": "Financiero",
-- 				"routerLink": [
-- 					"/dashboard/financiero"
-- 				]
-- 			}
-- 		],
-- 		"label": "Dashboard"
-- 	},
-- 	{
-- 		"items": [
-- 			{
-- 				"icon": "pi pi-fw pi-file",
-- 				"label": "Solicitudes",
-- 				"routerLink": [
-- 					"/financiero/solicitudes"
-- 				]
-- 			},
-- 			{
-- 				"icon": "pi pi-fw pi-credit-card",
-- 				"label": "Obligaciones",
-- 				"routerLink": [
-- 					"/financiero/obligaciones"
-- 				]
-- 			},
-- 			{
-- 				"icon": "pi pi-fw pi-dollar",
-- 				"label": "Forward",
-- 				"routerLink": [
-- 					"/financiero/forward"
-- 				]
-- 			},
-- 			{
-- 				"icon": "pi pi-fw pi-wallet",
-- 				"label": "Dif. en Cambio",
-- 				"routerLink": [
-- 					"/financiero/diferenciacambio"
-- 				]
-- 			},
-- 			{
-- 				"icon": "pi pi-fw pi-calendar",
-- 				"label": "Saldos Diarios",
-- 				"routerLink": [
-- 					"/financiero/saldosdiario"
-- 				]
-- 			}
-- 		],
-- 		"label": "Financiero"
-- 	}
-- ]'),
-- ('SALDOSINFOFIN', '[
-- 	{
-- 		"items": [
-- 			{
-- 				"icon": "pi pi-fw pi-calendar",
-- 				"label": "Saldos Diarios",
-- 				"routerLink": [
-- 					"/financiero/saldosdiario"
-- 				]
-- 			},
-- 			{
-- 				"icon": "pi pi-fw pi-database",
-- 				"label": "Info. Relevante",
-- 				"routerLink": [
-- 					"/financiero/inforelevante"
-- 				]
-- 			}
-- 		],
-- 		"label": "Financiero"
-- 	}
-- ]'),
-- ('DEUDASALDOSINFOFIN', '[
-- 	{
-- 		"items": [
-- 			{
-- 				"icon": "pi pi-fw pi-chart-pie",
-- 				"label": "Gerencial",
-- 				"routerLink": [
-- 					"/dashboard/gerencia"
-- 				]
-- 			},
-- 			{
-- 				"icon": "pi pi-fw pi-chart-bar",
-- 				"label": "Financiero",
-- 				"routerLink": [
-- 					"/dashboard/financiero"
-- 				]
-- 			}
-- 		],
-- 		"label": "Dashboard"
-- 	},
-- 	{
-- 		"items": [
-- 			{
-- 				"icon": "pi pi-fw pi-file",
-- 				"label": "Solicitudes",
-- 				"routerLink": [
-- 					"/financiero/solicitudes"
-- 				]
-- 			},
-- 			{
-- 				"icon": "pi pi-fw pi-credit-card",
-- 				"label": "Obligaciones",
-- 				"routerLink": [
-- 					"/financiero/obligaciones"
-- 				]
-- 			},
-- 			{
-- 				"icon": "pi pi-fw pi-dollar",
-- 				"label": "Forward",
-- 				"routerLink": [
-- 					"/financiero/forward"
-- 				]
-- 			},
-- 			{
-- 				"icon": "pi pi-fw pi-wallet",
-- 				"label": "Dif. en Cambio",
-- 				"routerLink": [
-- 					"/financiero/diferenciacambio"
-- 				]
-- 			},
-- 			{
-- 				"icon": "pi pi-fw pi-calendar",
-- 				"label": "Saldos Diarios",
-- 				"routerLink": [
-- 					"/financiero/saldosdiario"
-- 				]
-- 			},
-- 			{
-- 				"icon": "pi pi-fw pi-database",
-- 				"label": "Info. Relevante",
-- 				"routerLink": [
-- 					"/financiero/inforelevante"
-- 				]
-- 			}
-- 		],
-- 		"label": "Financiero"
-- 	}
-- ]')




-- IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_inforelevante_listar') 
-- 	DROP PROCEDURE [dbo].[sc_inforelevante_listar]
-- GO

-- CREATE PROCEDURE sc_inforelevante_listar
--     @fechainicial DATE,
--     @fechafinal DATE,
--     @regional INT
-- AS
--     DECLARE @TEMP AS TABLE (fecha Date, ndatos INT, ndiligenciados INT, estado VARCHAR(10))
--     WHILE @fechaInicial <= @fechaFinal AND @fechaInicial <= CAST(GETDATE() AS DATE)
--         BEGIN
--             IF DATEPART(dw, @fechainicial) = 2 OR @fechainicial = EOMONTH(@fechainicial)
--                 BEGIN
--                     INSERT INTO @TEMP VALUES
--                     (
--                         @fechainicial,
--                         4,
--                         (SELECT COUNT(*) FROM inforelevante WHERE fecha = @fechainicial AND regional = @regional),
--                         ''
--                     ) 
--                 END

--             SET @fechaInicial = DATEADD(DAY, 1, @fechaInicial);
--         END

--     UPDATE @TEMP 
--     SET estado = CASE 
-- 	WHEN ndiligenciados = 0 THEN 'PENDIENTE'
-- 	WHEN ndiligenciados = ndatos THEN 'OK'
-- 	ELSE 'PARCIAL' END
    
--     SELECT * FROM @TEMP FOR JSON PATH
-- GO


-- IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_inforelevante_listardia') 
-- 	DROP PROCEDURE [dbo].[sc_inforelevante_listardia]
-- GO

-- CREATE PROCEDURE sc_inforelevante_listardia
--     @fecha DATE,
--     @regional INT
-- AS
--     SELECT 
--         concepto.id idconcepto,
--         @regional regional,
--         @fecha fecha,
--         null valor,
--         concepto.descripcion
--     FROM 
--         valorcatalogo concepto
--     WHERE
--         concepto.ctgid = 'INFREL'
--         AND concepto.id NOT IN (SELECT idconcepto FROM inforelevante WHERE fecha = @fecha)
--         AND DATEPART(dw, @fecha) = 2 OR @fecha = EOMONTH(@fecha)
--     FOR JSON PATH, INCLUDE_NULL_VALUES
-- GO

-- IF EXISTS (SELECT * FROM sysobjects WHERE name='sc_inforelevante_crear_actualizar') 
-- 	DROP PROCEDURE [dbo].[sc_inforelevante_crear_actualizar]
-- GO

-- CREATE PROCEDURE sc_inforelevante_crear_actualizar
--     @idconcepto INT,
--     @fecha DATE,
--     @regional INT,
--     @valor NUMERIC(28,2),
--     @nick VARCHAR(50)
-- AS
--     DECLARE @existe INT
    
--     SELECT @existe = COUNT(*) FROM inforelevante WHERE idconcepto = @idconcepto AND fecha = @fecha AND regional = @regional

--     IF @existe < 1
--         INSERT INTO inforelevante VALUES
--         (
--             @idconcepto,
--             @fecha,
--             @regional,
--             @valor,
--             @nick,
--             GETDATE(),
--             @nick,
--             GETDATE()
--         )
--     ELSE
--         UPDATE inforelevante SET
--             valor = @valor,
--             usuariomod = @nick,
--             fechamod = GETDATE()
--         WHERE
--             idconcepto = @idconcepto 
--             AND fecha = @fecha
--             AND regional = @regional
-- GO

-- UPDATE usuarios SET ROLE = 'DEUDA' WHERE ROLE = 'TESORERIA'

SELECT * FROM menu