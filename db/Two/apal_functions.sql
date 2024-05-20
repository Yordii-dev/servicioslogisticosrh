/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Anderson Fuentes
 * Created: 26 may. 2022
 */

DROP FUNCTION IF EXISTS totales1;
DELIMITER $$
CREATE FUNCTION `totales1`() RETURNS DECIMAL
BEGIN

    DECLARE tot1 DECIMAL(10,2) DEFAULT 1.1;

    SELECT 
        SUM(S.DEVOLUCIONES_TOTALES) into tot1

    FROM tbl_resumen_dia S;

    RETURN (tot1);

END$$
DELIMITER ;


DROP FUNCTION IF EXISTS totales2;
DELIMITER $$
CREATE FUNCTION `totales2`() RETURNS DECIMAL
BEGIN

    DECLARE tot2 DECIMAL(10,2) DEFAULT 1.1;

    SELECT 
        SUM(S.DEVOLUCIONES_PARCIALES) into tot2

    FROM tbl_resumen_dia S;

    RETURN (tot2);

END$$
DELIMITER ;


-- OBSOLETO: FUNCION PARA DUPLICADOS EN QUERY RESUMENDIA

DROP FUNCTION IF EXISTS duplicadoresumendia;
DELIMITER $$
CREATE FUNCTION `duplicadoresumendia`(
    cod_cliente varchar(50)
) RETURNS INT
BEGIN

    DECLARE conteo INT DEFAULT 0;

    SELECT 
        COUNT(*) into conteo
    FROM
        (
            SELECT
                F.doc_venta as PEDIDO, 
                F.fecha_fact as FEC_ENT,
                F.destinatario as CLIENTE,
                Y.razon_social as RAZON,
                Y.region as REGION,
                Y.can_ped_tm as TOTAL_PESO,
                Y.importe as TOTAL_SOLES_SIN_IGV,
                SUM(F.impuesto_fact_pos) as TOTAL_FACT_SIN_IGV, 
                SUM(F.impuesto_fact_pos) + SUM(F.impuesto_pos) as TOTAL_FACT_CON_IGV,
                C.COD_USUARIO_FINAL as COD_TLV,
                C.COD_GESTOR as COD_GESTOR,
                C.SUPERVISOR_VENTAS as SUPERVISOR,
                D.DESCRIPCION_MOTIVO as MOTIVOS_DEL_DIA,
                D.ZDA as DEVOLUCIONES_TOTALES,
                D.ZDP as DEVOLUCIONES_PARCIALES

            FROM tbl_factura F

            LEFT JOIN 

                (
                    SELECT 
                        pedido as PEDIDO, 
                        fec_creacion as fec_creacion, 
                        cod_cliente as cod_cliente, 
                        razon_social as razon_social, 
                        region as region, 
                        SUM(can_ped_tm) as can_ped_tm, 
                        SUM(importe) as importe

                    FROM tbl_ysd080 
                    GROUP BY pedido

                ) Y

            ON F.doc_venta=Y.PEDIDO

            LEFT JOIN

                (
                    SELECT 
                        Y.pedido as PEDIDO, 
                        Y.fec_creacion as FEC_ENT, 
                        Y.cod_cliente as CLIENTE, 
                        Y.razon_social as RAZON_SOCIAL, 
                        Y.region as REGION, 
                        SUM(Y.can_ped_tm) as TOTAL_PESO, 
                        SUM(Y.importe) as TOTAL_SOLES_SIN_IGV, 
                        SUM(Y.importe) + SUM(Y.importe)*0.18 as TOTAL_SOLES_IGV, 
                        B.usuario_final as COD_USUARIO_FINAL, 
                        C.cod_rut as COD_GESTOR,
                        C.supervisor as SUPERVISOR_VENTAS

                    FROM tbl_ysd080 Y 
                    LEFT JOIN ( SELECT num_pedido, usuario_final from tbl_tlv_ped ) B 
                    ON B.num_pedido=Y.pedido
                    LEFT JOIN ( SELECT raz, cod_rut, supervisor from tbl_dat_gest ) C 
                    ON C.raz=B.usuario_final

                    GROUP BY Y.pedido
                ) C

            ON F.doc_venta= C.PEDIDO

            LEFT JOIN

                (
                    SELECT 
                        YD.fecha_entrega as FEC_ENT, 
                        YD.cod_cliente as CLIENTE, 
                        YD.razon_social as RAZON_SOCIAL, 
                        YD.des_ped as DESCRIPCION_MOTIVO, 
                        YD.region as REGION,
                        CONCAT(REPLACE(YD.fecha_entrega, '-', '' ),YD.cod_cliente) as IDCONCAT,
                        SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
                        SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

                    FROM tbl_ysd080_dev YD 
                    GROUP BY YD.fecha_entrega, YD.cod_cliente
                ) D

            ON F.id_concat=D.IDCONCAT

            WHERE F.destinatario=cod_cliente

            GROUP BY F.doc_venta
        )

    AS V;

    RETURN (conteo);

END$$
DELIMITER ;



-- FUNCION PARA RETORNAR EL TOTAL DEL QUERY dataDISTRIBUCION_general en DASHBOARD

DROP FUNCTION IF EXISTS totalDistribucion_general;
DELIMITER $$
CREATE FUNCTION `totalDistribucion_general`() RETURNS DECIMAL
BEGIN

    DECLARE tot2 DECIMAL(10,2) DEFAULT 1.1;

    SELECT

        SUM(G.TOTAL_GENERAL) into tot2

    FROM

    (
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
        GROUP BY YD.fecha_entrega, YD.cod_cliente) A
    ) G;

    RETURN (tot2);

END$$
DELIMITER ;