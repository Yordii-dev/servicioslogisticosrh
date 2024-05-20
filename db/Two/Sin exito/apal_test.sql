-- PRUEBAS 

SELECT 
        COUNT(total_peso) as total_peso, 
        SUM(P.total_soles_sin_igv) as total_soles_sin_igv, 
        SUM(P.total_soles_igv) as total_soles_igv, 
        codigo_llamada

    FROM tbl_preysd080 P
    LEFT JOIN 
    	(SELECT pedido, codigo_llamada FROM tbl_resumen_dia) R
    on P.pedido= R.pedido
    
    WHERE P.fec_ent="2022-05-28"
    GROUP BY R.codigo_llamada



-- PARA ELIMINAR REGISTROS DE PREYSD080 Y RESUMEN_DIA
DELETE FROM tbl_preysd080 where fec_ent="2022-05-26";
DELETE FROM tbl_resumen_dia where fec_ent="2022-05-26";

call nivelar_preysd080("2022-05-26");
call nivelar_resumendia("2022-05-26");


-- PRUEBA DE PIVOT CONSOLIDADO CÓDIGO DE LLAMADA

DROP PROCEDURE IF EXISTS dataPivotreporteir;

DELIMITER $$
CREATE PROCEDURE dataPivotreporteir(
    in fecha_ date
)
BEGIN

    SET @sql = NULL;
    SET @sqltwo = NULL;
    SET @sqlthree = NULL;
    SET @sqlfour = NULL;
    

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;


    SELECT
      GROUP_CONCAT(
        DISTINCT
        CONCAT('SUM(IF(`codigo_llamada` = ', `codigo_llamada`, ',total_soles_sin_igv,NULL)) AS DIA', `codigo_llamada`)
      ) INTO @sql

    FROM tbl_preysd080 P
    LEFT JOIN 
    	(SELECT pedido, codigo_llamada FROM tbl_resumen_dia) R
    on P.pedido= R.pedido
    WHERE P.fec_ent=@ff;


    SELECT
      GROUP_CONCAT(
        DISTINCT
        CONCAT('SUM(IF(`codigo_llamada` = ', `codigo_llamada`, ',total_soles_igv,NULL)) AS DIA', `codigo_llamada`)
      ) INTO @sqltwo

    FROM tbl_preysd080 P
    LEFT JOIN 
    	(SELECT pedido, codigo_llamada FROM tbl_resumen_dia) R
    on P.pedido= R.pedido
    WHERE P.fec_ent=@ff;


    SELECT
      GROUP_CONCAT(
        DISTINCT
        CONCAT('SUM(IF(`codigo_llamada` = ', `codigo_llamada`, ',total_peso,NULL)) AS DIA', `codigo_llamada`)
      ) INTO @sqlthree

    FROM tbl_preysd080 P
    LEFT JOIN 
    	(SELECT pedido, codigo_llamada FROM tbl_resumen_dia) R
    on P.pedido= R.pedido
    WHERE P.fec_ent=@ff;


    SELECT
      GROUP_CONCAT(
        DISTINCT
        CONCAT('COUNT(IF(`codigo_llamada` = ', `codigo_llamada`, ',cliente,NULL)) AS DIA', `codigo_llamada`)
      ) INTO @sqlfour

    FROM tbl_preysd080 P
    LEFT JOIN 
    	(SELECT pedido, codigo_llamada FROM tbl_resumen_dia) R
    on P.pedido= R.pedido
    WHERE P.fec_ent=@ff;


    SET @sql = CONCAT(' (SELECT ', @sql, ', SUM(total_soles_sin_igv) as TOTAL
                        FROM tbl_preysd080 P
                        LEFT JOIN 
                            (SELECT pedido, codigo_llamada, fec_ent FROM tbl_resumen_dia) R
                        on P.pedido= R.pedido
                        
                        WHERE P.fec_ent=@ff and R.codigo_llamada IS NOT NULL
                        GROUP BY R.fec_ent)
                        
                        UNION ALL
                        
                        (SELECT ', @sqltwo, ', SUM(total_soles_igv) as TOTAL
                        FROM tbl_preysd080 P
                        LEFT JOIN 
                            (SELECT pedido, codigo_llamada, fec_ent FROM tbl_resumen_dia) R
                        on P.pedido= R.pedido
                        
                        WHERE P.fec_ent=@ff and R.codigo_llamada IS NOT NULL
                        GROUP BY R.fec_ent)
                        
                        UNION ALL

                        (SELECT ', @sqlthree, ', SUM(total_peso) as TOTAL
                        FROM tbl_preysd080 P
                        LEFT JOIN 
                            (SELECT pedido, codigo_llamada, fec_ent FROM tbl_resumen_dia) R
                        on P.pedido= R.pedido
                        
                        WHERE P.fec_ent=@ff and R.codigo_llamada IS NOT NULL
                        GROUP BY R.fec_ent)
                        
                        UNION ALL
                        
                        (SELECT ', @sqlfour, ', COUNT(cliente) as TOTAL
                        FROM tbl_preysd080 P
                        LEFT JOIN 
                            (SELECT pedido, codigo_llamada, fec_ent FROM tbl_resumen_dia) R
                        on P.pedido= R.pedido
                        
                        WHERE P.fec_ent=@ff and R.codigo_llamada IS NOT NULL
                        GROUP BY R.fec_ent)');

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END$$
DELIMITER ;


