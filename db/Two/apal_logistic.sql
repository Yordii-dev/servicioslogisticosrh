/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Anderson Fuentes
 * Created: 26 may. 2022
 */

-- MODULE: LOGISTIC

DROP PROCEDURE IF EXISTS dataProgLimit;

DELIMITER $$
CREATE PROCEDURE dataProgLimit(
in desde int,
in per_pages int
)
BEGIN
    select * from tbl_prog P WHERE P.eliminado = 0 
    ORDER BY P.id ASC limit desde,per_pages;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataLiquiLimit;

DELIMITER $$
CREATE PROCEDURE dataLiquiLimit(
in desde int,
in per_pages int
)
BEGIN
    select * from tbl_liqui L WHERE L.eliminado = 0 
    ORDER BY L.id ASC limit desde,per_pages;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataPagofleLimit;

DELIMITER $$
CREATE PROCEDURE dataPagofleLimit(
in desde int,
in per_pages int
)
BEGIN
    select * from tbl_pago_fle P WHERE P.eliminado = 0 
    ORDER BY P.id ASC limit desde,per_pages;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataTiempokmLimit;

DELIMITER $$
CREATE PROCEDURE dataTiempokmLimit(
in desde int,
in per_pages int
)
BEGIN
    select * from tbl_tiempo_km T WHERE T.eliminado = 0 
    ORDER BY T.id ASC limit desde,per_pages;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataNoprogLimit;

DELIMITER $$
CREATE PROCEDURE dataNoprogLimit(
in desde int,
in per_pages int
)
BEGIN
    select * from tbl_noprog N WHERE N.eliminado = 0 
    ORDER BY N.id ASC limit desde,per_pages;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataPfrLimit;

DELIMITER $$
CREATE PROCEDURE dataPfrLimit(
in desde int,
in per_pages int
)
BEGIN
    select * from tbl_pfr P WHERE P.eliminado = 0 
    ORDER BY P.id ASC limit desde,per_pages;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataDropLimit;

DELIMITER $$
CREATE PROCEDURE dataDropLimit(
in desde int,
in per_pages int
)
BEGIN
    select * from tbl_drop D WHERE D.eliminado = 0 
    ORDER BY D.id ASC limit desde,per_pages;
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS dataPersonalLimit;

DELIMITER $$
CREATE PROCEDURE dataPersonalLimit(
in desde int,
in per_pages int
)
BEGIN
    select * from tbl_pers P WHERE P.estado = 1 
    ORDER BY P.id_reg ASC limit desde,per_pages;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataResumenLimit;

DELIMITER $$
CREATE PROCEDURE dataResumenLimit(
in desde int,
in per_pages int
)
BEGIN
    SET lc_time_names = 'es_ES';

    SELECT
        EXTRACT(YEAR FROM P.fecha_prog) AS ANIO,
        CONCAT(UCASE(LEFT(MONTHNAME(P.fecha_prog), 1)), 
        SUBSTRING(MONTHNAME(P.fecha_prog), 2)) AS MES,
        CONCAT(UCASE(LEFT(DAYNAME(P.fecha_prog), 1)), 
        SUBSTRING(DAYNAME(P.fecha_prog), 2)) AS DIA,
        P.idgenerado AS ID, 
        P.fecha_prog AS FECHA,
        P.placa AS PLACA,
        P.distancia AS DISTANCIA_PROGRAMADA,
        T.kilometraje AS DISTANCIA_REAL,
        ROUND((ABS((P.distancia - T.kilometraje)/P.distancia) * 100.00),2) AS DESVIACION_DISTANCIA,
        P.jornada_laboral AS TIEMPO_PROGRAMADO,
        T.tiempo_mercado AS TIEMPO_MERCADO,

        ROUND((ABS((((HOUR(P.jornada_laboral)/24) + ((MINUTE(P.jornada_laboral)/60)/24)) -
        ((HOUR(T.tiempo_mercado)/24) + ((MINUTE(T.tiempo_mercado)/60)/24))) /
        ((HOUR(P.jornada_laboral)/24) + ((MINUTE(P.jornada_laboral)/60)/24))) * 100.00),2) AS DESVIACION_TIEMPO,

        P.clientes AS CLIENTES_PROGRAMADOS,
        L.total AS CLIENTES_RECHAZADOS,
        ROUND(P.peso/1000,2) AS PRODUCT_POR_CAMION,
        L.cobranza_prog_sigv AS SOLES_PROGRAMADOS,
        L.soles_2 AS DEVOLUCIONES_SIN_IGV,
        ROUND(L.cobranza_prog_sigv-L.soles_2) AS SOLES_COBRADOS,
        PF.flete_sigv AS FLETE_SIN_IGV,
        ROUND((( (L.cobranza_prog_sigv-L.soles_2) / L.cobranza_prog_sigv) * 100.00),1) AS EFECTIVIDAD_SOLES,
        ROUND((((P.clientes - L.total)/P.clientes) * 100.00),1) AS EFECTIVIDAD_CLIENTES
        
    FROM tbl_prog P 
    inner join tbl_tiempo_km T on (P.idgenerado=T.idprog)
    inner join tbl_liqui L on (P.idgenerado=L.idprog)
    inner join tbl_pago_fle PF on (P.idgenerado=PF.idprog)
    WHERE P.eliminado = 0 
    ORDER BY P.id ASC limit desde,per_pages;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataSearchResumen;

