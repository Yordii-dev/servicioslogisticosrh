/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Anderson Fuentes
 * Created: 26 may. 2022
 */

DROP PROCEDURE IF EXISTS dataInventarioLimit;

DELIMITER $$
CREATE PROCEDURE dataInventarioLimit(
    in desde_ int,
    in hasta_ int
)
BEGIN

    SET @ff= CURDATE();

    SELECT 
        I.fecha_importacion FECHA,
        I.categoria CATEGORIA,
        I.material MATERIAL,
        I.descripcion DESCRIPCION,
        I.umb UMB,
        I.can_umb CANTIDAD

    FROM tbl_inv I 
    WHERE I.fecha_importacion=@ff
    GROUP BY I.categoria, I.material
    LIMIT desde_, hasta_;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS dataSearchInventario;

DELIMITER $$
CREATE PROCEDURE dataSearchInventario(
    in fecha_ date,
    in sociedad_ varchar(50),
    in categoria_ varchar(50)
)
BEGIN

    IF fecha_ IS NULL OR fecha_ = "" THEN
        SET @ff= CURDATE();
    ELSE
        SET @ff= fecha_;
    END IF;

    IF (sociedad_ IS NULL OR sociedad_ = "") AND (categoria_ IS NULL OR categoria_="") THEN
        
        SELECT 
            I.fecha_importacion FECHA,
            I.categoria CATEGORIA,
            I.material MATERIAL,
            I.descripcion DESCRIPCION,
            I.umb UMB,
            I.can_umb CANTIDAD

        FROM tbl_inv I 
        WHERE I.fecha_importacion=@ff
        GROUP BY I.categoria, I.material;

    ELSEIF (sociedad_ IS NOT NULL OR sociedad_ != "") AND (categoria_ IS NULL OR categoria_="") THEN

        SELECT 
            I.fecha_importacion FECHA,
            I.categoria CATEGORIA,
            I.material MATERIAL,
            I.descripcion DESCRIPCION,
            I.umb UMB,
            I.can_umb CANTIDAD

        FROM tbl_inv I 
        WHERE I.fecha_importacion=@ff and I.sociedad=sociedad_
        GROUP BY I.categoria, I.material;

    ELSEIF (sociedad_ IS NOT NULL OR sociedad_ != "") AND (categoria_ IS NOT NULL OR categoria_!="") THEN

        SELECT 
            I.fecha_importacion FECHA,
            I.categoria CATEGORIA,
            I.material MATERIAL,
            I.descripcion DESCRIPCION,
            I.umb UMB,
            I.can_umb CANTIDAD

        FROM tbl_inv I 
        WHERE (I.fecha_importacion=@ff and I.sociedad=sociedad_) and I.categoria=categoria_
        GROUP BY I.categoria, I.material;


    ELSEIF (sociedad_ IS NULL OR sociedad_ = "") AND (categoria_ IS NOT NULL OR categoria_!="") THEN

        SELECT 
            I.fecha_importacion FECHA,
            I.categoria CATEGORIA,
            I.material MATERIAL,
            I.descripcion DESCRIPCION,
            I.umb UMB,
            I.can_umb CANTIDAD

        FROM tbl_inv I 
        WHERE I.fecha_importacion=@ff and I.categoria=categoria_
        GROUP BY I.categoria, I.material;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS registerDataInventarios;

DELIMITER $$
CREATE PROCEDURE registerDataInventarios(
    in material_ varchar(50),
    in fecha_ date,
    in accion_ int,
    in validacion_ varchar(50)
)
BEGIN

    DECLARE total INT DEFAULT 0;
    SELECT COUNT(*) INTO total FROM tbl_auxiliar_inventarios AI WHERE AI.material=material_ AND AI.fecha=fecha_;

    IF total = 0 THEN
        INSERT INTO tbl_auxiliar_inventarios VALUES (DEFAULT, material_, fecha_, accion_, validacion_);
    ELSE
        UPDATE tbl_auxiliar_inventarios SET accion=accion_, validacion=validacion_ WHERE material=material_ AND fecha=fecha_;
    END IF;

    IF validacion_!="" THEN
        UPDATE tbl_inv SET can_umb=validacion_ WHERE fecha_importacion=fecha_ AND material=material_;
    END IF;

END$$
DELIMITER ;