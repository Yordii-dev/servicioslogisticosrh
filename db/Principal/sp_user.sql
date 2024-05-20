/** (13)
	USER_BY_NAME
    USER
    
    LAST_LOAD_DATE (out)
    LOADS   
    LOAD
    GROUPS
    OPERATORS
    OPERATORS_BY_STATUS
		ACTIVE_OPERATORS
    
    VEHICLES
    VEHICLES_BY_STATUS
		ACTIVE_VEHICLES    		
        VEHICLES_WITH_GROUP
		VEHICLES_WITHOUT_GROUP
        VEHICLES_WITH_GROUP_AND_WITHOUT_OPERATOR
    
    CHANGE_VEHICLES_STATUS
    CHANGE_ROUTES_STATUS
    USER_MANAGED (Se esta usando OPERATOR_MANAGER) Pendiente de eliminacion
    ROUTES
*/

-- **********************************GET USER BY NAME
delimiter //
drop procedure IF EXISTS USER_BY_NAME //

CREATE PROCEDURE USER_BY_NAME(in emailUser varchar(30))
begin
  select * from USER where name = emailUser;
end //
delimiter //

-- **********************************USER BY ID
delimiter //
drop procedure IF EXISTS USER //

CREATE PROCEDURE USER(in userId int)
begin
  select * from USER where id = userId;
end //
delimiter //


-- **********************************USER LAST LOAD DATE
-- Devuelve la fecha de la ultima carga de un usuario.   

delimiter //
drop procedure IF EXISTS LAST_LOAD_DATE //

CREATE PROCEDURE LAST_LOAD_DATE (in userId int, out loadDate datetime)
begin 
	select max(date) from `LOAD` where `LOAD`.userId = userId LIMIT 1 into loadDate;
end //
delimiter //;

-- **********************************USER LAST LOAD DATE
-- Devuelve la fecha de la primera carga de un usuario.   

delimiter //
drop procedure IF EXISTS FIRST_LOAD_DATE //

CREATE PROCEDURE FIRST_LOAD_DATE (in userId int, out loadDate datetime)
begin 
	select min(date) from `LOAD` where `LOAD`.userId = userId LIMIT 1 into loadDate;
end //
delimiter //;

-- **********************************USER LOADS
-- Devuelve todas las cargas de un usuario.   

delimiter //
drop procedure IF EXISTS LOADS //

CREATE PROCEDURE LOADS(in userId int)
begin 
	select id, CONVERT(date, CHAR) date, fileName
    from `LOAD` 
    where `LOAD`.userId = userId;
end //
delimiter //

-- **********************************USER BURDEN
/*
Devuelve carga de una fecha, si se pasa null devuelve la ultima.
*/
delimiter //
drop procedure IF EXISTS `LOAD` //

CREATE PROCEDURE `LOAD`(in userId int, in date datetime)
begin 
	declare loadDate datetime; 
    
    IF date is null then	
		call LAST_LOAD_DATE(userId, loadDate);
    ELSE
		set loadDate = date;
    END IF;    

	select id, CONVERT(date, CHAR) date, fileName 
	from `LOAD` 
    where `LOAD`.userId = userId and 
    `LOAD`.date = loadDate;
	
end //
delimiter //

-- **********************************USER GROUPS
-- Devuelve los grupos creados de un usuario
delimiter //
drop procedure IF EXISTS `GROUPS` //

CREATE PROCEDURE `GROUPS`(in userId int)
begin
	select id, name, CONVERT(date, CHAR) date
    from `GROUP` where `GROUP`.userId = userId;
end //
delimiter //

-- ============================================================================================ OPERATORS

-- **********************************USER OPERATORS
-- Devuelve los operadores creados de un usuario
delimiter //
drop procedure IF EXISTS OPERATORS //

CREATE PROCEDURE OPERATORS(in userId int)
begin
	select 
		OPERATOR.id,
		OPERATOR.fullName,
		OPERATOR.userName,
		OPERATOR.pin,
        CONVERT(OPERATOR.date, CHAR) date,
        VEHICLE.id,
        VEHICLE.patent
	from OPERATOR
	join VEHICLE on OPERATOR.vehicleId = VEHICLE.id
	where OPERATOR.userId = userId;