DELIMITER $$
CREATE PROCEDURE dataSearchResumen(
in texto varchar(50)
)
BEGIN
    SET lc_time_names = 'es_ES';

    SELECT
        EXTRACT(YEAR FROM P.fecha_prog) AS ANIO,
        CONCAT(UCASE(LEFT(MONTHNAME(P.fecha_prog), 1)), 
        SUBSTRING(MONTHNAME(P.fecha_prog), 2)) AS MES,
        CONCAT(UCASE(LEFT(DAYNAME(P.fecha_prog), 1)), 
        SUBSTRING(DAYNAME(P.fecha_prog), 2)) AS DIA,
        P.idgenerado AS ID, 
        P.fecha_prog AS FECHA,
        P.placa AS PLACA,
        P.distancia AS DISTANCIA_PROGRAMADA,
        T.kilometraje AS DISTANCIA_REAL,
        ROUND((ABS((P.distancia - T.kilometraje)/P.distancia) * 100.00),2) AS DESVIACION_DISTANCIA,
        P.jornada_laboral AS TIEMPO_PROGRAMADO,
        T.tiempo_mercado AS TIEMPO_MERCADO,

        ROUND((ABS((((HOUR(P.jornada_laboral)/24) + ((MINUTE(P.jornada_laboral)/60)/24)) -
        ((HOUR(T.tiempo_mercado)/24) + ((MINUTE(T.tiempo_mercado)/60)/24))) /
        ((HOUR(P.jornada_laboral)/24) + ((MINUTE(P.jornada_laboral)/60)/24))) * 100.00),2) AS DESVIACION_TIEMPO,

        P.clientes AS CLIENTES_PROGRAMADOS,
        L.total AS CLIENTES_RECHAZADOS,
        ROUND(P.peso/1000,2) AS PRODUCT_POR_CAMION,
        L.cobranza_prog_sigv AS SOLES_PROGRAMADOS,
        L.soles_2 AS DEVOLUCIONES_SIN_IGV,
        ROUND(L.cobranza_prog_sigv-L.soles_2) AS SOLES_COBRADOS,
        PF.flete_sigv AS FLETE_SIN_IGV,
        ROUND((( (L.cobranza_prog_sigv-L.soles_2) / L.cobranza_prog_sigv) * 100.00),1) AS EFECTIVIDAD_SOLES,
        ROUND((((P.clientes - L.total)/P.clientes) * 100.00),1) AS EFECTIVIDAD_CLIENTES

    FROM tbl_prog P 
    inner join tbl_tiempo_km T on (P.idgenerado=T.idprog)
    inner join tbl_liqui L on (P.idgenerado=L.idprog)
    inner join tbl_pago_fle PF on (P.idgenerado=PF.idprog)
    WHERE P.eliminado = 0 and (P.idgenerado=texto OR P.placa=texto OR P.fecha_prog=texto OR EXTRACT(YEAR FROM P.fecha_prog)=texto)
    ORDER BY P.id ASC;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataResumenReport;