-- ADD COLUMNS

ALTER TABLE tbl_preysd080 ADD COLUMN pedido_40 varchar(20);
ALTER TABLE tbl_preysd080 ADD COLUMN reincidente int;
ALTER TABLE tbl_preysd080 ADD COLUMN pedido_volumen varchar(20);
ALTER TABLE tbl_preysd080 ADD COLUMN codigo_llamada varchar(30);
ALTER TABLE tbl_preysd080 ADD COLUMN dia_llamada varchar(30);


-- QUERIES ANTIGUOS DE PLANEAMMIENTOS/DUPLICADOSDIA

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
            RR.*,
            CT.CONTEO as duplicado
        FROM tbl_resumen_dia RR

        LEFT JOIN

            (
                SELECT 
                    L.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_resumen_dia L
                WHERE L.fec_ent=@ff
                GROUP BY L.cliente
            ) CT

        ON RR.cliente=CT.CLIENTE
        WHERE CT.CONTEO>1 and RR.fec_ent=@ff;

    ELSE

        SELECT 
            RR.*,
            CT.CONTEO as duplicado
        FROM tbl_resumen_dia RR

        LEFT JOIN

            (
                SELECT 
                    L.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_resumen_dia L
                WHERE L.fec_ent=@ff
                GROUP BY L.cliente
            ) CT

        ON RR.cliente=CT.CLIENTE
        WHERE CT.CONTEO>1 and RR.fec_ent=@ff
        ORDER BY RR.cliente ASC
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
            RR.*,
            CT.CONTEO as duplicado
        FROM tbl_resumen_dia RR

        LEFT JOIN

            (
                SELECT 
                    L.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_resumen_dia L
                GROUP BY L.cliente
            ) CT

        ON RR.cliente=CT.CLIENTE
        WHERE RR.reincidente>3 and RR.fec_ent=@ff;

    ELSE

        SELECT 
            RR.*,
            CT.CONTEO as duplicado
        FROM tbl_resumen_dia RR

        LEFT JOIN

            (
                SELECT 
                    L.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_resumen_dia L
                GROUP BY L.cliente
            ) CT

        ON RR.cliente=CT.CLIENTE
        WHERE RR.reincidente>3 and RR.fec_ent=@ff
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
            RR.*,
            CT.CONTEO as duplicado
        FROM tbl_resumen_dia RR

        LEFT JOIN

            (
                SELECT 
                    L.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_resumen_dia L
                GROUP BY L.cliente
            ) CT

        ON RR.cliente=CT.CLIENTE
        WHERE RR.pedido_volumen="SI" and RR.fec_ent=@ff;

    ELSE

        SELECT 
            RR.*,
            CT.CONTEO as duplicado
        FROM tbl_resumen_dia RR

        LEFT JOIN

            (
                SELECT 
                    L.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_resumen_dia L
                GROUP BY L.cliente
            ) CT

        ON RR.cliente=CT.CLIENTE
        WHERE RR.pedido_volumen="SI" and RR.fec_ent=@ff
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

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;
    
    IF per_pages=0 THEN 

        SELECT 
            RR.*,
            CT.CONTEO as duplicado
        FROM tbl_resumen_dia RR

        LEFT JOIN
            (
                SELECT 
                    L.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_resumen_dia L
                GROUP BY L.cliente
            ) CT

        ON RR.cliente=CT.CLIENTE

        LEFT JOIN
            (
                SELECT 
                    A.at_cliente_dias as COD_LLAMADA, 
                    A.at_cliente_dias_descrip_2 as DIA

                FROM tbl_atencion A
            ) AA

        ON RR.codigo_llamada=AA.COD_LLAMADA

        WHERE AA.DIA!=UPPER(CONCAT(UCASE(LEFT(DAYNAME(@ff), 1)), 
            SUBSTRING(DAYNAME(@ff), 2))) and RR.fec_ent=@ff;

    ELSE

        SELECT 
            RR.*,
            CT.CONTEO as duplicado
        FROM tbl_resumen_dia RR

        LEFT JOIN
            (
                SELECT 
                    L.cliente as CLIENTE, 
                    COUNT(*) as CONTEO 

                FROM tbl_resumen_dia L
                GROUP BY L.cliente
            ) CT

        ON RR.cliente=CT.CLIENTE

        LEFT JOIN
            (
                SELECT 
                    A.at_cliente_dias as COD_LLAMADA, 
                    A.at_cliente_dias_descrip_2 as DIA

                FROM tbl_atencion A
            ) AA

        ON RR.codigo_llamada=AA.COD_LLAMADA

        WHERE AA.DIA!=UPPER(CONCAT(UCASE(LEFT(DAYNAME(@ff), 1)), 
            SUBSTRING(DAYNAME(@ff), 2))) and RR.fec_ent=@ff
        LIMIT desde,per_pages; 

    END IF;

