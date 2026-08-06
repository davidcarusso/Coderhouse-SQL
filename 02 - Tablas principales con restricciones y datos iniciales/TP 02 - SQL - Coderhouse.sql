CREATE SCHEMA IF NOT EXISTS retail_project();


CREATE TABLE IF NOT EXISTS retail_project.clientes(
	id_cliente SERIAL PRIMARY KEY
	, nombre_completo VARCHAR(120) NOT null
	, email VARCHAR(120) UNIQUE NOT NULL
	, edad INTEGER CHECK (edad > 0)
);


CREATE TABLE IF NOT EXISTS retail_project.productos(
	id_producto SERIAL PRIMARY KEY
	, nombre_producto VARCHAR(50) NOT NULL 
	, precio DECIMAL(10,2) CHECK (precio > 0) 
	, stock INTEGER CHECK (stock >= 0)
	, categoria VARCHAR(50) NOT NULL CHECK (categoria IN ('Periféricos y Accesorios', 'Conectividad y Redes', 'Componentes Core'))
);


CREATE TABLE IF NOT EXISTS retail_project.ventas(
	id_ventas SERIAL PRIMARY KEY 
	, id_cliente INTEGER NOT NULL 
	, id_producto INTEGER NOT null
	, cantidad INTEGER NOT NULL CHECK(cantidad > 0)
	
	--- conectro con tabla clientes
	, CONSTRAINT fk_clientes
	  FOREIGN KEY (id_cliente)
	  REFERENCES retail_project.clientes(id_cliente)
	  
	  --- conector con tabla productos
	, CONSTRAINT fk_productos
	  FOREIGN KEY (id_producto)
	  REFERENCES retail_project.productos(id_producto)
);


/*
-- Ayuda memoria. 
--	CONSTRAINT fk_tabla
--	FOREIGN KEY (id_dato)
--	REFERENCES tabla (id_dato), 
*/


/*INSERTAR DATOS EN LAS TABLAS:*/

BEGIN;

INSERT INTO retail_project.clientes (nombre_completo,email, edad)
VALUES 
	('Juan Pérez'	, 'juan.perez@example.com', 30),
	('María García'	, 'maria.garcia@example.com', 25),
	('Carlos López'	, 'carlos.lopez@example.com', 35),
	('Ana Rodríguez', 'ana.rodriguez@example.com', 28),
	('Luis Martínez', 'luis.martinez@example.com', 32)
;


INSERT INTO retail_project.productos (nombre_producto, precio, stock, categoria)
VALUES 
    ('Laptop Pro 15'		, 1299.99	, 15, 'Componentes Core'),
    ('Mouse Inalámbrico'	, 25.50		, 50, 'Periféricos y Accesorios'),
    ('Teclado Mecánico RGB'	, 89.90		, 30, 'Periféricos y Accesorios'),
    ('Monitor 27" 4K'		, 349.00	, 10, 'Periféricos y Accesorios'),
    ('Auriculares Bluetooth', 59.99		, 45, 'Periféricos y Accesorios')
;

INSERT INTO retail_project.ventas (id_cliente, id_producto, cantidad)
VALUES 
    (1, 2, 1),
    (2, 1, 2),
    (3, 4, 1),
    (1, 3, 3),
    (5, 5, 2)
;

COMMIT;

/* ACtualizar precio de una categoria especifica*/

BEGIN;

ALTER TABLE retail_project.productos
UPDATE 
SET precio = precio * 1.21 
WHERE categoria = 'Periféricos y Accesorios'
;

COMMIT;

/*Borrar registro*/

BEGIN; 

DELETE FROM retail_project.ventas
WHERE id_ventas = 3
;

COMMIT;











