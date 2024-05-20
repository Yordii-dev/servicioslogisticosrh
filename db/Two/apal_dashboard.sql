/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Anderson Fuentes
 * Created: 26 may. 2022
 */

-- dashboard/dia

DROP PROCEDURE IF EXISTS dataDashboardDiaTab1First;
DELIMITER $$
CREATE PROCEDURE dataDashboardDiaTab1First(
    in periodo_ varchar(50)
)
BEGIN

    IF periodo_ IS NULL OR periodo_ = "" THEN
        SET @ff= CONCAT(YEAR(now()),"-",MONTH(now()));
    ELSE
        SET @ff= periodo_;
    END IF;
    
    SELECT 
        X.fec_ent as FECHA_LIQ,
        SUM(X.total_soles_sin_igv_res) as TOTAL_FACT,
        SUM(X.devoluciones_totales) as TOTAL_DEV_TOT,
        SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC,
        (
        (SUM(X.total_soles_sin_igv_res) - ( SUM(X.devoluciones_totales) + SUM(X.devoluciones_parciales) )) /
        (SUM(X.total_soles_sin_igv_res)*100) 
        ) * 10000
        
        as EFECTIVIDAD

    FROM tbl_resumen_dia X 
    WHERE CONCAT(YEAR(X.fec_ent),"-",MONTH(X.fec_ent))=@ff
    GROUP BY X.fec_ent;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataDashboardDiaTab1Second;
DELIMITER $$
CREATE PROCEDURE dataDashboardDiaTab1Second(
    in periodo_ varchar(50)
)
BEGIN

    IF periodo_ IS NULL OR periodo_ = "" THEN
        SET @ff= CONCAT(YEAR(now()),"-",MONTH(now()));
    ELSE
        SET @ff= periodo_;
    END IF;

    SELECT 
        T.FECHA as FEC_EMIS,
        COUNT(*) as CLIENTES_PROG, 
        D.ZDA as DEV_TOTAL,
        D.ZDP as DEV_PARCIAL,
        COUNT(*) - D.ZDA as CLIENTES_EFECT,        
        ((COUNT(*) - D.ZDA) / COUNT(*)) * 100
        as EFECTIVIDAD
    
    FROM
    (
        SELECT
            R.fec_emis as FECHA
        FROM tbl_code C 
        inner join tbl_ruta R on (C.cod_venta_compra=R.codigo)

        LEFT JOIN 
            ( 
                SELECT 
                    doc_compras, 
                    placa, 
                    destinatario, 
                    SUM(peso_kg) as peso_tn 
                FROM 
                tbl_despacho 
                group by doc_compras 
                ORDER BY doc_compras ASC
            ) B 

        ON C.cod_venta_compra=B.doc_compras
        inner join tbl_auxiliar A on (A.placa=B.placa)
        inner join tbl_clientes CC on (CC.cod_cli=B.destinatario)
        group by R.codigo ORDER BY R.fec_emis DESC

    ) T

    LEFT JOIN
        (
            SELECT 
                A.FEC_ENT, 
                A.CLIENTE, 
                A.RAZON_SOCIAL, 
                A.DESCRIPCION_MOTIVO, 
                A.REGION, 
                COUNT(A.ZDA) as ZDA, 
                COUNT(A.ZDP) as ZDP, 
                (
                    SUM(CASE WHEN A.ZDA IS NULL THEN 0 ELSE A.ZDA END) + 
                    SUM(CASE WHEN A.ZDP IS NULL THEN 0 ELSE A.ZDP END)
                )  as TOTAL_GENERAL 

                FROM 

                    (
                        SELECT 
                            YD.fecha_entrega as FEC_ENT, 
                            YD.cod_cliente as CLIENTE, 
                            YD.razon_social as RAZON_SOCIAL, 
                            YD.des_ped as DESCRIPCION_MOTIVO, 
                            YD.region as REGION, 
                            SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
                            SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

                        FROM tbl_ysd080_dev YD 
                        GROUP BY YD.fecha_entrega, YD.cod_cliente
                    ) A
            
                GROUP BY A.FEC_ENT
            
        ) D

    ON T.FECHA=D.FEC_ENT
    WHERE CONCAT(YEAR(T.FECHA),"-",MONTH(T.FECHA))=@ff
    GROUP BY T.FECHA;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataDashboardDiaTab2First;
