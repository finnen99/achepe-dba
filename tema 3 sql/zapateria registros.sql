-- añadiendo un empleado personal de ventas
insert into personal values("MAPS780306G53", "Sebastian Marco Polo",500.00,"Pachuca de Soto","Hidalgo","Andador 4 117 Venta Prieta");
insert into personal values("PXNE000101H74", "Ernesto Noriega Perez",600.00,"Pachuca de Soto","Hidalgo","Santa sara 1080, La providencia");
insert into personal values("ROPA991220F34", "Andre Vladimir Rojas Palacios",111.00,"Pachuca de Soto","Hidalgo","Volcan Quinceo 103, San Cayetano");
insert into personal values("VXGO010415E13", "Omar Alexis Vatierra Bargas",800.00,"Pachuca de Soto","Hidalgo","Santa Sara 1093, La Providencia");
insert into personal values("SXNO000229D69", "Oscar Serrano Navarro",400.00,"Pachuca de Soto","Hidalgo","215 De Los Gurriones, San Antonio");
insert into personal_de_ventas values("MAPS780306G53",0.12);
insert into personal_de_ventas values("ROPA991220F34",0.25);
insert into personal_de_ventas values("SXNO000229D69",0.13);
insert into personal_de_inventario value ("PXNE000101H74");
insert into personal_de_inventario value ("VXGO010415E13");

-- registrando algunos ejemplares
insert into calzado values(1, 0, "Negro", 1099.00, "Tenis", 26, "Converse All Star");
insert into alimenta values(1,"PXNE000101H74", 1, 10, now() );
insert into calzado values(2, 0, "Negro", 1076.00, "Tenis", 25.5, "Converse All Star");
insert into alimenta values(2,"VXGO010415E13", 2, 8, now() );
insert into calzado values(3, 0, "Negro", 1049.00, "Tenis", 25, "Converse All Star");
insert into alimenta values(3,"VXGO010415E13", 3, 8, now() );

insert into calzado values(4, 0, "Rojo", 1568.12, "Tenis", 25.5, "Converse All Star");
insert into alimenta values(4,"PXNE000101H74", 4, 12, now() );

insert into calzado values(5, 0, "Azul", 1299.99, "Tenis", 28.5, "Adidas Lite Racer");
insert into alimenta values(5,"PXNE000101H74", 5, 16, now() );

insert into calzado values(6, 0, "Café", 699.99, "Zapatos", 24, "Flexi 47514");
insert into alimenta values(6,"VXGO010415E13", 6, 8, now() );


-- insertando 3 ventas
-- compra de 3 pares calzado id 1
-- stock de calzado con id 1 baja de 10 a 7
insert into ventas values(1, now(), null, "MAPS780306G53");
insert into contiene values(1, 1, 3, false);

-- compra de 4 pares calzado id 5, y un par del calzado id 4
-- stock de calzado con id 5 baja de 16 a 12
insert into ventas values(2, now(), null, "SXNO000229D69");
insert into contiene values(2, 5, 4, false);
insert into contiene values(2, 4, 1, false);

-- compra de 1 par calzado id 2
-- stock de calzado con id 2 baja de 8 a 7
insert into ventas values(3, now(), null, "ROPA991220F34");
insert into contiene values(3, 2, 1, false);

-- devolviendo segunda venta, 4 pares
-- stock de calzado con id 5 sube de 12 a 16
update contiene set fue_devuelto = true where id_venta = 2 and id_calzado = 5;


-- devolviendo tercera venta
-- stock de calzado con id 3 sube de 7 a 8
update contiene set fue_devuelto = true where id_venta = 3 and id_calzado = 2;
-- además, cambialo por otro calzado (quizás más barato)
-- stock de calzado con id 6 baja de 8 a 7
insert into ventas values(4, now(), null, "ROPA991220F34");
insert into contiene values(4, 6, 1, false);
insert into ventas_por_devolucion values(3,4);

-- otra venta + devolucion del calzado con id 5
insert into ventas values(5, now(), null, "SXNO000229D69");
insert into contiene values(5, 5, 2, false);
update contiene set fue_devuelto = true where id_venta = 5 and id_calzado = 5;
--
select * from contiene;
select * from calzado;

-- devuelve una lista de las ventas
select * from ventas;

-- devuelve una lista de las ventas que no fueron devueltas

-- devuelve una lista de las ventas que fueron resultado de la devolución de otra


-- muestra el dinero ganado por las ventas, sin devoluciones, del mes de marzo
select sum(ventas.monto) as 'total' from ventas inner join contiene
on ventas.id_venta = contiene.id_venta where ventas.fecha between '2020-03-01' and '2020-03-31'
and contiene.fue_devuelto = false;

-- muestra el dinero ganado por el porcentaje de comisión que corresponde a Sebastian por sus ventas, sin devoluciones,
-- el mes de marzo
select personal.rfc, personal.nombre_completo as 'nombre',
porcComision(personal_de_ventas.porc_comision, sum(ventas.monto)) as '% comision'
from ventas inner join contiene
on ventas.id_venta = contiene.id_venta  inner join personal
on ventas.rfc = personal.rfc inner join personal_de_ventas
on personal.rfc = personal_de_ventas.rfc
where ventas.fecha between '2020-03-01' and '2020-03-31'
and contiene.fue_devuelto = false group by personal.nombre_completo
having personal.rfc = "MAPS780306G53";

-- muestra el modelo de calzado que ha sido devuelto más veces
select calzado.id_calzado, calzado.modelo, sum(contiene.fue_devuelto) as "No. devoluciones" from calzado inner join contiene
on calzado.id_calzado = contiene.id_calzado where fue_devuelto group by calzado.id_calzado
order by "No. devoluciones" limit 1;