END$$
DELIMITER ;



-- PIVOT


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

    SELECT
        COUNT(*) into validacion FROM tbl_preysd080 P
    LEFT JOIN 
    	(SELECT pedido, codigo_llamada_res, dia_llamada_res, fec_ent FROM tbl_resumen_dia) R
    ON P.pedido= R.pedido
    WHERE P.fec_ent=@ff and R.codigo_llamada_res IS NOT NULL
    GROUP BY R.fec_ent;


    IF validacion>0 THEN

        SELECT
        GROUP_CONCAT(
            DISTINCT
            CONCAT('SUM(IF(`codigo_llamada_res` = ', `codigo_llamada_res`, ',total_soles_sin_igv,NULL)) AS DIA_', `codigo_llamada_res`)
        ) INTO @sql

        FROM tbl_preysd080 P
        LEFT JOIN 
            (SELECT pedido, codigo_llamada_res FROM tbl_resumen_dia) R
        on P.pedido= R.pedido
        WHERE P.fec_ent=@ff;


        SELECT
        GROUP_CONCAT(
            DISTINCT
            CONCAT('SUM(IF(`codigo_llamada_res` = ', `codigo_llamada_res`, ',total_soles_igv,NULL)) AS DIA_', `codigo_llamada_res`)
        ) INTO @sqltwo

        FROM tbl_preysd080 P
        LEFT JOIN 
            (SELECT pedido, codigo_llamada_res FROM tbl_resumen_dia) R
        on P.pedido= R.pedido
        WHERE P.fec_ent=@ff;


        SELECT
        GROUP_CONCAT(
            DISTINCT
            CONCAT('SUM(IF(`codigo_llamada_res` = ', `codigo_llamada_res`, ',total_peso,NULL)) AS DIA_', `codigo_llamada_res`)
        ) INTO @sqlthree

        FROM tbl_preysd080 P
        LEFT JOIN 
            (SELECT pedido, codigo_llamada_res FROM tbl_resumen_dia) R
        on P.pedido= R.pedido
        WHERE P.fec_ent=@ff;


        SELECT
        GROUP_CONCAT(
            DISTINCT
            CONCAT('COUNT(IF(`codigo_llamada_res` = ', `codigo_llamada_res`, ',cliente,NULL)) AS DIA_', `codigo_llamada_res`)
        ) INTO @sqlfour

        FROM tbl_preysd080 P
        LEFT JOIN 
            (SELECT pedido, codigo_llamada_res FROM tbl_resumen_dia) R
        on P.pedido= R.pedido
        WHERE P.fec_ent=@ff;


        SET @sql = CONCAT(' 

                            (SELECT "TOT. CLIE. PREVENTA" as ATENCION, ', @sqlfour, ', COUNT(cliente) as TOTAL
                            FROM tbl_preysd080 P
                            LEFT JOIN 
                                (SELECT pedido, codigo_llamada_res, fec_ent FROM tbl_resumen_dia) R
                            on P.pedido= R.pedido
                            
                            WHERE P.fec_ent=@ff and R.codigo_llamada_res IS NOT NULL
                            GROUP BY R.fec_ent)

                            UNION ALL
        
                            (SELECT "TOT. VENTA - [IGV]" as ATENCION, ', @sql, ', SUM(total_soles_sin_igv) as TOTAL
                            FROM tbl_preysd080 P
                            LEFT JOIN 
                                (SELECT pedido, codigo_llamada_res, fec_ent FROM tbl_resumen_dia) R
                            on P.pedido= R.pedido
                            
                            WHERE P.fec_ent=@ff and R.codigo_llamada_res IS NOT NULL
                            GROUP BY R.fec_ent)
                            
                            UNION ALL
                            
                            (SELECT "TOT. VENTA + [IGV]" as ATENCION, ', @sqltwo, ', SUM(total_soles_igv) as TOTAL
                            FROM tbl_preysd080 P
                            LEFT JOIN 
                                (SELECT pedido, codigo_llamada_res, fec_ent FROM tbl_resumen_dia) R
                            on P.pedido= R.pedido
                            
                            WHERE P.fec_ent=@ff and R.codigo_llamada_res IS NOT NULL
                            GROUP BY R.fec_ent)
                            
                            UNION ALL

                            (SELECT "TOTAL PESO" as ATENCION,  ', @sqlthree, ', SUM(total_peso) as TOTAL
                            FROM tbl_preysd080 P
                            LEFT JOIN 
                                (SELECT pedido, codigo_llamada_res, fec_ent FROM tbl_resumen_dia) R
                            on P.pedido= R.pedido
                            
                            WHERE P.fec_ent=@ff and R.codigo_llamada_res IS NOT NULL
                            GROUP BY R.fec_ent)
                            ');

        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    END IF;

END$$
DELIMITER ;


INSERT INTO tbl_pers (id_reg, cod_reg, fec_reg, ruc_emp, nom_emp, tip_doc, nro_doc, nom_ape, direccion, geoposicion, imagen, nro_tlfno, cargo, fec_nac, estado, fecha_caducidad, licencia) VALUES
(default, '70000', '2022-02-17', '20455707111', 'L&L OPERADOR SUR LOGISTICO EIRL', 'DNI', '40460367', 'WILFREDO CORONEL', 'JR. SANTA CRUZ 123 - URB CERRILLOS', '343', '', '975606036', 'ENCARGADO', '2022-02-01', 1, '2022-04-09', 'ACF-OND'),
(default, '70001', '2022-02-02', '20455707111', 'L&L OPERADOR SUR LOGISTICO EIRL', 'DNI', '23434545', 'Apaza Ramos David', 'JR. PASCO 450-URB SAN PABLO', '434', '', '994546978', 'CONDUCTOR', '2001-02-01', 1, '2022-04-09', 'EON-103');



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
        WHERE (B.destinatario= "7200023252") and  R.fec_emis="2022-06-03"
        group by R.codigo ORDER BY R.fec_emis DESC
        ) 
    AS t
    GROUP BY t.DESTINATARIO;

