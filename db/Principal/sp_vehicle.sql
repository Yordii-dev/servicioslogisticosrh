/** (5)
	OWNER_USER (out)
    OWNER_USER_BY_PATENT (out)
    OPERATOR (out)
    DELIVERIES
    TOTAL_DELIVERIES 
*/

-- **********************************VEHICLE USER
-- Devuelve userId de usuario dueño del vehiculo
delimiter //
drop procedure IF EXISTS OWNER_USER //

CREATE PROCEDURE OWNER_USER(in vehicleId int, out userId int)
begin 
    select VEHICLE.userId from VEHICLE where id = vehicleId  LIMIT 1 into userId;	   
end //
delimiter //

-- **********************************VEHICLE USER BY PATENT
-- Devuelve userId de usuario dueño del vehiculo por patente
delimiter //
drop procedure IF EXISTS OWNER_USER_BY_PATENT //

CREATE PROCEDURE OWNER_USER_BY_PATENT(in patent varchar(7), out userId int)
begin 
    select VEHICLE.userId from VEHICLE where patent = patent LIMIT 1 into userId;	   
end //
delimiter //

-- **********************************VEHICLE OPERATOR
-- Devuelve operatorId de vehiculo
delimiter //
drop procedure IF EXISTS OPERATOR //

CREATE PROCEDURE OPERATOR(in vehicleId int, out operatorId int)
begin 
	select OPERATOR.id from OPERATOR where OPERATOR.vehicleId = vehicleId LIMIT 1 into operatorId;       
end //
delimiter //

-- **********************************VEHICLE DELIVERIES
-- Devuelve las entregas que lleva un vehiculo
delimiter //
drop procedure IF EXISTS DELIVERIES //

CREATE PROCEDURE DELIVERIES(in vehicleId int, in date datetime)
begin
	declare userId int;
	declare loadDate datetime;
    
    call OWNER_USER(vehicleId, userId);    
	IF date is null THEN
		call LAST_LOAD_DATE(userId, loadDate);   -- Encuentro ultima fecha en que importo esa sesion
    ELSE
      set loadDate = date;
    END IF;
    
	select 
		DELIVERY.id,
		DELIVERY.ctDestination

	from DELIVERY 
	join `LOAD` on DELIVERY.loadId = `LOAD`.id
	where DELIVERY.vehicleId = vehicleId
    and `LOAD`.date = loadDate;
end//
delimiter //


-- **********************************VEHICLE TOTAL DELIVERIES
-- Cuenta las entregas de un vehiculo
delimiter //
drop procedure IF EXISTS TOTAL_DELIVERIES //

CREATE PROCEDURE TOTAL_DELIVERIES(in vehicleId int, in date datetime)
begin	
    declare userId int;
	declare loadDate datetime;
    
    call OWNER_USER(vehicleId, userId);    
	IF date is null THEN
		call LAST_LOAD_DATE(userId, loadDate);   -- Encuentro ultima fecha en que importo esa sesion
    ELSE
      set loadDate = date;
    END IF;
    
	select 
		count(*) 'total'
	from DELIVERY 
    join `LOAD` on DELIVERY.loadId = `LOAD`.id
	where DELIVERY.vehicleId = vehicleId
    and `LOAD`.date = loadDate;		
end //
delimiter //