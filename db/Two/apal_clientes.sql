/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Anderson Fuentes
 * Created: 26 may. 2022
 */

-- MODULE: CLIENTES

DROP PROCEDURE IF EXISTS dataPedidosLimit;

DELIMITER $$
CREATE PROCEDURE dataPedidosLimit(
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
    WHERE R.fec_emis=DATE(DATE_SUB( NOW() , INTERVAL 4 HOUR ))
    group by R.codigo ORDER BY R.fec_emis DESC limit desde,per_pages) as t;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataSearchPedidos;

DELIMITER $$
CREATE PROCEDURE dataSearchPedidos(
    in texto varchar(50)
)
BEGIN

    SET lc_time_names = 'es_ES';

    SELECT 
        t.*, 
        t.VALOR_CON_IGV as VALOR_CON_IGV_OF,
        t.PESO_TN as PESO_TN_OF
    FROM
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
        WHERE (B.destinatario= texto or CC.nombre= texto) and R.fec_emis=DATE(DATE_SUB( NOW() , INTERVAL 4 HOUR ))
        group by R.codigo ORDER BY R.fec_emis DESC
        ) 
    AS t
    GROUP BY t.DESTINATARIO;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataCountPedidos;

DELIMITER $$
CREATE PROCEDURE dataCountPedidos()
BEGIN

    SELECT COUNT(*) as total FROM (SELECT COUNT(*)
    FROM tbl_code C 
    inner join tbl_ruta R on (C.cod_venta_compra=R.codigo)
    LEFT JOIN ( SELECT doc_compras, placa, secuencia, destinatario, SUM(peso_kg) as peso_tn 
               from tbl_despacho group by doc_compras ORDER BY doc_compras ASC) B ON C.cod_venta_compra=B.doc_compras
    inner join tbl_auxiliar A on (A.placa=B.placa)
    inner join tbl_clientes CC on (CC.cod_cli=B.destinatario)
    WHERE R.fec_emis=DATE(DATE_SUB( NOW() , INTERVAL 4 HOUR ))
    group by R.codigo ORDER BY R.fec_emis DESC) A;

END$$
DELIMITER ;

-- clientes/historial

DROP PROCEDURE IF EXISTS dataDEV_YSD080_One;

DELIMITER $$
CREATE PROCEDURE dataDEV_YSD080_One(
    in desde int,
    in per_pages int
)
BEGIN

    SELECT A.*, 
    (
            CASE WHEN A.ZDA IS NULL THEN 0 ELSE A.ZDA END + 
            CASE WHEN A.ZDP IS NULL THEN 0 ELSE A.ZDP END
        )  as TOTAL_GENERAL FROM 

    (SELECT 
        YD.fecha_entrega as FEC_ENT, 
        YD.cod_cliente as CLIENTE, 
        YD.razon_social as RAZON_SOCIAL, 
        YD.des_ped as DESCRIPCION_MOTIVO, 
        YD.region as REGION, 
        SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
        SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

    FROM tbl_ysd080_dev YD 
    GROUP BY YD.fecha_entrega, YD.cod_cliente
    LIMIT desde,per_pages
    ) A;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataHistorialPaginators;

DELIMITER $$
CREATE PROCEDURE dataHistorialPaginators()
BEGIN

    SELECT COUNT(*) as total FROM 
    (SELECT 
        YD.fecha_entrega as FEC_ENT, 
        YD.cod_cliente as CLIENTE, 
        YD.razon_social as RAZON_SOCIAL, 
        YD.des_ped as DESCRIPCION_MOTIVO, 
        YD.region as REGION, 
        SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
        SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

    FROM tbl_ysd080_dev YD 
    GROUP BY YD.fecha_entrega, YD.cod_cliente
    ) A;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataDEV_YSD080_One_Search;

DELIMITER $$
CREATE PROCEDURE dataDEV_YSD080_One_Search(
    in texto varchar(50)
)
BEGIN

    SELECT A.*, 
    (
            CASE WHEN A.ZDA IS NULL THEN 0 ELSE A.ZDA END + 
            CASE WHEN A.ZDP IS NULL THEN 0 ELSE A.ZDP END
        )  as TOTAL_GENERAL FROM 

    (SELECT 
        YD.fecha_entrega as FEC_ENT, 
        YD.cod_cliente as CLIENTE, 
        YD.razon_social as RAZON_SOCIAL, 
        YD.des_ped as DESCRIPCION_MOTIVO, 
        YD.region as REGION, 
        SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
        SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

    FROM tbl_ysd080_dev YD
    WHERE YD.fecha_entrega=texto OR YD.cod_cliente=texto OR YD.razon_social=texto
    GROUP BY YD.fecha_entrega, YD.cod_cliente) A;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataDEV_YSD080_One_Totales;