DELIMITER $$
CREATE PROCEDURE dataDashboardDiaTab2First(
    in periodo_ varchar(50),
    in supervisor_ varchar(100)
)
BEGIN

    IF periodo_ IS NULL OR periodo_ = "" THEN
        SET @ff= CONCAT(YEAR(now()),"-",MONTH(now()));
    ELSE
        SET @ff= periodo_;
    END IF;

    IF supervisor_ IS NULL OR supervisor_ = "" THEN
        
        SELECT 
            X.fec_ent as FECHA_LIQ,
            SUM(X.total_soles_sin_igv_res) as TOTAL_FACT,
            SUM(X.devoluciones_totales) as TOTAL_DEV_TOT,
            SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC,
            (
            (SUM(X.total_soles_sin_igv_res) - ( SUM(X.devoluciones_totales) + SUM(X.devoluciones_parciales) )) /
            (SUM(X.total_soles_sin_igv_res)*100) 
            ) * 10000
            
            as EFECTIVIDAD

        FROM tbl_resumen_dia X 
        LEFT JOIN 
        (
            SELECT
                L.cod_rut as COD_GESTOR,
                L.supervisor as SUPERVISOR
            FROM tbl_dat_gest L
        )
        G
        ON X.cod_gestor=G.COD_GESTOR
        WHERE CONCAT(YEAR(X.fec_ent),"-",MONTH(X.fec_ent))=@ff
        GROUP BY X.fec_ent;

    ELSE

        SELECT 
            X.fec_ent as FECHA_LIQ,
            SUM(X.total_soles_sin_igv_res) as TOTAL_FACT,
            SUM(X.devoluciones_totales) as TOTAL_DEV_TOT,
            SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC,
            (
            (SUM(X.total_soles_sin_igv_res) - ( SUM(X.devoluciones_totales) + SUM(X.devoluciones_parciales) )) /
            (SUM(X.total_soles_sin_igv_res)*100) 
            ) * 10000
            
            as EFECTIVIDAD

        FROM tbl_resumen_dia X 
        LEFT JOIN 
        (
            SELECT
                L.cod_rut as COD_GESTOR,
                L.supervisor as SUPERVISOR
            FROM tbl_dat_gest L
        )
        G
        ON X.cod_gestor=G.COD_GESTOR
        WHERE CONCAT(YEAR(X.fec_ent),"-",MONTH(X.fec_ent))=@ff AND
            G.SUPERVISOR=supervisor_
        GROUP BY X.fec_ent;
        
    END IF;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataDashboardDiaTab2Second;
