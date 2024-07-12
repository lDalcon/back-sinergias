select * from forward where id = 13044
select * from forward_saldos where idforward = 13044 and idcredito = 12379 
order by ano, periodo, idcredito asc
select * from creditoforward where idforward = 13044 and idcredito = 12379
select * from detalleforward where idforward = 13044 
select * from detallepago where idcredito = 12379
select * from cierreforward where id = 13044



-- update cierreforward set periodo = 11 where id = 11607
-- update creditoforward set periodo = 4 where seq = 775

-- update detalleforward set ano = 2022 where seq = 1584