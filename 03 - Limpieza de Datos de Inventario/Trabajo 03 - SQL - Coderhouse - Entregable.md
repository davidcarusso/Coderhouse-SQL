## Ejercicio de Práctica: Limpieza de Datos de Inventario

En este ejercicio, actuarás como analista para una empresa de retail que tiene datos incompletos en su inventario. Deberás limpiar los resultados usando lo aprendido.

### **Contexto:**
---
Tienes una tabla llamada `productos` con las siguientes columnas:

- `nombre` (Texto)
- `precio_lista` (Numérico, puede ser NULL)
- `descuento_promocional` (Numérico, puede ser NULL)
- `categoria` (Texto, puede ser NULL)

Para ello se creo la siguiente estructura: 

```sql
-- Creamos schema para separar las tablas en entregable_03.
CREATE SCHEMA entregable_03;

-- Creamos tablas dentro de entregable_03.
CREATE TABLE IF NOT EXISTS entregable_03.productos(
	id_producto SERIAL PRIMARY KEY
	, nombre VARCHAR(50) NOT NULL
	, precio_lista DECIMAL(10,2)
	, descuento_promocional DECIMAL(10,2) default(0)
	, categoria VARCHAR(50)
)
;

-- Ingresamos datos en tablas.
INSERT INTO entregable_03.productos(nombre, precio_lista, descuento_promocional, categoria)
VALUES
 
-- ARTICULOS GENERADOS POR IA

-- 1 a 10: Electrónica / Tecnología
	('Teclado Mecánico RGB', 45000.00, 5000.00, 'Electrónica'),
	('Mouse Inalámbrico', 18000.50, NULL, 'Electrónica'),
	('Monitor 24 Pulgadas', 120000.00, 0, 'Electrónica'),
	('Auriculares Bluetooth', 32000.00, NULL, NULL),
	('Cable HDMI 2m', NULL, NULL, 'Electrónica'),
	('Cargador Carga Rápida', 15000.00, 1500.00, 'Electrónica'),
	('Placa de Video RTX 3060', NULL, 15000.00, 'Electrónica'),
	('Gabinete ATX', 55000.00, 0.00, NULL),
	('Memoria RAM 16GB', 42000.00, NULL, 'Electrónica'),
	('Disco SSD 1TB', 65000.00, 5000.00, 'Electrónica'),

-- 11 a 20: Indumentaria
	('Remera Algodón Negra', 12000.00, 0, 'Indumentaria'),
	('Pantalón Jean Clásico', 35000.00, 3500.00, 'Indumentaria'),
	('Buzo con Capucha', NULL, NULL, 'Indumentaria'),
	('Campera de Abrigo', 85000.00, NULL, 'Indumentaria'),
	('Zapatillas Deportivas', 60000.00, 10000.00, NULL),
	('Medias x3 Pares', 4500.00, 0.00, 'Indumentaria'),
	('Cinturón de Cuero', 15000.00, NULL, 'Indumentaria'),
	('Gorra Urbana', NULL, 1000.00, 'Indumentaria'),
	('Vestido Casual', 28000.00, NULL, NULL),
	('Malla Natación', 18000.00, 2000.00, 'Indumentaria'),

-- 21 a 30: Hogar y Bazar
	('Juego de Sábanas 2 Plazas', 25000.00, 2500.00, 'Hogar'),
	('Almohada Viscoelástica', 18000.00, NULL, 'Hogar'),
	('Taza Cerámica', 3500.00, 0, NULL),
	('Sartén Antiadherente', 22000.00, 2000.00, 'Hogar'),
	('Lámpara de Escritorio', NULL, NULL, 'Hogar'),
	('Cortina de Baño', 8500.00, NULL, 'Hogar'),
	('Silla de Escritorio Ergonómica', 110000.00, 15000.00, NULL),
	('Organizador de Plastico', 4200.00, 0.00, 'Hogar'),
	('Plato Playo Cerámica', 2800.00, NULL, 'Hogar'),
	('Juego de Cubiertos 24 piezas', 38000.00, 4000.00, 'Hogar'),

-- 31 a 40: Alimentos y Bebidas
	('Café en Grano 500g', 14000.00, NULL, 'Alimentos'),
	('Yerba Mate 1kg', 4200.00, 0, 'Alimentos'),
	('Aceite de Oliva Extra Virgen 500ml', 9500.00, 1000.00, NULL),
	('Vino Tinto Reserva', NULL, NULL, 'Bebidas'),
	('Chocolate Amargo 70%', 3200.00, NULL, 'Alimentos'),
	('Agua Mineral 1.5L', 1200.00, 0.00, 'Bebidas'),
	('Pack Cerveza Artesanal x6', 11000.00, 1500.00, 'Bebidas'),
	('Queso Sardo 500g', 7800.00, NULL, NULL),
	('Galletitas Avena y Miel', NULL, 0, 'Alimentos'),
	('Arroz Largo Fino 1kg', 2100.00, NULL, 'Alimentos'),

-- 41 a 50: Herramientas y Otros
	('Taladro Percutor 650W', 75000.00, 7500.00, 'Herramientas'),
	('Juego de Destornilladores', 16000.00, NULL, 'Herramientas'),
	('Cinta Métrica 5m', 4500.00, 0, NULL),
	('Caja de Herramientas Plástica', 28000.00, 3000.00, 'Herramientas'),
	('Martillo Galponero', NULL, NULL, 'Herramientas'),
	('Lija para Madera Pliego', 600.00, NULL, NULL),
	('Set Pintura Acrílica', 19000.00, 2000.00, 'Librería'),
	('Cuaderno Anillado A4', 6500.00, 0.00, 'Librería'),
	('Mochila Ejecutiva', 48000.00, NULL, 'Accesorios'),
	('Lentes de Sol', NULL, 5000.00, 'Accesorios')
;
```

