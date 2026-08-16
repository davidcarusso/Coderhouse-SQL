-- Creamos el schema para tp 04:
CREATE SCHEMA IF NOT EXISTS entregable_04;


-- Creamos las tablas del tp02: 
CREATE TABLE IF NOT EXISTS entregable_04.clientes(
	id_cliente SERIAL PRIMARY KEY
	, nombre_completo VARCHAR(120) NOT null
	, email VARCHAR(120) UNIQUE NOT NULL
	, edad INTEGER CHECK (edad > 0)
);


CREATE TABLE IF NOT EXISTS entregable_04.productos(
	id_producto SERIAL PRIMARY KEY
	, nombre_producto VARCHAR(50) NOT NULL 
	, precio DECIMAL(10,2) CHECK (precio > 0) 
	, stock INTEGER CHECK (stock >= 0)
	, categoria VARCHAR(50) NOT NULL CHECK (categoria IN ('Periféricos y Accesorios', 'Conectividad y Redes', 'Componentes Core'))
);


CREATE TABLE IF NOT EXISTS entregable_04.ventas(
	id_ventas SERIAL PRIMARY KEY 
	, id_cliente INTEGER NOT NULL 
	, id_producto INTEGER NOT null
	, cantidad INTEGER NOT NULL CHECK(cantidad > 0)
	
	--- conectro con tabla clientes
	, CONSTRAINT fk_clientes
	  FOREIGN KEY (id_cliente)
	  REFERENCES entregable_04.clientes(id_cliente)
	  
	  --- conector con tabla productos
	, CONSTRAINT fk_productos
	  FOREIGN KEY (id_producto)
	  REFERENCES entregable_04.productos(id_producto)
);



--- CARGAMOS CLIENTES --- 

BEGIN;

INSERT INTO entregable_04.clientes (nombre_completo, email, edad)
VALUES 
    ('Pedro Sánchez', 'pedro.sanchez@example.com', 41),
    ('Laura Fernández', 'laura.fernandez@example.com', 29),
    ('Diego González', 'diego.gonzalez@example.com', 38),
    ('Sofía Ramírez', 'sofia.ramirez@example.com', 24),
    ('Martín Torres', 'martin.torres@example.com', 45),
    ('Camila Díaz', 'camila.diaz@example.com', 31),
    ('Federico Castro', 'federico.castro@example.com', 27),
    ('Valentina Ruiz', 'valentina.ruiz@example.com', 22),
    ('Nicolás Romero', 'nicolas.romero@example.com', 36),
    ('Lucía Álvarez', 'lucia.alvarez@example.com', 33),
    ('Sebastián Molina', 'sebastian.molina@example.com', 40),
    ('Julieta Suárez', 'julieta.suarez@example.com', 26),
    ('Gabriel Herrera', 'gabriel.herrera@example.com', 37),
    ('Carolina Navarro', 'carolina.navarro@example.com', 30),
    ('Andrés Medina', 'andres.medina@example.com', 43),
    ('Florencia Acosta', 'florencia.acosta@example.com', 28),
    ('Matías Vega', 'matias.vega@example.com', 34),
    ('Paula Cabrera', 'paula.cabrera@example.com', 39),
    ('Rodrigo Pereyra', 'rodrigo.pereyra@example.com', 46),
    ('Agustina Rojas', 'agustina.rojas@example.com', 23),
    ('Tomás Núñez', 'tomas.nunez@example.com', 32),
    ('Daniela Ortiz', 'daniela.ortiz@example.com', 35),
    ('Ignacio Silva', 'ignacio.silva@example.com', 29),
    ('Micaela Campos', 'micaela.campos@example.com', 27),
    ('Franco Duarte', 'franco.duarte@example.com', 42),
    ('Emilia Sosa', 'emilia.sosa@example.com', 25),
    ('Joaquín Bravo', 'joaquin.bravo@example.com', 31),
    ('Renata Miranda', 'renata.miranda@example.com', 36),
    ('Maximiliano Godoy', 'maximiliano.godoy@example.com', 44),
    ('Martina Figueroa', 'martina.figueroa@example.com', 21),
    ('Gonzalo Ibarra', 'gonzalo.ibarra@example.com', 39),
    ('Abril Vera', 'abril.vera@example.com', 26),
    ('Leandro Correa', 'leandro.correa@example.com', 48),
    ('Pilar Ferreyra', 'pilar.ferreyra@example.com', 30),
    ('Esteban Maldonado', 'esteban.maldonado@example.com', 37),
    ('Milagros Ponce', 'milagros.ponce@example.com', 24),
    ('Hernán Arias', 'hernan.arias@example.com', 41),
    ('Rocío Benítez', 'rocio.benitez@example.com', 28),
    ('Germán Villalba', 'german.villalba@example.com', 35),
    ('Natalia Cárdenas', 'natalia.cardenas@example.com', 33),
    ('Pablo Bustos', 'pablo.bustos@example.com', 47),
    ('Malena Quiroga', 'malena.quiroga@example.com', 22),
    ('Ezequiel Miranda', 'ezequiel.miranda@example.com', 34),
    ('Victoria Ledesma', 'victoria.ledesma@example.com', 29),
    ('Ramiro Escobar', 'ramiro.escobar@example.com', 40),
    ('Constanza Ojeda', 'constanza.ojeda@example.com', 31)
