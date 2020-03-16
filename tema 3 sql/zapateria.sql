drop database if exists zapateria;
create database zapateria;

use zapateria;


create table personal
(
rfc varchar(15) not null,
nombre_completo varchar(100),
sueldo decimal(12,2),
ciudad varchar(50),
estado varchar(50),
direccion varchar(150),
-- constraints
primary key(rfc)
);

create table personal_de_ventas
(
rfc varchar(15) not null,
porc_comision decimal(12,2),
-- constraints
primary key(rfc),
constraint foreign key (rfc) references personal(rfc)
on update cascade on delete cascade
);

create table personal_de_inventario
(
rfc varchar(15) not null,
-- constraints
primary key(rfc),
constraint foreign key (rfc) references personal(rfc)
on update cascade on delete cascade
);

create table calzado
(
id_calzado int not null,
stock int not null,
color varchar(20),
precio decimal(12,2),
tipo varchar(20),
talla decimal(3,1),
modelo varchar(50),
-- constraints
primary key(id_calzado)
);

create table ventas
(
id_venta int not null,
fecha datetime,
monto decimal(12,2),
rfc varchar(15),
-- constraints
primary key(id_venta),
constraint foreign key (rfc) references personal_de_ventas(rfc)
on update cascade on delete cascade
);

create table ventas_por_devolucion
(
id_venta int not null,
id_venta_nueva int not null unique,
-- constrants
primary key(id_venta),
constraint foreign key (id_venta) references ventas(id_venta)
on update cascade on delete cascade,
constraint foreign key (id_venta_nueva) references ventas(id_venta)
on update cascade on delete cascade
);

create table contiene
(
id_venta int not null,
id_calzado int not null,
cantidad int,
fue_devuelto bool,
-- constraints
primary key(id_venta, id_calzado),
constraint foreign key (id_venta) references ventas(id_venta)
on update cascade on delete cascade,
constraint foreign key (id_calzado) references calzado(id_calzado)
on update cascade on delete cascade
);

create table alimenta
(
id_operacion int not null, -- para identificar dos operaciones de un mismo empleado sobre un mismo calzado
rfc varchar(15) not null,
id_calzado int not null,
cantidad int,
fecha datetime,
-- constraints
primary key(id_operacion),
constraint foreign key (id_calzado) references calzado(id_calzado)
on update cascade on delete cascade,
constraint foreign key (rfc) references personal_de_inventario(rfc)
on update cascade on delete cascade
);