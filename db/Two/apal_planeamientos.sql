/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Anderson Fuentes
 * Created: 26 may. 2022
 */

-- MODULE: PLANEAMIENTO

DROP PROCEDURE IF EXISTS insertChecklist1;

DELIMITER $$
CREATE PROCEDURE `insertChecklist1`(
in ruc varchar(50),
in proveedor varchar(50),
in responsable_inspeccion varchar(200),
in placa varchar(50),
in tipo_vehiculo varchar(50),
in horometro varchar(50),
in dni varchar(50),
in nombre_apellido varchar(150),
in chofer varchar(150),
in licencia_cat varchar(50),
in fecha_caducidad date,
in revision_tecnica varchar(50),
in fecha_caducidad_rev date,
in soat varchar(50),
in fecha_caducidad_soat date,
in permiso_circulacion varchar(50),
in fecha_caducidad_perm date,
in programa_mantenim varchar(50),
in obs_1 text,
in obs_2 text,
in obs_3 text,
in obs_4 text,
in obs_5 text,
in obs_6 text,
in img_1_insp varchar(250),
in img_2_insp varchar(250),
in img_3_insp varchar(250),
in img_4_insp varchar(250),
in img_5_insp varchar(250),
in img_6_insp varchar(250),
in img_7_insp varchar(250)
)
BEGIN

    DECLARE auto INT;

    INSERT INTO tbl_checklist VALUES (default, ruc, proveedor, now(), responsable_inspeccion, placa, tipo_vehiculo, 
    horometro, dni, nombre_apellido, chofer, licencia_cat, fecha_caducidad, revision_tecnica, fecha_caducidad_rev, soat, fecha_caducidad_soat,
    permiso_circulacion, fecha_caducidad_perm, programa_mantenim, obs_1, obs_2, obs_3, obs_4, obs_5, obs_6, img_1_insp, img_2_insp, img_3_insp,
    img_4_insp, img_5_insp, img_6_insp, img_7_insp);

    SELECT MAX(id_checklist) into auto FROM tbl_checklist;

    SELECT auto;
	
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS importCode;

DELIMITER $$
CREATE PROCEDURE `importCode`(
in docompraventa varchar(50)
)
BEGIN

    DECLARE total INT DEFAULT 0;

    SELECT COUNT(*) INTO total FROM tbl_code where cod_venta_compra=docompraventa;
    IF total =0 THEN

        INSERT INTO tbl_code VALUES (default, docompraventa, now());

    END IF;
	
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS importCliente;

