/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Anderson Fuentes
 * Created: 26 jul. 2022
 */

-- MODULE: INFORMACION

DROP PROCEDURE IF EXISTS storeInformacion;
DELIMITER $$
CREATE PROCEDURE storeInformacion(
in cod_qr_ varchar(150),
in creado_por_ varchar(250),
in titulo_ varchar(200),
in descripcion_ text,
in path_qr_ varchar(250),
in path_video_ varchar(250)
)
BEGIN

    INSERT INTO tbl_qr VALUES (cod_qr_, creado_por_, titulo_, path_qr_, now());
    INSERT INTO tbl_qr_detail VALUES (DEFAULT, cod_qr_, descripcion_, path_video_, DATE_SUB( NOW() , INTERVAL 1 HOUR ));

END$$
DELIMITER ;