DELIMITER $$
CREATE PROCEDURE dataResumenReport(
in fecha_1_ date,
in fecha_2_ date
)
BEGIN
    SET lc_time_names = 'es_ES';

    SELECT
        EXTRACT(YEAR FROM P.fecha_prog) AS ANIO,
        CONCAT(UCASE(LEFT(MONTHNAME(P.fecha_prog), 1)), 
        SUBSTRING(MONTHNAME(P.fecha_prog), 2)) AS MES,
        CONCAT(UCASE(LEFT(DAYNAME(P.fecha_prog), 1)), 
        SUBSTRING(DAYNAME(P.fecha_prog), 2)) AS DIA,
        P.idgenerado AS ID, 
        P.fecha_prog AS FECHA,
        P.placa AS PLACA,
        P.distancia AS DISTANCIA_PROGRAMADA,
        T.kilometraje AS DISTANCIA_REAL,
        ROUND((ABS((P.distancia - T.kilometraje)/P.distancia) * 100.00),2) AS DESVIACION_DISTANCIA,
        P.jornada_laboral AS TIEMPO_PROGRAMADO,
        T.tiempo_mercado AS TIEMPO_MERCADO,

        ROUND((ABS((((HOUR(P.jornada_laboral)/24) + ((MINUTE(P.jornada_laboral)/60)/24)) -
        ((HOUR(T.tiempo_mercado)/24) + ((MINUTE(T.tiempo_mercado)/60)/24))) /
        ((HOUR(P.jornada_laboral)/24) + ((MINUTE(P.jornada_laboral)/60)/24))) * 100.00),2) AS DESVIACION_TIEMPO,

        P.clientes AS CLIENTES_PROGRAMADOS,
        L.total AS CLIENTES_RECHAZADOS,
        ROUND(P.peso/1000,2) AS PRODUCT_POR_CAMION,
        L.cobranza_prog_sigv AS SOLES_PROGRAMADOS,
        L.soles_2 AS DEVOLUCIONES_SIN_IGV,
        ROUND(L.cobranza_prog_sigv-L.soles_2) AS SOLES_COBRADOS,
        PF.flete_sigv AS FLETE_SIN_IGV,
        ROUND((( (L.cobranza_prog_sigv-L.soles_2) / L.cobranza_prog_sigv) * 100.00),1) AS EFECTIVIDAD_SOLES,
        ROUND((((P.clientes - L.total)/P.clientes) * 100.00),1) AS EFECTIVIDAD_CLIENTES
        
    FROM tbl_prog P 
    inner join tbl_tiempo_km T on (P.idgenerado=T.idprog)
    inner join tbl_liqui L on (P.idgenerado=L.idprog)
    inner join tbl_pago_fle PF on (P.idgenerado=PF.idprog)
    WHERE P.eliminado = 0 and (P.fecha_prog>= fecha_1_ and P.fecha_prog<=fecha_2_)
    ORDER BY P.id ASC;

END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS dataFleteLimit;

DELIMITER $$
CREATE PROCEDURE dataFleteLimit(
in desde int,
in per_pages int
)
BEGIN
    select * from tbl_flete F WHERE F.eliminado = 0 
    ORDER BY F.id ASC limit desde,per_pages;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS registerPersonal;

DELIMITER $$
CREATE PROCEDURE `registerPersonal`(
in ruc varchar(20),
in nombreempresa varchar(200),
in tipodoc varchar(150),
in numdoc varchar(150),
in nombreemp varchar(150),
in direccion varchar(200),
in geoposicion varchar(150),
in telefono varchar(150),
in cargo varchar(150),
in fenaci date,
in licencia varchar(50),
in fechacaducidad date,
in imagen varchar(250)
)
BEGIN

    DECLARE cont INT;
    DECLARE cod INT;

    SET cod=7000;

    SELECT MAX(id_reg) into cont FROM tbl_pers;

    IF cont IS NULL THEN
        INSERT INTO tbl_pers VALUES (default, cod, now(), ruc, nombreempresa, tipodoc, numdoc, nombreemp, 
                    direccion, geoposicion, imagen, telefono, cargo, fenaci, 1, fechacaducidad, licencia);
    ELSE
        SET cod=cod+1;
        INSERT INTO tbl_pers VALUES (default, cod, now(), ruc, nombreempresa, tipodoc, numdoc, nombreemp, 
                    direccion, geoposicion, imagen, telefono, cargo, fenaci, 1, fechacaducidad, licencia);
    END IF;
	
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS dataControltempLimit;

DELIMITER $$
CREATE PROCEDURE dataControltempLimit(
in desde int,
in per_pages int
)
BEGIN
    select * from tbl_temperatura T WHERE T.eliminado = 0 
    ORDER BY T.id DESC limit desde,per_pages;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataControltempReport;

DELIMITER $$
CREATE PROCEDURE dataControltempReport(
in fecha_1 date,
in fecha_2 date
)
BEGIN
    select * from tbl_temperatura T WHERE T.eliminado = 0 and (T.fecha>= fecha_1 and T.fecha<=fecha_2)
    ORDER BY T.id DESC;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataControltempDetalleReport;

DELIMITER $$
CREATE PROCEDURE dataControltempDetalleReport(
in fecha_1 date,
in fecha_2 date
)
BEGIN
    select T.fecha, T.ruc, T.placa as placa_temp, TD.* from tbl_temperatura T inner join 
    tbl_temperatura_detalle TD ON (T.id=TD.id_temperatura)
    WHERE T.eliminado = 0 and (T.fecha>= fecha_1 and T.fecha<=fecha_2) ORDER BY T.id DESC;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS storeFileProviders;
DELIMITER $$
CREATE PROCEDURE storeFileProviders(
in propietario_ varchar(250),
in nick_ varchar(200),
in path_ varchar(250)
)
BEGIN
    
    DECLARE auto INT;

    INSERT INTO tbl_file VALUES (DEFAULT, propietario_, nick_, now());
    SELECT MAX(id_file) into auto FROM tbl_file;

    INSERT INTO tbl_file_detail VALUES (DEFAULT, auto, path_, DATE_SUB( NOW() , INTERVAL 1 HOUR ));

END$$
DELIMITER ;