END$$
DELIMITER ;


SELECT * FROM tbl_pages PP 
WHERE NOT EXISTS 
(
    SELECT 
        NULL 
    FROM tbl_user U 
    INNER JOIN tbl_rol R on (U.id_rol=R.id_rol) 
    INNER JOIN tbl_rol_pages RP ON (R.id_rol=RP.id_rol) 
    INNER JOIN tbl_centros C on (C.id_centro=RP.id_centro) 
    INNER JOIN tbl_pages P on(P.id_page=RP.id_page) 
    WHERE U.id_user=1 AND 
    (P.id_page=PP.id_page)
);

SELECT * FROM tbl_pages PP 
WHERE NOT EXISTS 
(
    SELECT 
        NULL 
    FROM tbl_user U 
    INNER JOIN tbl_rol R on (U.id_rol=R.id_rol) 
    INNER JOIN tbl_rol_pages RP ON (R.id_rol=RP.id_rol) 
    INNER JOIN tbl_centros C on (C.id_centro=RP.id_centro) 
    INNER JOIN tbl_pages P on(P.id_page=RP.id_page) 
    WHERE (R.id_rol=1 AND C.id_centro=1) AND 
    (P.id_page=PP.id_page)
);



--

ALTER TABLE tbl_checklist_cabinas DROP CONSTRAINT fk_cabinas_check;
ALTER TABLE tbl_checklist_cabinas DROP CONSTRAINT fk_cabinas_inspeccion;
ALTER TABLE tbl_checklist_cabinas DROP CONSTRAINT fk_cabinas_calificacion;

