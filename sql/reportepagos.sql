--154 lineas

DECLARE @ano INT = 2024
DECLARE @periodo INT = 2
DECLARE @anoanterior INT
DECLARE @periodoanterior INT
DECLARE @trmcierre NUMERIC(18,2)
SET @periodoanterior = (CASE @periodo WHEN 1 THEN 12 ELSE @periodo - 1 END)
SET @anoanterior = (CASE @periodo WHEN 1 THEN @ano - 1  ELSE @ano END)
SELECT TOP 1 @trmcierre = VALOR FROM macroeconomicos WHERE ANO = @anoanterior AND periodo = @periodoanterior AND tipo = 'TRM' ORDER BY fecha DESC

SELECT
    detallepago.ano [año],
    detallepago.periodo [mes],
    empresa.razonsocial [empresa],
    v_lineacredito_tipo.tipo [lineacredito],
    detallepago.fechapago [fechapago],
    detallepago.seq [idpago],
    detallepago.idcredito [idcredito],
    detalleforward.idforward [idforward],
    detallepago.formapago [formapago],
    detallepago.trm [tasa_pago],
    forward.fechacumplimiento [fechacumplimiento],
    credito.fechadesembolso [fechadesembolso],
    trm.valor [trm_desembolso],
    ISNULL(forward.tasaforward, @trmcierre) [tasaforward/trmcierre],
    forward.dias [fwd_dias],
    DATEDIFF(day, credito.fechadesembolso, detallepago.fechapago) [dias_al_pago],
    ISNULL(DATEDIFF(day, credito.fechadesembolso, forward.fechacumplimiento), credito.plazo * 30) [dias_al_cumplimiento],
    detallepago.valor [valor_pago],
    ISNULL(dc_forward.totaldifcambio, dc_resumen_credito.difcambiodeudanocubiertaacum) [difcambio_no_realizada],
    '=POWER([@[tasaforward/trmcierre]]/[@[trm_desembolso]],365/[@[dias_al_cumplimiento]])-1' [dev_estimada],
    ISNULL(dc_forward.difacumulada, dc_resumen_credito.difcambiodeudanocubiertaacum) [difcambio_acumulada],
    ISNULL(dc_forward.difxcausar, 0) [difcambio_x_causar],
    detallepago.valor * (trm.valor - detallepago.trm) [dif_cambio_realizada],
    '=POWER([@[tasa_pago]]/[@[trm_desembolso]],365/[@[dias_al_pago]])-1' [dev_real_causada],
    '=([@[dev_real_causada]]-[@[dev_estimada]])/[@[dev_estimada]]' [variacion_relativa],
    '=(1+[@[dev_real_causada]])/(1+[@[dev_estimada]])-1' [variacion_abs]
FROM
    detallepago

    LEFT JOIN detalleforward
    ON detallepago.seq = detalleforward.seq

    LEFT JOIN forward
    ON detalleforward.idforward = forward.id

    INNER JOIN credito
    ON detallepago.idcredito = credito.id

    INNER JOIN regional
    ON credito.regional = regional.id

    INNER JOIN empresa
    ON regional.nit = empresa.nit

    INNER JOIN v_lineacredito_tipo
    ON credito.lineacredito = v_lineacredito_tipo.id

    LEFT JOIN dc_forward
    ON detallepago.idcredito = dc_forward.idcredito
        AND detalleforward.idforward = dc_forward.idforward
        AND dc_forward.ano = @anoanterior
        AND dc_forward.periodo = @periodoanterior

    LEFT JOIN dc_resumen_credito
    ON detallepago.idcredito = dc_resumen_credito.idcredito
        AND dc_resumen_credito.ano = @anoanterior
        AND dc_resumen_credito.periodo = @periodoanterior

    LEFT JOIN macroeconomicos trm
    ON trm.tipo = 'TRM'
        AND credito.fechadesembolso = trm.fecha

WHERE
    detallepago.ano = @ano
    AND detallepago.periodo = @periodo
    AND detallepago.tipopago = 'Capital'
    AND detallepago.formapago IN ('SPOT','FORWARD')
    AND detallepago.estado = 'ACTIVO'

-- select top (10) * from detallepago