/** (5)
	OPERATOR_BY_VEHICLEID_AND_PIN    
    VEHICLE (out)
    OPERATOR_MANAGED
    OPERATOR_TOTAL_MANAGED
	OPERATOR_CLIENTS (Se usa en ves de DELIVERIES y CLIENT ya que eran mas lentos)
    ROUTE
*/

-- **********************************GET OPERATOR BY VEHICLEID AND PIN
delimiter //
drop procedure IF EXISTS OPERATOR_BY_VEHICLEID_AND_PIN //

CREATE PROCEDURE OPERATOR_BY_VEHICLEID_AND_PIN(in vehicleId int, in pin varchar(30))
begin
	select 
		OPERATOR.id,
        OPERATOR.vehicleId,
        VEHICLE.patent
	from OPERATOR 
    join VEHICLE on OPERATOR.vehicleId = VEHICLE.id
    where OPERATOR.vehicleId = vehicleId and OPERATOR.pin = pin;    
end //
delimiter //


-- **********************************OPERATOR VEHICLE
-- Devuelve el vehicleId del operador
delimiter //
drop procedure IF EXISTS VEHICLE //

CREATE PROCEDURE VEHICLE(in operatorId int, out vehicleId int)
begin
	select OPERATOR.vehicleId from OPERATOR where id = operatorId LIMIT 1 into vehicleId;	   
end //
delimiter //

-- **********************************OPERATOR MANAGEDS
-- Devuelve las entregas gestionadas de un operador
delimiter //
drop procedure IF EXISTS OPERATOR_MANAGED //

CREATE PROCEDURE OPERATOR_MANAGED(in operatorId int, in date datetime)
begin
    declare userId int;
    declare vehicleId int;
    declare loadDate datetime;	 
	
    call VEHICLE(operatorId, vehicleId);    
    call OWNER_USER(vehicleId, userId);
    
	IF date is null THEN
		call LAST_LOAD_DATE(userId, loadDate);   -- Encuentro ultima fecha en que importo esa sesion
    ELSE
      set loadDate = date;
    END IF;
    
    select 
		DELIVERY.id,
        MANAGED_DELIVERY.status,
        MANAGED_DELIVERY.subStatus,
		CONVERT(MANAGED_DELIVERY.date, CHAR) date,
        
        operatorId
        
    from MANAGED_DELIVERY
    join DELIVERY on MANAGED_DELIVERY.deliveryId = DELIVERY.id
    join `LOAD` on DELIVERY.loadId = `LOAD`.id
    
    where DELIVERY.vehicleId = vehicleId 
    and `LOAD`.userId = userId
    and `LOAD`.date = loadDate;
end//
delimiter //

-- **********************************OPERATOR TOTAL MANAGEDS
-- Devuelve el total de etregas gestionadas de un operador
delimiter //
drop procedure IF EXISTS OPERATOR_TOTAL_MANAGED //

CREATE PROCEDURE OPERATOR_TOTAL_MANAGED(in operatorId int, in date datetime)
begin
    declare userId int;
    declare vehicleId int;
    declare loadDate datetime;	 
	
    call VEHICLE(operatorId, vehicleId);    
    call OWNER_USER(vehicleId, userId);
    
	IF date is null THEN
		call LAST_LOAD_DATE(userId, loadDate);   -- Encuentro ultima fecha en que importo esa sesion
    ELSE
      set loadDate = date;
    END IF;
    
    select count(*) total
    from MANAGED_DELIVERY
    join DELIVERY on MANAGED_DELIVERY.deliveryId = DELIVERY.id
    join `LOAD` on DELIVERY.loadId = `LOAD`.id
    
    where DELIVERY.vehicleId = vehicleId 
    and `LOAD`.userId = userId
    and `LOAD`.date = loadDate;
end//
delimiter //

-- **********************************OPERATOR CLIENTS
-- (Se usa en ves de DELIVERIES y CLIENT ya que eran mas lentos)
delimiter //
drop procedure IF EXISTS OPERATOR_CLIENTS //

CREATE PROCEDURE OPERATOR_CLIENTS(in operatorId int, in date datetime)
begin 	 
	declare userId int;	
	declare vehicleId int;
    declare loadDate datetime;
        
    call VEHICLE(operatorId, vehicleId);
    call OWNER_USER(vehicleId, userId);
    
    IF date is null THEN
		call LAST_LOAD_DATE(userId, loadDate);   -- Encuentro ultima fecha en que importo esa sesion
    ELSE
      set loadDate = date;
    END IF;
        
	select
		DELIVERY.id 'deliveryId',
        DELIVERY.ctDestination,
        DELIVERY.serviceTime,
        MANAGED_DELIVERY.status 'deliveryStatus',
		CLIENT.id,
		CLIENT.name,
		CLIENT.address,
		CLIENT.phone,
		CLIENT.latitude,
        CLIENT.longitude
	from DELIVERY
    left join MANAGED_DELIVERY on DELIVERY.id = MANAGED_DELIVERY.deliveryId
    join CLIENT on DELIVERY.clientId = CLIENT.id
    join `LOAD` on DELIVERY.loadId= `LOAD`.id
    
    where DELIVERY.vehicleId = vehicleId 
	and `LOAD`.userId = userId
    and `LOAD`.date = loadDate;
end //
delimiter //;
 

-- **********************************OPERATOR ROUTE
-- Devuelve ruta de un operador, si se pasa fecha null obtiene la ultima ruta
delimiter //
drop procedure IF EXISTS ROUTE //

CREATE PROCEDURE ROUTE(in operatorId int, in date datetime)
begin
	declare userId int;
    declare vehicleId int;
	declare loadDate datetime;
    
    call VEHICLE(operatorId, vehicleId);
	call OWNER_USER(vehicleId, userId);  

    IF date is null THEN
		call LAST_LOAD_DATE(userId, loadDate);   -- Encuentro ultima fecha en que importo esa sesion
    ELSE
      set loadDate = date;
    END IF;
    
    select 
		OPERATOR.userName,        
        convert(ROUTE.date, char) date,
		convert(`LOAD`.date, char) 'loadDate',
		ROUTE.status,
        ROUTE.totalDeliveries
    from ROUTE
    join OPERATOR on ROUTE.operatorId = OPERATOR.id
    join `LOAD` on ROUTE.loadId = `LOAD`.id
    where OPERATOR.id = operatorId
	and `LOAD`.date = loadDate;
end //
delimiter //