### **Tareas a realizadas:**

> [!Question] Ejercicio 1: Identificar Huecos
> Escribe una consulta que devuelva todos los productos que **no tienen una categoría asignada**.
 
- Input: 

```sql
-- Ejercicio 01

SELECT
	*
FROM entregable_03.productos
WHERE categoria IS NULL
;
```

- Output:

| id_producto | nombre                             | precio_lista | descuento_promocional | categoria |
| ----------- | ---------------------------------- | ------------ | --------------------- | --------- |
| 4           | Auriculares Bluetooth              | 32,000       | [NULL]                | [NULL]    |
| 8           | Gabinete ATX                       | 55,000       | 0                     | [NULL]    |
| 15          | Zapatillas Deportivas              | 60,000       | 10,000                | [NULL]    |
| 19          | Vestido Casual                     | 28,000       | [NULL]                | [NULL]    |
| 23          | Taza Cerámica                      | 3,500        | 0                     | [NULL]    |
| 27          | Silla de Escritorio Ergonómica     | 110,000      | 15,000                | [NULL]    |
| 33          | Aceite de Oliva Extra Virgen 500ml | 9,500        | 1,000                 | [NULL]    |
| 38          | Queso Sardo 500g                   | 7,800        | [NULL]                | [NULL]    |
| 43          | Cinta Métrica 5m                   | 4,500        | 0                     | [NULL]    |
| 46          | Lija para Madera Pliego            | 600          | [NULL]                | [NULL]    |

> [!Question] Ejercicio 2: Reporte de Precios para el Cliente: 
> - Crea un listado que muestre el nombre del producto y el precio.
> 	- Si el `precio_lista` es NULL, debe mostrar `0`.
> 	- Llama a esta columna `precio_final`.

```sql 
--Ejercicio 02

SELECT
	p.nombre AS nombre_producto
,   COALESCE(p.precio_lista, 0) AS precio_final
FROM entregable_03.productos AS p
ORDER BY 2 DESC
;
```

+ Output:

