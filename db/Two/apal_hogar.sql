/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Anderson Fuentes
 * Created: 26 may. 2022
 */

-- MODULE: HOGAR

DROP PROCEDURE IF EXISTS dataUsersLimit;

DELIMITER $$
CREATE PROCEDURE dataUsersLimit(
in desde int,
in per_pages int
)
BEGIN
    select * from tbl_user U inner join tbl_rol R on (U.id_rol=R.id_rol) inner join tbl_centros C
    ON (U.id_centro=C.id_centro) WHERE U.estado = 1 
    ORDER BY U.id_user ASC limit desde,per_pages;
END$$
DELIMITER ;

-- CENTROS

DROP PROCEDURE IF EXISTS dataCentrosLimit;

DELIMITER $$
CREATE PROCEDURE dataCentrosLimit(
in desde int,
in per_pages int
)
BEGIN
    select * from tbl_centros C limit desde,per_pages;
END$$
DELIMITER ;


-- ROLES

DROP PROCEDURE IF EXISTS storeRoles;

DELIMITER $$
CREATE PROCEDURE storeRoles(
in id_rol_ int,
in id_centro_ int,
in id_page_ int
)
BEGIN

    DECLARE aux INT DEFAULT 0;
    SELECT COUNT(*) into aux FROM tbl_rol_pages R WHERE (R.id_rol=id_rol_ and R.id_centro=id_centro_) and R.id_page=id_page_; 

    IF aux=0 THEN
        INSERT INTO tbl_rol_pages VALUES (default, id_rol_, id_centro_, id_page_);
    END IF;

    SELECT aux+1 as res;

END$$
DELIMITER ;