ALTER TABLE tbl_checklist_electrica DROP CONSTRAINT fk_electrica_check;
ALTER TABLE tbl_checklist_electrica DROP CONSTRAINT fk_electricas_inspeccion_elec;
ALTER TABLE tbl_checklist_electrica DROP CONSTRAINT fk_electrica_calificacion;

ALTER TABLE tbl_checklist_desinfeccion DROP CONSTRAINT fk_desinfeccion_check;
ALTER TABLE tbl_checklist_desinfeccion DROP CONSTRAINT fk_desinfeccion_kit;
ALTER TABLE tbl_checklist_desinfeccion DROP CONSTRAINT fk_desinfeccion_calificacion;

ALTER TABLE tbl_checklist_bioseguridad DROP CONSTRAINT fk_bioseguridad_check;
ALTER TABLE tbl_checklist_bioseguridad DROP CONSTRAINT fk_bioseguridad_elemento;
ALTER TABLE tbl_checklist_bioseguridad DROP CONSTRAINT fk_bioseguridad_calificacion;

ALTER TABLE tbl_checklist_mecanica DROP CONSTRAINT fk_mecanica_check;
ALTER TABLE tbl_checklist_mecanica DROP CONSTRAINT fk_mecanica_inspeccionmec;
ALTER TABLE tbl_checklist_mecanica DROP CONSTRAINT fk_mecanica_calificacion;

ALTER TABLE tbl_checklist_epps DROP CONSTRAINT fk_epps_check;
ALTER TABLE tbl_checklist_epps DROP CONSTRAINT fk_epps_inspeccionmec;
ALTER TABLE tbl_checklist_epps DROP CONSTRAINT fk_epps_calificacion;

ALTER TABLE tbl_checklist_seguridad DROP CONSTRAINT fk_seguridad_check;
ALTER TABLE tbl_checklist_seguridad DROP CONSTRAINT fk_seguridad_inspeccionseg;
ALTER TABLE tbl_checklist_seguridad DROP CONSTRAINT fk_seguridad_calificacion;

--