;

-- COMPLETAMOS A LOS 50 CLIENTES: 

INSERT INTO entregable_04.clientes
    (nombre_completo, email, edad)
VALUES
    ('Luciano Méndez', 'luciano.mendez@example.com', 32),
    ('Verónica Paz', 'veronica.paz@example.com', 27),
    ('Santiago Peralta', 'santiago.peralta@example.com', 41),
    ('Mariana Lozano', 'mariana.lozano@example.com', 29)
;

-- AGREGAMOS CLIENTES PARA QUE NO TENGAN VENTAS: 

INSERT INTO entregable_04.clientes
    (nombre_completo, email, edad)
VALUES
    ('Federico Navarro', 'federico.navarro@example.com', 31),
    ('Camila Torres', 'camila.torres@example.com', 26),
    ('Martín Cabrera', 'martin.cabrera@example.com', 38),
    ('Julieta Molina', 'julieta.molina@example.com', 24),
    ('Diego Ferreyra', 'diego.ferreyra@example.com', 45);

SELECT * FROM entregable_04.clientes AS c
ORDER BY c.id_cliente DESC
;

COMMIT;


--- CARGAMOS PRODUCTOS ---

BEGIN;

INSERT INTO entregable_04.productos 
    (nombre_producto, precio, stock, categoria)
VALUES 
    ('SSD NVMe 1TB', 119.99, 25, 'Componentes Core'),
    ('Memoria RAM 16GB', 74.50, 40, 'Componentes Core'),
    ('Procesador Ryzen 5', 219.99, 12, 'Componentes Core'),
    ('Placa de Video RTX 4060', 399.99, 8, 'Componentes Core'),
    ('Fuente 650W 80 Plus', 89.90, 20, 'Componentes Core'),
    ('Gabinete ATX Gaming', 109.99, 18, 'Componentes Core'),
    ('Disco HDD 2TB', 69.99, 22, 'Componentes Core'),
    ('Motherboard B550', 139.90, 14, 'Componentes Core'),
    ('Cooler CPU RGB', 45.99, 30, 'Componentes Core'),
    ('Placa Madre X570', 189.90, 9, 'Componentes Core'),

    ('Webcam Full HD', 49.99, 35, 'Periféricos y Accesorios'),
    ('Parlantes 2.1', 45.90, 28, 'Periféricos y Accesorios'),
    ('Pad Mouse XL', 19.99, 60, 'Periféricos y Accesorios'),
    ('Joystick Inalámbrico', 54.99, 25, 'Periféricos y Accesorios'),
    ('Micrófono USB', 79.90, 16, 'Periféricos y Accesorios'),
    ('Hub USB-C', 34.50, 40, 'Periféricos y Accesorios'),
    ('Adaptador Bluetooth', 14.99, 55, 'Periféricos y Accesorios'),
    ('Cable USB-C 2m', 12.90, 80, 'Periféricos y Accesorios'),
    ('Cable DisplayPort', 18.50, 45, 'Periféricos y Accesorios'),
    ('Soporte para Monitor', 64.99, 20, 'Periféricos y Accesorios'),
    ('Silla Gamer', 299.99, 7, 'Periféricos y Accesorios'),
    ('Teclado Inalámbrico', 39.90, 32, 'Periféricos y Accesorios'),
    ('Mouse Gaming RGB', 44.99, 38, 'Periféricos y Accesorios'),
    ('Auriculares Gaming', 89.90, 21, 'Periféricos y Accesorios'),
    ('Controlador MIDI', 129.99, 11, 'Periféricos y Accesorios'),

    ('Router WiFi 6', 129.99, 17, 'Conectividad y Redes'),
    ('Switch Gigabit 8 Puertos', 59.90, 23, 'Conectividad y Redes'),
    ('Placa de Red WiFi', 29.99, 31, 'Conectividad y Redes'),
    ('Repetidor WiFi', 44.99, 27, 'Conectividad y Redes'),
    ('Cable Ethernet 10m', 15.90, 65, 'Conectividad y Redes'),
    ('Router Mesh', 179.99, 13, 'Conectividad y Redes'),
    ('Switch 16 Puertos', 99.90, 14, 'Conectividad y Redes'),
    ('Access Point WiFi', 109.99, 18, 'Conectividad y Redes'),
    ('Cable Ethernet Cat6 5m', 9.99, 70, 'Conectividad y Redes'),
    ('Adaptador USB WiFi', 24.99, 42, 'Conectividad y Redes'),

    ('Cámara IP', 99.99, 15, 'Conectividad y Redes'),
    ('Kit Cámara IP x2', 189.90, 8, 'Conectividad y Redes'),
    ('UPS 1000VA', 159.99, 12, 'Componentes Core'),
    ('Estabilizador 1200VA', 54.90, 26, 'Componentes Core'),
    ('Regleta 6 Tomas', 24.99, 48, 'Periféricos y Accesorios'),
    ('Cable HDMI 5m', 22.90, 50, 'Periféricos y Accesorios'),
    ('Adaptador HDMI-VGA', 17.99, 38, 'Periféricos y Accesorios'),
    ('Cable Lightning 2m', 21.90, 44, 'Periféricos y Accesorios'),
    ('Cable Auxiliar', 8.99, 70, 'Periféricos y Accesorios'),
    ('Cargador USB-C 65W', 49.99, 29, 'Periféricos y Accesorios')