DELIMITER $$
CREATE PROCEDURE dataDashboardDiaTab2Second(
    in periodo_ varchar(50)
)
BEGIN

    IF periodo_ IS NULL OR periodo_ = "" THEN
        SET @ff= CONCAT(YEAR(now()),"-",MONTH(now()));
    ELSE
        SET @ff= periodo_;
    END IF;

    SET @tot1= totales1();
    SET @tot2= totales2();

    IF @ff = "ALL" THEN

        SELECT 
            X.fec_ent as FECHA_LIQ,
            X.cod_gestor as GESTOR,
            G.supervisor as SUPERVISOR,
            CONCAT(X.cod_gestor,'-',G.supervisor) AS GESTOR_SUPERVISOR,
            SUM(X.devoluciones_totales) as TOTAL_DEV_TOT,
            ROUND((SUM(X.devoluciones_totales)/@tot1)*100,2) as DEV_TOT,
            SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC,
            ROUND((SUM(X.devoluciones_parciales)/@tot2)*100,2) as DEV_PARC,

            ( CASE WHEN SUM(X.devoluciones_totales) IS NULL THEN 0 ELSE SUM(X.devoluciones_totales) END + 
            CASE WHEN SUM(X.devoluciones_parciales) IS NULL THEN 0 ELSE SUM(X.devoluciones_parciales) END ) 
            as TOTAL_GENERAL,

            (CASE WHEN (
            (SUM(X.total_soles_sin_igv_res) - ( SUM(X.devoluciones_totales) + SUM(X.devoluciones_parciales) )) /
            (SUM(X.total_soles_sin_igv_res)*100) 
            ) * 10000 IS NULL THEN 0 ELSE (
            (SUM(X.total_soles_sin_igv_res) - ( SUM(X.devoluciones_totales) + SUM(X.devoluciones_parciales) )) /
            (SUM(X.total_soles_sin_igv_res)*100) 
            ) * 10000 END) as EFECTIVIDAD

        FROM tbl_resumen_dia X
        LEFT JOIN 
            (
                SELECT
                    L.cod_rut as COD_GESTOR,
                    L.supervisor as SUPERVISOR
                FROM tbl_dat_gest L
            )
        G
        ON X.cod_gestor=G.COD_GESTOR
        GROUP BY X.cod_gestor;

    ELSE

        SELECT 
            X.fec_ent as FECHA_LIQ,
            X.cod_gestor as GESTOR,
            G.supervisor as SUPERVISOR,
            CONCAT(X.cod_gestor,'-',G.supervisor) AS GESTOR_SUPERVISOR,
            SUM(X.devoluciones_totales) as TOTAL_DEV_TOT,
            ROUND((SUM(X.devoluciones_totales)/@tot1)*100,2) as DEV_TOT,
            SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC,
            ROUND((SUM(X.devoluciones_parciales)/@tot2)*100,2) as DEV_PARC,

            ( CASE WHEN SUM(X.devoluciones_totales) IS NULL THEN 0 ELSE SUM(X.devoluciones_totales) END + 
            CASE WHEN SUM(X.devoluciones_parciales) IS NULL THEN 0 ELSE SUM(X.devoluciones_parciales) END ) 
            as TOTAL_GENERAL,

            (CASE WHEN (
            (SUM(X.total_soles_sin_igv_res) - ( SUM(X.devoluciones_totales) + SUM(X.devoluciones_parciales) )) /
            (SUM(X.total_soles_sin_igv_res)*100) 
            ) * 10000 IS NULL THEN 0 ELSE (
            (SUM(X.total_soles_sin_igv_res) - ( SUM(X.devoluciones_totales) + SUM(X.devoluciones_parciales) )) /
            (SUM(X.total_soles_sin_igv_res)*100) 
            ) * 10000 END) as EFECTIVIDAD

        FROM tbl_resumen_dia X
        LEFT JOIN 
            (
                SELECT
                    L.cod_rut as COD_GESTOR,
                    L.supervisor as SUPERVISOR
                FROM tbl_dat_gest L
            )
        G
        ON X.cod_gestor=G.COD_GESTOR
        WHERE CONCAT(YEAR(X.fec_ent),"-",MONTH(X.fec_ent))=@ff
        GROUP BY X.cod_gestor;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataDashboardDiaTab3First;
