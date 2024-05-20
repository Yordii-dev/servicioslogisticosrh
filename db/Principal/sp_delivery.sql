/** (5)
	TOTAL_ORDERS
    DELIVERY_DETAIL
    DELIVERY
	DELIVERY_ORDERS
    DELIVERY_CLIENT
    EXISTS_DELIVERY
*/

-- **********************************TOTAL TOTAL ORDERS
-- Cuenta los productos de una entrega
delimiter //
drop procedure IF EXISTS TOTAL_ORDERS //

CREATE PROCEDURE TOTAL_ORDERS(in deliveryId int)
begin   
    select 
		count(*) 'total'
    from `ORDER`
    join DELIVERY on `ORDER`.deliveryId = DELIVERY.id
    where DELIVERY.id = deliveryId;
end //
delimiter //

-- ********************************** GET DELIVERY
delimiter //
drop procedure IF EXISTS DELIVERY //

CREATE PROCEDURE DELIVERY(in deliveryId int)
begin   
    select * 
    from DELIVERY	
    where DELIVERY.id = deliveryId;
end //
delimiter //

-- **********************************DELIVERY DETAIL
delimiter //
drop procedure IF EXISTS DELIVERY_DETAIL //

CREATE PROCEDURE DELIVERY_DETAIL(in deliveryId int)
begin
	select		
		DELIVERY.id,		
        MANAGED_DELIVERY.status 'managed',
        MANAGED_ORDERS.id 'ordersManaged',   
        EVIDENCED_DELIVERY.id 'evidenced'        
        
	from DELIVERY
    left join MANAGED_DELIVERY on DELIVERY.id = MANAGED_DELIVERY.deliveryId
    left join MANAGED_ORDERS on DELIVERY.id = MANAGED_ORDERS.deliveryId
    left join EVIDENCED_DELIVERY on DELIVERY.id = EVIDENCED_DELIVERY.deliveryId
    
    where DELIVERY.id = deliveryId;
end//
delimiter //

-- **********************************DELIVERY ITEMS
delimiter //
drop procedure IF EXISTS DELIVERY_ORDERS //

CREATE PROCEDURE DELIVERY_ORDERS(in deliveryId int)
begin
	select
		`ORDER`.id,
		ITEM.id 'itemId',
		ITEM.name,
        `ORDER`.amount,
        if(DELIVERED_ORDER.amount is null, 
			0, 
			DELIVERED_ORDER.amount) 'given'
		
	from `ORDER`
    join ITEM on `ORDER`.itemId = ITEM.id	
    left join DELIVERED_ORDER on `ORDER`.id = DELIVERED_ORDER.orderId
    join DELIVERY on `ORDER`.deliveryId = DELIVERY.id
    
    where DELIVERY.id = deliveryId;
end //
delimiter //;

-- **********************************DELIVERY CLIENT
delimiter //
drop procedure IF EXISTS DELIVERY_CLIENT //

CREATE PROCEDURE DELIVERY_CLIENT(in deliveryId int)
begin    
    select 
		-- DELIVERY.id 'deliveryId',
		CLIENT.id,
		CLIENT.name,
		CLIENT.address,
		CLIENT.phone,
		CLIENT.latitude,
        CLIENT.longitude
    from DELIVERY 
    join CLIENT on DELIVERY.clientId = CLIENT.id
	where DELIVERY.id = deliveryId;
end //
delimiter //;

-- **********************************EXISTS DELIVERY
delimiter //
drop procedure IF EXISTS EXISTS_DELIVERY //

CREATE PROCEDURE EXISTS_DELIVERY(in deliveryId bigint)
begin    
	select DELIVERY.id from
    DELIVERY where id = deliveryId;
end //
delimiter //;