| nombre_producto                    | precio_final |
| ---------------------------------- | ------------ |
| Monitor 24 Pulgadas                | 120,000      |
| Silla de Escritorio Ergonómica     | 110,000      |
| Campera de Abrigo                  | 85,000       |
| Taladro Percutor 650W              | 75,000       |
| Disco SSD 1TB                      | 65,000       |
| Zapatillas Deportivas              | 60,000       |
| Gabinete ATX                       | 55,000       |
| Mochila Ejecutiva                  | 48,000       |
| Teclado Mecánico RGB               | 45,000       |
| Memoria RAM 16GB                   | 42,000       |
| Juego de Cubiertos 24 piezas       | 38,000       |
| Pantalón Jean Clásico              | 35,000       |
| Auriculares Bluetooth              | 32,000       |
| Vestido Casual                     | 28,000       |
| Caja de Herramientas Plástica      | 28,000       |
| Juego de Sábanas 2 Plazas          | 25,000       |
| Sartén Antiadherente               | 22,000       |
| Set Pintura Acrílica               | 19,000       |
| Mouse Inalámbrico                  | 18,000.5     |
| Malla Natación                     | 18,000       |
| Almohada Viscoelástica             | 18,000       |
| Juego de Destornilladores          | 16,000       |
| Cinturón de Cuero                  | 15,000       |
| Cargador Carga Rápida              | 15,000       |
| Café en Grano 500g                 | 14,000       |
| Remera Algodón Negra               | 12,000       |
| Pack Cerveza Artesanal x6          | 11,000       |
| Aceite de Oliva Extra Virgen 500ml | 9,500        |
| Cortina de Baño                    | 8,500        |
| Queso Sardo 500g                   | 7,800        |
| Cuaderno Anillado A4               | 6,500        |
| Medias x3 Pares                    | 4,500        |
| Cinta Métrica 5m                   | 4,500        |
| Yerba Mate 1kg                     | 4,200        |
| Organizador de Plastico            | 4,200        |
| Taza Cerámica                      | 3,500        |
| Chocolate Amargo 70%               | 3,200        |
| Plato Playo Cerámica               | 2,800        |
| Arroz Largo Fino 1kg               | 2,100        |
| Agua Mineral 1.5L                  | 1,200        |
| Lija para Madera Pliego            | 600          |
| Lentes de Sol                      | 0            |
| Vino Tinto Reserva                 | 0            |
| Lámpara de Escritorio              | 0            |
| Galletitas Avena y Miel            | 0            |
| Gorra Urbana                       | 0            |
| Buzo con Capucha                   | 0            |
| Martillo Galponero                 | 0            |
| Placa de Video RTX 3060            | 0            |
| Cable HDMI 2m                      | 0            |

>[!Question] Ejercicio 3: Limpieza de Categorías
>- Crea una consulta que muestre el nombre del producto y su categoría.
>- Si la categoría es NULL, debe mostrar el texto `'Sin Categorizar'`.

```sql
SELECT
	p.nombre
	, COALESCE(p.categoria, 'Sin Categorizar') AS categoria
FROM entregable_03.productos AS p
ORDER BY 2
;
```

- Output:

| nombre                             | categoria       |
| ---------------------------------- | --------------- |
| Lentes de Sol                      | Accesorios      |
| Mochila Ejecutiva                  | Accesorios      |
| Café en Grano 500g                 | Alimentos       |
| Arroz Largo Fino 1kg               | Alimentos       |
| Galletitas Avena y Miel            | Alimentos       |
| Chocolate Amargo 70%               | Alimentos       |
| Yerba Mate 1kg                     | Alimentos       |
| Vino Tinto Reserva                 | Bebidas         |
| Pack Cerveza Artesanal x6          | Bebidas         |
| Agua Mineral 1.5L                  | Bebidas         |
| Teclado Mecánico RGB               | Electrónica     |
| Monitor 24 Pulgadas                | Electrónica     |
| Cable HDMI 2m                      | Electrónica     |
| Cargador Carga Rápida              | Electrónica     |
| Mouse Inalámbrico                  | Electrónica     |
| Placa de Video RTX 3060            | Electrónica     |
| Memoria RAM 16GB                   | Electrónica     |
| Disco SSD 1TB                      | Electrónica     |
| Caja de Herramientas Plástica      | Herramientas    |
| Taladro Percutor 650W              | Herramientas    |
| Juego de Destornilladores          | Herramientas    |
| Martillo Galponero                 | Herramientas    |
| Juego de Sábanas 2 Plazas          | Hogar           |
| Sartén Antiadherente               | Hogar           |
| Lámpara de Escritorio              | Hogar           |
| Cortina de Baño                    | Hogar           |
| Almohada Viscoelástica             | Hogar           |
| Organizador de Plastico            | Hogar           |
| Plato Playo Cerámica               | Hogar           |
| Juego de Cubiertos 24 piezas       | Hogar           |
| Campera de Abrigo                  | Indumentaria    |
| Gorra Urbana                       | Indumentaria    |
| Cinturón de Cuero                  | Indumentaria    |
| Medias x3 Pares                    | Indumentaria    |
| Buzo con Capucha                   | Indumentaria    |
| Pantalón Jean Clásico              | Indumentaria    |
| Remera Algodón Negra               | Indumentaria    |
| Malla Natación                     | Indumentaria    |
| Cuaderno Anillado A4               | Librería        |
| Set Pintura Acrílica               | Librería        |
| Gabinete ATX                       | Sin Categorizar |
| Cinta Métrica 5m                   | Sin Categorizar |
| Vestido Casual                     | Sin Categorizar |
| Aceite de Oliva Extra Virgen 500ml | Sin Categorizar |
| Auriculares Bluetooth              | Sin Categorizar |
| Lija para Madera Pliego            | Sin Categorizar |
| Zapatillas Deportivas              | Sin Categorizar |
| Taza Cerámica                      | Sin Categorizar |
| Queso Sardo 500g                   | Sin Categorizar |
| Silla de Escritorio Ergonómica     | Sin Categorizar |