ALTER TABLE tbl_checklist_cabinas ADD CONSTRAINT fk_cabinas_check FOREIGN KEY (id_checklist) REFERENCES tbl_checklist(id_checklist) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_cabinas ADD CONSTRAINT fk_cabinas_inspeccion FOREIGN KEY (id_inspeccion_cabina) REFERENCES tbl_inspeccion_cabinas(id_inspeccion_cabina) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_cabinas ADD CONSTRAINT fk_cabinas_calificacion FOREIGN KEY (id_calificacion) REFERENCES tbl_calificacion(id_calificacion) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE tbl_checklist_electrica ADD CONSTRAINT fk_electrica_check FOREIGN KEY (id_checklist) REFERENCES tbl_checklist(id_checklist) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_electrica ADD CONSTRAINT fk_electricas_inspeccion_elec FOREIGN KEY (id_inspeccion_electrica) REFERENCES tbl_inspeccion_electrica(id_inspeccion_electrica) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_electrica ADD CONSTRAINT fk_electrica_calificacion FOREIGN KEY (id_calificacion) REFERENCES tbl_calificacion(id_calificacion) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE tbl_checklist_desinfeccion ADD CONSTRAINT fk_desinfeccion_check FOREIGN KEY (id_checklist) REFERENCES tbl_checklist(id_checklist) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_desinfeccion ADD CONSTRAINT fk_desinfeccion_kit FOREIGN KEY (id_kit) REFERENCES tbl_kit_desinfeccion(id_kit) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_desinfeccion ADD CONSTRAINT fk_desinfeccion_calificacion FOREIGN KEY (id_calificacion) REFERENCES tbl_calificacion(id_calificacion) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE tbl_checklist_bioseguridad ADD CONSTRAINT fk_bioseguridad_check FOREIGN KEY (id_checklist) REFERENCES tbl_checklist(id_checklist) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_bioseguridad ADD CONSTRAINT fk_bioseguridad_elemento FOREIGN KEY (id_elemento_bioseguridad) REFERENCES tbl_elementos_bioseguridad(id_elemento_bioseguridad) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_bioseguridad ADD CONSTRAINT fk_bioseguridad_calificacion FOREIGN KEY (id_calificacion) REFERENCES tbl_calificacion(id_calificacion) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE tbl_checklist_mecanica ADD CONSTRAINT fk_mecanica_check FOREIGN KEY (id_checklist) REFERENCES tbl_checklist(id_checklist) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_mecanica ADD CONSTRAINT fk_mecanica_inspeccionmec FOREIGN KEY (id_inspeccion_mecanica) REFERENCES tbl_inspeccion_mecanica(id_inspeccion_mecanica) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_mecanica ADD CONSTRAINT fk_mecanica_calificacion FOREIGN KEY (id_calificacion) REFERENCES tbl_calificacion(id_calificacion) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE tbl_checklist_epps ADD CONSTRAINT fk_epps_check FOREIGN KEY (id_checklist) REFERENCES tbl_checklist(id_checklist) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_epps ADD CONSTRAINT fk_epps_inspeccionmec FOREIGN KEY (id_inspeccion_epps) REFERENCES tbl_inspeccion_epps(id_inspeccion_epps) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_epps ADD CONSTRAINT fk_epps_calificacion FOREIGN KEY (id_calificacion) REFERENCES tbl_calificacion(id_calificacion) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE tbl_checklist_seguridad ADD CONSTRAINT fk_seguridad_check FOREIGN KEY (id_checklist) REFERENCES tbl_checklist(id_checklist) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_seguridad ADD CONSTRAINT fk_seguridad_inspeccionseg FOREIGN KEY (id_inspeccion_seguridad) REFERENCES tbl_inspeccion_seguridad(id_inspeccion_seguridad) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_checklist_seguridad ADD CONSTRAINT fk_seguridad_calificacion FOREIGN KEY (id_calificacion) REFERENCES tbl_calificacion(id_calificacion) ON DELETE CASCADE ON UPDATE CASCADE;



-- TEST 1/08/2022
SELECT 
    X.fec_ent as FECHA_LIQ, 
    X.cod_gestor as GESTOR, 
    SUM(X.devoluciones_totales) as TOTAL_DEV_TOT, 
    SUM(X.devoluciones_parciales) as TOTAL_DEV_PARC, 
    ( CASE WHEN SUM(X.devoluciones_totales) IS NULL THEN 0 ELSE SUM(X.devoluciones_totales) END + 
    CASE WHEN SUM(X.devoluciones_parciales) IS NULL THEN 0 ELSE SUM(X.devoluciones_parciales) END ) 
    as TOTAL_GENERAL 
FROM tbl_resumen_dia X 
GROUP BY X.cod_gestor