;

-- COMPLETAMOS A LOS 50 PRODUCTOS: 

INSERT INTO entregable_04.productos
    (nombre_producto, precio, stock, categoria)
VALUES
    ('Monitor 24" Full HD', 189.99, 15, 'Periféricos y Accesorios'),
    ('Router WiFi 5', 79.99, 20, 'Conectividad y Redes'),
    ('Memoria RAM 8GB', 39.99, 35, 'Componentes Core'),
    ('SSD SATA 480GB', 49.99, 25, 'Componentes Core'),
    ('Teclado USB', 19.99, 40, 'Periféricos y Accesorios')
;


SELECT * FROM entregable_04.productos
ORDER BY id_producto DESC
;

COMMIT; 


-- CARGAMOS VENTAS ---

BEGIN;

INSERT INTO entregable_04.ventas (id_cliente, id_producto, cantidad)
VALUES
    (17, 43, 2),
    (3, 8, 1),
    (41, 27, 4),
    (12, 35, 2),
    (29, 14, 1),
    (7, 49, 3),
    (36, 21, 5),
    (22, 6, 2),
    (45, 32, 1),
    (9, 18, 4),

    (31, 46, 2),
    (14, 11, 3),
    (48, 29, 1),
    (5, 37, 6),
    (26, 4, 2),
    (39, 50, 1),
    (18, 23, 3),
    (2, 41, 2),
    (34, 16, 5),
    (11, 30, 1),

    (43, 7, 2),
    (20, 44, 3),
    (6, 19, 1),
    (27, 33, 4),
    (50, 12, 2),
    (15, 25, 7),
    (38, 2, 1),
    (24, 39, 3),
    (1, 48, 2),
    (32, 17, 1),

    (8, 31, 5),
    (46, 10, 2),
    (19, 45, 3),
    (35, 22, 1),
    (13, 36, 4),
    (42, 5, 2),
    (4, 28, 6),
    (30, 15, 1),
    (21, 40, 3),
    (49, 9, 2),

    (16, 34, 1),
    (37, 20, 4),
    (10, 47, 2),
    (28, 13, 3),
    (44, 26, 1),
    (23, 42, 5),
    (33, 3, 2),
    (47, 38, 1),
    (25, 24, 3),
    (40, 49, 2),

    (6, 43, 7),
    (29, 7, 1),
    (17, 32, 3),
    (45, 18, 2),
    (2, 27, 4),
    (38, 11, 1),
    (12, 46, 2),
    (31, 5, 3),
    (9, 39, 1),
    (50, 21, 5),

    (20, 14, 2),
    (35, 48, 1),
    (4, 16, 4),
    (26, 30, 2),
    (43, 9, 3),
    (15, 44, 1),
    (7, 23, 6),
    (33, 37, 2),
    (48, 6, 1),
    (19, 50, 3),

    (41, 28, 2),
    (11, 41, 1),
    (24, 12, 4),
    (36, 35, 2),
    (5, 19, 3),
    (27, 45, 1),
    (14, 3, 5),
    (46, 22, 2),
    (30, 31, 1),
    (8, 40, 3),

    (22, 17, 2),
    (39, 29, 4),
    (1, 34, 1),
    (34, 8, 3),
    (18, 47, 2),
    (47, 15, 1),
    (10, 36, 5),
    (25, 26, 2),
    (42, 49, 3),
    (3, 20, 1),

    (37, 43, 4),
    (13, 10, 2),
    (49, 24, 1),
    (21, 38, 3),
    (32, 7, 2),
    (16, 45, 6),
    (44, 30, 1),
    (28, 18, 4),
    (40, 33, 2),
    (23, 50, 3);

COMMIT;



