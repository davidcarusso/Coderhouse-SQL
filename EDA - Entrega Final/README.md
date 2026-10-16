# Maven Toys — Análisis Exploratorio de Datos (EDA)

**Fuente de datos:** [Maven Analytics — Data Playground: Mexico Toy Sales](https://mavenanalytics.io/data-playground/mexico-toy-sales)
### Descripción del dataset

El conjunto de datos _Mexico Toy Sales_ fue publicado por Maven Analytics y representa una cadena ficticia de jugueterías ubicada en México. Contiene información comercial que permite analizar el desempeño de las ventas, la rentabilidad de los productos y los resultados de las tiendas.

El dataset original está compuesto por cuatro tablas en formato CSV: `sales`, `products`, `stores` e `inventory`. Estas contienen información sobre las transacciones de venta, los productos comercializados, las ubicaciones de las tiendas y el inventario disponible. La información permite relacionar las ventas con sus productos y establecimientos para obtener indicadores relevantes para la toma de decisiones comerciales.

### Objetivo del análisis

El objetivo de este proyecto es realizar un análisis exploratorio utilizando PostgreSQL para identificar patrones de ventas, evaluar la evolución de los márgenes, comparar el desempeño de los productos y las tiendas, y detectar oportunidades de mejora en la rentabilidad del negocio.

Para ello, se realizaron tareas de preparación y transformación de datos, consultas SQL, agregaciones, uniones entre tablas y análisis de tendencias temporales.

**Herramientas utilizadas:** PostgreSQL y NeonDB. 

---

# Creación de estructura

## Creación de schema

Creamos el SCHEMA
```sql
CREATE SCHEMA trabajo_final_eda;
```

Dentro del SCHEMA creamos las primeras 3 tablas principales. Para evitar errores de cargar creo todas las columnas como VARCHAR. 
A medida que revisamos los tipos de datos se irán modificando. 

```sql
-- Creamos la tabla productos, todas las columnas son varchar para evitar errores. Luego procedemos a cambiar los tipos. 
CREATE TABLE IF NOT EXISTS trabajo_final_eda.products(
	  Product_ID 		VARCHAR(100) PRIMARY KEY 	
	, Product_Name		VARCHAR(100)
	, Product_Category	VARCHAR(100)
	, Product_Cost		VARCHAR(100)
	, Product_Price		VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS trabajo_final_eda.stores(
	  Store_ID 			VARCHAR(100) PRIMARY KEY 	
	, Store_Name		VARCHAR(100)
	, Store_City		VARCHAR(100)
	, Store_Location	VARCHAR(100)
	, Store_Open_Date	VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS trabajo_final_eda.sales(
	  Sale_ID 		VARCHAR(100) PRIMARY KEY 
	, "Date" 		VARCHAR(100)	
	, Store_ID		VARCHAR(100)
	, Product_ID 	VARCHAR(100)	
	, Units 		VARCHAR(100)
	--- Creamos llaves foraneas
	, CONSTRAINT fk_store
	  FOREIGN KEY (Store_ID)
	  REFERENCES trabajo_final_eda.stores(Store_ID)
	---
	, CONSTRAINT fk_product
	  FOREIGN KEY (Product_ID)
	  REFERENCES trabajo_final_eda.products(Product_ID)
);
```

## Importamos datos

Importar mediante la herramienta de `DBreave` importar Datos. Es importante estar seleccionando la tabla que se quiere completar. 


![Descripción de la imagen](./static/image/Pasted%20image%2020261006190511.png)

![Descripción de la imagen](./static/image/Pasted%20image%2020261006190455.png)

![Descripción de la imagen](./static/image/Pasted%20image%2020261006191445.png)


Podemos observar un modelo estrella con una tabla transaccional (sales) y otras dos dimensionales (products y stores). 

![Esquema de base de datos en Neon](./static/image/neondb%20-%20neondb%20-%20trabajo_final_eda.png)


# Exploración de datos

### Tabla Products

Products: 

```sql
--- visualizamos la tabla productos: 
SELECT count(*) FROM trabajo_final_eda.products;

-- 35 filas 
```

```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'products';
```

|column_name|data_type|is_nullable|column_default|
|---|---|---|---|
|product_id|character varying|NO|[NULL]|
|product_name|character varying|YES|[NULL]|
|product_category|character varying|YES|[NULL]|
|product_cost|character varying|YES|[NULL]|
|product_price|character varying|YES|[NULL]|
|product_id|character varying|NO|[NULL]|
|product_name|character varying|YES|[NULL]|
|product_category|character varying|YES|[NULL]|
|product_cost|character varying|YES|[NULL]|
|product_price|character varying|YES|[NULL]|

Cantidad de productos 
```sql
SELECT count(DISTINCT  Product_Name) FROM trabajo_final_eda.products 
ORDER BY 1;
```

Encontramos 35 productos. 


Columna Precio:
---

Chequeamos la columna. 
```sql
SELECT 
	DISTINCT product_price    
FROM products
ORDER BY 1;

-- verificamos con un SELECT que no emite error el cast
SELECT 
	DISTINCT product_price 
	, product_price:: decimal 
FROM trabajo_final_eda.products
;
```

No encontramos anomalías en los precios. Se puede pasar a cambiar el tipo de dato con `ALTER TABLE`.

| product_price | product_price |
| ------------- | ------------- |
| 10.99         | 10.99         |
| 2.99          | 2.99          |
| 24.99         | 24.99         |
| 6.99          | 6.99          |
| 15.99         | 15.99         |
| 12.99         | 12.99         |
| 8.99          | 8.99          |
| 3.99          | 3.99          |
| 39.99         | 39.99         |
| 20.99         | 20.99         |
| 7.99          | 7.99          |
| 11.99         | 11.99         |
| 4.99          | 4.99          |
| 5.99          | 5.99          |
| 14.99         | 14.99         |
| 9.99          | 9.99          |
| 19.99         | 19.99         |
| 25.99         | 25.99         |

Modificamos el tipo de dato a DECIMAL. 
Importante usamos transacciónes con `BEGIN` y `COMMIT`
```sql
BEGIN;

-- modificamos la columna precio a tipo decimal 
ALTER TABLE trabajo_final_eda.products 
ALTER COLUMN product_price TYPE DECIMAL(10,2)
USING product_price:: DECIMAL(10,2)
;

COMMIT;
```


Columna Costo
---

En la columna costo se encuentra signo `$` por lo que será necesario, quitar el símbolo para normalizar el tipo de dato. 

```sql
SELECT 
	DISTINCT product_cost   
FROM trabajo_final_eda.products
ORDER BY 1;


-- Encontramos el signo $ en costo. 
/*product_cost
$9.99 
1.99 
10.99 
*/
```

Con un `SELECT` chequeamos que no de error el `REPLACE`
```sql
SELECT 
	DISTINCT product_cost
	, REPLACE (product_cost, '$', '') AS precio_normalizado_text
	, REPLACE (product_cost, '$', '') :: DECIMAL (10,2) AS precio_normalizado_numeric 
FROM trabajo_final_eda.products
ORDER BY 1
;
```

| product_cost | precio_normalizado_text | precio_normalizado_numeric |
| ------------ | ----------------------- | -------------------------- |
| $9.99        | 9.99                    | 9.99                       |
| 1.99         | 1.99                    | 1.99                       |
| 10.99        | 10.99                   | 10.99                      |
| 11.99        | 11.99                   | 11.99                      |
| 13.99        | 13.99                   | 13.99                      |
| 14.99        | 14.99                   | 14.99                      |
| 17.99        | 17.99                   | 17.99                      |
| 2.99         | 2.99                    | 2.99                       |
| 20.99        | 20.99                   | 20.99                      |
| 3.99         | 3.99                    | 3.99                       |
| 34.99        | 34.99                   | 34.99                      |
| 4.99         | 4.99                    | 4.99                       |
| 5.99         | 5.99                    | 5.99                       |
| 6.99         | 6.99                    | 6.99                       |
| 7.99         | 7.99                    | 7.99                       |
| 8.99         | 8.99                    | 8.99                       |
| 9.99         | 9.99                    | 9.99                       |

Usamos `REPLACE (product_cost, '$', '') :: DECIMAL (10,2)` para el `ALTER TABLE`. 

### Categorías 

```sql
SELECT 
	 product_category 
	, count(product_id) AS cant_productos
	--- PRECIO ---
	, round(AVG (product_price), 2) AS prom_price
	, MAX (product_price) 			AS max_price
	, MIN (product_price)			AS min_price
	--- COSTO ---
	, round(AVG (product_cost), 2 ) AS prom_cost
	, MAX (product_cost)			AS max_cost
	, MIN (product_cost)			AS min_cost
	--- MARGEN --- 
	, sum(product_price - product_cost) AS margen
	, rank() OVER ( ORDER BY sum(product_price - product_cost) DESC )
FROM trabajo_final_eda.products
GROUP BY product_category
ORDER BY rank ASC
;
```

| product_category  | cant_productos | prom_price | max_price | min_price | prom_cost | max_cost | min_cost | margen | rank |
| ----------------- | -------------- | ---------- | --------- | --------- | --------- | -------- | -------- | ------ | ---- |
| Toys              | 9              | 15.99      | 39.99     | 5.99      | 11.66     | 34.99    | 3.99     | 39     | 1    |
| Sports & Outdoors | 7              | 15.28      | 24.99     | 8.99      | 10.28     | 14.99    | 6.99     | 35     | 2    |
| Art & Crafts      | 8              | 13.12      | 24.99     | 2.99      | 8.99      | 20.99    | 1.99     | 33     | 3    |
| Games             | 8              | 12.37      | 19.99     | 6.99      | 8.37      | 17.99    | 2.99     | 32     | 4    |
| Electronics       | 3              | 20.66      | 25.99     | 14.99     | 14.32     | 20.99    | 6.99     | 19     | 5    |

Tenemos 5 categorías, la cantidad de productos esta bien distribuida entre las categorías, con un total de 35 productos. 
Si ordenamos por margen la categoría  Toys esta en el top. 
Electronics tiene el menor de todas las categorías. 
¿Cambia la tendencia si categorizamos por productos? 

Margen por producto
---

```sql
SELECT 
	product_name AS product
	, product_category AS category
	, sum (product_price - product_cost ) AS margen 
FROM trabajo_final_eda.products
GROUP BY product_name, product_category
ORDER BY margen DESC;
```

Top productos que generan mayor margen. 

| product              | category          | margen |
| -------------------- | ----------------- | ------ |
| Mini Basketball Hoop | Sports & Outdoors | 16     |
| Plush Pony           | Toys              | 11     |
| Etch A Sketch        | Art & Crafts      | 10     |
| Colorbuds            | Electronics       | 8      |

| product               | category          | margen |
| --------------------- | ----------------- | ------ |
| Mini Basketball Hoop  | Sports & Outdoors | 16     |
| Plush Pony            | Toys              | 11     |
| Etch A Sketch         | Art & Crafts      | 10     |
| Colorbuds             | Electronics       | 8      |
| Jenga                 | Games             | 7      |
| Playfoam              | Art & Crafts      | 7      |
| Action Figure         | Toys              | 6      |
| Monopoly              | Games             | 6      |
| Gamer Headphones      | Electronics       | 6      |
| Kids Makeup Kit       | Art & Crafts      | 6      |
| Mr. Potatohead        | Toys              | 5      |
| Lego Bricks           | Toys              | 5      |
| Nerf Gun              | Sports & Outdoors | 5      |
| Toy Robot             | Electronics       | 5      |
| Glass Marbles         | Games             | 5      |
| Uno Card Game         | Games             | 4      |
| Dinosaur Figures      | Toys              | 4      |
| Dart Gun              | Sports & Outdoors | 4      |
| PlayDoh Playset       | Art & Crafts      | 4      |
| Supersoaker Water Gun | Sports & Outdoors | 3      |
| Deck Of Cards         | Games             | 3      |
| Mini Ping Pong Set    | Sports & Outdoors | 3      |
| Chutes & Ladders      | Games             | 3      |
| Foam Disk Launcher    | Sports & Outdoors | 3      |
| Animal Figures        | Toys              | 3      |
| Magic Sand            | Art & Crafts      | 2      |
| Barrel O' Slime       | Art & Crafts      | 2      |
| Rubik's Cube          | Games             | 2      |
| Hot Wheels 5-Pack     | Toys              | 2      |
| Teddy Bear            | Toys              | 2      |
| Classic Dominoes      | Games             | 2      |
| Dino Egg              | Toys              | 1      |
| PlayDoh Toolkit       | Art & Crafts      | 1      |
| Splash Balls          | Sports & Outdoors | 1      |
| PlayDoh Can           | Art & Crafts      | 1      |

Los principales productos con mejor margen individual son:

| product              | category          | margen |
| -------------------- | ----------------- | ------ |
| Mini Basketball Hoop | Sports & Outdoors | 16     |
| Plush Pony           | Toys              | 11     |
| Etch A Sketch        | Art & Crafts      | 10     |

Hay una potencialidad de ganancias en los productos Mini Basketball Hoop, Plush Pony y Etch A Sketch gracias a su precio de reventa. 

# Stores:

Encontramos 29 ciudades

```sql
-- cantidad de ciudades
SELECT count(DISTINCT store_city) AS cant_ciudades FROM trabajo_final_eda.stores;

-- listado de ciudades
SELECT DISTINCT store_city FROM trabajo_final_eda.stores ORDER BY 1;


```

¿Cuáles son las ciudades con mayor cantidad de tiendas? 

| store_city     |
| -------------- |
| Aguascalientes |
| Campeche       |
| Chetumal       |
| Chihuahua      |
| Chilpancingo   |
| Cuernavaca     |
| Culiacan       |
| DF             |
| Durango        |
| Guadalajara    |
| Guanajuato     |
| Hermosillo     |
| La Paz         |
| Merida         |
| Mexicali       |
| Monterrey      |
| Morelia        |
| Oaxaca         |
| Pachuca        |
| Potosi         |
| Puebla         |
| Saltillo       |
| Santiago       |
| Toluca         |
| Tuxtla         |
| Victoria       |
| Villahermosa   |
| Xalapa         |
| Zacatecas      |

La columna `store_location` indica **tipo de zona/ubicación**:

- `Airport` → Aeropuerto
- `Commercial` → Comercial
- `Downtown` → Centro / zona céntrica
- `Residential` → Residencial

### Aperturas de tiendas: 

Calculamos tiendas abiertas por año. 
```sql
WITH tiendas_annio AS 
(
SELECT 
	 to_char(date_trunc('year', store_open_date), 'YYYY') AS annios
	 , count(store_id) AS tiendas 
	 , sum(count(store_id)) OVER (ORDER BY date_trunc('year', store_open_date)) AS tiendas_acumuladas
	 , count ( )
FROM trabajo_final_eda.stores
GROUP BY date_trunc('year', store_open_date)
ORDER BY 1
)
SELECT 
	*
FROM tiendas_annio
;
```

Calculamos trayectoria en años. 
```sql
WITH tiendas_annio AS 
(
SELECT 
	 to_char(date_trunc('year', store_open_date), 'YYYY') AS annios
	 , count(store_id) AS tiendas 
	 , sum(count(store_id)) OVER (ORDER BY date_trunc('year', store_open_date)) AS tiendas_acumuladas
FROM trabajo_final_eda.stores
GROUP BY date_trunc('year', store_open_date)
ORDER BY 1
), trayectoria AS 
(
SELECT 
	max (annios :: integer ) - min(annios :: integer) AS trayectoria 
FROM tiendas_annio
)
	SELECT * FROM trayectoria
;
```

Comenzó desde 1992 con una expansión hasta el 2016. Con un total de 50 tiendas. 24 años de trayectoria.

Por lo que podemos afirmar que es una empresa consolidada en el mercado. 

| annios | tiendas | tiendas_acumuladas |
| ------ | ------- | ------------------ |
| 1992   | 1       | 1                  |
| 1995   | 1       | 2                  |
| 1999   | 1       | 3                  |
| 2000   | 1       | 4                  |
| 2001   | 1       | 5                  |
| 2003   | 2       | 7                  |
| 2004   | 2       | 9                  |
| 2005   | 2       | 11                 |
| 2006   | 2       | 13                 |
| 2007   | 4       | 17                 |
| 2008   | 2       | 19                 |
| 2009   | 2       | 21                 |
| 2010   | 6       | 27                 |
| 2011   | 3       | 30                 |
| 2012   | 2       | 32                 |
| 2013   | 5       | 37                 |
| 2014   | 7       | 44                 |
| 2015   | 3       | 47                 |
| 2016   | 3       | 50                 |

# Sales:
Tabla de hechos, en ella se ven las transacciones de la compañía. 

- Exploramos la tabla sales: 
```sql
SELECT count(*) FROM trabajo_final_eda.sales;
```

| count   |
| ------- |
| 829,262 |

Contamos con 829,262 registros. 

```sql
SELECT 
	column_name, 
	data_type, 
	is_nullable, 
	column_default
FROM information_schema.columns
WHERE table_name = 'sales';
```

| column_name | data_type         | is_nullable | column_default |
| ----------- | ----------------- | ----------- | -------------- |
| Sale_ID     | integer           | YES         | [NULL]         |
| Date        | date              | YES         | [NULL]         |
| Store_ID    | integer           | YES         | [NULL]         |
| Product_ID  | integer           | YES         | [NULL]         |
| Units       | integer           | YES         | [NULL]         |
| sale_id     | character varying | NO          | [NULL]         |
| Date        | character varying | YES         | [NULL]         |
| store_id    | character varying | YES         | [NULL]         |
| product_id  | character varying | YES         | [NULL]         |
| units       | character varying | YES         | [NULL]         |
|             |                   |             |                |

```sql
-- Probamos el cambio del Date (text a date)
SELECT 
	TO_DATE("Date", 'DD-MM-YYYY') AS fecha
FROM trabajo_final_eda.sales
;
```

| fecha      |
| ---------- |
| 2023-07-06 |
| 2023-03-31 |
| 2022-02-17 |
| 2023-11-11 |
| 2023-07-18 |
| 2024-06-19 |
| 2025-12-01 |

¿Fechas mínimas y máximas? 

```sql
-- Rango de fechas 
SELECT 
	  min(sale_date) AS fecha_inicial
	, max(sale_date) AS fecha_final
	, AGE( max(sale_date),  min(sale_date))  AS tiempo_transcurrido
FROM trabajo_final_eda.sales s
LIMIT 10;
```

|fecha_inicial|fecha_final|tiempo_transcurrido|
|---|---|---|
|2022-01-01|2026-05-31|4 years 4 mons 30 days|
Tenemos 4 años y cuatro de meses en ventas. Siendo la ultima fecha el 31 de mayo del 2026. 

Columna units
---

```sql
-- Probamos el cambio de type con un select
SELECT 
	units 
	, units :: integer 
FROM trabajo_final_eda.sales;

-- usaremos units :: integer 
```

Generamos el cambio con `ALTER TABLE`

```sql
--- abrimos transaccion
BEGIN;

-- modificar columna unidades
ALTER TABLE trabajo_final_eda.sales
ALTER COLUMN units TYPE INTEGER 
USING units :: integer 
;

-- Verificamos 
SELECT units FROM trabajo_final_eda.sales;

-- cerramos 
COMMIT;
```


Nulos
---

Chequeamos si tenemos nulos en la tablas: 

```sql
-- Hay datos nulos en la tabla sales ? 
SELECT 
	  count(1) FILTER ( WHERE sale_id IS NULL)
	, count(2) FILTER ( WHERE sale_date IS NULL)
	, count(3) FILTER ( WHERE store_id IS NULL)
	, count(4) FILTER ( WHERE product_id IS NULL)
	, count(5) FILTER ( WHERE units IS NULL)
FROM trabajo_final_eda.sales;

/* no encontramos nulos en la tabla de ventas */


-- nulos en Prodcuts 
SELECT 
	 count(1) FILTER ( WHERE product_id IS NULL)
	 , count(2) FILTER ( WHERE product_name IS NULL)
	 , count(3) FILTER ( WHERE product_category IS NULL)
	 , count(4) FILTER ( WHERE product_cost IS NULL)
	 , count(5) FILTER ( WHERE product_price IS NULL)
FROM trabajo_final_eda.products
;

/*No encontramso nulos products*/


-- Nulos en Stores
SELECT 
	  count(1) FILTER ( WHERE store_id IS NULL)
	, count(2) FILTER ( WHERE store_name IS NULL)
	, count(3) FILTER ( WHERE store_city IS NULL)
	, count(4) FILTER ( WHERE store_location IS NULL)
	, count(5) FILTER ( WHERE store_open_date IS NULL)	
FROM trabajo_final_eda.stores
;

/* No encontramso nulos en store. */


```

No se encontró nulos en ninguna de las tablas. 

|count|count|count|count|count|
|---|---|---|---|---|
|0|0|0|0|0|


# View con uniones de tablas

Creamos una query con las uniones que necesitamos, para la practica usamos dos metodos de conectar las columnas `USING` y `ON`.

```sql
-- nos paramos en sales
SELECT * FROM trabajo_final_eda.sales AS s
-- unimos con producto metodo ON
LEFT JOIN trabajo_final_eda.products AS p 
	ON s.product_id = p.product_id
-- unimos con store metodo USING
LEFT JOIN trabajo_final_eda.stores s2 
	USING(store_id) -- usamos metodo using para unir tablas
;
```


Creamos la `VIEW`
---
```sql
-- creamos una vista con estos datos, para manipularlos en otras querys. 
CREATE OR REPLACE VIEW vw_datos AS 
WITH datos AS 
(
SELECT 
	* 
FROM trabajo_final_eda.sales AS s
LEFT JOIN trabajo_final_eda.products USING (product_id)  
LEFT JOIN trabajo_final_eda.stores USING(store_id)
)
SELECT 
	sale_id
	, sale_date
	, units
	, product_name
	, product_category
	, product_cost
	, product_price
	, store_name
	, store_city
	, store_location
	, store_open_date
FROM datos
;
```


Tabla con datos. 

|sale_id|sale_date|units|product_name|product_category|product_cost|product_price|store_name|store_city|store_location|store_open_date|
|---|---|---|---|---|---|---|---|---|---|---|
|1|2023-07-06|1|Chutes & Ladders|Games|9.99|12.99|Maven Toys Aguascalientes 1|Aguascalientes|Downtown|2010-07-31|
|2|2023-03-31|1|Action Figure|Toys|9.99|15.99|Maven Toys Puebla 2|Puebla|Downtown|2011-04-01|
|3|2022-02-17|1|Deck Of Cards|Games|3.99|6.99|Maven Toys Mexicali 1|Mexicali|Commercial|2003-12-13|
|4|2023-11-11|1|Dart Gun|Sports & Outdoors|11.99|15.99|Maven Toys Saltillo 2|Saltillo|Commercial|2016-03-23|
|5|2023-07-18|1|Lego Bricks|Toys|34.99|39.99|Maven Toys Puebla 3|Puebla|Residential|2014-12-27|
|6|2024-06-19|1|Splash Balls|Sports & Outdoors|7.99|8.99|Maven Toys Guadalajara 1|Guadalajara|Residential|1992-09-18|
|7|2025-12-01|1|Dart Gun|Sports & Outdoors|11.99|15.99|Maven Toys Toluca 2|Toluca|Commercial|2014-05-27|
|8|2026-03-25|1|Animal Figures|Toys|9.99|12.99|Maven Toys Puebla 1|Puebla|Commercial|2008-12-16|
|9|2024-12-21|1|Mini Ping Pong Set|Sports & Outdoors|6.99|9.99|Maven Toys Chihuahua 2|Chihuahua|Downtown|2014-03-18|
|10|2024-10-06|1|Deck Of Cards|Games|3.99|6.99|Maven Toys Santiago 1|Santiago|Downtown|2009-11-23|

Totales
---

Generamos una consulta con la vista y revisamos los generales. 

```sql
-- Totales Generales -- 
-- to_char para aplicar formatos
SELECT
	  count(sale_id) - count(DISTINCT sale_id) AS "Diferencia de Ventas"
	,  count(DISTINCT EXTRACT (YEAR FROM sale_date)) "Cantidad de años" 
	, to_char(sum(product_price * units), '$99,999,999') AS "Ventas Totales"
	, to_char(sum((product_price - product_cost) * units ), '$99,999,999') AS "Margen Total"
	, count(sale_id) "Ticket Totales"
	, to_char(AVG(product_price * units), '$99') AS "Ticket Promedio "
	, count(DISTINCT store_name) AS "Cantidad de tiendas"
	, count(DISTINCT store_city) AS "Cantidad diferentes de Ciudades"
	, count(DISTINCT product_name) AS "Cantidad diferentes de productos"
	, count(DISTINCT product_category) AS "Cantidad de product_categorys"
FROM vw_datos
;
```

Usamos `TO_CHAR()` para aplicar formatos de salida. 

| Diferencia de Ventas | Cantidad de años | Ventas Totales | Margen Total | Ticket Totales | Ticket Promedio | Cantidad de tiendas | Cantidad diferentes de Ciudades | Cantidad diferentes de productos | Cantidad de product_categorys |
| -------------------- | ---------------- | -------------- | ------------ | -------------- | --------------- | ------------------- | ------------------------------- | -------------------------------- | ----------------------------- |
| 0                    | 5                | $ 14,444,572   | $ 4,014,029  | 829,262        | $ 17            | 50                  | 29                              | 35                               | 5                             |

- Diferencia de ventas: buscamos ver si tenemos varios productos en el mismo id_venta --> implica que cada ticket es una sola compra o un solo producto. Ergo no hay dos productos por ticket. 

- Se vendió un total de 14,4 M en  5 años, con un total de 829,262 ticket a cuenta de $17 el ticket promedio. 

- Tenemos un total de 50 tiendas en 29 ciudades y comercializamos 35 diferentes productos, en 5 categorías diferentes. 

Análisis del Margen
---

```sql
SELECT
	  to_char(sum(product_price * units), '$99,999,999') AS "Ventas Totales"
	, to_char(sum((product_price - product_cost) * units ), '$99,999,999') AS "Margen Total"
	, round((sum((product_price - product_cost) * units ) / sum(product_price * units) * 100) :: NUMERIC , 2) AS "Margen Bruto"
FROM vw_datos
;
;
```

> [!info] Definición del Margen Bruto
> **Eficiencia directa del producto/servicio:** Mide la capacidad de fijación de precios (_pricing power_) y la eficiencia en la producción o adquisición de bienes antes de gastos operativos.
> $$\text{Margen Bruto} = \frac{Venta - \text{Costos de Venta}}{Ventas} \times 100$$

| Ventas Totales | Margen Total | Margen Bruto |
| -------------- | ------------ | ------------ |
| $ 14,444,572   | $ 4,014,029  | 27.79        |

Podemos encontrar que el margen total es de un 27,8 %, lo cual para el sector de Retail es un buen indicador. 

### Comparación de margen con las industrias: 

- **Servicios y tecnología (Software, Consultorías, Banca):** Presentan los márgenes más altos, generalmente entre el **50% y el 70%** ( llegando al 100% en el sector financiero), debido a la baja necesidad de bienes físicos vendidos. [[1](https://translate.google.com/translate?u=https://www.venasolutions.com/blog/average-profit-margin-by-industry&hl=es&sl=en&tl=es&client=sge), [2](https://www.youtube.com/shorts/YeqpCYYpFqo)]
- **Sector comercial / Retail:** Maneja un margen bruto intermedio, ubicado comúnmente entre el **15% y el 40%**, dependiendo de la rotación de los productos y los costos de reposición. [[1](https://www.youtube.com/shorts/YeqpCYYpFqo)]
- **Sector industrial y manufacturero:** Se sitúa entre el **12% y el 35%**, debido a la alta inversión en materias primas y mano de obra directa. [[1](https://www.youtube.com/watch?v=bdJkeyWY_b0&t=43), [2](https://translate.google.com/translate?u=https://www.investopedia.com/terms/g/grossmargin.asp&hl=es&sl=en&tl=es&client=sge), [3](https://www.youtube.com/shorts/YeqpCYYpFqo)]
- **Automotriz y transporte:** Suelen registrar los márgenes brutos más bajos del mercado, promediando entre el **10% y el 12,45%**. [[1](https://translate.google.com/translate?u=https://fullratio.com/profit-margin-by-industry&hl=es&sl=en&tl=es&client=sge), [2](https://translate.google.com/translate?u=https://www.venasolutions.com/blog/average-profit-margin-by-industry&hl=es&sl=en&tl=es&client=sge)]

Segmentación de Años
---

- Ranking de años con mas venta. 

```sql
SELECT
	to_char(date_trunc('year', sale_date), 'YYYY')
	, to_char(sum(product_price * units), '$99,999,999') AS "Ventas Totales"
	, to_char(sum((product_price - product_cost) * units ), '$99,999,999') AS "Margen Total"
	, round ((sum((product_price - product_cost) * units ) / sum(product_price * units) * 100) :: numeric , 2)   AS "Margen Bruto"
	, dense_rank() over(ORDER BY round ((sum((product_price - product_cost) * units ) / sum(product_price * units) * 100) :: numeric , 2) DESC) AS "Ranking Margen Bruto"
FROM vw_datos
GROUP BY date_trunc('year', sale_date)
;
```

> [!info] Insight
> Mejores ventas no significa mayor ganancia.
> año 2024 top ventas, pero 3° puesto en margen. 

| to_char | Ventas Totales | Margen Total | Margen Bruto | Ranking Margen Bruto |
| ------- | -------------- | ------------ | ------------ | -------------------- |
| 2026    | $ 1,343,813    | $ 375,418    | 27.94        | 1                    |
| 2025    | $ 3,276,962    | $ 911,691    | 27.82        | 2                    |
| 2023    | $ 3,274,735    | $ 910,754    | 27.81        | 3                    |
| 2022    | $ 3,265,577    | $ 905,590    | 27.73        | 4                    |
| 2024    | $ 3,283,484    | $ 910,576    | 27.73        | 4                    |

Las ventas por año son constantes.

```sql
WITH margen_anual AS 
(
	SELECT
		to_char(date_trunc('year', sale_date), 'YYYY') AS annio
		, count ( DISTINCT  date_trunc('month', sale_date) ) AS "cantidad de meses"
		, sum((product_price - product_cost) * units ) AS "Margen Total"
	FROM vw_datos
	GROUP BY date_trunc('year', sale_date)
	ORDER BY 1
), margen_anual_con_LAG AS 
(
	SELECT 
	  *
	, COALESCE (LAG ("Margen Total") OVER (ORDER BY annio), 0 ) AS "Margen Anterior"
	FROM margen_anual
)
	SELECT 
		  *
--	cambiamos el null por 0  
		  , COALESCE (
-- 	redondeo
		  round(
-- 	diferencia de margen
			("Margen Total" - "Margen Anterior") / 
-- 	usamos nullif para evitar dividir con 0  	
				NULLIF ("Margen Anterior" , 0) * 100, 
			2)
			, 0 )
--	alias 
			AS variacion_porcentual
	FROM margen_anual_con_LAG
	WHERE NOT annio = '2026' -- annio es varchar por el TO_char
;
```

| annio | cantidad de meses | Margen Total | Margen Anterior | variacion_porcentual |
| ----- | ----------------- | ------------ | --------------- | -------------------- |
| 2022  | 12                | 905,590      | 0               | 0                    |
| 2023  | 12                | 910,754      | 905,590         | 0.57                 |
| 2024  | 12                | 910,576      | 910,754         | -0.02                |
| 2025  | 12                | 911,691      | 910,576         | 0.12                 |

Analizamos el crecimiento por año del margen. Descartamos el año 2026 ya que tiene menos meses para comparar con años anteriores. 

Revisamos cantidad de meses de crecimiento
---

```sql
WITH datos AS 
(
	SELECT
		date_trunc('month', sale_date) :: date AS mes
		, sum((product_price - product_cost) * units ) AS "Margen Total"
	FROM vw_datos
	GROUP BY date_trunc('month', sale_date)
	ORDER BY 1
),datos_margenes_mes_diff_porcentual AS 
(
	SELECT 
		  *
		, COALESCE (LAG ("Margen Total") OVER (ORDER BY mes), 0)  AS mg_ant
		, COALESCE ( ("Margen Total" - LAG ("Margen Total") OVER (ORDER BY mes)) / LAG ("Margen Total") OVER (ORDER BY mes), 0)   * 100 AS diff_porcentual
 	FROM datos 
	ORDER BY 1
)
	SELECT 
		* 
		, CASE	
			WHEN diff_porcentual > 0 THEN 'Crecio'
			WHEN diff_porcentual < 0 THEN 'Bajo'
			ELSE 'Sin diferencia'
		  END AS crecimiento
	FROM datos_margenes_mes_diff_porcentual
;
```

| mes        | Margen Total | mg_ant | diff_porcentual | crecimiento    |
| ---------- | ------------ | ------ | --------------- | -------------- |
| 2022-01-01 | 77,856       | 0      | 0               | Sin diferencia |
| 2022-02-01 | 68,985       | 77,856 | -11.3941122072  | Bajo           |
| 2022-03-01 | 75,889       | 68,985 | 10.0079727477   | Crecio         |
| 2022-04-01 | 75,118       | 75,889 | -1.0159575169   | Bajo           |
| 2022-05-01 | 77,529       | 75,118 | 3.2096168695    | Crecio         |
| 2022-06-01 | 71,837       | 77,529 | -7.3417688865   | Bajo           |
| 2022-07-01 | 79,266       | 71,837 | 10.3414674889   | Crecio         |
| 2022-08-01 | 76,914       | 79,266 | -2.9672242828   | Bajo           |
| 2022-09-01 | 75,205       | 76,914 | -2.2219621915   | Bajo           |
| 2022-10-01 | 76,963       | 75,205 | 2.3376105312    | Crecio         |
| 2022-11-01 | 73,084       | 76,963 | -5.0400841963   | Bajo           |
| 2022-12-01 | 76,944       | 73,084 | 5.2815937825    | Crecio         |
| 2023-01-01 | 79,809       | 76,944 | 3.7234872115    | Crecio         |
| 2023-02-01 | 69,951       | 79,809 | -12.351990377   | Bajo           |
| 2023-03-01 | 78,885       | 69,951 | 12.771797401    | Crecio         |
| 2023-04-01 | 73,682       | 78,885 | -6.5956772517   | Bajo           |
| 2023-05-01 | 76,876       | 73,682 | 4.334844331     | Crecio         |
| 2023-06-01 | 74,382       | 76,876 | -3.2441854415   | Bajo           |
| 2023-07-01 | 76,723       | 74,382 | 3.1472668119    | Crecio         |
| 2023-08-01 | 77,111       | 76,723 | 0.5057153657    | Crecio         |
| 2023-09-01 | 74,749       | 77,111 | -3.0631168056   | Bajo           |
| 2023-10-01 | 77,142       | 74,749 | 3.2013806205    | Crecio         |
| 2023-11-01 | 74,551       | 77,142 | -3.358741023    | Bajo           |
| 2023-12-01 | 76,893       | 74,551 | 3.1414736221    | Crecio         |
| 2024-01-01 | 78,116       | 76,893 | 1.5905218941    | Crecio         |
| 2024-02-01 | 71,728       | 78,116 | -8.1775820575   | Bajo           |
| 2024-03-01 | 76,763       | 71,728 | 7.019573946     | Crecio         |
| 2024-04-01 | 74,679       | 76,763 | -2.714849602    | Bajo           |
| 2024-05-01 | 77,029       | 74,679 | 3.1468016444    | Crecio         |
| 2024-06-01 | 75,304       | 77,029 | -2.2394163237   | Bajo           |
| 2024-07-01 | 77,410       | 75,304 | 2.7966641878    | Crecio         |
| 2024-08-01 | 75,898       | 77,410 | -1.953236016    | Bajo           |
| 2024-09-01 | 74,865       | 75,898 | -1.3610371815   | Bajo           |
| 2024-10-01 | 76,743       | 74,865 | 2.5085153276    | Crecio         |
| 2024-11-01 | 74,452       | 76,743 | -2.9852885605   | Bajo           |
| 2024-12-01 | 77,589       | 74,452 | 4.213452963     | Crecio         |
| 2025-01-01 | 77,023       | 77,589 | -0.7294848497   | Bajo           |
| 2025-02-01 | 70,144       | 77,023 | -8.931098503    | Bajo           |
| 2025-03-01 | 77,471       | 70,144 | 10.4456546533   | Crecio         |
| 2025-04-01 | 76,392       | 77,471 | -1.3927792335   | Bajo           |
| 2025-05-01 | 77,179       | 76,392 | 1.0302125877    | Crecio         |
| 2025-06-01 | 74,145       | 77,179 | -3.9311211599   | Bajo           |
| 2025-07-01 | 76,074       | 74,145 | 2.6016589116    | Crecio         |
| 2025-08-01 | 79,141       | 76,074 | 4.0316008097    | Crecio         |
| 2025-09-01 | 74,306       | 79,141 | -6.1093491364   | Bajo           |
| 2025-10-01 | 77,076       | 74,306 | 3.72782817      | Crecio         |
| 2025-11-01 | 75,355       | 77,076 | -2.2328610722   | Bajo           |
| 2025-12-01 | 77,385       | 75,355 | 2.6939154668    | Crecio         |
| 2026-01-01 | 77,983       | 77,385 | 0.7727595787    | Crecio         |
| 2026-02-01 | 68,512       | 77,983 | -12.1449546696  | Bajo           |
| 2026-03-01 | 76,593       | 68,512 | 11.7950140121   | Crecio         |
| 2026-04-01 | 74,821       | 76,593 | -2.3135273458   | Bajo           |
| 2026-05-01 | 77,509       | 74,821 | 3.5925742773    | Crecio         |

Contamos cantidades de meses que crece y baja. 

```sql
WITH datos AS 
(
	SELECT
		date_trunc('month', sale_date) :: date AS mes
		, sum((product_price - product_cost) * units ) AS "Margen Total"
	FROM vw_datos
	GROUP BY date_trunc('month', sale_date)
	ORDER BY 1
),datos_margenes_mes_diff_porcentual AS 
(
	SELECT 
		  *
		, COALESCE (LAG ("Margen Total") OVER (ORDER BY mes), 0)  AS mg_ant
		, COALESCE ( ("Margen Total" - LAG ("Margen Total") OVER (ORDER BY mes)) / LAG ("Margen Total") OVER (ORDER BY mes), 0)   * 100 AS diff_porcentual
 	FROM datos 
	ORDER BY 1
), datos_crecimiento AS 
(
	SELECT 
		* 
		, CASE	
			WHEN diff_porcentual > 0 THEN 'Crecio'
			WHEN diff_porcentual < 0 THEN 'Bajo'
			ELSE 'Sin diferencia'
		  END AS crecimiento
	FROM datos_margenes_mes_diff_porcentual
)
	SELECT 
		crecimiento
		, count(*)
	FROM datos_crecimiento
	GROUP BY crecimiento
;
```

| crecimiento    | count |
| -------------- | ----- |
| Bajo           | 25    |
| Crecio         | 27    |
| Sin diferencia | 1     |

Mayor cantidad de meses en crecimiento. 

```sql
-- Ventas mensuales toda la empresa
SELECT 
	  to_char(date_trunc('month', sale_date), 'YYYY-MM') AS mes
	, round(sum(product_price * units) :: NUMERIC , 2) AS venta
	, round(sum((product_price - product_cost) * units )::NUMERIC , 2) AS margen
	, dense_rank() OVER (win_venta) AS ranking_venta
	, dense_rank() OVER (win_margen) AS ranking_margen
FROM vw_datos
GROUP BY date_trunc('month', sale_date)
WINDOW 
	  win_venta AS (ORDER BY round(sum(product_price * units) :: NUMERIC , 2) DESC)
	, win_margen AS (ORDER BY round(sum((product_price - product_cost) * units )::NUMERIC , 2 ) DESC)
ORDER BY ranking_margen 
LIMIT 10
;
```

| mes     | venta      | margen | ranking_venta | ranking_margen |
| ------- | ---------- | ------ | ------------- | -------------- |
| 2023-01 | 285,382.99 | 79,809 | 1             | 1              |
| 2022-07 | 281,742.68 | 79,266 | 4             | 2              |
| 2025-08 | 283,306.75 | 79,141 | 2             | 3              |
| 2023-03 | 282,403.21 | 78,885 | 3             | 4              |
| 2024-01 | 280,955.88 | 78,116 | 7             | 5              |
| 2026-01 | 277,345.27 | 77,983 | 20            | 6              |
| 2022-01 | 281,676.76 | 77,856 | 5             | 7              |
| 2024-12 | 279,392.22 | 77,589 | 8             | 8              |
| 2022-05 | 277,986.64 | 77,529 | 15            | 9              |
| 2026-05 | 276,457.67 | 77,509 | 26            | 10             |

El mes de enero de distintos años se encuentra en el top 10. Contradice la suposición que en diciembre por navidades debería repetirse el patrón de mejores ventas. 

```sql
WITH datos AS 
(
	SELECT
		date_trunc('month', sale_date) :: date AS mes
		, sum((product_price - product_cost) * units ) AS "Margen Total"
	FROM vw_datos
	GROUP BY date_trunc('month', sale_date)
	ORDER BY 1
),datos_margenes_mes_diff_porcentual AS 
(
	SELECT 
		  *
		, COALESCE (LAG ("Margen Total") OVER (ORDER BY mes), 0)  AS mg_ant
		, COALESCE ( ("Margen Total" - LAG ("Margen Total") OVER (ORDER BY mes)) / LAG ("Margen Total") OVER (ORDER BY mes), 0)   * 100 AS diff_porcentual
 	FROM datos 
	ORDER BY 1
), datos_crecimiento AS 
(
	SELECT 
		* 
		, CASE	
			WHEN diff_porcentual > 0 THEN 'Crecio'
			WHEN diff_porcentual < 0 THEN 'Bajo'
			ELSE 'Sin diferencia'
		  END AS crecimiento
	FROM datos_margenes_mes_diff_porcentual
), cte_intermedio_tipo_mes  AS 
(
	SELECT 
		  TO_CHAR(mes, 'TMMonth') AS mes_nombre 
		, count(*) FILTER (WHERE crecimiento LIKE 'Bajo') 	AS bajo
		, count(*) FILTER (WHERE crecimiento LIKE 'Crecio')	AS crecio
	FROM datos_crecimiento
	GROUP BY TO_CHAR(mes, 'TMMonth')
	ORDER BY crecio DESC
)
	SELECT 
		*
		, CASE 
			WHEN bajo < crecio THEN 'Mes Creciente'
			WHEN bajo > crecio THEN 'Mes Bajista'
			WHEN bajo = crecio THEN 'Estabilidad'			
			ELSE 'Revisar'
		  END AS "Tipo de Mes"
	FROM cte_intermedio_tipo_mes
;
```

| mes_nombre | bajo | crecio | Tipo de Mes   |
| ---------- | ---- | ------ | ------------- |
| March      | 0    | 5      | Mes Creciente |
| May        | 0    | 5      | Mes Creciente |
| October    | 0    | 4      | Mes Creciente |
| July       | 0    | 4      | Mes Creciente |
| December   | 0    | 4      | Mes Creciente |
| January    | 1    | 3      | Mes Creciente |
| August     | 2    | 2      | Estabilidad   |
| September  | 4    | 0      | Mes Bajista   |
| February   | 5    | 0      | Mes Bajista   |
| June       | 4    | 0      | Mes Bajista   |
| November   | 4    | 0      | Mes Bajista   |
| April      | 5    | 0      | Mes Bajista   |

Top ventas por productos 
---

```sql
SELECT 
	product_name
	, sum(units) AS unidades
	, sum (units * product_price) AS venta
FROM vw_datos
GROUP BY product_name
ORDER BY 3 DESC 
LIMIT 10 
;
```

| product_name   | unidades | venta        |
| -------------- | -------- | ------------ |
| Lego Bricks    | 59,737   | 2,388,882.63 |
| Colorbuds      | 104,368  | 1,564,476.32 |
| Magic Sand     | 60,598   | 968,962.02   |
| Action Figure  | 57,958   | 926,748.42   |
| Rubik's Cube   | 45,672   | 912,983.28   |
| Deck Of Cards  | 84,034   | 587,397.66   |
| Splash Balls   | 60,248   | 541,629.52   |
| Nerf Gun       | 26,543   | 530,594.57   |
| Animal Figures | 39,089   | 507,766.11   |
| Dart Gun       | 31,588   | 505,092.12   |

Las principales ventas y flujo de efectivo son por Lego Bricks y Colorbuds. Solo dos productos superan el millón de unidades monetarias. 

Top 3 Productos menos vendidos global
---
```sql
WITH datos AS 
(
	SELECT 
		product_name
		, product_category 
		, sum(units * product_price) AS ventas
		, rank() OVER (ORDER BY sum(units * product_price) DESC) AS rank_ventas_global 
		, rank() OVER (PARTITION BY product_category ORDER BY sum(units * product_price) ) AS rank_ventas_categoria
	FROM vw_datos
	GROUP BY product_name, product_category 
), productos_top_3_menos_vendidos AS 
(
	SELECT 
		* 
	FROM datos
	ORDER BY rank_ventas_global DESC
	LIMIT 3
), productos_top_3_menos_vendidos_categorias AS 
(
	SELECT 
		* 
	FROM datos
	WHERE rank_ventas_categoria IN (1, 2 ,3)
	ORDER BY product_category, rank_ventas_categoria
)
	SELECT * FROM productos_top_3_menos_vendidos
;
```

| product_name     | product_category | ventas    |
| ---------------- | ---------------- | --------- |
| Uno Card Game    | Games            | 21,652.9  |
| Classic Dominoes | Games            | 44,665.29 |
| Playfoam         | Art & Crafts     | 45,696.42 |

Los tres productos menos vendidos en unidades monetarias son: Uno Card Game, Classic Dominoes y Playfoam. 
Siendo el juego Uno el producto con menos monto vendido. 

Top 3 Productos menos vendidos por categoria
---

```sql
WITH datos AS 
(
	SELECT 
		product_name
		, product_category 
		, sum(units * product_price) AS ventas
		, rank() OVER (ORDER BY sum(units * product_price) DESC) AS rank_ventas_global 
		, rank() OVER (PARTITION BY product_category ORDER BY sum(units * product_price) ) AS rank_ventas_categoria
	FROM vw_datos
	GROUP BY product_name, product_category 
), productos_top_3_menos_vendidos AS 
(
	SELECT 
		* 
	FROM datos
	ORDER BY rank_ventas_global
	LIMIT 3
), productos_top_3_menos_vendidos_categorias AS 
(
	SELECT 
		* 
	FROM datos
	WHERE rank_ventas_categoria IN (1, 2 ,3)
	ORDER BY product_category, rank_ventas_categoria
)
	SELECT 
		product_name, 
		product_category, 
		ventas, 
		rank_ventas_categoria
	FROM productos_top_3_menos_vendidos_categorias
;
```

| product_name          | product_category  | ventas       | rank_ventas_categoria |
| --------------------- | ----------------- | ------------ | --------------------- |
| Playfoam              | Art & Crafts      | 45,696.42    | 1                     |
| PlayDoh Toolkit       | Art & Crafts      | 115,408.72   | 2                     |
| PlayDoh Playset       | Art & Crafts      | 157,387.02   | 3                     |
| Toy Robot             | Electronics       | 305,356.51   | 1                     |
| Gamer Headphones      | Electronics       | 376,938.42   | 2                     |
| Colorbuds             | Electronics       | 1,564,476.32 | 3                     |
| Uno Card Game         | Games             | 21,652.9     | 1                     |
| Classic Dominoes      | Games             | 44,665.29    | 2                     |
| Chutes & Ladders      | Games             | 49,738.71    | 3                     |
| Mini Basketball Hoop  | Sports & Outdoors | 66,148.53    | 1                     |
| Foam Disk Launcher    | Sports & Outdoors | 91,363.8     | 2                     |
| Supersoaker Water Gun | Sports & Outdoors | 101,827.07   | 3                     |
| Teddy Bear            | Toys              | 83,343.84    | 1                     |
| Mr. Potatohead        | Toys              | 85,963.95    | 2                     |
| Plush Pony            | Toys              | 109,705.12   | 3                     |

Ahora podemos evaluar dentro de cada categoría los principales 3 productos menos vendidos.  La diferencia entre el producto menos monto vendido por categoría es muy amplio. Ya que varían los precios de venta. 

Top Margen Bruto por producto
---

```sql
WITH datos AS 
(
SELECT 
	product_name 
	, sum (units * product_price) AS venta
	, sum(units * product_cost) AS costo 
FROM vw_datos
GROUP BY product_name 
ORDER BY 3 DESC
)
SELECT 
	  * 
	, venta - costo AS margen
	, RANK () OVER (ORDER BY venta DESC) AS "Ranking Producto Ventas"
	, RANK () OVER (ORDER BY  (venta - costo) DESC) AS "Rank Product Margen"
	, round ((venta - costo) / venta * 100 , 2 ) AS "Margen Bruto"
	, RANK ( ) OVER ( ORDER BY round ((venta - costo) / venta * 100 , 2 ) DESC) AS "Rank Margen Bruto Product"
FROM  datos 
ORDER BY "Rank Margen Bruto Product"
LIMIT 5
;
```

| product_name         | venta        | costo      | margen  | Ranking Producto Ventas | Rank Product Margen | Margen Bruto | Rank Margen Bruto Product |
| -------------------- | ------------ | ---------- | ------- | ----------------------- | ------------------- | ------------ | ------------------------- |
| Jenga                | 130,409.46   | 39,031.46  | 91,378  | 23                      | 17                  | 70.07        | 1                         |
| Mini Basketball Hoop | 66,148.53    | 23,796.53  | 42,352  | 31                      | 24                  | 64.03        | 2                         |
| Playfoam             | 45,696.42    | 16,590.42  | 29,106  | 33                      | 26                  | 63.69        | 3                         |
| Plush Pony           | 109,705.12   | 49,337.12  | 60,368  | 25                      | 19                  | 55.03        | 4                         |
| Colorbuds            | 1,564,476.32 | 729,532.32 | 834,944 | 2                       | 1                   | 53.37        | 5                         |

Reutilizamos el código y agregamos una sentencia para ordenar y encontrar los productos con mayor margen bruto. 

```sql
-- Top 10 productos con mayor margen (ventas - costos)
WITH datos AS 
(
SELECT 
	product_name 
	, product_category
	, sum (units * product_price) AS venta
	, sum(units * product_cost) AS costo 
FROM vw_datos
GROUP BY product_name , product_category
ORDER BY 3 DESC
), margenes AS 
(
	SELECT 
		  * 
		, venta - costo AS margen
		, RANK () OVER (ORDER BY venta DESC) AS "Ranking Producto Ventas"
		, RANK () OVER (ORDER BY  (venta - costo) DESC) AS "Rank Product Margen"
		, round ((venta - costo) / venta * 100 , 2 ) AS "Margen Bruto"
		, RANK ( ) OVER ( ORDER BY round ((venta - costo) / venta * 100 , 2 ) DESC) AS "Rank Margen Bruto Product"
	FROM  datos 
	ORDER BY "Ranking Producto Ventas"
)
SELECT 
	product_name
	,  product_category
	, "Margen Bruto"
FROM margenes
ORDER BY "Margen Bruto" DESC
LIMIT 10
;
```

|product_name|product_category|Margen Bruto|
|---|---|---|
|Jenga|Games|70.07|
|Mini Basketball Hoop|Sports & Outdoors|64.03|
|Playfoam|Art & Crafts|63.69|
|Plush Pony|Toys|55.03|
|Colorbuds|Electronics|53.37|
|Barrel O' Slime|Art & Crafts|50.13|
|Uno Card Game|Games|50.06|
|Mr. Potatohead|Toys|50.05|
|Etch A Sketch|Art & Crafts|47.64|
|Glass Marbles|Games|45.5|

El margen bruto por producto ignora las cantidades totales vendidas, ya que no se cumple la condición de ser top en venas o en cantidades para ser los productos mas rentables. 

> [!Importante] Enfocarse en mejorar las cantidades vendidas de productos con mayor margen. 



Año 2026 
---

```sql
WITH datos AS 
(
	SELECT 
		* 
	FROM vw_datos
	WHERE EXTRACT ( 'year' FROM sale_date) = 2026
)
	SELECT 
		product_name
		, sum ( units *  product_price ) AS venta
	FROM datos 
	GROUP BY product_name
	ORDER BY 2 DESC
;
```

|product_name|venta|
|---|---|
|Lego Bricks|216,025.98|
|Colorbuds|145,957.63|
|Magic Sand|90,311.52|
|Action Figure|86,170.11|
|Rubik's Cube|85,617.17|
|Deck Of Cards|56,115.72|
|Splash Balls|50,478.85|
|Nerf Gun|49,635.17|
|Dart Gun|48,385.74|
|Animal Figures|45,958.62|
|Kids Makeup Kit|43,398.29|
|Dinosaur Figures|42,061.94|
|Glass Marbles|39,871.72|
|Dino Egg|37,904.51|
|Gamer Headphones|35,871.91|
|Barrel O' Slime|34,381.83|
|Mini Ping Pong Set|31,128.84|
|PlayDoh Can|29,687.71|
|Toy Robot|28,770.93|
|Etch A Sketch|23,005.04|
|PlayDoh Playset|14,194.32|
|Hot Wheels 5-Pack|12,836.57|
|Jenga|12,607.38|
|PlayDoh Toolkit|10,978|
|Plush Pony|10,554.72|
|Foam Disk Launcher|9,256.28|
|Supersoaker Water Gun|8,559.29|
|Teddy Bear|8,235.66|
|Mr. Potatohead|8,001.99|
|Mini Basketball Hoop|6,422.43|
|Monopoly|6,116.94|
|Chutes & Ladders|4,559.49|
|Classic Dominoes|4,255.74|
|Playfoam|4,242.14|
|Uno Card Game|2,253.18|

Top 10 tiendas con mayores ventas 
---

```sql
WITH datos AS 
(
	SELECT 
		* 
	FROM vw_datos
	WHERE EXTRACT ( 'year' FROM sale_date) = 2026
), producto AS 
(
	SELECT 
		product_name
		, sum ( units *  product_price ) AS venta
	FROM datos 
	GROUP BY product_name
	ORDER BY 2 DESC
)
	SELECT 
		  REPLACE (store_name, 'Maven Toys ', '') AS "Maven Toys"
		, sum ( units *  product_price ) AS venta
	FROM datos
	GROUP BY store_name
	ORDER BY 2 DESC
	LIMIT 10
;
```


Top 10 ciudades con mayor ventas
---

```sql
WITH datos AS 
(
	SELECT 
		* 
	FROM vw_datos
	WHERE EXTRACT ( 'year' FROM sale_date) = 2026
), producto AS 
(
	SELECT 
		product_name
		, sum ( units *  product_price ) AS venta
	FROM datos 
	GROUP BY product_name
	ORDER BY 2 DESC
), top_ventas_tiendas AS 
(
	SELECT 
		  REPLACE (store_name, 'Maven Toys ', '') AS "Maven Toys"
		, sum ( units *  product_price ) AS venta
	FROM datos
	GROUP BY store_name
	ORDER BY 2 DESC
	LIMIT 10
), top_ciudad_ventas AS 
(
	SELECT 
		store_city
		, sum ( units *  product_price ) AS venta
		, round (AVG ( units *  product_price ) , 2) AS ticket_promedio
	FROM datos
	GROUP BY store_city
	ORDER BY 2 DESC
	LIMIT 10 
)
SELECT * FROM top_ciudad_ventas
;
```

|store_city|venta|ticket_promedio|
|---|---|---|
|DF|152,816.81|18.07|
|Guadalajara|123,917.86|17.55|
|Monterrey|118,675.01|18.1|
|Hermosillo|82,328.32|17.99|
|Guanajuato|81,338.05|17.42|
|Puebla|71,992.4|16.7|
|Toluca|57,657.84|17.15|
|Xalapa|57,411.29|17.75|
|Mexicali|55,519.11|17.22|
|Saltillo|54,573.41|17.15|


Ventas Por mes 2026
---

```sql
WITH datos AS 
(
	SELECT 
		* 
	FROM vw_datos
	WHERE EXTRACT ( 'year' FROM sale_date) = 2026
), producto AS 
(
	SELECT 
		product_name
		, sum ( units *  product_price ) AS venta
	FROM datos 
	GROUP BY product_name
	ORDER BY 2 DESC
), top_ventas_tiendas AS 
(
	SELECT 
		  REPLACE (store_name, 'Maven Toys ', '') AS "Maven Toys"
		, sum ( units *  product_price ) AS venta
	FROM datos
	GROUP BY store_name
	ORDER BY 2 DESC
	LIMIT 10
), top_ciudad_ventas AS 
(
	SELECT 
		store_city
		, sum ( units *  product_price ) AS venta
		, round (AVG ( units *  product_price ) , 2) AS ticket_promedio
	FROM datos
	GROUP BY store_city
	ORDER BY 2 DESC
	LIMIT 10 
), ventas_mensuales AS 
(
	SELECT 
		to_char(date_trunc('month', sale_date), 'YYYYMM')
		, sum(units * product_price) AS ventas
		, RANK () OVER (ORDER BY sum(units * product_price) DESC) AS rk_ventas
	FROM datos
	GROUP BY date_trunc('month', sale_date)
	ORDER BY 1
)
	SELECT * FROM ventas_mensuales
;
```

|to_char|ventas|rk_ventas|
|---|---|---|
|202601|277,345.27|1|
|202602|244,119.74|5|
|202603|276,770.05|2|
|202604|269,120.63|4|
|202605|276,457.67|3|



# Conclusión final

El análisis de Maven Toys evidencia una oportunidad para mejorar la rentabilidad del negocio mediante una gestión más eficiente de sus productos y tiendas. La estabilidad del margen total entre 2022 y 2025 sugiere la necesidad de revisar la evolución de los precios, los costos y el volumen de ventas para identificar oportunidades de crecimiento.

A partir de las diferencias observadas entre tiendas, se recomienda investigar qué factores explican los distintos niveles de facturación y evaluar la posibilidad de replicar las prácticas de los establecimientos con mejores resultados. Asimismo, priorizar los productos que combinan un alto volumen de ventas con una mayor contribución al margen permitiría orientar mejor las decisiones comerciales y de inventario.

En definitiva, Maven Toys debería enfocar sus decisiones no solo en incrementar las ventas, sino también en **mejorar la rentabilidad, optimizar la gestión del inventario e identificar oportunidades de crecimiento sostenible**, utilizando los datos como herramienta para detectar desvíos y asignar los recursos de manera más eficiente.


