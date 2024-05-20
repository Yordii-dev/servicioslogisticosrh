/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Anderson Fuentes
 * Created: 26 may. 2022
 */

-- MODULE: MAIN

DROP PROCEDURE IF EXISTS getUserData;

DELIMITER $$
CREATE PROCEDURE getUserData(
in correo varchar(150),
in pass varchar(150)
)
BEGIN
    select * from tbl_user U inner join tbl_rol R on (U.id_rol=R.id_rol)
    where (U.correo=correo and U.contrasena=MD5(pass));
END$$
DELIMITER ;


-- MIDDLEWARE

DROP PROCEDURE IF EXISTS authContent;

DELIMITER $$
CREATE PROCEDURE authContent(
    in iduser_ int
)
BEGIN
    SELECT P.description as PAGE FROM tbl_user U INNER JOIN tbl_rol R on (U.id_rol=R.id_rol) 
    INNER JOIN tbl_rol_pages RP ON (R.id_rol=RP.id_rol) INNER JOIN tbl_centros C on (C.id_centro=RP.id_centro) 
    INNER JOIN tbl_pages P on(P.id_page=RP.id_page) WHERE U.id_user=iduser_;
END$$
DELIMITER ;