DELIMITER $$
CREATE PROCEDURE dataDashboardDiaTab3First(
    in periodo_ varchar(50),
    in dia_ varchar(30),
    in supervisor_ varchar(50)
)
BEGIN

    IF (periodo_ IS NULL OR periodo_ = "") AND (dia_ IS NULL OR dia_ = "")  THEN
        SET @ff= CONCAT(YEAR(now()),"-",MONTH(now()),"-",DAY(now()));
        SET @dia="";
    ELSEIF (periodo_ IS NOT NULL OR periodo_!="") AND (dia_!="") THEN
        IF dia_="ALL" THEN
            SET @dia="ALL";
        ELSE
            SET @ff= CONCAT(periodo_,"-",dia_);
            SET @dia="";
        END IF;
    ELSEIF (periodo_ IS NOT NULL OR periodo_!="") AND (dia_ IS NULL OR dia_="") THEN
        SET @dia="ALL";
    END IF;

    IF supervisor_ = "" THEN
        SET @supervisorgest= "ALL";

    ELSEIF supervisor_!="" THEN

        IF supervisor_="ALL" THEN
            SET @supervisorgest= "ALL";
        ELSE
            SET @supervisorgest= supervisor_;
        END IF;

    END IF;

    IF @dia = "ALL" AND @supervisorgest = "ALL" THEN

        SELECT 
            X.fec_ent as FECHA_LIQ, 
            X.cod_gestor as GESTOR, 
            G.SUPERVISOR as SUPERVISOR,
            G.NOMBRE_CLIENTE as NOMBRE_CLIENTE,
            COUNT(*) as Q_CLIENTES,
            SUM(X.devoluciones_totales) as TOTAL_DEV_TOT, 
            SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC, 
            ( CASE WHEN SUM(X.devoluciones_totales) IS NULL THEN 0 ELSE SUM(X.devoluciones_totales) END + 
            CASE WHEN SUM(X.devoluciones_parciales) IS NULL THEN 0 ELSE SUM(X.devoluciones_parciales) END ) 
            as TOTAL_GENERAL 

        FROM tbl_resumen_dia X 
        LEFT JOIN 
            (
                SELECT
                    L.cod_rut as COD_GESTOR,
                    L.nombre as NOMBRE_CLIENTE,
                    L.supervisor as SUPERVISOR
                FROM tbl_dat_gest L
            )
        G
        ON X.cod_gestor=G.COD_GESTOR
        WHERE CONCAT(YEAR(X.fec_ent),"-",MONTH(X.fec_ent))=periodo_
        GROUP BY G.NOMBRE_CLIENTE;

    ELSEIF @dia != "ALL" AND @supervisorgest = "ALL" THEN

        SELECT 
            X.fec_ent as FECHA_LIQ, 
            X.cod_gestor as GESTOR, 
            G.SUPERVISOR as SUPERVISOR,
            G.NOMBRE_CLIENTE as NOMBRE_CLIENTE,
            COUNT(*) as Q_CLIENTES,
            SUM(X.devoluciones_totales) as TOTAL_DEV_TOT, 
            SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC, 
            ( CASE WHEN SUM(X.devoluciones_totales) IS NULL THEN 0 ELSE SUM(X.devoluciones_totales) END + 
            CASE WHEN SUM(X.devoluciones_parciales) IS NULL THEN 0 ELSE SUM(X.devoluciones_parciales) END ) 
            as TOTAL_GENERAL 

        FROM tbl_resumen_dia X 
        LEFT JOIN 
            (
                SELECT
                    L.cod_rut as COD_GESTOR,
                    L.nombre as NOMBRE_CLIENTE,
                    L.supervisor as SUPERVISOR
                FROM tbl_dat_gest L
            )
        G
        ON X.cod_gestor=G.COD_GESTOR
        WHERE CONCAT(YEAR(X.fec_ent),"-",MONTH(X.fec_ent),"-",DAY(X.fec_ent))=@ff
        GROUP BY G.NOMBRE_CLIENTE;

    ELSEIF @dia = "ALL" AND @supervisorgest != "ALL" THEN

        SELECT 
            X.fec_ent as FECHA_LIQ, 
            X.cod_gestor as GESTOR, 
            G.SUPERVISOR as SUPERVISOR,
            G.NOMBRE_CLIENTE as NOMBRE_CLIENTE,
            COUNT(*) as Q_CLIENTES,
            SUM(X.devoluciones_totales) as TOTAL_DEV_TOT, 
            SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC, 
            ( CASE WHEN SUM(X.devoluciones_totales) IS NULL THEN 0 ELSE SUM(X.devoluciones_totales) END + 
            CASE WHEN SUM(X.devoluciones_parciales) IS NULL THEN 0 ELSE SUM(X.devoluciones_parciales) END ) 
            as TOTAL_GENERAL 

        FROM tbl_resumen_dia X 
        LEFT JOIN 
            (
                SELECT
                    L.cod_rut as COD_GESTOR,
                    L.nombre as NOMBRE_CLIENTE,
                    L.supervisor as SUPERVISOR
                FROM tbl_dat_gest L
            )
        G
        ON X.cod_gestor=G.COD_GESTOR
        WHERE CONCAT(YEAR(X.fec_ent),"-",MONTH(X.fec_ent))=periodo_ AND G.SUPERVISOR=@supervisorgest
        GROUP BY G.NOMBRE_CLIENTE;

    ELSEIF @dia != "ALL" AND @supervisorgest != "ALL" THEN

        SELECT 
            X.fec_ent as FECHA_LIQ, 
            X.cod_gestor as GESTOR, 
            G.SUPERVISOR as SUPERVISOR,
            G.NOMBRE_CLIENTE as NOMBRE_CLIENTE,
            COUNT(*) as Q_CLIENTES,
            SUM(X.devoluciones_totales) as TOTAL_DEV_TOT, 
            SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC, 
            ( CASE WHEN SUM(X.devoluciones_totales) IS NULL THEN 0 ELSE SUM(X.devoluciones_totales) END + 
            CASE WHEN SUM(X.devoluciones_parciales) IS NULL THEN 0 ELSE SUM(X.devoluciones_parciales) END ) 
            as TOTAL_GENERAL 

        FROM tbl_resumen_dia X 
        LEFT JOIN 
            (
                SELECT
                    L.cod_rut as COD_GESTOR,
                    L.nombre as NOMBRE_CLIENTE,
                    L.supervisor as SUPERVISOR
                FROM tbl_dat_gest L
            )
        G
        ON X.cod_gestor=G.COD_GESTOR
        WHERE CONCAT(YEAR(X.fec_ent),"-",MONTH(X.fec_ent),"-",DAY(X.fec_ent))=@ff AND G.SUPERVISOR=@supervisorgest
        GROUP BY G.NOMBRE_CLIENTE;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataDashboardDiaTab3Second;
