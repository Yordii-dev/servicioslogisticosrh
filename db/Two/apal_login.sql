/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Anderson Fuentes
 * Created: 26 may. 2022
 */

-- STORED PROCEDURES
-- MODULE: LOGIN

DROP PROCEDURE IF EXISTS login;

DELIMITER $$
CREATE PROCEDURE login(
in correo varchar(150),
in pass varchar(150)
)
BEGIN
    select * from tbl_user U 
    where (U.correo=correo and U.contrasena=MD5(pass));
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS checkEmail;

DELIMITER $$
CREATE PROCEDURE `checkEmail`(
in mail varchar(150)
)
BEGIN
     select * from tbl_user where correo=mail;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS checkUser;

DELIMITER $$
CREATE PROCEDURE `checkUser`(
in usuario_ varchar(150)
)
BEGIN
     select * from tbl_user where usuario=usuario_;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS registerUser;

DELIMITER $$
CREATE PROCEDURE `registerUser`(
in fullname varchar(200),
in mail varchar(200),
in usuario varchar(150),
in pass varchar(150)
)
BEGIN

     INSERT INTO tbl_user VALUES (default, 6, fullname, mail, usuario, MD5(pass), 1, 1000);
	
END$$
DELIMITER ;