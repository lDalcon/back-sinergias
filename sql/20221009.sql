USE SINERGIAS_DB
GO

UPDATE credito SET amortizacion = '{"amortizacion":[]}'

ALTER TABLE credito
ADD observaciones NVARCHAR(MAX) DEFAULT ''

INSERT INTO valorcatalogo VALUES
('ENTFIN', 'ECU ITALCOL', '{"tipo": "Vinculado"}')

UPDATE menu SET opciones = '[{"label":"Admin","items":[{"label":"Usuarios","icon":"pi pi-fw pi-user","routerLink":["/admin/usuarios"]},{"label":"Catalogos","icon":"pi pi-fw pi-book","routerLink":["/admin/catalogos"]},{"label":"Macroeconómicos","icon":"pi pi-fw pi-chart-line","routerLink":["/admin/macroeconomicos"]},{"label":"Calendario","icon":"pi pi-fw pi-calendar","routerLink":["/admin/calendario"]}]},{"label":"Dashboard","items":[{"label":"Gerencial","icon":"pi pi-fw pi-chart-pie","routerLink":["/dashboard/gerencia"]},{"label":"Financiero","icon":"pi pi-fw pi-chart-bar","routerLink":["/dashboard/financiero"]}]},{"label":"Financiero","items":[{"label":"Obligaciones","icon":"pi pi-fw pi-credit-card","routerLink":["/financiero/obligaciones"]},{"label":"Forward","icon":"pi pi-fw pi-dollar","routerLink":["/financiero/forward"]},{"label":"Dif. en Cambio","icon":"pi pi-fw pi-wallet","routerLink":["/financiero/diferenciacambio"]}]}]' 
WHERE role = 'ADMIN'

UPDATE credito SET estado = 'PAGO' WHERE saldo = 0
UPDATE credito SET estado = 'CXC' WHERE saldo < 0