DELIMITER $$
CREATE PROCEDURE `importCliente`(
in codcliente varchar(50)
)
BEGIN

    DECLARE total INT DEFAULT 0;

    SELECT COUNT(*) INTO total FROM tbl_clientes where cod_cli=codcliente;
    IF total =0 THEN

        INSERT INTO tbl_clientes VALUES (codcliente, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

    END IF;
	
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS importAuxiliar;

DELIMITER $$
CREATE PROCEDURE `importAuxiliar`(
in placa_ varchar(30)
)
BEGIN

    DECLARE total INT DEFAULT 0;

    SELECT COUNT(*) INTO total FROM tbl_auxiliar where placa=placa_;
    IF total =0 THEN
        INSERT INTO tbl_auxiliar VALUES (default, placa_, NULL, NULL);
    END IF;
	
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS importAuxiliarTwo;

DELIMITER $$
CREATE PROCEDURE `importAuxiliarTwo`(
in id_aux int,
in chofer varchar(250)
)
BEGIN

    DECLARE telefono_ varchar(50);

    SELECT P.nro_tlfno into telefono_ from tbl_pers P where P.nom_ape=chofer;
    UPDATE tbl_auxiliar SET transportista= chofer, telefono=telefono_ WHERE id=id_aux;

    SELECT telefono_ as telefono;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataConsolidado;

DELIMITER $$
CREATE PROCEDURE dataConsolidado(
in desde int,
in per_pages int
)
BEGIN
    SET lc_time_names = 'es_ES';
    SET @a = desde;

    SELECT LPAD(@a:=@a+1,5,'0') as ID, t.* from
    (SELECT
        R.fec_emis as FECHA,
        B.placa as PLACA,
        B.secuencia as SECUENCIA,
        A.id as CT,
        "" as TRANSPORTISTA,
        B.destinatario as DESTINATARIO,
        CC.nombre as NOMBRE_CLIENTE,
        CC.direccion as DIRECCION,
        CC.distrito as DISTRITO,
        CC.telefono01 as CONTACTO,
        CC.ruta_visita as GESTOR,
        "" as SUPERVISOR,
        CC.ruta_llamada as TLV,
        CC.dia_llamada as DIA_LLAMADA,
        CC.latitud as LATITUD,
        CC.longitud as LONGITUD,
        SUM(R.monto) as VALOR_CON_IGV,
        B.peso_tn as PESO_TN,
        B.placa as PLACA_2,
        "" as TELEFONO_CHOFER,
        CONCAT(UCASE(LEFT(DAYNAME(R.fec_emis), 1)), 
        SUBSTRING(DAYNAME(R.fec_emis), 2)) AS DIA

    FROM tbl_code C 
    inner join tbl_ruta R on (C.cod_venta_compra=R.codigo)
    LEFT JOIN ( SELECT doc_compras, placa, secuencia, destinatario, SUM(peso_kg) as peso_tn 
               from tbl_despacho group by doc_compras ORDER BY doc_compras ASC) B ON C.cod_venta_compra=B.doc_compras
    inner join tbl_auxiliar A on (A.placa=B.placa)
    inner join tbl_clientes CC on (CC.cod_cli=B.destinatario) 
    group by R.codigo ORDER BY R.fec_emis DESC limit desde,per_pages) as t;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataSearchConsolidado;

DELIMITER $$
CREATE PROCEDURE dataSearchConsolidado(
in texto varchar(100)
)
BEGIN
    SET lc_time_names = 'es_ES';
    SET @a = 0;

    SELECT LPAD(@a:=@a+1,5,'0') as ID, t.* from
    (SELECT
        R.fec_emis as FECHA,
        B.placa as PLACA,
        B.secuencia as SECUENCIA,
        A.id as CT,
        "" as TRANSPORTISTA,
        B.destinatario as DESTINATARIO,
        CC.nombre as NOMBRE_CLIENTE,
        CC.direccion as DIRECCION,
        CC.distrito as DISTRITO,
        CC.telefono01 as CONTACTO,
        CC.ruta_visita as GESTOR,
        "" as SUPERVISOR,
        CC.ruta_llamada as TLV,
        CC.dia_llamada as DIA_LLAMADA,
        CC.latitud as LATITUD,
        CC.longitud as LONGITUD,
        SUM(R.monto) as VALOR_CON_IGV,
        B.peso_tn as PESO_TN,
        B.placa as PLACA_2,
        "" as TELEFONO_CHOFER,
        CONCAT(UCASE(LEFT(DAYNAME(R.fec_emis), 1)), 
        SUBSTRING(DAYNAME(R.fec_emis), 2)) AS DIA

    FROM tbl_code C 
    inner join tbl_ruta R on (C.cod_venta_compra=R.codigo)
    LEFT JOIN ( SELECT doc_compras, placa, secuencia, destinatario, SUM(peso_kg) as peso_tn 
               from tbl_despacho group by doc_compras ORDER BY doc_compras ASC) B ON C.cod_venta_compra=B.doc_compras
    inner join tbl_auxiliar A on (A.placa=B.placa)
    inner join tbl_clientes CC on (CC.cod_cli=B.destinatario)
    where (CC.nombre=texto OR CC.distrito=texto OR CC.telefono01=texto OR B.placa=texto OR B.destinatario=texto)
    group by R.codigo ORDER BY R.fec_emis DESC) as t;
       
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataTransportista;

DELIMITER $$
CREATE PROCEDURE `dataTransportista`(
in placa varchar(50)
)
BEGIN

    DECLARE ruc varchar(50);
    SELECT F.ruc_proveedor INTO ruc FROM tbl_flota F where F.placa=placa;

    IF ruc IS NOT NULL THEN
        SELECT P.nom_ape as nombres FROM tbl_pers P WHERE P.ruc_emp=ruc;
    END IF;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataValidacionTransportista;

DELIMITER $$
CREATE PROCEDURE `dataValidacionTransportista`(
in placa varchar(50)
)
BEGIN

    DECLARE total INT DEFAULT 0;
    SELECT COUNT(*) INTO total FROM tbl_auxiliar A where A.placa=placa and A.transportista IS NOT NULL;

    IF total>0 THEN
        SELECT * FROM tbl_auxiliar A where A.placa=placa;
    END IF;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataConsolidadoReport;

DELIMITER $$
CREATE PROCEDURE dataConsolidadoReport(
    in fecha_1 date,
    in fecha_2 date
)
BEGIN
    SET lc_time_names = 'es_ES';
    SET @a = 0;

    SELECT LPAD(@a:=@a+1,5,'0') as ID, t.* from
    (SELECT
        R.fec_emis as FECHA,
        B.placa as PLACA,
        B.secuencia as SECUENCIA,
        A.id as CT,
        CASE 
            WHEN A.transportista IS NULL THEN "SIN DATOS"
            ELSE A.transportista
        END as TRANSPORTISTA,
        B.destinatario as DESTINATARIO,
        CC.nombre as NOMBRE_CLIENTE,
        CC.direccion as DIRECCION,
        CC.distrito as DISTRITO,
        CC.telefono01 as CONTACTO,
        CC.ruta_visita as GESTOR,
        "" as SUPERVISOR,
        CC.ruta_llamada as TLV,
        CC.dia_llamada as DIA_LLAMADA,
        CC.latitud as LATITUD,
        CC.longitud as LONGITUD,
        SUM(R.monto) as VALOR_CON_IGV,
        B.peso_tn as PESO_TN,
        B.placa as PLACA_2,
        CASE 
            WHEN A.telefono IS NULL THEN "SIN DATOS"
            ELSE A.telefono
        END as TELEFONO_CHOFER,
        CONCAT(UCASE(LEFT(DAYNAME(R.fec_emis), 1)), 
        SUBSTRING(DAYNAME(R.fec_emis), 2)) AS DIA

    FROM tbl_code C 
    inner join tbl_ruta R on (C.cod_venta_compra=R.codigo)
    LEFT JOIN ( SELECT doc_compras, placa, secuencia, destinatario, SUM(peso_kg) as peso_tn 
               from tbl_despacho group by doc_compras ORDER BY doc_compras ASC) B ON C.cod_venta_compra=B.doc_compras
    inner join tbl_auxiliar A on (A.placa=B.placa)
    inner join tbl_clientes CC on (CC.cod_cli=B.destinatario)
    WHERE (R.fec_emis>= fecha_1 and R.fec_emis<=fecha_2)
    group by R.codigo ORDER BY R.fec_emis DESC, B.placa, B.secuencia) as t;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataDetalladoFacturacionDespachoLimit;

DELIMITER $$
CREATE PROCEDURE dataDetalladoFacturacionDespachoLimit(
in desde int,
in per_pages int
)
BEGIN
    SET lc_time_names = 'es_ES';
    SET @a = 0;

    SELECT
        F.doc_venta as NRO_PEDIDO,
        F.cd_is as CANAL_DIST,
        F.transporte as NRO_TRANSPORTE,
        F.signatura as PLACA,
        F.destinatario as COD_CLIENTE,
        F.nombre_destinatario as RAZON_SOCIAL,
        SUM(F.impuesto_pos) as IMPUESTO_IGV,
        SUM(F.impuesto_fact_pos) as TOT_VALOR_VENTA,
        SUM(F.impuesto_pos) + SUM(F.impuesto_fact_pos) as TOT_VENTA_FACT
        
    FROM tbl_factura F  
    group by F.doc_venta limit desde,per_pages;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataSearchDetalladoFacturacionDespachoLimit;

DELIMITER $$
CREATE PROCEDURE dataSearchDetalladoFacturacionDespachoLimit(
in texto varchar(50)
)
BEGIN
    SET lc_time_names = 'es_ES';
    SET @a = 0;

    SELECT
        F.doc_venta as NRO_PEDIDO,
        F.cd_is as CANAL_DIST,
        F.transporte as NRO_TRANSPORTE,
        F.signatura as PLACA,
        F.destinatario as COD_CLIENTE,
        F.nombre_destinatario as RAZON_SOCIAL,
        SUM(F.impuesto_pos) as IMPUESTO_IGV,
        SUM(F.impuesto_fact_pos) as TOT_VALOR_VENTA,
        SUM(F.impuesto_pos) + SUM(F.impuesto_fact_pos) as TOT_VENTA_FACT
        
    FROM tbl_factura F
    where (F.doc_venta=texto OR F.transporte=texto OR F.signatura=texto OR F.destinatario=texto
    OR F.nombre_destinatario=texto)
    group by F.doc_venta;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataDetalladoFacturacionDespachoReport;

DELIMITER $$
CREATE PROCEDURE dataDetalladoFacturacionDespachoReport(
in fecha_1 date,
in fecha_2 date
)
BEGIN
    SET lc_time_names = 'es_ES';
    SET @a = 0;

    SELECT
        F.doc_venta as NRO_PEDIDO,
        F.fecha_doc as FECHA,
        F.cd_is as CANAL_DIST,
        F.transporte as NRO_TRANSPORTE,
        F.signatura as PLACA,
        F.destinatario as COD_CLIENTE,
        F.nombre_destinatario as RAZON_SOCIAL,
        SUM(F.impuesto_pos) as IMPUESTO_IGV,
        SUM(F.impuesto_fact_pos) as TOT_VALOR_VENTA,
        SUM(F.impuesto_pos) + SUM(F.impuesto_fact_pos) as TOT_VENTA_FACT
        
    FROM tbl_factura F  
    WHERE (F.fecha_doc>= fecha_1 and F.fecha_doc<=fecha_2)
    group by F.doc_venta;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataDetalladoDespachoProductosLimit;

DELIMITER $$
CREATE PROCEDURE dataDetalladoDespachoProductosLimit(
in desde int,
in per_pages int
)
BEGIN
    SET lc_time_names = 'es_ES';
    SET @a = 0;

    SELECT
        D.doc_compras as NRO_PEDIDO,
        D.placa as PLACA,
        D.destinatario as COD_CLIENTE,
        D.nom_dest_mercancias as NOMBRE_DESTINATARIO,
        SUM(D.peso_kg) as PESO,
        SUM(D.peso_kg)/1000 as PESO_2

    FROM tbl_despacho D  
    group by D.doc_compras limit desde,per_pages;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataSearchDetalladoDespachoProductosLimit;

DELIMITER $$
CREATE PROCEDURE dataSearchDetalladoDespachoProductosLimit(
in texto varchar(50)
)
BEGIN
    SET lc_time_names = 'es_ES';
    SET @a = 0;

    SELECT
        D.doc_compras as NRO_PEDIDO,
        D.placa as PLACA,
        D.destinatario as COD_CLIENTE,
        D.nom_dest_mercancias as NOMBRE_DESTINATARIO,
        SUM(D.peso_kg) as PESO,
        SUM(D.peso_kg)/1000 as PESO_2

    FROM tbl_despacho D
    where (D.doc_compras=texto OR D.placa=texto OR D.destinatario=texto OR D.nom_dest_mercancias=texto)
    group by D.doc_compras;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataDetalladoDespachoProductosReport;

DELIMITER $$
CREATE PROCEDURE dataDetalladoDespachoProductosReport(
in fecha_1 date,
in fecha_2 date
)
BEGIN
    SET lc_time_names = 'es_ES';
    SET @a = 0;

    SELECT 
        D.doc_compras as NRO_PEDIDO, 
        B.fecha as FECHA, 
        D.placa as PLACA, 
        D.destinatario as COD_CLIENTE, 
        D.nom_dest_mercancias as NOMBRE_DESTINATARIO, 
        SUM(D.peso_kg) as PESO, 
        SUM(D.peso_kg)/1000 as PESO_2 
    
    FROM tbl_despacho D LEFT JOIN ( SELECT codigo, fec_emis as fecha 
        from tbl_ruta group by codigo ) B ON B.codigo=D.doc_compras

    WHERE (B.fecha>= fecha_1 and B.fecha<=fecha_2)
    group by D.doc_compras;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataFacturacionDespachoProductosLimit;

DELIMITER $$
CREATE PROCEDURE dataFacturacionDespachoProductosLimit(
in desde int,
in per_pages int
)
BEGIN

    SELECT 
        F.doc_venta as COD_PEDIDO, 
        F.cd_is as CANAL_DIST, 
        F.transporte as N_TRANSPORTE, 
        F.signatura as PLACA, 
        F.destinatario as COD_CLI, 
        F.nombre_destinatario as RAZON_SOCIAL, 
        SUM(F.impuesto_pos) as IMPUESTO_IGV, 
        SUM(F.impuesto_fact_pos) as VALOR_VENTA, 
        ROUND(B.peso,2) as PESO 
        FROM tbl_factura F 
        LEFT JOIN ( SELECT doc_compras, SUM(peso_kg)/1000 as peso from tbl_despacho group by doc_compras ) B 
        ON B.doc_compras=F.doc_venta 
    group by F.doc_venta limit desde,per_pages;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataSearchFacturacionDespachoProductos;

DELIMITER $$
CREATE PROCEDURE dataSearchFacturacionDespachoProductos(
in texto varchar(50)
)
BEGIN

    SELECT 
        F.doc_venta as COD_PEDIDO, 
        F.cd_is as CANAL_DIST, 
        F.transporte as N_TRANSPORTE, 
        F.signatura as PLACA, 
        F.destinatario as COD_CLI, 
        F.nombre_destinatario as RAZON_SOCIAL, 
        SUM(F.impuesto_pos) as IMPUESTO_IGV, 
        SUM(F.impuesto_fact_pos) as VALOR_VENTA, 
        ROUND(B.peso,2) as PESO FROM tbl_factura F 
        LEFT JOIN ( SELECT doc_compras, SUM(peso_kg)/1000 as peso from tbl_despacho group by doc_compras ) B 
        ON B.doc_compras=F.doc_venta

    WHERE (F.doc_venta=texto OR F.transporte=texto OR F.signatura=texto OR F.destinatario=texto
    OR F.nombre_destinatario=texto)
    group by F.doc_venta;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataFacturacionDespachoProductosReport;

DELIMITER $$
CREATE PROCEDURE dataFacturacionDespachoProductosReport(
in fecha_1 date,
in fecha_2 date
)
BEGIN

    SELECT 
        F.doc_venta as COD_PEDIDO,
        F.fecha_doc as FECHA,
        F.cd_is as CANAL_DIST, 
        F.transporte as N_TRANSPORTE, 
        F.signatura as PLACA, 
        F.destinatario as COD_CLI, 
        F.nombre_destinatario as RAZON_SOCIAL, 
        SUM(F.impuesto_pos) as IMPUESTO_IGV, 
        SUM(F.impuesto_fact_pos) as VALOR_VENTA, 
        ROUND(B.peso,3) as PESO FROM tbl_factura F 
        LEFT JOIN ( SELECT doc_compras, SUM(peso_kg)/1000 as peso from tbl_despacho group by doc_compras ) B 
        ON B.doc_compras=F.doc_venta

    WHERE (F.fecha_doc>= fecha_1 and F.fecha_doc<=fecha_2)
    group by F.doc_venta;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataPivotConsolidado;

DELIMITER $$
CREATE PROCEDURE dataPivotConsolidado(
    in fecha_ date
)
BEGIN

    SET @sql = NULL;

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    SELECT
      GROUP_CONCAT(
        DISTINCT
        CONCAT('SUM(IF(`cd_is` = ', `cd_is`, ',impuesto_fact_pos,NULL)) AS VALOR_VENTA', `cd_is`, ',' 
        ,'SUM(IF(`cd_is` = ', `cd_is`, ',impuesto_pos,NULL)) AS IMPUESTO', `cd_is`,',' 
        ,'ROUND(SUM(IF(`cd_is` = ', `cd_is`, ',peso,NULL)),2) AS PESO', `cd_is`)
      ) INTO @sql

    FROM tbl_factura F 
    LEFT JOIN ( SELECT doc_compras, SUM(peso_kg)/1000 as peso from tbl_despacho group by doc_compras ) B 
    ON B.doc_compras=F.doc_venta;

    SET @sql = CONCAT('SELECT A.N_TRANSPORTE as transporte, A.PLACA as signatura, ', @sql, ', SUM(A.impuesto_fact_pos) as TOTAL_VALOR_VENTA, 
                            SUM(A.impuesto_pos) as TOTAL_IMP, SUM(A.PESO) as TOTAL_PESO
                            FROM (SELECT 
                            F.doc_venta as COD_PEDIDO, 
                            F.cd_is as cd_is, 
                            F.transporte as N_TRANSPORTE, 
                            F.signatura as PLACA, 
                            F.destinatario as COD_CLI, 
                            F.nombre_destinatario as RAZON_SOCIAL, 
                            SUM(F.impuesto_pos) as impuesto_pos, 
                            SUM(F.impuesto_fact_pos) as impuesto_fact_pos, 
                            ROUND(B.peso,4) as peso 
                            FROM tbl_factura F 
                            LEFT JOIN ( SELECT doc_compras, SUM(peso_kg)/1000 as peso from tbl_despacho group by doc_compras ) B 
                            ON B.doc_compras=F.doc_venta 
                        WHERE F.fecha_fact=@ff group by F.doc_venta) A
                    GROUP BY A.N_TRANSPORTE');

    PREPARE stmt FROM @sql;
    EXECUTE stmt;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataPivotConsolidadoTotales;

DELIMITER $$
CREATE PROCEDURE dataPivotConsolidadoTotales(
    in fecha_ date
)
BEGIN

    SET @sql = NULL;

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    SELECT
      GROUP_CONCAT(
        DISTINCT
        CONCAT('SUM(IF(`cd_is` = ', `cd_is`, ',impuesto_fact_pos,NULL)) AS VALOR_VENTA', `cd_is`, ',' 
        ,'SUM(IF(`cd_is` = ', `cd_is`, ',impuesto_pos,NULL)) AS IMPUESTO', `cd_is`,',' 
        ,'ROUND(SUM(IF(`cd_is` = ', `cd_is`, ',peso,NULL)),2) AS PESO', `cd_is`)
      ) INTO @sql

    FROM tbl_factura F 
    LEFT JOIN ( SELECT doc_compras, SUM(peso_kg)/1000 as peso from tbl_despacho group by doc_compras ) B 
    ON B.doc_compras=F.doc_venta;

    SET @sql = CONCAT('SELECT A.N_TRANSPORTE as transporte, A.PLACA as signatura, ', @sql, ', SUM(A.impuesto_fact_pos) as TOTAL_VALOR_VENTA, 
                            SUM(A.impuesto_pos) as TOTAL_IMP, SUM(A.PESO) as TOTAL_PESO
                            FROM (SELECT 
                            F.doc_venta as COD_PEDIDO, 
                            F.cd_is as cd_is, 
                            F.transporte as N_TRANSPORTE, 
                            F.signatura as PLACA, 
                            F.destinatario as COD_CLI, 
                            F.nombre_destinatario as RAZON_SOCIAL, 
                            SUM(F.impuesto_pos) as impuesto_pos, 
                            SUM(F.impuesto_fact_pos) as impuesto_fact_pos, 
                            ROUND(B.peso,4) as peso 
                            FROM tbl_factura F 
                            LEFT JOIN ( SELECT doc_compras, SUM(peso_kg)/1000 as peso from tbl_despacho group by doc_compras ) B 
                            ON B.doc_compras=F.doc_venta 
                        WHERE F.fecha_fact=@ff group by F.doc_venta) A');

    PREPARE stmt FROM @sql;
    EXECUTE stmt;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataReporteIRAjax;

DELIMITER $$
CREATE PROCEDURE dataReporteIRAjax(
in fecha_ date,
in total int,
in subtotal1 decimal(10,2),
in subtotal2 decimal(10,2)
)
BEGIN

    -- Version 1:

    /* 
    SELECT

        COUNT(P.cliente) as CLIENTES,
        SUM(P.total_peso) as TN_PROGRAMADO,
        SUM(P.total_soles_sin_igv) as VENTAS_SIN_IGV,
        SUM(P.total_soles_igv) as VENTAS_CON_IGV,
        COUNT(P.cliente)/total as CLIE_REPARTO,
        SUM(P.total_soles_sin_igv)/total as SOLES_REPARTO,
        subtotal1+subtotal2 as FLETE_DIA,
        ((subtotal1+subtotal2)/SUM(P.total_soles_sin_igv)) * 100 as COSTO_VENTA,
        SUM(P.total_soles_sin_igv)/COUNT(P.cliente) as DROP_SIZE,
        SUM(P.total_peso)/total as TN_CAMION

    FROM tbl_preysd080 P
    WHERE P.fec_ent=fecha_
    GROUP BY P.fec_ent;
    */

    -- Version 2:
    /*
    SELECT

        COUNT(P.cod_cliente) as CLIENTES,
        SUM(P.can_ped_tm) as TN_PROGRAMADO,
        SUM(P.importe) as VENTAS_SIN_IGV,
        SUM(P.importe) + SUM(P.importe)*0.18 as VENTAS_CON_IGV,
        COUNT(P.cod_cliente)/total as CLIE_REPARTO,
        SUM(P.importe)/total as SOLES_REPARTO,
        subtotal1+subtotal2 as FLETE_DIA,
        ((subtotal1+subtotal2)/SUM(P.importe)) * 100 as COSTO_VENTA,
        SUM(P.importe)/COUNT(P.cod_cliente) as DROP_SIZE,
        SUM(P.can_ped_tm)/total as TN_CAMION

    FROM tbl_ysd080 P
    WHERE P.fec_creacion=fecha_
    GROUP BY P.fec_creacion;*/

    -- Version 3:
    SELECT
        COUNT(L.CLIENTES) AS CLIENTES,
        SUM(L.TN_PROGRAMADO) as TN_PROGRAMADO,
        SUM(L.VENTAS_SIN_IGV) as VENTAS_SIN_IGV,
        SUM(L.VENTAS_CON_IGV) as VENTAS_CON_IGV,
        COUNT(L.CLIENTES)/total as CLIE_REPARTO,
        SUM(L.VENTAS_SIN_IGV)/total as SOLES_REPARTO,
        subtotal1+subtotal2 as FLETE_DIA,
        ((subtotal1+subtotal2)/SUM(L.VENTAS_SIN_IGV)) * 100 as COSTO_VENTA,
        SUM(L.VENTAS_SIN_IGV)/COUNT(L.CLIENTES) as DROP_SIZE,
        SUM(L.TN_PROGRAMADO)/total as TN_CAMION
    FROM 
        (
            SELECT 
                P.fec_creacion as FECHA,
                COUNT(P.cod_cliente) as CLIENTES,
                SUM(P.can_ped_tm) as TN_PROGRAMADO,
                SUM(P.importe) as VENTAS_SIN_IGV,
                SUM(P.importe) + SUM(P.importe)*0.18 as VENTAS_CON_IGV
            FROM tbl_ysd080 P 
            WHERE P.fec_creacion=fecha_
            GROUP BY P.pedido
        ) L

    GROUP BY L.FECHA;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS datacodllamadaPivot;
DELIMITER $$
CREATE PROCEDURE datacodllamadaPivot(
in fecha_ date
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    -- Version 1

    /*
    SELECT
        P.codigo_llamada as CODLLAMADA,
		P.dia_llamada as DIALLAMADA
    FROM tbl_preysd080 P
    WHERE P.fec_ent=@ff and P.codigo_llamada IS NOT NULL
    GROUP BY P.codigo_llamada;*/

    -- Version 2

    SELECT 
        L.CODLLAMADA as CODLLAMADA,
		L.DIALLAMADA as DIALLAMADA
    FROM
        (
            SELECT 
                Y.*,
                CLL.DIA_LLAMADA as CODLLAMADA,
                CLL.DESCRIPCION as DIALLAMADA
            FROM tbl_ysd080 Y 

            LEFT JOIN
            (
                SELECT 
                    CL.cod_cli as COD_CLIENTE,
                    CL.dia_llamada as DIA_LLAMADA,
                    A.DESCRIPCION as DESCRIPCION
                FROM tbl_clientes CL

                LEFT JOIN

                    (
                        SELECT 
                            at_cliente_dias as CLIENTE_DIAS,
                            at_cliente_dias_descrip as DESCRIPCION
                        FROM tbl_atencion
                    ) A

                ON CL.dia_llamada=A.CLIENTE_DIAS
            ) CLL
            ON Y.cod_cliente=CLL.COD_CLIENTE

            WHERE Y.fec_creacion=@ff
            GROUP BY Y.pedido

        ) L
    
    WHERE L.CODLLAMADA IS NOT NULL
    GROUP BY L.CODLLAMADA;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataPivotreporteir;
DELIMITER $$
CREATE PROCEDURE dataPivotreporteir(
in fecha_ date
)
BEGIN

    DECLARE validacion INT DEFAULT 0;

    SET @sql = NULL;
    SET @sqltwo = NULL;
    SET @sqlthree = NULL;
    SET @sqlfour = NULL;
    
    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    -- Version 1

    /*

    SELECT
        COUNT(*) into validacion FROM tbl_preysd080 P

    WHERE P.fec_ent=@ff and P.codigo_llamada IS NOT NULL
    GROUP BY P.fec_ent;

    IF validacion>0 THEN

        SELECT
        GROUP_CONCAT(
            DISTINCT
            CONCAT('SUM(IF(`codigo_llamada` = ', `codigo_llamada`, ',total_soles_sin_igv,NULL)) AS DIA_', `codigo_llamada`)
        ) INTO @sql

        FROM tbl_preysd080 P
        WHERE P.fec_ent=@ff;


        SELECT
        GROUP_CONCAT(
            DISTINCT
            CONCAT('SUM(IF(`codigo_llamada` = ', `codigo_llamada`, ',total_soles_igv,NULL)) AS DIA_', `codigo_llamada`)
        ) INTO @sqltwo

        FROM tbl_preysd080 P
        WHERE P.fec_ent=@ff;


        SELECT
        GROUP_CONCAT(
            DISTINCT
            CONCAT('SUM(IF(`codigo_llamada` = ', `codigo_llamada`, ',total_peso,NULL)) AS DIA_', `codigo_llamada`)
        ) INTO @sqlthree

        FROM tbl_preysd080 P
        WHERE P.fec_ent=@ff;


        SELECT
        GROUP_CONCAT(
            DISTINCT
            CONCAT('COUNT(IF(`codigo_llamada` = ', `codigo_llamada`, ',cliente,NULL)) AS DIA_', `codigo_llamada`)
        ) INTO @sqlfour

        FROM tbl_preysd080 P
        WHERE P.fec_ent=@ff;


        SET @sql = CONCAT(' 

                            (SELECT "TOT. CLIE. PREVENTA" as ATENCION, ', @sqlfour, ', COUNT(cliente) as TOTAL
                            FROM tbl_preysd080 P
                            
                            WHERE P.fec_ent=@ff and P.codigo_llamada IS NOT NULL
                            GROUP BY P.fec_ent)

                            UNION ALL
        
                            (SELECT "TOT. VENTA - [IGV]" as ATENCION, ', @sql, ', SUM(total_soles_sin_igv) as TOTAL
                            FROM tbl_preysd080 P
                            
                            WHERE P.fec_ent=@ff and P.codigo_llamada IS NOT NULL
                            GROUP BY P.fec_ent)
                            
                            UNION ALL
                            
                            (SELECT "TOT. VENTA + [IGV]" as ATENCION, ', @sqltwo, ', SUM(total_soles_igv) as TOTAL
                            FROM tbl_preysd080 P
                            
                            WHERE P.fec_ent=@ff and P.codigo_llamada IS NOT NULL
                            GROUP BY P.fec_ent)
                            
                            UNION ALL

                            (SELECT "TOTAL PESO" as ATENCION,  ', @sqlthree, ', SUM(total_peso) as TOTAL
                            FROM tbl_preysd080 P
                            
                            WHERE P.fec_ent=@ff and P.codigo_llamada IS NOT NULL
                            GROUP BY P.fec_ent)
                            ');

        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    END IF;
    */

    -- Version 2

    DROP TEMPORARY TABLE IF EXISTS tmp;
    CREATE TEMPORARY TABLE tmp(
        id int NOT NULL AUTO_INCREMENT,
        fec_ent date,
        cliente varchar(50),
        total_peso decimal(10,3),
        total_soles_sin_igv decimal(10,3),
        total_soles_igv decimal(10,3),
        codigo_llamada varchar(30),
        dia_llamada varchar(30),
        PRIMARY KEY(id)
    );

    INSERT INTO tmp(fec_ent, cliente, total_peso, total_soles_sin_igv, total_soles_igv, codigo_llamada, dia_llamada)
    SELECT 
        Y.fec_creacion as FECHA, 
        Y.cod_cliente as CLIENTE,
        SUM(Y.can_ped_tm) as PESO, 
        SUM(Y.importe) as TOTAL_SOLES_SIN_IGV, 
        SUM(Y.importe) + SUM(Y.importe)*0.18 as TOTAL_SOLES_IGV, 
        CLL.DIA_LLAMADA as DIA_LLAMADA,
        CLL.DESCRIPCION as DESCRIPCION
    FROM tbl_ysd080 Y 

    LEFT JOIN
    (
        SELECT 
            CL.cod_cli as COD_CLIENTE,
            CL.dia_llamada as DIA_LLAMADA,
            A.DESCRIPCION as DESCRIPCION
        FROM tbl_clientes CL

        LEFT JOIN

            (
                SELECT 
                    at_cliente_dias as CLIENTE_DIAS,
                    at_cliente_dias_descrip as DESCRIPCION
                FROM tbl_atencion
            ) A

        ON CL.dia_llamada=A.CLIENTE_DIAS
    ) CLL
    ON Y.cod_cliente=CLL.COD_CLIENTE

    WHERE Y.fec_creacion=@ff
    GROUP BY Y.pedido;


    SELECT
        COUNT(*) into validacion FROM tmp T
    WHERE T.fec_ent=@ff and T.codigo_llamada IS NOT NULL
    GROUP BY T.fec_ent;


    IF validacion>0 THEN

        SELECT
        GROUP_CONCAT(
            DISTINCT
            CONCAT('SUM(IF(`codigo_llamada` = ', `codigo_llamada`, ',total_soles_sin_igv,NULL)) AS DIA_', `codigo_llamada`)
        ) INTO @sql

        FROM tmp P
        WHERE P.fec_ent=@ff;


        SELECT
        GROUP_CONCAT(
            DISTINCT
            CONCAT('SUM(IF(`codigo_llamada` = ', `codigo_llamada`, ',total_soles_igv,NULL)) AS DIA_', `codigo_llamada`)
        ) INTO @sqltwo

        FROM tmp P
        WHERE P.fec_ent=@ff;


        SELECT
        GROUP_CONCAT(
            DISTINCT
            CONCAT('SUM(IF(`codigo_llamada` = ', `codigo_llamada`, ',total_peso,NULL)) AS DIA_', `codigo_llamada`)
        ) INTO @sqlthree

        FROM tmp P
        WHERE P.fec_ent=@ff;


        SELECT
        GROUP_CONCAT(
            DISTINCT
            CONCAT('COUNT(IF(`codigo_llamada` = ', `codigo_llamada`, ',cliente,NULL)) AS DIA_', `codigo_llamada`)
        ) INTO @sqlfour

        FROM tmp P
        WHERE P.fec_ent=@ff;


        SET @sql = CONCAT(' 

                            (SELECT "TOT. CLIE. PREVENTA" as ATENCION, ', @sqlfour, ', COUNT(cliente) as TOTAL
                            FROM tmp P
                            
                            WHERE P.fec_ent=@ff and P.codigo_llamada IS NOT NULL
                            GROUP BY P.fec_ent)

                            UNION ALL
        
                            (SELECT "TOT. VENTA - [IGV]" as ATENCION, ', @sql, ', SUM(total_soles_sin_igv) as TOTAL
                            FROM tmp P
                            
                            WHERE P.fec_ent=@ff and P.codigo_llamada IS NOT NULL
                            GROUP BY P.fec_ent)
                            
                            UNION ALL
                            
                            (SELECT "TOT. VENTA + [IGV]" as ATENCION, ', @sqltwo, ', SUM(total_soles_igv) as TOTAL
                            FROM tmp P
                            
                            WHERE P.fec_ent=@ff and P.codigo_llamada IS NOT NULL
                            GROUP BY P.fec_ent)
                            
                            UNION ALL

                            (SELECT "TOTAL PESO" as ATENCION,  ', @sqlthree, ', SUM(total_peso) as TOTAL
                            FROM tmp P
                            
                            WHERE P.fec_ent=@ff and P.codigo_llamada IS NOT NULL
                            GROUP BY P.fec_ent)
                            ');

        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataCompuestoReporteIR;

DELIMITER $$
CREATE PROCEDURE dataCompuestoReporteIR(
in fecha_ date
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    -- VERSION 1
    /*
    SELECT

        P.region as REGION,
        CC.LOCALIDAD as LOCALIDADES,
        P.supervisor_ventas as SUPERVISOR,
        COUNT(*) as CLIENTES,
        SUM(P.total_peso) as TOTAL_PESO,
        SUM(P.total_soles_sin_igv) as TOT_VENTA_SIN_IGV,
        SUM(P.total_soles_igv) as TOT_VENTA_CON_IGV

    FROM tbl_preysd080 P

    LEFT JOIN

        (
            SELECT 
                C.cod_cli as CODIGO,
                C.distrito as LOCALIDAD
            FROM tbl_clientes C
        ) CC

    ON P.cliente=CC.CODIGO

    WHERE P.fec_ent=@ff
    GROUP BY P.region, CC.LOCALIDAD, P.supervisor_ventas;*/

    -- VERSION 2

    SELECT 
        L.REGION as REGION,
        CC.LOCALIDAD as LOCALIDADES,
        "" as SUPERVISOR,
        COUNT(L.CLIENTE) AS CLIENTES,
        SUM(L.PESO) as TOTAL_PESO,
        SUM(L.TOTAL_SOLES_SIN_IGV) as TOT_VENTA_SIN_IGV,
        SUM(L.TOTAL_SOLES_IGV) as TOT_VENTA_CON_IGV
    FROM
        (
            SELECT 
                Y.region as REGION,
                Y.fec_creacion as FECHA, 
                Y.cod_cliente as CLIENTE,
                SUM(Y.can_ped_tm) as PESO, 
                SUM(Y.importe) as TOTAL_SOLES_SIN_IGV, 
                SUM(Y.importe) + SUM(Y.importe)*0.18 as TOTAL_SOLES_IGV
            FROM tbl_ysd080 Y 

            WHERE Y.fec_creacion=@ff
            GROUP BY Y.pedido
        ) L
    
    LEFT JOIN

        (
            SELECT 
                C.cod_cli as CODIGO,
                C.distrito as LOCALIDAD
            FROM tbl_clientes C
        ) CC

    ON L.CLIENTE=CC.CODIGO
    WHERE L.FECHA=@ff
    GROUP BY L.REGION, CC.LOCALIDAD;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataCompuestoReporteIR_Totales;

DELIMITER $$
CREATE PROCEDURE dataCompuestoReporteIR_Totales(
in fecha_ date
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    SELECT

        COUNT(*) as CLIENTES,
        SUM(P.total_peso) as TOTAL_PESO,
        SUM(P.total_soles_sin_igv) as TOT_VENTA_SIN_IGV,
        SUM(P.total_soles_igv) as TOT_VENTA_CON_IGV

    FROM tbl_preysd080 P

    LEFT JOIN

        (
            SELECT 
                C.cod_cli as CODIGO,
                C.distrito as LOCALIDAD
            FROM tbl_clientes C
        ) CC

    ON P.cliente=CC.CODIGO

    WHERE P.fec_ent=@ff;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataDuplicadosDia;

DELIMITER $$
CREATE PROCEDURE dataDuplicadosDia(
    in fecha_ date,
    in desde int,
    in per_pages int
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    IF per_pages=0 THEN 
    
        SELECT 
            PP.*,
            CT.CONTEO as duplicado
        FROM tbl_preysd080 PP

        LEFT JOIN

            (
                SELECT 
                    P.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_preysd080 P
                WHERE P.fec_ent=@ff
                GROUP BY P.cliente
            ) CT

        ON PP.cliente=CT.CLIENTE
        WHERE CT.CONTEO>1 and PP.fec_ent=@ff;

    ELSE

        SELECT 
            PP.*,
            CT.CONTEO as duplicado
        FROM tbl_preysd080 PP

        LEFT JOIN

            (
                SELECT 
                    P.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_preysd080 P
                WHERE P.fec_ent=@ff
                GROUP BY P.cliente
            ) CT

        ON PP.cliente=CT.CLIENTE
        WHERE CT.CONTEO>1 and PP.fec_ent=@ff
        ORDER BY PP.cliente ASC
        LIMIT desde,per_pages;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataReincidenteDia;

DELIMITER $$
CREATE PROCEDURE dataReincidenteDia(
    in fecha_ date,
    in desde int,
    in per_pages int
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;
    
    IF per_pages=0 THEN 
    
        SELECT 
            PP.*,
            CT.CONTEO as duplicado
        FROM tbl_preysd080 PP

        LEFT JOIN

            (
                SELECT 
                    P.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_preysd080 P
                WHERE P.fec_ent=@ff
                GROUP BY P.cliente
            ) CT

        ON PP.cliente=CT.CLIENTE
        WHERE PP.reincidente>3 and PP.fec_ent=@ff;

    ELSE

        SELECT 
            PP.*,
            CT.CONTEO as duplicado
        FROM tbl_preysd080 PP

        LEFT JOIN

            (
                SELECT 
                    P.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_preysd080 P
                WHERE P.fec_ent=@ff
                GROUP BY P.cliente
            ) CT

        ON PP.cliente=CT.CLIENTE
        WHERE PP.reincidente>3 and PP.fec_ent=@ff
        ORDER BY PP.cliente ASC
        LIMIT desde,per_pages;

    END IF;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataPedidosVolumen;

DELIMITER $$
CREATE PROCEDURE dataPedidosVolumen(
    in fecha_ date,
    in desde int,
    in per_pages int
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    IF per_pages=0 THEN 
    
        SELECT 
            PP.*,
            CT.CONTEO as duplicado
        FROM tbl_preysd080 PP

        LEFT JOIN

            (
                SELECT 
                    P.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_preysd080 P
                WHERE P.fec_ent=@ff
                GROUP BY P.cliente
            ) CT

        ON PP.cliente=CT.CLIENTE
        WHERE PP.pedido_volumen="SI" and PP.fec_ent=@ff;

    ELSE

        SELECT 
            PP.*,
            CT.CONTEO as duplicado
        FROM tbl_preysd080 PP

        LEFT JOIN

            (
                SELECT 
                    P.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_preysd080 P
                WHERE P.fec_ent=@ff
                GROUP BY P.cliente
            ) CT

        ON PP.cliente=CT.CLIENTE
        WHERE PP.pedido_volumen="SI" and PP.fec_ent=@ff
        ORDER BY PP.cliente ASC
        LIMIT desde,per_pages;

    END IF;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataDiaDeLlamadaVisita;

DELIMITER $$
CREATE PROCEDURE dataDiaDeLlamadaVisita(
    in fecha_ date,
    in desde int,
    in per_pages int
)
BEGIN

    DECLARE diaOne varchar(50) DEFAULT "";
    DECLARE diaTwo varchar(50) DEFAULT "";

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    SET @fff= DATE_SUB(@ff,INTERVAL 1 DAY);

    -- REGLAS DE NEGOCIO SEGÚN TABLA DE BITACORA
    IF UPPER(CONCAT(UCASE(LEFT(DAYNAME(@fff), 1)), SUBSTRING(DAYNAME(@fff), 2))) = "MONDAY" OR 
        UPPER(CONCAT(UCASE(LEFT(DAYNAME(@fff), 1)), SUBSTRING(DAYNAME(@fff), 2))) = "THURSDAY" THEN
        SET diaOne="MONDAY";
        SET diaTwo="THURSDAY";

    ELSEIF UPPER(CONCAT(UCASE(LEFT(DAYNAME(@fff), 1)), SUBSTRING(DAYNAME(@fff), 2))) = "TUESDAY" OR
        UPPER(CONCAT(UCASE(LEFT(DAYNAME(@fff), 1)), SUBSTRING(DAYNAME(@fff), 2))) = "FRIDAY" THEN
        SET diaOne="TUESDAY";
        SET diaTwo="FRIDAY";

    ELSEIF UPPER(CONCAT(UCASE(LEFT(DAYNAME(@fff), 1)), SUBSTRING(DAYNAME(@fff), 2))) = "WEDNESDAY" OR
        UPPER(CONCAT(UCASE(LEFT(DAYNAME(@fff), 1)), SUBSTRING(DAYNAME(@fff), 2))) = "SATURDAY" THEN
        SET diaOne="WEDNESDAY";
        SET diaTwo="SATURDAY";

    END IF;
    
    IF per_pages=0 THEN 

        SELECT 
            PP.*,
            CT.CONTEO as duplicado
        FROM tbl_preysd080 PP

        LEFT JOIN

            (
                SELECT 
                    P.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_preysd080 P
                WHERE P.fec_ent=@ff
                GROUP BY P.cliente
            ) CT
        ON PP.cliente=CT.CLIENTE

        LEFT JOIN
            (
                SELECT 
                    A.at_cliente_dias as COD_LLAMADA, 
                    A.at_cliente_dias_descrip_2 as DIA

                FROM tbl_atencion A
            ) AA
        ON PP.codigo_llamada=AA.COD_LLAMADA

        WHERE (AA.DIA!=diaOne and AA.DIA!=diaTwo) and (PP.fec_ent=@ff and AA.COD_LLAMADA!="0000000");

    ELSE

        SELECT 
            PP.*,
            CT.CONTEO as duplicado
        FROM tbl_preysd080 PP

        LEFT JOIN

            (
                SELECT 
                    P.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_preysd080 P
                WHERE P.fec_ent=@ff
                GROUP BY P.cliente
            ) CT
        ON PP.cliente=CT.CLIENTE

        LEFT JOIN
            (
                SELECT 
                    A.at_cliente_dias as COD_LLAMADA, 
                    A.at_cliente_dias_descrip_2 as DIA

                FROM tbl_atencion A
            ) AA
        ON PP.codigo_llamada=AA.COD_LLAMADA

        WHERE (AA.DIA!=diaOne and AA.DIA!=diaTwo) and (PP.fec_ent=@ff and AA.COD_LLAMADA!="0000000")
        LIMIT desde,per_pages;

    END IF;

END$$
DELIMITER ;