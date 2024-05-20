/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Anderson Fuentes
 * Created: 26 may. 2022
 */

DROP PROCEDURE IF EXISTS dataDEV_YSD080_Two;

DELIMITER $$
CREATE PROCEDURE dataDEV_YSD080_Two()
BEGIN

    SELECT A.*, 
        (
            CASE WHEN A.ZDA IS NULL THEN 0 ELSE A.ZDA END + 
            CASE WHEN A.ZDP IS NULL THEN 0 ELSE A.ZDP END
	)   as TOTAL_GENERAL FROM 

    (SELECT 
        YD.fecha_entrega as FEC_ENT, 
        YD.can_ped as CANTIDAD, 
        YD.des_ped as DESCRIPCION_MOTIVO, 
        YD.texto_breve as TEXTO_BREVE, 
        SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
        SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

    FROM tbl_ysd080_dev YD 
    GROUP BY YD.fecha_entrega, YD.texto_breve) A;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataRESUMENDIA;

DELIMITER $$
CREATE PROCEDURE dataRESUMENDIA()
BEGIN
    
    SELECT 
        RR.*,
        CT.CONTEO as DUPLICADO
    FROM tbl_resumen_dia RR

    LEFT JOIN

        (
            SELECT 
                L.cliente as CLIENTE, 
                COUNT(*) as CONTEO 

            FROM tbl_resumen_dia L
            GROUP BY L.cliente
        ) CT

    ON RR.cliente=CT.CLIENTE;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataCONSOLIDADODIA_Two;

DELIMITER $$
CREATE PROCEDURE dataCONSOLIDADODIA_Two()
BEGIN

    SET @tot1= totales1();
    SET @tot2= totales2();

    SELECT 
        X.fec_ent as FECHA_LIQ,
        X.cod_gestor as GESTOR,
        SUM(X.devoluciones_totales) as TOTAL_DEV_TOT,
        ROUND((SUM(X.devoluciones_totales)/@tot1)*100,2) as DEV_TOT,
        SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC,
        ROUND((SUM(X.devoluciones_parciales)/@tot2)*100,2) as DEV_PARC

    FROM tbl_resumen_dia

    X GROUP BY X.fec_ent, X.cod_gestor;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS nivelar_preysd080;

DELIMITER $$
CREATE PROCEDURE nivelar_preysd080(
    in fecha_ysd080 date
)
BEGIN

    DECLARE total INT DEFAULT 0;
    DECLARE totalTwo INT DEFAULT 0;
    DECLARE controlNivelacion INT DEFAULT 0;
    
    SELECT COUNT(*) into total FROM tbl_tlv_ped T WHERE T.dia=fecha_ysd080;
    SELECT COUNT(*) into totalTwo FROM tbl_ysd080 Y WHERE Y.fec_creacion=fecha_ysd080;
    SELECT COUNT(*) into controlNivelacion FROM tbl_preysd080 P WHERE P.fec_ent=fecha_ysd080;

    IF total>0 and totalTwo>0 THEN

        IF controlNivelacion=0 THEN

            INSERT INTO tbl_preysd080 (pedido, fec_ent, cliente, razon_social, 
            region, total_peso, total_soles_sin_igv, total_soles_igv, cod_usuario_final,
            cod_gestor, supervisor_ventas, pedido_40, reincidente, pedido_volumen, codigo_llamada, dia_llamada) 

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
                C.supervisor as SUPERVISOR_VENTAS,
                (
                    CASE 
                        WHEN SUM(Y.importe) <40
                        THEN "SI" 
                        ELSE "NO" 
                    END
                ) AS PEDIDO_40,
                RR.REPETICIONES as REINCIDENTE,
                (
                    CASE 
                        WHEN SUM(Y.importe) >2000
                        THEN "SI" 
                        ELSE "NO" 
                    END
                ) AS PEDIDO_VOLUMEN,
                CLL.DIA_LLAMADA as CODIGO_LLAMADA,
                CLL.DESCRIPCION as DIA_LLAMADA

            FROM tbl_ysd080 Y 
            LEFT JOIN ( SELECT num_pedido, usuario_final from tbl_tlv_ped ) B 
            ON B.num_pedido=Y.pedido
            LEFT JOIN ( SELECT raz, cod_rut, supervisor from tbl_dat_gest ) C 
            ON C.raz=B.usuario_final

            LEFT JOIN

                (
                    SELECT 
                        DV.CLIENTE AS CLIENTE,
                        COUNT(*) AS REPETICIONES
                    FROM

                        (
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
                                GROUP BY YD.fecha_entrega, YD.cod_cliente) 
                            A
                        ) DV

                    GROUP BY DV.CLIENTE
                ) RR

            ON Y.cod_cliente=RR.CLIENTE

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

            WHERE Y.fec_creacion= fecha_ysd080
            GROUP BY Y.pedido;

        END IF;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS nivelar_resumendia;

