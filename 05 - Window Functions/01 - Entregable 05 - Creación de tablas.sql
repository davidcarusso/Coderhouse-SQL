-- Creamos el Schema 

CREATE SCHEMA IF NOT EXISTS entregable_05;


-- Creamos las tablas:


CREATE TABLE IF NOT EXISTS entregable_05.categorias(
	id_categoria SERIAL PRIMARY KEY 
,	nombre_categoria VARCHAR(120) UNIQUE NOT NULL 
);


CREATE  TABLE IF NOT EXISTS entregable_05.productos(
	id_producto SERIAL PRIMARY KEY 
,	nombre_producto VARCHAR(120) UNIQUE NOT NULL   
,	precio_producto DECIMAL(10,2) NOT NULL CHECK (precio_producto > 0)
,	id_categoria INTEGER NOT NULL 

--- conector con categoria
, CONSTRAINT fk_categoria
	FOREIGN KEY (id_categoria)
	REFERENCES entregable_05.categorias (id_categoria)
);


CREATE  TABLE IF NOT EXISTS entregable_05.venta(
	id_ventas SERIAL PRIMARY KEY 
,	id_producto INTEGER NOT NULL 
, 	cantidad INTEGER NOT NULL CHECK (cantidad > 0)
,	fecha TIMESTAMP NOT NULL  
  --- conector con tabla productos
,	CONSTRAINT fk_productos
	FOREIGN KEY (id_producto)
	REFERENCES entregable_05.productos(id_producto)
);