DELIMITER $$
CREATE PROCEDURE dataDashboardDiaTab3Second(
    in periodo_ varchar(50),
    in dia_ varchar(30),
    in supervisor_ varchar(50)
)
BEGIN

    IF (periodo_ IS NULL OR periodo_ = "") AND (dia_ IS NULL OR dia_ = "")  THEN
        SET @ff= CONCAT(YEAR(now()),"-",MONTH(now()),"-",DAY(now()));
        SET @dia="";
    ELSEIF (periodo_ IS NOT NULL OR periodo_!="") AND (dia_!="") THEN
        IF dia_="ALL" THEN
            SET @dia="ALL";
        ELSE
            SET @ff= CONCAT(periodo_,"-",dia_);
            SET @dia="";
        END IF;
    ELSEIF (periodo_ IS NOT NULL OR periodo_!="") AND (dia_ IS NULL OR dia_="") THEN
        SET @dia="ALL";
    END IF;

    IF supervisor_ = "" THEN
        SET @supervisorgest= "ALL";

    ELSEIF supervisor_!="" THEN

        IF supervisor_="ALL" THEN
            SET @supervisorgest= "ALL";
        ELSE
            SET @supervisorgest= supervisor_;
        END IF;

    END IF;

    IF @dia = "ALL" AND @supervisorgest = "ALL" THEN

        SELECT 
            X.fec_ent as FECHA_LIQ, 
            X.cod_gestor as GESTOR, 
            G.SUPERVISOR as SUPERVISOR,
            G.NOMBRE_CLIENTE as NOMBRE_CLIENTE,
            YD.DESCRIPCION_MOTIVO,
            SUM(X.devoluciones_totales) as TOTAL_DEV_TOT, 
            SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC, 
            ( CASE WHEN SUM(X.devoluciones_totales) IS NULL THEN 0 ELSE SUM(X.devoluciones_totales) END + 
            CASE WHEN SUM(X.devoluciones_parciales) IS NULL THEN 0 ELSE SUM(X.devoluciones_parciales) END ) 
            as TOTAL_GENERAL 

        FROM tbl_resumen_dia X 
        LEFT JOIN 
            (
                SELECT
                    L.cod_rut as COD_GESTOR,
                    L.nombre as NOMBRE_CLIENTE,
                    L.supervisor as SUPERVISOR
                FROM tbl_dat_gest L
            )
        G
        ON X.cod_gestor=G.COD_GESTOR
        
        LEFT JOIN
            (
                SELECT 
                    YD.fecha_entrega as FEC_ENT,
                    YD.des_ped as DESCRIPCION_MOTIVO
                FROM tbl_ysd080_dev YD 
                GROUP BY YD.fecha_entrega, YD.texto_breve
            )
        YD
        ON X.fec_ent=YD.FEC_ENT
        WHERE CONCAT(YEAR(X.fec_ent),"-",MONTH(X.fec_ent))=periodo_
        GROUP BY G.NOMBRE_CLIENTE, YD.DESCRIPCION_MOTIVO;

    ELSEIF @dia != "ALL" AND @supervisorgest = "ALL" THEN

        SELECT 
            X.fec_ent as FECHA_LIQ, 
            X.cod_gestor as GESTOR, 
            G.SUPERVISOR as SUPERVISOR,
            G.NOMBRE_CLIENTE as NOMBRE_CLIENTE,
            YD.DESCRIPCION_MOTIVO,
            SUM(X.devoluciones_totales) as TOTAL_DEV_TOT, 
            SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC, 
            ( CASE WHEN SUM(X.devoluciones_totales) IS NULL THEN 0 ELSE SUM(X.devoluciones_totales) END + 
            CASE WHEN SUM(X.devoluciones_parciales) IS NULL THEN 0 ELSE SUM(X.devoluciones_parciales) END ) 
            as TOTAL_GENERAL 

        FROM tbl_resumen_dia X 
        LEFT JOIN 
            (
                SELECT
                    L.cod_rut as COD_GESTOR,
                    L.nombre as NOMBRE_CLIENTE,
                    L.supervisor as SUPERVISOR
                FROM tbl_dat_gest L
            )
        G
        ON X.cod_gestor=G.COD_GESTOR
        LEFT JOIN
            (
                SELECT 
                    YD.fecha_entrega as FEC_ENT,
                    YD.des_ped as DESCRIPCION_MOTIVO
                FROM tbl_ysd080_dev YD 
                GROUP BY YD.fecha_entrega, YD.texto_breve
            )
        YD
        ON X.fec_ent=YD.FEC_ENT
        WHERE CONCAT(YEAR(X.fec_ent),"-",MONTH(X.fec_ent),"-",DAY(X.fec_ent))=@ff
        GROUP BY G.NOMBRE_CLIENTE, YD.DESCRIPCION_MOTIVO;

    ELSEIF @dia = "ALL" AND @supervisorgest != "ALL" THEN

        SELECT 
            X.fec_ent as FECHA_LIQ, 
            X.cod_gestor as GESTOR, 
            G.SUPERVISOR as SUPERVISOR,
            G.NOMBRE_CLIENTE as NOMBRE_CLIENTE,
            YD.DESCRIPCION_MOTIVO,
            SUM(X.devoluciones_totales) as TOTAL_DEV_TOT, 
            SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC, 
            ( CASE WHEN SUM(X.devoluciones_totales) IS NULL THEN 0 ELSE SUM(X.devoluciones_totales) END + 
            CASE WHEN SUM(X.devoluciones_parciales) IS NULL THEN 0 ELSE SUM(X.devoluciones_parciales) END ) 
            as TOTAL_GENERAL 

        FROM tbl_resumen_dia X 
        LEFT JOIN 
            (
                SELECT
                    L.cod_rut as COD_GESTOR,
                    L.nombre as NOMBRE_CLIENTE,
                    L.supervisor as SUPERVISOR
                FROM tbl_dat_gest L
            )
        G
        ON X.cod_gestor=G.COD_GESTOR
        LEFT JOIN
            (
                SELECT 
                    YD.fecha_entrega as FEC_ENT,
                    YD.des_ped as DESCRIPCION_MOTIVO
                FROM tbl_ysd080_dev YD 
                GROUP BY YD.fecha_entrega, YD.texto_breve
            )
        YD
        ON X.fec_ent=YD.FEC_ENT
        WHERE CONCAT(YEAR(X.fec_ent),"-",MONTH(X.fec_ent))=periodo_ AND G.SUPERVISOR=@supervisorgest
        GROUP BY G.NOMBRE_CLIENTE, YD.DESCRIPCION_MOTIVO;

    ELSEIF @dia != "ALL" AND @supervisorgest != "ALL" THEN

        SELECT 
            X.fec_ent as FECHA_LIQ, 
            X.cod_gestor as GESTOR, 
            G.SUPERVISOR as SUPERVISOR,
            G.NOMBRE_CLIENTE as NOMBRE_CLIENTE,
            YD.DESCRIPCION_MOTIVO,
            SUM(X.devoluciones_totales) as TOTAL_DEV_TOT, 
            SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC, 
            ( CASE WHEN SUM(X.devoluciones_totales) IS NULL THEN 0 ELSE SUM(X.devoluciones_totales) END + 
            CASE WHEN SUM(X.devoluciones_parciales) IS NULL THEN 0 ELSE SUM(X.devoluciones_parciales) END ) 
            as TOTAL_GENERAL 

        FROM tbl_resumen_dia X 
        LEFT JOIN 
            (
                SELECT
                    L.cod_rut as COD_GESTOR,
                    L.nombre as NOMBRE_CLIENTE,
                    L.supervisor as SUPERVISOR
                FROM tbl_dat_gest L
            )
        G
        ON X.cod_gestor=G.COD_GESTOR
        LEFT JOIN
            (
                SELECT 
                    YD.fecha_entrega as FEC_ENT,
                    YD.des_ped as DESCRIPCION_MOTIVO
                FROM tbl_ysd080_dev YD 
                GROUP BY YD.fecha_entrega, YD.texto_breve
            )
        YD
        ON X.fec_ent=YD.FEC_ENT
        WHERE CONCAT(YEAR(X.fec_ent),"-",MONTH(X.fec_ent),"-",DAY(X.fec_ent))=@ff AND G.SUPERVISOR=@supervisorgest
        GROUP BY G.NOMBRE_CLIENTE, YD.DESCRIPCION_MOTIVO;

    END IF;

