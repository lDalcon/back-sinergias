USE Sinergias_db
GO

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

-- update menu set opciones = '[{"label":"Admin","items":[{"label":"Usuarios","icon":"pi pi-fw pi-user","routerLink":["/admin/usuarios"]},{"label":"Catalogos","icon":"pi pi-fw pi-book","routerLink":["/admin/catalogos"]},{"label":"Macroeconómicos","icon":"pi pi-fw pi-chart-line","routerLink":["/admin/macroeconomicos"]}]},{"label":"Dashboard","items":[{"label":"Gerencial","icon":"pi pi-fw pi-chart-pie","routerLink":["/dashboard/gerencia"]},{"label":"Financiero","icon":"pi pi-fw pi-chart-bar","routerLink":["/dashboard/financiero"]}]},{"label":"Financiero","items":[{"label":"Obligaciones","icon":"pi pi-fw pi-credit-card","routerLink":["/financiero/obligaciones"]},{"label":"Forward","icon":"pi pi-fw pi-dollar","routerLink":["/financiero/forward"]},{"label":"Dif. en Cambio","icon":"pi pi-fw pi-wallet","routerLink":["/financiero/diferenciacambio"]}]}]' where role = 'ADMIN'
-- update menu set opciones = '[{"label":"Dashboard","items":[{"label":"Financiero","icon":"pi pi-fw pi-chart-bar","routerLink":["/dashboard/financiero"]}]},{"label":"Financiero","items":[{"label":"Obligaciones","icon":"pi pi-fw pi-credit-card","routerLink":["/financiero/obligaciones"]},{"label":"Forward","icon":"pi pi-fw pi-dollar","routerLink":["/financiero/forward"]},{"label":"Dif. en Cambio","icon":"pi pi-fw pi-wallet","routerLink":["/financiero/diferenciacambio"]}]}]' where role = 'TESORERIA'