end //
delimiter //

-- **********************************USER OPERATORS BY STATUS
-- Devuelve los operadores con un status de un usuario 
delimiter //
drop procedure IF EXISTS OPERATORS_BY_STATUS //

CREATE PROCEDURE OPERATORS_BY_STATUS(in userId int, in status varchar(10))
begin	
	IF status = 'A' THEN
		call ACTIVE_OPERATORS(userId);	
	END IF;
end //
delimiter //

-- **********************************USER ACTIVES OPERATORS
/*
Devuelve operadores que sus vehiculos estan activos
*/
delimiter //
drop procedure IF EXISTS ACTIVE_OPERATORS //

CREATE PROCEDURE ACTIVE_OPERATORS(in userId int)
begin	    
	select 
		OPERATOR.id,
        OPERATOR.userName,
		VEHICLE.id 'vehicleId',
        VEHICLE.patent
    from OPERATOR     
    join VEHICLE on VEHICLE.id = OPERATOR.vehicleId
    join USER on VEHICLE.userId = USER.id
    
    where USER.id = userId and
    VEHICLE.status = 'Activo';
end //
delimiter //

-- ============================================================================================ END OPERATORS
-- ============================================================================================ VEHICLES

-- **********************************USER VEHICLES
-- Devuelve los vehiculos de un usuario
delimiter //
drop procedure IF EXISTS VEHICLES //

CREATE PROCEDURE VEHICLES(in userId int)
begin    
	select * from VEHICLE where VEHICLE.userId = userId;
end //
delimiter //

-- **********************************USER VEHICLES BY STATUS
-- Devuelve los vehiculos de un status de un usuario
delimiter //
drop procedure IF EXISTS VEHICLES_BY_STATUS //

CREATE PROCEDURE VEHICLES_BY_STATUS(in userId int, in status varchar(10))
begin
	IF status = 'A' THEN
		call ACTIVE_VEHICLES(userId);
	ELSEIF status = 'G' THEN
		call VEHICLES_WITH_GROUP(userId);
	ELSEIF status = 'NO-G' THEN
		call VEHICLES_WITHOUT_GROUP(userId);
	ELSEIF status = 'G-NO-O' THEN
		call VEHICLES_WITH_GROUP_AND_WITHOUT_OPERATOR(userId);	
	END IF;
end //
delimiter //

-- **********************************USER ACTIVE VEHICLES
-- Devuelve los vehiculos activos de un usuario
delimiter //
drop procedure IF EXISTS ACTIVE_VEHICLES //

CREATE PROCEDURE ACTIVE_VEHICLES(in userId int)
begin    
	select * from VEHICLE 
    where VEHICLE.userId = userId and 
    VEHICLE.status = 'Activo';
end //
delimiter //

-- **********************************USER VEHICLES WITH GROUP
-- Devuelve los vehiculos con grupo
delimiter //
drop procedure IF EXISTS VEHICLES_WITH_GROUP //

CREATE PROCEDURE VEHICLES_WITH_GROUP(in userId int)
begin    
	select 
		VEHICLE.id,
		VEHICLE.patent,
		`GROUP`.name
    from VEHICLE 
    join `GROUP` on VEHICLE.groupId = `GROUP`.id
    where VEHICLE.groupId is not null and 
    VEHICLE.userId = userId;
end //
delimiter //

-- **********************************USER VEHICLES WITHOUT GROUP
-- Devuelve los vehiculos sin grupo
delimiter //
drop procedure IF EXISTS VEHICLES_WITHOUT_GROUP //

CREATE PROCEDURE VEHICLES_WITHOUT_GROUP(in userId int)
begin    
    select 
		VEHICLE.id,
        VEHICLE.patent
    from VEHICLE 
    where groupId is null and 
    VEHICLE.userId = userId;
end //
delimiter //

-- **********************************USER VEHICLES WITH GROUP AND WITHOUT OPERATOR
-- Devuelve vehiculos que tienen grupo pero no operador
delimiter //
drop procedure IF EXISTS VEHICLES_WITH_GROUP_AND_WITHOUT_OPERATOR //

