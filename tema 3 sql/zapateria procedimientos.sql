-- ----------------------
-- DISPARADORES
-- ----------------------
delimiter //
drop trigger if exists ai_contiene//
create trigger ai_contiene after insert on contiene for each row
begin
    declare canti int;
     
    set canti = (select cantidad from calzado inner join contiene
    on calzado.id_calzado = contiene.id_calzado
    where contiene.id_venta = new.id_venta and contiene.id_calzado = new.id_calzado);
    
    
	-- para restar al stock
	call subStock(canti, new.id_calzado);
	-- para determinar el monto     
    call setMonto(new.id_calzado, new.id_venta);
end//
delimiter ;

delimiter //
drop trigger if exists au_contiene//
create trigger au_contiene after update on contiene for each row
begin
    declare canti int;
    
    set canti = (select cantidad from calzado inner join contiene
    on calzado.id_calzado = contiene.id_calzado
    where contiene.id_venta = new.id_venta and contiene.id_calzado = new.id_calzado);
    
    -- si se actualizó el pedido para que fuera devuelto
	if new.fue_devuelto then
	 	call addStock(canti, new.id_calzado);
    end if;
    
    -- este procedimiento actualiza el monto al descartarse el dinero de una venta devuelta
    call setMonto(new.id_calzado, new.id_venta);
end//
delimiter ;

delimiter //
drop trigger if exists ai_alimenta//
create trigger ai_alimenta after insert on alimenta for each row
begin
	call addStock(new.cantidad, new.id_calzado);
end//



-- ----------------------
-- PROCEDIMIENTOS
-- ----------------------

delimiter //
drop procedure if exists addStock//
create procedure addStock(in cantidad int, in id_cal int)
begin
	declare stockOrig int;
    declare stockNew int;
    
    set stockOrig = (select stock from calzado where id_calzado = id_cal);
    set stockNew = stockOrig + cantidad;
    update calzado set stock = stockNew where id_calzado = id_cal;
end//
delimiter ;

delimiter //
drop procedure if exists subStock//
create procedure subStock(in canti int, in id_cal int)
begin
	set canti = -canti;
	call addStock(canti, id_cal);
end//
delimiter ;

delimiter //
drop procedure if exists setMonto//
create procedure setMonto(in id_calz int, in id_ven int)
begin
	declare tempMonto decimal(12,2);
    set tempMonto = montoTotal(id_calz, id_ven);
	-- si el monto temporal resulta ser nulo, cambialo a 0
	if tempMonto is null then
		update ventas set monto = 0 where ventas.id_venta = id_ven;
	else
		update ventas set monto = montoTotal(id_calz, id_ven) where ventas.id_venta = id_ven;
	end if;
end//
delimiter ;

-- ----------------------
-- FUNCIONES
-- ----------------------

delimiter //
drop function if exists nextVentaIndex//
create function nextVentaIndex() returns int reads sql data
begin
	declare nextIndex int;
	set nextIndex = (select max(id_venta) from ventas)+1;
    return nextIndex;
end//
delimiter ;


delimiter //
drop function if exists montoTotal//
create function montoTotal(calz_id int, id_ven int) returns decimal(12,2) reads sql data
begin
	declare total decimal(12,2);
	set total = (select sum(contiene.cantidad * calzado.precio) as "multi" from calzado inner join contiene
	on calzado.id_calzado = contiene.id_calzado where not contiene.fue_devuelto
    and contiene.id_venta = id_ven
    group by contiene.id_venta);
    return total;
end//
delimiter ;

delimiter //
drop function if exists porcComision//
create function porcComision(porcentaje decimal(12,2), precio decimal(12,2)) returns decimal(12,2) reads sql data
begin
	declare total decimal(12,2);
	set total = porcentaje * precio;
    return total;
end//
delimiter ;