END$$
DELIMITER ;


-- dashboard/efecdiaria

DROP PROCEDURE IF EXISTS dataCONSOLIDADODIA_One;
DELIMITER $$
CREATE PROCEDURE dataCONSOLIDADODIA_One()
BEGIN

    SELECT 
        X.fec_ent as FECHA_LIQ,
        SUM(X.total_soles_sin_igv_res) as TOTAL_FACT,
        SUM(X.devoluciones_totales) as TOTAL_DEV_TOT,
        SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC,
        SUM(X.total_soles_sin_igv_res) - ( SUM(X.devoluciones_totales) + SUM(X.devoluciones_parciales))
        as TOTAL_LIQUIDADO,
        
        (
        (SUM(X.total_soles_sin_igv_res) - ( SUM(X.devoluciones_totales) + SUM(X.devoluciones_parciales) )) /
        (SUM(X.total_soles_sin_igv_res)*100) 
        ) * 10000
        
        as EFECTIVIDAD

    FROM tbl_resumen_dia

    X GROUP BY X.fec_ent;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataCONSOLIDADODIA_One_Totales;

DELIMITER $$
CREATE PROCEDURE dataCONSOLIDADODIA_One_Totales()
BEGIN

    SELECT  

        SUM(K.TOTAL_FACT) as TOTAL_FACT,
        SUM(K.TOTAL_DEV_TOT) as TOTAL_DEV_TOT,
        SUM(K.TOTAL_DEV_PARC) as TOTAL_DEV_PARC,
        SUM(K.TOTAL_LIQUIDADO) as TOTAL_LIQUIDADO,

        ROUND(AVG(K.EFECTIVIDAD),2) as EFECTIVIDAD
    
    FROM

        (
            SELECT 
                X.fec_ent as FECHA_LIQ,
                SUM(X.total_soles_sin_igv_res) as TOTAL_FACT,
                SUM(X.devoluciones_totales) as TOTAL_DEV_TOT,
                SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC,
                SUM(X.total_fact_sin_igv_res) - ( SUM(X.devoluciones_totales) + SUM(X.devoluciones_parciales))
                as TOTAL_LIQUIDADO,

                (
                (SUM(X.total_fact_sin_igv_res) - ( SUM(X.devoluciones_totales) + SUM(X.devoluciones_parciales) )) /
                (SUM(X.total_fact_sin_igv_res)*100) 
                ) * 10000

                as EFECTIVIDAD

            FROM tbl_resumen_dia

            X GROUP BY X.fec_ent
        ) K;