DELIMITER $$
CREATE PROCEDURE dataDEV_YSD080_One_Totales(
    in texto varchar(50),
    in desde int,
    in per_pages int
)
BEGIN

    IF texto IS NULL OR texto="" THEN

        SELECT 
            SUM(RR.ZDA) as ZDA,
            SUM(RR.ZDP) as ZDP,
            SUM(RR.TOTAL_GENERAL) AS TOTAL_GENERAL

        FROM 
            (
                SELECT 
                    A.*, 
                    (
                        CASE WHEN A.ZDA IS NULL THEN 0 ELSE A.ZDA END + 
                        CASE WHEN A.ZDP IS NULL THEN 0 ELSE A.ZDP END
                    )  as TOTAL_GENERAL 

                FROM 

                    (SELECT 
                        YD.fecha_entrega as FEC_ENT, 
                        YD.cod_cliente as CLIENTE, 
                        YD.razon_social as RAZON_SOCIAL, 
                        YD.des_ped as DESCRIPCION_MOTIVO, 
                        YD.region as REGION, 
                        SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
                        SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

                    FROM tbl_ysd080_dev YD 
                    GROUP BY YD.fecha_entrega, YD.cod_cliente
                    LIMIT desde,per_pages
                    ) 
                A
            ) 
        RR;

    ELSE

        SELECT A.*, 
        (
                CASE WHEN A.ZDA IS NULL THEN 0 ELSE A.ZDA END + 
                CASE WHEN A.ZDP IS NULL THEN 0 ELSE A.ZDP END
            )  as TOTAL_GENERAL 

        FROM 

            (SELECT 
                YD.fecha_entrega as FEC_ENT, 
                YD.cod_cliente as CLIENTE, 
                YD.razon_social as RAZON_SOCIAL, 
                YD.des_ped as DESCRIPCION_MOTIVO, 
                YD.region as REGION, 
                SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
                SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

            FROM tbl_ysd080_dev YD
            WHERE YD.fecha_entrega=texto OR YD.cod_cliente=texto OR YD.razon_social=texto
            ) 
        A;

    END IF;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataDEV_YSD080_One_Report;

DELIMITER $$
CREATE PROCEDURE dataDEV_YSD080_One_Report(
    in fecha_1 date,
    in fecha_2 date,
    in codcliente varchar(50)
)
BEGIN

    IF fecha_1 IS NULL OR fecha_1="" THEN

        SELECT A.*, 
        (
                CASE WHEN A.ZDA IS NULL THEN 0 ELSE A.ZDA END + 
                CASE WHEN A.ZDP IS NULL THEN 0 ELSE A.ZDP END
            )  as TOTAL_GENERAL FROM 

        (SELECT 
            YD.fecha_entrega as FEC_ENT, 
            YD.cod_cliente as CLIENTE, 
            YD.razon_social as RAZON_SOCIAL, 
            YD.des_ped as DESCRIPCION_MOTIVO, 
            YD.region as REGION, 
            SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
            SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

        FROM tbl_ysd080_dev YD
        WHERE (YD.cod_cliente= codcliente)
        GROUP BY YD.fecha_entrega, YD.cod_cliente) A;

    ELSE

        SELECT A.*, 
        (
                CASE WHEN A.ZDA IS NULL THEN 0 ELSE A.ZDA END + 
                CASE WHEN A.ZDP IS NULL THEN 0 ELSE A.ZDP END
            )  as TOTAL_GENERAL FROM 

        (SELECT 
            YD.fecha_entrega as FEC_ENT, 
            YD.cod_cliente as CLIENTE, 
            YD.razon_social as RAZON_SOCIAL, 
            YD.des_ped as DESCRIPCION_MOTIVO, 
            YD.region as REGION, 
            SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
            SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

        FROM tbl_ysd080_dev YD
        WHERE (YD.fecha_entrega>= fecha_1 and YD.fecha_entrega<=fecha_2)
        GROUP BY YD.fecha_entrega, YD.cod_cliente) A;

    END IF;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataDEV_YSD080_One_Report_Totales;

DELIMITER $$
CREATE PROCEDURE dataDEV_YSD080_One_Report_Totales(
    in fecha_1 date,
    in fecha_2 date,
    in codcliente varchar(50)
)
BEGIN

    IF fecha_1 IS NULL OR fecha_1="" THEN

        SELECT A.*, 
        (
                CASE WHEN A.ZDA IS NULL THEN 0 ELSE A.ZDA END + 
                CASE WHEN A.ZDP IS NULL THEN 0 ELSE A.ZDP END
            )  as TOTAL_GENERAL 
        FROM 

            (SELECT 
                YD.fecha_entrega as FEC_ENT, 
                YD.cod_cliente as CLIENTE, 
                YD.razon_social as RAZON_SOCIAL, 
                YD.des_ped as DESCRIPCION_MOTIVO, 
                YD.region as REGION, 
                SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
                SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

            FROM tbl_ysd080_dev YD
            WHERE (YD.cod_cliente= codcliente)
            ) 
        A;

    ELSE

        SELECT A.*, 
        (
                CASE WHEN A.ZDA IS NULL THEN 0 ELSE A.ZDA END + 
                CASE WHEN A.ZDP IS NULL THEN 0 ELSE A.ZDP END
            )  as TOTAL_GENERAL 
        FROM 

            (SELECT 
                YD.fecha_entrega as FEC_ENT, 
                YD.cod_cliente as CLIENTE, 
                YD.razon_social as RAZON_SOCIAL, 
                YD.des_ped as DESCRIPCION_MOTIVO, 
                YD.region as REGION, 
                SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
                SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

            FROM tbl_ysd080_dev YD
            WHERE (YD.fecha_entrega>= fecha_1 and YD.fecha_entrega<=fecha_2)
            ) 
        A;

    END IF;

END$$
DELIMITER ;