CREATE PROCEDURE VEHICLES_WITH_GROUP_AND_WITHOUT_OPERATOR(in userId int)
begin    
    select 
		VEHICLE.id,
        VEHICLE.patent
    from VEHICLE
    left join OPERATOR on VEHICLE.id = OPERATOR.vehicleId
    where OPERATOR.id is null and
    VEHICLE.groupId is not null and
    VEHICLE.userId = userId;
end //
delimiter //

-- ============================================================================================ END VEHICLES
-- **********************************CHANGE USER VEHICLE STATUS
-- Cambia el estado de los vehiculos de un usuario
delimiter //
drop procedure IF EXISTS CHANGE_VEHICLES_STATUS //

CREATE PROCEDURE CHANGE_VEHICLES_STATUS(in userId int, in status varchar(15))
begin    
    UPDATE VEHICLE
    SET VEHICLE.status = status
    WHERE VEHICLE.userId = userId;
end //
delimiter //

-- **********************************CHANGE USER ROUTE STATUS
-- Cambia el estado de todas las rutas de un usuario
delimiter //
drop procedure IF EXISTS CHANGE_ROUTES_STATUS //

CREATE PROCEDURE CHANGE_ROUTES_STATUS(in userId int, in status varchar(15))
begin
	UPDATE ROUTE
	INNER JOIN `LOAD` ON ROUTE.loadId = `LOAD`.id
	SET ROUTE.status = status
	WHERE `LOAD`.userId = userId;
end //
delimiter //


-- **********************************USER MANAGEDS (Se esta usando OPERATOR_MANAGER)
-- Devuelve las gestiones de un usuario
delimiter //
drop procedure IF EXISTS USER_MANAGED //

CREATE PROCEDURE USER_MANAGED(in userId int, in date datetime)
begin
	declare loadDate datetime;
	IF date is null THEN
		call LAST_LOAD_DATE(userId, loadDate);   -- Encuentro ultima fecha en que importo esa sesion
    ELSE
      set loadDate = date;
    END IF;    
    
    select 
		DELIVERY.id,
        DELIVERY.serviceTime,
        MANAGED_DELIVERY.status,
        MANAGED_DELIVERY.subStatus,
		CONVERT(MANAGED_DELIVERY.date, CHAR) date,
        
        OPERATOR.id 'operatorId',
        
        CLIENT.name 'clientName',
        CLIENT.phone 'clientPhone',
        CLIENT.address 'clientAddress',
        CLIENT.latitude 'clientLatitude',
        CLIENT.longitude 'clientLongitude'
        
    from MANAGED_DELIVERY
    join DELIVERY on MANAGED_DELIVERY.deliveryId = DELIVERY.id
    join CLIENT on DELIVERY.clientId = CLIENT.id
    join VEHICLE on DELIVERY.vehicleId = VEHICLE.id
    join OPERATOR on VEHICLE.id = OPERATOR.vehicleId    
    join `LOAD` on DELIVERY.loadId = `LOAD`.id
    
    where `LOAD`.userId = userId and 
    `LOAD`.date = loadDate;	
end //
delimiter // 

-- **********************************USER ROUTES
/*
Obtiene las rutas de un usuario en una determinada fecha, funciona con 'tipo date' 
ya que se basara en el control input date y este control no maneja segundos.
*/
delimiter //
drop procedure IF EXISTS ROUTES //

CREATE PROCEDURE ROUTES(in userId int, in date datetime)
begin        
	declare loadDate datetime;
    IF date is null THEN
		call LAST_LOAD_DATE(userId, loadDate);   -- Encuentro ultima fecha en que importo esa sesion
    ELSE
      set loadDate = date;
    END IF;
    select 
		OPERATOR.userName,
        VEHICLE.patent,
        `GROUP`.name 'group',
        convert(ROUTE.date, char) date,
		convert(`LOAD`.date, char) 'loadDate',
		ROUTE.status,
        ROUTE.totalDeliveries
    from ROUTE
    join OPERATOR on ROUTE.operatorId = OPERATOR.id
    join VEHICLE on OPERATOR.vehicleId = VEHICLE.id
    join `GROUP` on VEHICLE.groupId = `GROUP`.id
    join `LOAD` on ROUTE.loadId = `LOAD`.id
    where `LOAD`.userId = userId
    and Date(`LOAD`.date) = Date(loadDate);
end //
delimiter //