> [!Question] Ejercicio 4: Cálculo de Descuentos (Reto)
> - Crea una consulta que calcule el precio tras aplicar el descuento (`precio_lista - descuento_promocional`).
> - ¡Cuidado! Si el descuento es NULL, la resta fallará (dará NULL). Usa `COALESCE` para que, si el descuento es NULL, sea tratado como `0`.

- Input:
```sql
SELECT
	p.nombre AS nombre_producto
	-- pecio - descuento (descuento en unidades no porcentual). 
		, COALESCE(p.precio_lista, 0) 
			- COALESCE(p.descuento_promocional, 0) 
				  AS precio_final_descuento
FROM entregable_03.productos AS p
ORDER BY 2
;
```

- Output:

| nombre_producto                    | precio_final_descuento |
| ---------------------------------- | ---------------------- |
| Placa de Video RTX 3060            | -15,000                |
| Lentes de Sol                      | -5,000                 |
| Gorra Urbana                       | -1,000                 |
| Martillo Galponero                 | 0                      |
| Galletitas Avena y Miel            | 0                      |
| Lámpara de Escritorio              | 0                      |
| Cable HDMI 2m                      | 0                      |
| Buzo con Capucha                   | 0                      |
| Vino Tinto Reserva                 | 0                      |
| Lija para Madera Pliego            | 600                    |
| Agua Mineral 1.5L                  | 1,200                  |
| Arroz Largo Fino 1kg               | 2,100                  |
| Plato Playo Cerámica               | 2,800                  |
| Chocolate Amargo 70%               | 3,200                  |
| Taza Cerámica                      | 3,500                  |
| Organizador de Plastico            | 4,200                  |
| Yerba Mate 1kg                     | 4,200                  |
| Medias x3 Pares                    | 4,500                  |
| Cinta Métrica 5m                   | 4,500                  |
| Cuaderno Anillado A4               | 6,500                  |
| Queso Sardo 500g                   | 7,800                  |
| Aceite de Oliva Extra Virgen 500ml | 8,500                  |
| Cortina de Baño                    | 8,500                  |
| Pack Cerveza Artesanal x6          | 9,500                  |
| Remera Algodón Negra               | 12,000                 |
| Cargador Carga Rápida              | 13,500                 |
| Café en Grano 500g                 | 14,000                 |
| Cinturón de Cuero                  | 15,000                 |
| Juego de Destornilladores          | 16,000                 |
| Malla Natación                     | 16,000                 |
| Set Pintura Acrílica               | 17,000                 |
| Almohada Viscoelástica             | 18,000                 |
| Mouse Inalámbrico                  | 18,000.5               |
| Sartén Antiadherente               | 20,000                 |
| Juego de Sábanas 2 Plazas          | 22,500                 |
| Caja de Herramientas Plástica      | 25,000                 |
| Vestido Casual                     | 28,000                 |
| Pantalón Jean Clásico              | 31,500                 |
| Auriculares Bluetooth              | 32,000                 |
| Juego de Cubiertos 24 piezas       | 34,000                 |
| Teclado Mecánico RGB               | 40,000                 |
| Memoria RAM 16GB                   | 42,000                 |
| Mochila Ejecutiva                  | 48,000                 |
| Zapatillas Deportivas              | 50,000                 |
| Gabinete ATX                       | 55,000                 |
| Disco SSD 1TB                      | 60,000                 |
| Taladro Percutor 650W              | 67,500                 |
| Campera de Abrigo                  | 85,000                 |
| Silla de Escritorio Ergonómica     | 95,000                 |
| Monitor 24 Pulgadas                | 120,000                |