END$$
DELIMITER ;


-- dashboard/efecdiaria

DROP PROCEDURE IF EXISTS dataEFECTIVIDAD_Contactos;

DELIMITER $$
CREATE PROCEDURE dataEFECTIVIDAD_Contactos()
BEGIN

    SELECT 

        T.FECHA as FEC_EMIS,
        COUNT(*) as CLIENTES_PROG, 
        D.ZDA as DEV_TOTAL,
        D.ZDP as DEV_PARCIAL,
        COUNT(*) - D.ZDA as CLIENTES_EFECT,        
        
        ((COUNT(*) - D.ZDA) / COUNT(*)) * 100
        as EFECTIVIDAD
    
    FROM
    (
        SELECT
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

        LEFT JOIN 
            ( 
                SELECT 
                    doc_compras, 
                    placa, 
                    secuencia, 
                    destinatario, 
                    SUM(peso_kg) as peso_tn 
                FROM 
                tbl_despacho 
                group by doc_compras 
                ORDER BY doc_compras ASC
            ) B 

        ON C.cod_venta_compra=B.doc_compras
        inner join tbl_auxiliar A on (A.placa=B.placa)
        inner join tbl_clientes CC on (CC.cod_cli=B.destinatario)
        group by R.codigo ORDER BY R.fec_emis DESC

    ) T

    LEFT JOIN

        (
            SELECT 
                A.FEC_ENT, 
                A.CLIENTE, 
                A.RAZON_SOCIAL, 
                A.DESCRIPCION_MOTIVO, 
                A.REGION, 
                COUNT(A.ZDA) as ZDA, 
                COUNT(A.ZDP) as ZDP, 
                (
                    SUM(CASE WHEN A.ZDA IS NULL THEN 0 ELSE A.ZDA END) + 
                    SUM(CASE WHEN A.ZDP IS NULL THEN 0 ELSE A.ZDP END)
                )  as TOTAL_GENERAL 

                FROM 

                    (
                        SELECT 
                            YD.fecha_entrega as FEC_ENT, 
                            YD.cod_cliente as CLIENTE, 
                            YD.razon_social as RAZON_SOCIAL, 
                            YD.des_ped as DESCRIPCION_MOTIVO, 
                            YD.region as REGION, 
                            SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
                            SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

                        FROM tbl_ysd080_dev YD 
                        GROUP BY YD.fecha_entrega, YD.cod_cliente
                    ) A
            
                GROUP BY A.FEC_ENT
            
        ) D

    ON T.FECHA=D.FEC_ENT

    GROUP BY T.FECHA;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataEFECTIVIDAD_Contactos_Totales;

