/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Anderson Fuentes
 * Created: 26 may. 2022
 */

-- MODULE: ANALISIS

DROP PROCEDURE IF EXISTS importBaseYSD080;

DELIMITER $$
CREATE PROCEDURE `importBaseYSD080`(
in pedido varchar(50),
in fec_creacion date,
in cod_cliente varchar(50),
in razon_social varchar(150),
in can_ped int,
in can_ped_tm decimal(10,3),
in importe decimal(10,2),
in region varchar(150)
)
BEGIN

    DECLARE total INT DEFAULT 0;
    DECLARE idconcat varchar(50);

    SET idconcat= CONCAT(REPLACE(fec_creacion, '-', '' ),cod_cliente);

    SELECT COUNT(*) INTO total FROM tbl_clientes where cod_cli=cod_cliente;
    IF total =0 THEN

        INSERT INTO tbl_clientes VALUES (cod_cliente, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

        INSERT INTO tbl_ysd080 VALUES (default, cod_cliente,pedido, fec_creacion, razon_social, can_ped, 
        can_ped_tm, importe, region,idconcat);

    ELSE

        INSERT INTO tbl_ysd080 VALUES (default, cod_cliente,pedido, fec_creacion, razon_social, can_ped, 
        can_ped_tm, importe, region,idconcat);

    END IF;
	
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS importBaseYSD080dev;

DELIMITER $$
CREATE PROCEDURE `importBaseYSD080dev`(
in cla_ped varchar(50),
in cod_cliente varchar(50),
in razon_social varchar(150),
in motivo_ped varchar(50),
in des_ped varchar(150),
in texto_breve varchar(250),
in fecha_entrega date,
in can_ped int,
in can_ped_tm decimal(10,3),
in importe decimal(10,2),
in region varchar(150),
in fechacreacion date
)
BEGIN

    DECLARE total INT DEFAULT 0;

    SELECT COUNT(*) INTO total FROM tbl_clientes where cod_cli=cod_cliente;
    IF total =0 THEN

        INSERT INTO tbl_clientes VALUES (cod_cliente, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

        INSERT INTO tbl_ysd080_dev VALUES (default, cod_cliente, cla_ped, razon_social, motivo_ped, des_ped, 
                            texto_breve, fecha_entrega, can_ped, can_ped_tm, importe, region, fechacreacion);

    ELSE

        INSERT INTO tbl_ysd080_dev VALUES (default, cod_cliente, cla_ped, razon_social, motivo_ped, des_ped, 
                            texto_breve, fecha_entrega, can_ped, can_ped_tm, importe, region, fechacreacion);

    END IF;
	
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS importBaseClientes;

DELIMITER $$
CREATE PROCEDURE `importBaseClientes`(
in cod_cli_ varchar(100),
in ciudad_ varchar(50),
in nombre_ varchar(150),
in direccion_ varchar(200),
in distrito_ varchar(150),
in dni_ruc_ varchar(50),
in giro_negocio_ varchar(70),
in subcanal_ varchar(70),
in segmento_ varchar(50),
in telefono01_ varchar(20),
in telefono02_ varchar(20),
in telefono03_ varchar(20),
in ruta_llamada_ varchar(10),
in dia_llamada_ varchar(50),
in frecuencia_llamada_ varchar(10),
in ruta_visita_ varchar(10),
in dia_visita_ varchar(20),
in frecuencia_visita_ varchar(20),
in secuencia_visita_ int,
in longitud_ varchar(80),
in latitud_ varchar(80),
in fecha_alta_ date,
in cod_dist_ varchar(40)
)
BEGIN

    DECLARE total INT DEFAULT 0;

    SELECT COUNT(*) INTO total FROM tbl_clientes where cod_cli=cod_cli_;

    IF total =0 THEN

        INSERT INTO tbl_clientes VALUES (cod_cli_, ciudad_, nombre_, direccion_, distrito_, dni_ruc_, giro_negocio_, 
        subcanal_, segmento_, telefono01_, telefono02_, telefono03_, ruta_llamada_, dia_llamada_, frecuencia_llamada_, 
        ruta_visita_, dia_visita_, frecuencia_visita_, secuencia_visita_, longitud_, latitud_, fecha_alta_, cod_dist_);

    ELSE

        UPDATE tbl_clientes SET ciudad=ciudad_, nombre=nombre_, direccion=direccion_, distrito=distrito_, dni_ruc=dni_ruc_, 
        giro_negocio=giro_negocio_, subcanal=subcanal_, segmento=segmento_, telefono01=telefono01_, telefono02=telefono02_,
        telefono03=telefono03_, ruta_llamada=ruta_llamada_, dia_llamada=dia_llamada_, frecuencia_llamada=frecuencia_llamada_,
        ruta_visita=ruta_visita_, dia_visita=dia_visita_, frecuencia_visita=frecuencia_visita_, secuencia_visita=secuencia_visita_, 
        longitud=longitud_, latitud=latitud_, fecha_alta=fecha_alta_, cod_dist=cod_dist_ where cod_cli=cod_cli_;

    END IF;
	
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS importBaseGestor;

DELIMITER $$
CREATE PROCEDURE `importBaseGestor`(
in raz_ varchar(30),
in cod_rut_ varchar(20),
in cod_doc_ varchar(20),
in nombre_ varchar(150),
in canal_venta_ varchar(50),
in zona_ varchar(50),
in supervisor_ varchar(60),
in celular_ varchar(20),
in celular_personal_ varchar(30)
)
BEGIN

    DECLARE total INT DEFAULT 0;
    SELECT COUNT(*) INTO total FROM tbl_dat_gest where raz=raz_;

    IF total =0 THEN
        INSERT INTO tbl_dat_gest VALUES (raz_, cod_rut_, cod_doc_, nombre_, canal_venta_, zona_, supervisor_,
                                         celular_, celular_personal_, now());
    ELSE
        UPDATE tbl_dat_gest SET cod_rut=cod_rut_, cod_doc=cod_doc_, nombre=nombre_, canal_venta=canal_venta_, zona=zona_,
        supervisor=supervisor_, celular=celular_, celular_personal=celular_personal_, fecha_reg=now() where raz=raz_;
    END IF;
	
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS importBaseTlvped;

DELIMITER $$
CREATE PROCEDURE `importBaseTlvped`(
in dia_ date,
in hora_ time,
in num_pedido_ varchar(20),
in cod_cliente_ varchar(20),
in nombre_cliente_ varchar(150),
in direccion_ varchar(250),
in distrito_ varchar(50),
in ruta_campo_ varchar(15),
in ruta_llamada_ varchar(15),
in importe_venta_ decimal(10,2),
in usuario_cod_ varchar(20),
in usuario_final_ varchar(20)
)
BEGIN

    DECLARE total INT DEFAULT 0;
    SELECT COUNT(*) INTO total FROM tbl_tlv_ped where num_pedido=num_pedido_;

    IF total =0 THEN
        INSERT INTO tbl_tlv_ped VALUES (default, dia_, hora_, num_pedido_, cod_cliente_, nombre_cliente_,
                                        direccion_, distrito_, ruta_campo_, ruta_llamada_, importe_venta_,
                                        usuario_cod_, usuario_final_, now());
    ELSE
        UPDATE tbl_tlv_ped SET dia=dia_, hora=hora_, cod_cliente=cod_cliente_, nombre_cliente=nombre_cliente_,
        direccion=direccion_, distrito=distrito_, ruta_campo=ruta_campo_, ruta_llamada=ruta_llamada_, importe_venta=importe_venta_,
        usuario_cod=usuario_cod_, usuario_final=usuario_final_, fecha_reg=now() where num_pedido=num_pedido_;
    END IF;
	
END$$
DELIMITER ;


-- analisis/informacion

DROP PROCEDURE IF EXISTS dataPREYSD080;

DELIMITER $$
CREATE PROCEDURE dataPREYSD080(
in desde int,
in per_pages int
)
BEGIN

    SELECT 
        PR.pedido as PEDIDO, 
        PR.fec_ent as FEC_ENT, 
        PR.cliente as CLIENTE, 
        PR.razon_social as RAZON_SOCIAL, 
        PR.region as REGION, 
        PR.total_peso as TOTAL_PESO, 
        PR.total_soles_sin_igv as TOTAL_SOLES_SIN_IGV, 
        PR.total_soles_igv as TOTAL_SOLES_IGV, 
        PR.cod_usuario_final as COD_USUARIO_FINAL, 
        PR.cod_gestor as COD_GESTOR,
        PR.supervisor_ventas as SUPERVISOR_VENTAS

    FROM tbl_preysd080 PR
    
    LIMIT desde, per_pages;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataPREYSD080Search;

DELIMITER $$
CREATE PROCEDURE dataPREYSD080Search(
in texto varchar(50)
)
BEGIN

    SELECT 
        PR.pedido as PEDIDO, 
        PR.fec_ent as FEC_ENT, 
        PR.cliente as CLIENTE, 
        PR.razon_social as RAZON_SOCIAL, 
        PR.region as REGION, 
        PR.total_peso as TOTAL_PESO, 
        PR.total_soles_sin_igv as TOTAL_SOLES_SIN_IGV, 
        PR.total_soles_igv as TOTAL_SOLES_IGV, 
        PR.cod_usuario_final as COD_USUARIO_FINAL, 
        PR.cod_gestor as COD_GESTOR,
        PR.supervisor_ventas as SUPERVISOR_VENTAS

    FROM tbl_preysd080 PR

    WHERE (PR.pedido=texto OR PR.cliente=texto OR PR.razon_social=texto OR PR.region=texto 
            OR PR.cod_usuario_final=texto OR PR.cod_gestor=texto OR PR.supervisor_ventas);

END$$
DELIMITER ;


-- analisis/fillrate

DROP PROCEDURE IF EXISTS dataFillrate;

DELIMITER $$
CREATE PROCEDURE dataFillrate(
    in fecha_ date
)
BEGIN

    DECLARE diaOne varchar(50) DEFAULT "";
    DECLARE diaTwo varchar(50) DEFAULT "";
    DECLARE totalMotivos DECIMAL(10,2);
    DECLARE totalClientesMotivos DECIMAL(10,2);

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

    -- OBTENIENDO TOTALES
    SELECT 
        SUM(A.TOTAL), SUM(A.CLIENTES) into totalMotivos, totalClientesMotivos
    FROM
        (
            SELECT 
                (
                    SUM(CASE WHEN R.devoluciones_totales IS NULL THEN 0 ELSE R.devoluciones_totales END) + 
                    SUM(CASE WHEN R.devoluciones_parciales IS NULL THEN 0 ELSE R.devoluciones_parciales END)
                )  as TOTAL,
                COUNT(*) as CLIENTES
            FROM tbl_resumen_dia R
            
            WHERE R.fec_ent=@ff and R.motivos_del_dia IS NOT NULL
            GROUP BY R.motivos_del_dia
        ) A;
    

    (SELECT 
        "Preventa total del día" as OBSERVACIONES, 
        SUM(R.total_soles_sin_igv_res) as SOLES_SIN_IGV,
        COUNT(*) as CLIENTES,
        NULL as PORCENTAJE
    FROM tbl_resumen_dia R
    
    WHERE R.fec_ent=@ff
    GROUP BY R.fec_ent)

    UNION ALL

    (SELECT 
        "Duplicados" as OBSERVACIONES, 
        SUM(R.total_soles_sin_igv_res) as SOLES_SIN_IGV,
        COUNT(*) as CLIENTES,
        NULL as PORCENTAJE
    FROM tbl_resumen_dia R

    LEFT JOIN

        (
            SELECT 
                RR.cliente as CLIENTE, 
                COUNT(*) as CONTEO 

            FROM tbl_resumen_dia RR
            WHERE RR.fec_ent=@ff
            GROUP BY RR.cliente
        ) RRR

    ON R.cliente=RRR.CLIENTE
    WHERE RRR.CONTEO>1 and R.fec_ent=@ff
    GROUP BY R.fec_ent)

    UNION ALL

    (SELECT 
        "Clientes prepago sin depósitos" as OBSERVACIONES, 
        0 as SOLES_SIN_IGV,
        0 as CLIENTES,
        NULL as PORCENTAJE)

    UNION ALL

    (SELECT 
        "FR (Fuera de política)" as OBSERVACIONES, 
        SUM(R.total_soles_sin_igv_res) as SOLES_SIN_IGV,
        COUNT(*) as CLIENTES,
        NULL as PORCENTAJE
    FROM tbl_resumen_dia R

    LEFT JOIN
        (
            SELECT 
                A.at_cliente_dias as COD_LLAMADA, 
                A.at_cliente_dias_descrip_2 as DIA

            FROM tbl_atencion A
        ) AA
    ON R.codigo_llamada_res=AA.COD_LLAMADA

    WHERE (AA.DIA!=diaOne and AA.DIA!=diaTwo) and (R.fec_ent=@ff and AA.COD_LLAMADA!="0000000")
    GROUP BY R.fec_ent)
    
    UNION ALL

    (
        SELECT 
            "Preventa para planificar" as OBSERVACIONES, 
            T1.PREVENTA - (T2.PREVENTA + T3.PREVENTA) as SOLES_SIN_IGV,
            T1.CLIENTES - (T2.CLIENTES + T3.CLIENTES) as CLIENTES,
            NULL as PORCENTAJE
        FROM
            (
                SELECT
                    1 as ONE, 
                    SUM(R.total_soles_sin_igv_res) as PREVENTA,
                    COUNT(*) as CLIENTES
                FROM tbl_resumen_dia R
                
                WHERE R.fec_ent=@ff
                GROUP BY R.fec_ent
            ) T1

        INNER JOIN 
            (
                SELECT
                    1 as ONE, 
                    SUM(R.total_soles_sin_igv_res) as PREVENTA,
                    COUNT(*) as CLIENTES
                FROM tbl_resumen_dia R

                LEFT JOIN

                    (
                        SELECT 
                            RR.cliente as CLIENTE, 
                            COUNT(*) as CONTEO 

                        FROM tbl_resumen_dia RR
                        WHERE RR.fec_ent=@ff
                        GROUP BY RR.cliente
                    ) RRR

                ON R.cliente=RRR.CLIENTE
                WHERE RRR.CONTEO>1 and R.fec_ent=@ff
                GROUP BY R.fec_ent
            ) T2
        ON T1.ONE=T2.ONE

        INNER JOIN
            (
                SELECT 
                    1 as ONE, 
                    SUM(R.total_soles_sin_igv_res) as PREVENTA,
                    COUNT(*) as CLIENTES
                FROM tbl_resumen_dia R

                LEFT JOIN
                    (
                        SELECT 
                            A.at_cliente_dias as COD_LLAMADA, 
                            A.at_cliente_dias_descrip_2 as DIA

                        FROM tbl_atencion A
                    ) AA
                ON R.codigo_llamada_res=AA.COD_LLAMADA

                WHERE (AA.DIA!=diaOne and AA.DIA!=diaTwo) and (R.fec_ent=@ff and AA.COD_LLAMADA!="0000000")
                GROUP BY R.fec_ent
            ) T3
        ON T2.ONE=T3.ONE 
    )

    UNION ALL

    (SELECT 
        "Fuera de ruta y mal geoposición" as OBSERVACIONES, 
        0 as SOLES_SIN_IGV,
        0 as CLIENTES,
        NULL as PORCENTAJE)

    UNION ALL

    (
        SELECT 
            "Preventa para facturar" as OBSERVACIONES, 
            TT1.SOLES_SIN_IGV -  TT2.SOLES_SIN_IGV as SOLES_SIN_IGV,
            TT1.CLIENTES - TT2.CLIENTES as CLIENTES,
            NULL as PORCENTAJE
        FROM
            
            (
                SELECT
                    1 as ONE,
                    T1.PREVENTA - (T2.PREVENTA + T3.PREVENTA) as SOLES_SIN_IGV,
                    T1.CLIENTES - (T2.CLIENTES + T3.CLIENTES) as CLIENTES
                FROM
                    (
                        SELECT
                            1 as ONE, 
                            SUM(R.total_soles_sin_igv_res) as PREVENTA,
                            COUNT(*) as CLIENTES
                        FROM tbl_resumen_dia R
                        
                        WHERE R.fec_ent=@ff
                        GROUP BY R.fec_ent
                    ) T1

                INNER JOIN 
                    (
                        SELECT
                            1 as ONE, 
                            SUM(R.total_soles_sin_igv_res) as PREVENTA,
                            COUNT(*) as CLIENTES
                        FROM tbl_resumen_dia R

                        LEFT JOIN

                            (
                                SELECT 
                                    RR.cliente as CLIENTE, 
                                    COUNT(*) as CONTEO 

                                FROM tbl_resumen_dia RR
                                WHERE RR.fec_ent=@ff
                                GROUP BY RR.cliente
                            ) RRR

                        ON R.cliente=RRR.CLIENTE
                        WHERE RRR.CONTEO>1 and R.fec_ent=@ff
                        GROUP BY R.fec_ent
                    ) T2
                ON T1.ONE=T2.ONE

                INNER JOIN
                    (
                        SELECT 
                            1 as ONE, 
                            SUM(R.total_soles_sin_igv_res) as PREVENTA,
                            COUNT(*) as CLIENTES
                        FROM tbl_resumen_dia R

                        LEFT JOIN
                            (
                                SELECT 
                                    A.at_cliente_dias as COD_LLAMADA, 
                                    A.at_cliente_dias_descrip_2 as DIA

                                FROM tbl_atencion A
                            ) AA
                        ON R.codigo_llamada_res=AA.COD_LLAMADA

                        WHERE (AA.DIA!=diaOne and AA.DIA!=diaTwo) and (R.fec_ent=@ff and AA.COD_LLAMADA!="0000000")
                        GROUP BY R.fec_ent
                    ) T3
                ON T2.ONE=T3.ONE 
            ) TT1

        INNER JOIN 
            (
                SELECT 
                    1 as ONE,
                    0 as SOLES_SIN_IGV,
                    0 as CLIENTES
            ) TT2

        ON TT1.ONE=TT2.ONE
    )

    UNION ALL

    (SELECT 
        "Quiebres" as OBSERVACIONES, 
        SUM(Q.soles) as SOLES_SIN_IGV,
        COUNT(*) as CLIENTES,
        NULL as PORCENTAJE
    FROM tbl_quiebre Q
    
    WHERE Q.fecha_importacion=@ff AND 
    Q.tipo="Stock Critico/Out"
    )

    UNION ALL

    (SELECT 
        "Errores de Sistema" as OBSERVACIONES, 
        SUM(Q.soles) as SOLES_SIN_IGV,
        COUNT(*) as CLIENTES,
        NULL as PORCENTAJE
    FROM tbl_quiebre Q
    
    WHERE Q.fecha_importacion=@ff AND 
    Q.tipo="Fuera de Ruta (FR)"
    )

    UNION ALL

    (SELECT 
        "Pedido duplicado" as OBSERVACIONES, 
        SUM(Q.soles) as SOLES_SIN_IGV,
        COUNT(*) as CLIENTES,
        NULL as PORCENTAJE
    FROM tbl_quiebre Q
    
    WHERE Q.fecha_importacion=@ff AND 
    Q.tipo="Pedido duplicado (PD)"
    )

    UNION ALL

    (SELECT 
        "Preventa planificado minorista" as OBSERVACIONES, 
        SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
        COUNT(*) as CLIENTES,
        NULL as PORCENTAJE
    FROM tbl_resumen_dia R
    
    WHERE R.fec_ent=@ff
    GROUP BY R.fec_ent)

    UNION ALL

    (SELECT 
        "Preventa planificada para Rep." as OBSERVACIONES, 
        0 as SOLES_SIN_IGV,
        0 as CLIENTES,
        NULL as PORCENTAJE)

    UNION ALL

    (SELECT 
        "Preventa facturado minorista" as OBSERVACIONES, 
        SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
        COUNT(*) as CLIENTES,
        NULL as PORCENTAJE
    FROM tbl_resumen_dia R
    
    WHERE R.fec_ent=@ff
    GROUP BY R.fec_ent)

    UNION ALL

    (SELECT 
        R.motivos_del_dia as OBSERVACIONES, 
        (
            SUM(CASE WHEN R.devoluciones_totales IS NULL THEN 0 ELSE R.devoluciones_totales END) + 
            SUM(CASE WHEN R.devoluciones_parciales IS NULL THEN 0 ELSE R.devoluciones_parciales END)
        )  as SOLES_SIN_IGV,
        COUNT(*) as CLIENTES,
        ROUND(((SUM(R.devoluciones_totales) + SUM(R.devoluciones_parciales))/totalMotivos)*100,0) as PORCENTAJE
    FROM tbl_resumen_dia R
    
    WHERE R.fec_ent=@ff and R.motivos_del_dia IS NOT NULL
    GROUP BY R.motivos_del_dia)

    UNION ALL

    (SELECT 
        "Totales de motivos" as OBSERVACIONES, 
        totalMotivos as SOLES_SIN_IGV,
        totalClientesMotivos as CLIENTES,
        ROUND(100,0) as PORCENTAJE
    FROM tbl_resumen_dia R
    
    WHERE R.fec_ent=@ff
    GROUP BY R.fec_ent)

    UNION ALL

    (SELECT 
        NULL as OBSERVACIONES, 
        NULL as SOLES_SIN_IGV,
        NULL as CLIENTES,
        NULL as PORCENTAJE)

    UNION ALL

    (
        SELECT
            "Entregado por el reparto C" as OBSERVACIONES, 
            TB1.SOLES_SIN_IGV - totalMotivos as SOLES_SIN_IGV,
            TB1.CLIENTES - totalClientesMotivos as CLIENTES,
            NULL as PORCENTAJE
        FROM

        (
            SELECT 
                SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
                COUNT(*) as CLIENTES
            FROM tbl_resumen_dia R
            
            WHERE R.fec_ent=@ff
            GROUP BY R.fec_ent
        )TB1
    )

    UNION ALL

    (
        SELECT
            "Fill rate (C/A)" as OBSERVACIONES, 
            (TBB1.SOLES_SIN_IGV/TBB2.SOLES_SIN_IGV)*100 as SOLES_SIN_IGV,
            (TBB1.CLIENTES/TBB2.CLIENTES)*100 as CLIENTES,
            NULL as PORCENTAJE
        FROM 

        (
            SELECT 
                1 as ONE,
                TB1.SOLES_SIN_IGV - totalMotivos as SOLES_SIN_IGV,
                TB1.CLIENTES - totalClientesMotivos as CLIENTES
            FROM

            (
                SELECT 
                    SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
                    COUNT(*) as CLIENTES
                FROM tbl_resumen_dia R
                
                WHERE R.fec_ent=@ff
                GROUP BY R.fec_ent
            )TB1
        )TBB1

        INNER JOIN

        (
            SELECT 
                1 as ONE,
                SUM(R.total_soles_sin_igv_res) as SOLES_SIN_IGV,
                COUNT(*) as CLIENTES
            FROM tbl_resumen_dia R
            
            WHERE R.fec_ent=@ff
            GROUP BY R.fec_ent
        )TBB2

        ON TBB1.ONE=TBB2.ONE
    )

    UNION ALL

    (
        SELECT
            "Efectividad reparto (C/B)" as OBSERVACIONES, 
            (TT1.SOLES_SIN_IGV/TT2.SOLES_SIN_IGV)*100 as SOLES_SIN_IGV,
            (TT1.CLIENTES/TT2.CLIENTES)*100 as CLIENTES,
            NULL as PORCENTAJE
        FROM

        (
            SELECT 
                1 as ONE,
                TB1.SOLES_SIN_IGV - totalMotivos as SOLES_SIN_IGV,
                TB1.CLIENTES - totalClientesMotivos as CLIENTES
            FROM

            (
                SELECT 
                    SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
                    COUNT(*) as CLIENTES
                FROM tbl_resumen_dia R
                
                WHERE R.fec_ent=@ff
                GROUP BY R.fec_ent
            )TB1
        )TT1

        INNER JOIN

        (
            SELECT 
                1 as ONE,
                SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
                COUNT(*) as CLIENTES
            FROM tbl_resumen_dia R
            
            WHERE R.fec_ent=@ff
            GROUP BY R.fec_ent
        )TT2

        ON TT1.ONE=TT2.ONE
    )

    UNION ALL

    (SELECT 
        NULL as OBSERVACIONES, 
        NULL as SOLES_SIN_IGV,
        NULL as CLIENTES,
        NULL as PORCENTAJE)

    UNION ALL

    (
        SELECT
            "% de fuera de ruta" as OBSERVACIONES,
            (TB1.SOLES_SIN_IGV/TB2.SOLES_SIN_IGV) * 100 as SOLES_SIN_IGV,
            (TB1.CLIENTES/TB2.CLIENTES) * 100 as CLIENTES,
            NULL as PORCENTAJE
        FROM

        (
            SELECT 
                1 as ONE,
                SUM(R.total_soles_sin_igv_res) as SOLES_SIN_IGV,
                COUNT(*) as CLIENTES
            FROM tbl_resumen_dia R

            LEFT JOIN
                (
                    SELECT 
                        A.at_cliente_dias as COD_LLAMADA, 
                        A.at_cliente_dias_descrip_2 as DIA

                    FROM tbl_atencion A
                ) AA
            ON R.codigo_llamada_res=AA.COD_LLAMADA

            WHERE (AA.DIA!=diaOne and AA.DIA!=diaTwo) and (R.fec_ent=@ff and AA.COD_LLAMADA!="0000000")
            GROUP BY R.fec_ent
        ) TB1

        INNER JOIN
        (
            SELECT 
                1 as ONE,
                TB1.SOLES_SIN_IGV - totalMotivos as SOLES_SIN_IGV,
                TB1.CLIENTES - totalClientesMotivos as CLIENTES
            FROM

            (
                SELECT 
                    SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
                    COUNT(*) as CLIENTES
                FROM tbl_resumen_dia R
                
                WHERE R.fec_ent=@ff
                GROUP BY R.fec_ent
            )TB1
        )TB2

        ON TB1.ONE=TB2.ONE
    )

    UNION ALL

    (
        SELECT
             "% de pedidos <40" as OBSERVACIONES,
            (TB1.SOLES_SIN_IGV/TB2.SOLES_SIN_IGV) * 100 as SOLES_SIN_IGV,
            (TB1.CLIENTES/TB2.CLIENTES) * 100 as CLIENTES,
            NULL as PORCENTAJE
        FROM

        (
            SELECT 
                1 as ONE,
                SUM(R.total_soles_sin_igv_res) as SOLES_SIN_IGV,
                COUNT(*) as CLIENTES
            FROM tbl_resumen_dia R

            WHERE R.fec_ent=@ff and R.pedido_40="SI"
            GROUP BY R.fec_ent
        ) TB1

        INNER JOIN
        (
            SELECT 
                1 as ONE,
                TB1.SOLES_SIN_IGV - totalMotivos as SOLES_SIN_IGV,
                TB1.CLIENTES - totalClientesMotivos as CLIENTES
            FROM

            (
                SELECT 
                    SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
                    COUNT(*) as CLIENTES
                FROM tbl_resumen_dia R
                
                WHERE R.fec_ent=@ff
                GROUP BY R.fec_ent
            )TB1
        )TB2

        ON TB1.ONE=TB2.ONE
    )

    UNION ALL

    (SELECT 
        NULL as OBSERVACIONES, 
        NULL as SOLES_SIN_IGV,
        NULL as CLIENTES,
        NULL as PORCENTAJE)

    UNION ALL

    (SELECT 
        NULL as OBSERVACIONES, 
        NULL as SOLES_SIN_IGV,
        NULL as CLIENTES,
        NULL as PORCENTAJE)

    UNION ALL

    (
        SELECT
            "Fill rate S/. " as OBSERVACIONES, 
            (TBB1.SOLES_SIN_IGV/TBB2.SOLES_SIN_IGV)*100 as SOLES_SIN_IGV,
            0 as CLIENTES,
            NULL as PORCENTAJE
        FROM 

        (
            SELECT 
                1 as ONE,
                TB1.SOLES_SIN_IGV - totalMotivos as SOLES_SIN_IGV,
                TB1.CLIENTES - totalClientesMotivos as CLIENTES
            FROM

            (
                SELECT 
                    SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
                    COUNT(*) as CLIENTES
                FROM tbl_resumen_dia R
                
                WHERE R.fec_ent=@ff
                GROUP BY R.fec_ent
            )TB1
        )TBB1

        INNER JOIN

        (
            SELECT 
                1 as ONE,
                SUM(R.total_soles_sin_igv_res) as SOLES_SIN_IGV,
                COUNT(*) as CLIENTES
            FROM tbl_resumen_dia R
            
            WHERE R.fec_ent=@ff
            GROUP BY R.fec_ent
        )TBB2

        ON TBB1.ONE=TBB2.ONE
    )

    UNION ALL

    (
        SELECT
            "Fill rate Clientes " as OBSERVACIONES, 
            (TBB1.CLIENTES/TBB2.CLIENTES)*100 as SOLES_SIN_IGV,
            0 as CLIENTES,
            NULL as PORCENTAJE
        FROM 

        (
            SELECT 
                1 as ONE,
                TB1.SOLES_SIN_IGV - totalMotivos as SOLES_SIN_IGV,
                TB1.CLIENTES - totalClientesMotivos as CLIENTES
            FROM

            (
                SELECT 
                    SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
                    COUNT(*) as CLIENTES
                FROM tbl_resumen_dia R
                
                WHERE R.fec_ent=@ff
                GROUP BY R.fec_ent
            )TB1
        )TBB1

        INNER JOIN

        (
            SELECT 
                1 as ONE,
                SUM(R.total_soles_sin_igv_res) as SOLES_SIN_IGV,
                COUNT(*) as CLIENTES
            FROM tbl_resumen_dia R
            
            WHERE R.fec_ent=@ff
            GROUP BY R.fec_ent
        )TBB2

        ON TBB1.ONE=TBB2.ONE
    )

    UNION ALL

    (
        SELECT
            "Efectividad S/." as OBSERVACIONES, 
            (TT1.SOLES_SIN_IGV/TT2.SOLES_SIN_IGV)*100 as SOLES_SIN_IGV,
            0 as CLIENTES,
            NULL as PORCENTAJE
        FROM

        (
            SELECT 
                1 as ONE,
                TB1.SOLES_SIN_IGV - totalMotivos as SOLES_SIN_IGV,
                TB1.CLIENTES - totalClientesMotivos as CLIENTES
            FROM

            (
                SELECT 
                    SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
                    COUNT(*) as CLIENTES
                FROM tbl_resumen_dia R
                
                WHERE R.fec_ent=@ff
                GROUP BY R.fec_ent
            )TB1
        )TT1

        INNER JOIN

        (
            SELECT 
                1 as ONE,
                SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
                COUNT(*) as CLIENTES
            FROM tbl_resumen_dia R
            
            WHERE R.fec_ent=@ff
            GROUP BY R.fec_ent
        )TT2

        ON TT1.ONE=TT2.ONE
    )

    UNION ALL

    (
        SELECT
            "Efectividad Clientes" as OBSERVACIONES, 
            (TT1.CLIENTES/TT2.CLIENTES)*100 as SOLES_SIN_IGV,
            0 as CLIENTES,
            NULL as PORCENTAJE
        FROM

        (
            SELECT 
                1 as ONE,
                TB1.SOLES_SIN_IGV - totalMotivos as SOLES_SIN_IGV,
                TB1.CLIENTES - totalClientesMotivos as CLIENTES
            FROM

            (
                SELECT 
                    SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
                    COUNT(*) as CLIENTES
                FROM tbl_resumen_dia R
                
                WHERE R.fec_ent=@ff
                GROUP BY R.fec_ent
            )TB1
        )TT1

        INNER JOIN

        (
            SELECT 
                1 as ONE,
                SUM(R.total_fact_sin_igv_res) as SOLES_SIN_IGV,
                COUNT(*) as CLIENTES
            FROM tbl_resumen_dia R
            
            WHERE R.fec_ent=@ff
            GROUP BY R.fec_ent
        )TT2

        ON TT1.ONE=TT2.ONE
    );

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS importBasePreventaYSD080;

DELIMITER $$
CREATE PROCEDURE `importBasePreventaYSD080`(
in fec_creacion_ date,
in can_dist_ int,
in grp_vend_ varchar(20),
in nombres_apellidos_ varchar(150),
in material_ varchar(50),
in can_ped_tm_ decimal(10,3),
in importe_ decimal(10,2),
in pto_expedicion_ varchar(30)
)
BEGIN

    DECLARE categoria_ varchar(80);
    DECLARE tipo_ varchar(80);
    DECLARE sede_ varchar(80);

    SELECT M.categoria, M.tipo into categoria_, tipo_ FROM tbl_material M where M.sku=material_ GROUP BY M.categoria, M.tipo;
    SELECT C.orr into sede_ FROM tbl_centros C where C.psex=pto_expedicion_;
    
    INSERT INTO tbl_ysd080_temporal VALUES (default, fec_creacion_, can_dist_, grp_vend_, nombres_apellidos_, material_,
                                            can_ped_tm_, importe_, pto_expedicion_, categoria_, tipo_, sede_);
	
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataPreventaTablaOne;

DELIMITER $$
CREATE PROCEDURE dataPreventaTablaOne(
    in fecha_ date,
    in cd_ varchar(50)
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    IF cd_ IS NULL OR cd_ = "" THEN
        
        SELECT 
            Y.grp_vend as GRP_VEND,
            Y.nombres_apellidos as NOMBRES,
            SUM(Y.can_ped_tm) as PESO,
            SUM(Y.importe) as TOTAL_VENTA

        FROM tbl_ysd080_temporal Y 
        WHERE Y.fec_creacion=@ff GROUP BY Y.grp_vend;

    ELSE

        SELECT 
            Y.grp_vend as GRP_VEND,
            Y.nombres_apellidos as NOMBRES,
            SUM(Y.can_ped_tm) as PESO,
            SUM(Y.importe) as TOTAL_VENTA

        FROM tbl_ysd080_temporal Y 
        WHERE Y.fec_creacion=@ff and Y.sede=cd_ GROUP BY Y.grp_vend;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataPreventaTablaOneTotales;

DELIMITER $$
CREATE PROCEDURE dataPreventaTablaOneTotales(
    in fecha_ date,
    in cd_ varchar(50)
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    IF cd_ IS NULL OR cd_ = "" THEN
        
        SELECT 
            Y.grp_vend as GRP_VEND,
            Y.nombres_apellidos as NOMBRES,
            SUM(Y.can_ped_tm) as PESO,
            SUM(Y.importe) as TOTAL_VENTA

        FROM tbl_ysd080_temporal Y 
        WHERE Y.fec_creacion=@ff;

    ELSE

        SELECT 
            Y.grp_vend as GRP_VEND,
            Y.nombres_apellidos as NOMBRES,
            SUM(Y.can_ped_tm) as PESO,
            SUM(Y.importe) as TOTAL_VENTA

        FROM tbl_ysd080_temporal Y 
        WHERE Y.fec_creacion=@ff and Y.sede=cd_;
        
    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataPreventaTablaTwo;
DELIMITER $$
CREATE PROCEDURE dataPreventaTablaTwo(
    in fecha_ date,
    in cd_ varchar(50)
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    IF cd_ IS NULL OR cd_ = "" THEN
        
        SELECT 
            Y.can_dist as CANAL_VTA,
            SUM(Y.importe) as TOTAL_VENTA,
            SUM(Y.can_ped_tm) as PESO

        FROM tbl_ysd080_temporal Y 
        WHERE Y.fec_creacion=@ff GROUP BY Y.can_dist;

    ELSE

        SELECT 
            Y.can_dist as CANAL_VTA,
            SUM(Y.importe) as TOTAL_VENTA,
            SUM(Y.can_ped_tm) as PESO

        FROM tbl_ysd080_temporal Y 
        WHERE Y.fec_creacion=@ff and Y.sede=cd_ GROUP BY Y.can_dist;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataPreventaTablaTwoTotales;
DELIMITER $$
CREATE PROCEDURE dataPreventaTablaTwoTotales(
    in fecha_ date,
    in cd_ varchar(50)
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    IF cd_ IS NULL OR cd_ = "" THEN
        
        SELECT 
            Y.can_dist as CANAL_VTA,
            SUM(Y.importe) as TOTAL_VENTA,
            SUM(Y.can_ped_tm) as PESO

        FROM tbl_ysd080_temporal Y 
        WHERE Y.fec_creacion=@ff;

    ELSE

        SELECT 
            Y.can_dist as CANAL_VTA,
            SUM(Y.importe) as TOTAL_VENTA,
            SUM(Y.can_ped_tm) as PESO

        FROM tbl_ysd080_temporal Y 
        WHERE Y.fec_creacion=@ff and Y.sede=cd_;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataPreventaTablaThree;
DELIMITER $$
CREATE PROCEDURE dataPreventaTablaThree(
    in fecha_ date,
    in cd_ varchar(50)
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    IF cd_ IS NULL OR cd_ = "" THEN
        
        SELECT 
            Y.categoria as CATEGORIA,
            SUM(Y.can_ped_tm) as PESO,
            SUM(Y.importe) as TOTAL_VENTA

        FROM tbl_ysd080_temporal Y 
        WHERE Y.fec_creacion=@ff GROUP BY Y.categoria;

    ELSE

        SELECT 
            Y.categoria as CATEGORIA,
            SUM(Y.can_ped_tm) as PESO,
            SUM(Y.importe) as TOTAL_VENTA

        FROM tbl_ysd080_temporal Y 
        WHERE Y.fec_creacion=@ff and Y.sede=cd_ GROUP BY Y.categoria;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataPreventaTablaThreeTotales;
DELIMITER $$
CREATE PROCEDURE dataPreventaTablaThreeTotales(
    in fecha_ date,
    in cd_ varchar(50)
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    IF cd_ IS NULL OR cd_ = "" THEN
        
        SELECT 
            Y.categoria as CATEGORIA,
            SUM(Y.can_ped_tm) as PESO,
            SUM(Y.importe) as TOTAL_VENTA

        FROM tbl_ysd080_temporal Y 
        WHERE Y.fec_creacion=@ff;

    ELSE

        SELECT 
            Y.categoria as CATEGORIA,
            SUM(Y.can_ped_tm) as PESO,
            SUM(Y.importe) as TOTAL_VENTA

        FROM tbl_ysd080_temporal Y 
        WHERE Y.fec_creacion=@ff and Y.sede=cd_;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataQuiebreTablaOne;
DELIMITER $$
CREATE PROCEDURE dataQuiebreTablaOne(
    in fecha_ date,
    in operacion_ varchar(50)
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    IF operacion_ IS NULL OR operacion_ = "" THEN
        
        SELECT 
            Q.operacion OPERACION,
            SUM(Q.soles) SOLES
        FROM tbl_quiebre Q 
        WHERE Q.fecha_importacion=@ff GROUP BY Q.operacion;

    ELSE

        SELECT 
            Q.operacion OPERACION,
            SUM(Q.soles) SOLES
        FROM tbl_quiebre Q 
        WHERE Q.fecha_importacion=@ff AND Q.operacion=operacion_
        GROUP BY Q.operacion;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataQuiebreTablaTwo;
DELIMITER $$
CREATE PROCEDURE dataQuiebreTablaTwo(
    in fecha_ date,
    in operacion_ varchar(50)
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    IF operacion_ IS NULL OR operacion_ = "" THEN
        
        SELECT 
            Q.tipo TIPO_BLOQUEO,
            COUNT(*) CANTIDAD,
            SUM(Q.soles) SOLES
        FROM tbl_quiebre Q 
        WHERE Q.fecha_importacion=@ff GROUP BY Q.tipo;

    ELSE

        SELECT 
            Q.tipo TIPO_BLOQUEO,
            COUNT(*) CANTIDAD,
            SUM(Q.soles) SOLES
        FROM tbl_quiebre Q 
        WHERE Q.fecha_importacion=@ff AND Q.operacion=operacion_ 
        GROUP BY Q.tipo;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataQuiebreTablaThree;
DELIMITER $$
CREATE PROCEDURE dataQuiebreTablaThree(
    in fecha_ date,
    in operacion_ varchar(50)
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    IF operacion_ IS NULL OR operacion_ = "" THEN
        
        SELECT 
            Q.material MATERIAL,
            Q.texto_breve TEXTO_BREVE,
            SUM(Q.soles) SOLES
        FROM tbl_quiebre Q 
        WHERE Q.fecha_importacion=@ff GROUP BY Q.material
        ORDER BY SUM(Q.soles) DESC;

    ELSE

        SELECT 
            Q.material MATERIAL,
            Q.texto_breve TEXTO_BREVE,
            SUM(Q.soles) SOLES
        FROM tbl_quiebre Q 
        WHERE Q.fecha_importacion=@ff AND Q.operacion=operacion_ 
        GROUP BY Q.material
        ORDER BY SUM(Q.soles) DESC;

    END IF;

END$$
DELIMITER ;