DELIMITER $$
CREATE PROCEDURE nivelar_resumendia(
    in fecha_ date
)
BEGIN

    DECLARE totalOne INT DEFAULT 0;
    DECLARE totalTwo INT DEFAULT 0;
    DECLARE controlNivelacion INT DEFAULT 0;
    
    SELECT COUNT(*) into totalOne FROM tbl_preysd080 P WHERE P.fec_ent=fecha_;
    SELECT COUNT(*) into totalTwo FROM tbl_ysd080_dev YD WHERE YD.fecha_entrega=fecha_;
    SELECT COUNT(*) into controlNivelacion FROM tbl_resumen_dia R WHERE R.fec_ent=fecha_;

    IF totalOne>0 and totalTwo>0 THEN

        IF controlNivelacion=0 THEN

            -- PRIMERA PARTE DE AQUELLOS REGISTROS QUE ESTÁN EN FACTURA Y YSD080

            INSERT INTO tbl_resumen_dia (pedido, fec_ent, cliente, razon_social, 
            region, total_peso_res, total_soles_sin_igv_res, total_fact_sin_igv_res, total_fact_con_igv_res,
            pedido_40, reincidente, pedido_volumen, codigo_llamada_res, dia_llamada_res, cod_tlv,
            cod_gestor, supervisor, motivos_del_dia, devoluciones_totales, devoluciones_parciales) 

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
                (
                    CASE 
                        WHEN Y.importe <40
                        THEN "SI" 
                        ELSE "NO" 
                    END
                ) AS PEDIDO_40,
                RR.REPETICIONES as REINCIDENTE,
                (
                    CASE 
                        WHEN Y.importe >2000
                        THEN "SI" 
                        ELSE "NO" 
                    END
                ) AS PEDIDO_VOLUMEN,
                CLL.DIA_LLAMADA as CODIGO_LLAMADA,
                CLL.DESCRIPCION as DIA_LLAMADA,
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
                        PR.pedido as PEDIDO,
                        PR.cod_usuario_final as COD_USUARIO_FINAL,
                        PR.cod_gestor as COD_GESTOR,
                        PR.supervisor_ventas as SUPERVISOR_VENTAS

                    FROM tbl_preysd080 PR

                    WHERE PR.fec_ent=fecha_
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

            LEFT JOIN

                (
                    SELECT 
                        DV.CLIENTE AS CLIENTE,
                        COUNT(*) AS REPETICIONES
                    FROM

                        (
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
                                GROUP BY YD.fecha_entrega, YD.cod_cliente) 
                            A
                        ) DV

                    GROUP BY DV.CLIENTE
                ) RR

            ON F.destinatario=RR.CLIENTE

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

            ON F.destinatario=CLL.COD_CLIENTE

            WHERE F.fecha_fact=fecha_

            GROUP BY F.doc_venta;

            -- SEGUNDA PARTE DE AQUELLOS REGISTROS QUE ESTÁN EN YSD080 PERO NO EN FACTURA

            INSERT INTO tbl_resumen_dia (pedido, fec_ent, cliente, razon_social, 
            region, total_peso_res, total_soles_sin_igv_res, total_fact_sin_igv_res, total_fact_con_igv_res,
            pedido_40, reincidente, pedido_volumen, codigo_llamada_res, dia_llamada_res, cod_tlv,
            cod_gestor, supervisor, motivos_del_dia, devoluciones_totales, devoluciones_parciales) 

            SELECT 
                Y.pedido as PEDIDO, 
                Y.fec_creacion as FEC_ENT,
                Y.cod_cliente as CLIENTE,
                Y.razon_social as RAZON,
                Y.region as REGION,
                SUM(Y.can_ped_tm) as TOTAL_PESO,
                SUM(Y.importe) as TOTAL_SOLES_SIN_IGV,
                NULL as TOTAL_FACT_SIN_IGV, 
                NULL as TOTAL_FACT_CON_IGV,
                (
                    CASE 
                        WHEN SUM(Y.importe) <40
                        THEN "SI" 
                        ELSE "NO" 
                    END
                ) AS PEDIDO_40,
                RR.REPETICIONES as REINCIDENTE,
                (
                    CASE 
                        WHEN SUM(Y.importe) >2000
                        THEN "SI" 
                        ELSE "NO" 
                    END
                ) AS PEDIDO_VOLUMEN,
                CLL.DIA_LLAMADA as CODIGO_LLAMADA,
                CLL.DESCRIPCION as DIA_LLAMADA,
                C.COD_USUARIO_FINAL as COD_TLV,
                C.COD_GESTOR as COD_GESTOR,
                C.SUPERVISOR_VENTAS as SUPERVISOR,
                D.DESCRIPCION_MOTIVO as MOTIVOS_DEL_DIA,
                D.ZDA as DEVOLUCIONES_TOTALES,
                D.ZDP as DEVOLUCIONES_PARCIALES

            FROM tbl_ysd080 Y

            LEFT JOIN

                (
                    SELECT 
                        PR.pedido as PEDIDO,
                        PR.cod_usuario_final as COD_USUARIO_FINAL,
                        PR.cod_gestor as COD_GESTOR,
                        PR.supervisor_ventas as SUPERVISOR_VENTAS

                    FROM tbl_preysd080 PR

                    WHERE PR.fec_ent=fecha_
                ) C

            ON Y.pedido= C.PEDIDO

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

            ON Y.id_concat=D.IDCONCAT

            LEFT JOIN

                (
                    SELECT 
                        DV.CLIENTE AS CLIENTE,
                        COUNT(*) AS REPETICIONES
                    FROM

                        (
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
                                GROUP BY YD.fecha_entrega, YD.cod_cliente) 
                            A
                        ) DV

                    GROUP BY DV.CLIENTE
                ) RR

            ON Y.cod_cliente=RR.CLIENTE

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

            WHERE NOT EXISTS 
            (SELECT NULL FROM tbl_factura F WHERE F.doc_venta = Y.pedido) 
            and Y.fec_creacion=fecha_
                                
            GROUP BY Y.pedido;
            

        END IF;

    END IF;

END$$
DELIMITER ;