DELIMITER $$
CREATE PROCEDURE dataEFECTIVIDAD_Contactos_Totales()
BEGIN

    SELECT 
        SUM(PP.CLIENTES_PROG) as CLIENTES_PROG, 
        SUM(PP.DEV_TOTAL) as DEV_TOTAL, 
        SUM(PP.DEV_PARCIAL) as DEV_PARCIAL, 
        SUM(PP.CLIENTES_EFECT) as CLIENTES_EFECT, 
        ROUND(AVG(PP.EFECTIVIDAD),2) as EFECTIVIDAD 
    
    FROM

    (
        SELECT 

            T.FECHA as FEC_EMIS,
            COUNT(*) as CLIENTES_PROG, 
            D.ZDA as DEV_TOTAL,
            D.ZDP as DEV_PARCIAL,
            COUNT(*) - D.ZDA as CLIENTES_EFECT,        

            ((COUNT(*) - D.ZDA) / COUNT(*)) * 100
            as EFECTIVIDAD

        FROM
        (
            SELECT
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

            LEFT JOIN 
                ( 
                    SELECT 
                        doc_compras, 
                        placa, 
                        secuencia, 
                        destinatario, 
                        SUM(peso_kg) as peso_tn 
                    FROM 
                    tbl_despacho 
                    group by doc_compras 
                    ORDER BY doc_compras ASC
                ) B 

            ON C.cod_venta_compra=B.doc_compras
            inner join tbl_auxiliar A on (A.placa=B.placa)
            inner join tbl_clientes CC on (CC.cod_cli=B.destinatario)
            group by R.codigo ORDER BY R.fec_emis DESC

        ) AS T

        LEFT JOIN

            (
                SELECT 
                    A.FEC_ENT, 
                    A.CLIENTE, 
                    A.RAZON_SOCIAL, 
                    A.DESCRIPCION_MOTIVO, 
                    A.REGION, 
                    COUNT(A.ZDA) as ZDA, 
                    COUNT(A.ZDP) as ZDP, 
                    (
                        SUM(CASE WHEN A.ZDA IS NULL THEN 0 ELSE A.ZDA END) + 
                        SUM(CASE WHEN A.ZDP IS NULL THEN 0 ELSE A.ZDP END)
                    )  as TOTAL_GENERAL 

                    FROM 

                        (
                            SELECT 
                                YD.fecha_entrega as FEC_ENT, 
                                YD.cod_cliente as CLIENTE, 
                                YD.razon_social as RAZON_SOCIAL, 
                                YD.des_ped as DESCRIPCION_MOTIVO, 
                                YD.region as REGION, 
                                SUM(CASE WHEN YD.cla_ped = 'ZDA' THEN YD.importe ELSE NULL END) AS ZDA,
                                SUM(CASE WHEN YD.cla_ped = 'ZDP' THEN YD.importe ELSE NULL END) AS ZDP

                            FROM tbl_ysd080_dev YD 
                            GROUP BY YD.fecha_entrega, YD.cod_cliente
                        ) A

                    GROUP BY A.FEC_ENT

            ) AS D

        ON T.FECHA=D.FEC_ENT

        GROUP BY T.FECHA

    ) PP;

END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS dataDISTRIBUCION_general;

DELIMITER $$
CREATE PROCEDURE dataDISTRIBUCION_general()
BEGIN

    DECLARE res1 DECIMAL(10,2);

    SET res1 = totalDistribucion_general();

    SELECT

        G.DESCRIPCION_MOTIVO as DESCRIPCION_PEDIDO,
        SUM(G.TOTAL_GENERAL) as MONTO,

        ROUND((SUM(G.TOTAL_GENERAL)/res1)*100,2) as TG_MONTO

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
    ) G

    GROUP BY G.DESCRIPCION_MOTIVO;

END$$
DELIMITER ;