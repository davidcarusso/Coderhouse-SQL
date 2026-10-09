



-------------------------------------
--- COMENZAMOS CON LA EXPLORACIÓN ---
-------------------------------------


---------------------------------------
--- Comenzamos a explorar los datos ---
---------------------------------------


-- Tablas
SELECT * FROM trabajo_final_eda.products;  		-- productos
SELECT * FROM trabajo_final_eda.stores;			-- tiendas
SELECT * FROM trabajo_final_eda.sales s;  		-- ventas


----------------
--- PRODUCTS ---
----------------


--- visualizamos la tabla productos: 
SELECT count(*) FROM trabajo_final_eda.products;

-- 35 filas 

SELECT * FROM trabajo_final_eda.products;


-- Exploramos el tipo de dato. 
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'products';



SELECT count(DISTINCT  Product_Name) FROM trabajo_final_eda.products 
ORDER BY 1;

-- 35 productos totales 


SELECT 
	DISTINCT product_price    
FROM trabajo_final_eda.products
ORDER BY 1;

-- sin signos $ se procede a cambiar el tipo de dato en la tabla. 

-- verificamos con un SELECT que no emite error el cast
SELECT 
	DISTINCT product_price 
	, product_price:: decimal 
FROM trabajo_final_eda.products
;


-- Verificamos los datos que hay en la columna costo. 

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

-- visualmente encontramos $ en los datos de costo:

-- Probamos quitar el $ y modificar el dato a decimal 
SELECT 
	DISTINCT product_cost
	, REPLACE (product_cost, '$', '') AS precio_normalizado_text
	, REPLACE (product_cost, '$', '') :: DECIMAL (10,2) AS precio_normalizado_numeric 
FROM trabajo_final_eda.products
ORDER BY 1
;

-- usaremos REPLACE (product_cost, '$', '') :: DECIMAL (10,2) para el ALTER TABLE 


SELECT * FROM trabajo_final_eda.products;

--- product_categoryS ---

SELECT DISTINCT product_category FROM trabajo_final_eda.products;

--- 5 product_categorys 

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


SELECT 
	product_name AS product
	, product_category AS category
	, sum (product_price - product_cost ) AS margen 
FROM trabajo_final_eda.products
GROUP BY product_name, product_category
ORDER BY margen DESC
;






--------------
--- STORES ---
--------------

SELECT * FROM trabajo_final_eda.stores;

SELECT count(*) FROM trabajo_final_eda.stores;

-- 50 filas 

-- cantidad de ciudades 
SELECT count(DISTINCT store_city) AS cant_ciudades FROM trabajo_final_eda.stores;
-- 29 ciudades 

-- listado de ciudades 
SELECT DISTINCT store_city FROM trabajo_final_eda.stores ORDER BY 1;

/* Ciudades MEXICANAS
store_city
	Aguascalientes
	Campeche
	Chetumal
	Chihuahua
	Chilpancingo
	Cuernavaca
	Culiacan
	DF
	Durango
	Guadalajara
	Guanajuato
	Hermosillo
	La Paz
	Merida
	Mexicali
	Monterrey
	Morelia
	Oaxaca
	Pachuca
	Potosi
	Puebla
	Saltillo
	Santiago
	Toluca
	Tuxtla
	Victoria
	Villahermosa
	Xalapa
	Zacatecas
*/

-- Tipo de locacion 
SELECT DISTINCT store_location FROM trabajo_final_eda.stores;

/* tipo de zona
 * Podremos ver si las ventas mejoran o tienen algun indicio la zona. 

Airport
Commercial
Downtown
Residential 
*/


-- sale_dates en varchar. 
SELECT DISTINCT store_open_date FROM trabajo_final_eda.stores;

-- ¿Genera error si las casteo a date? 
SELECT 
	DISTINCT store_open_date 
	, store_open_date :: date 
	, EXTRACT (YEAR FROM store_open_date:: date ) AS annio
	, EXTRACT (MONTH FROM store_open_date:: date ) AS mes
FROM trabajo_final_eda.stores
ORDER BY 2 DESC
;

/*
 * Como funciona el casteo pasamos a alter table: 
 * 
2016-05-18	2016-05-18	2016	5
2016-05-10	2016-05-10	2016	5
2016-03-23	2016-03-23	2016	3
2015-11-21	2015-11-21	2015	11
2015-10-31	2015-10-31	2015	10
2015-06-21	2015-06-21	2015	6

USAREMOS store_open_date :: date
 */


SELECT 
	  MIN(store_open_date) AS inicio_tienda
	, MAX(store_open_date) AS ultima_tienda  
FROM trabajo_final_eda.stores;


-- Desde 1992 hasta el 2016 se abrieron tiendas 

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
	SELECT * FROM tiendas_annio
;




------------
-- SALES ---
------------

SELECT * FROM trabajo_final_eda.sales;


SELECT count(*) FROM trabajo_final_eda.sales; 

/*filas: 829262*/



SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'sales';



-- Probamos el cambio del Date (text a date) con un select. 
SELECT 
	TO_DATE("Date", 'DD-MM-YYYY') AS sale_date
FROM 
;



--- se cambia el nombre de "Date" a sale_date para mejorar sintaxis. 


-- Hay datos nulos en la tabla sales ? 
SELECT 
	  count(1) FILTER ( WHERE sale_id IS NULL)
	, count(2) FILTER ( WHERE sale_date IS NULL)
	, count(3) FILTER ( WHERE store_id IS NULL)
	, count(4) FILTER ( WHERE product_id IS NULL)
	, count(5) FILTER ( WHERE units IS NULL)
FROM trabajo_final_eda.sales;

-- Opcion 2 para revisar nullos. 
SELECT 
	  count(*) - count(1) AS null_col_1
	, count(*) - count(2) AS null_col_2
	, count(*) - count(3) AS null_col_3
	, count(*) - count(4) AS null_col_4
	, count(*) - count(5) AS null_col_5
FROM trabajo_final_eda.sales s;


-- Rango de sale_dates 
SELECT 
	  min(sale_date) AS sale_date_inicial
	, max(sale_date) AS sale_date_final
	, AGE( max(sale_date),  min(sale_date))  AS tiempo_transcurrido
FROM trabajo_final_eda.sales s
LIMIT 10;


--sale_date_inicial	sale_date_final		tiempo_transcurrido
--2022-01-01		2026-05-31		4 years 4 mons 30 days


--- units ---

-- Probamos el cambio de type con un select
SELECT 
	units 
	, units :: integer 
FROM trabajo_final_eda.sales;

-- usaremos units :: integer 

-- Total de units vendidas. 
SELECT sum(units) FROM trabajo_final_eda.sales;

-- sum
-- 1,090,565



--------------------------------------------
-- creamos una query con todos los datos --- 
--------------------------------------------

-- nos paramos en sales
SELECT * FROM trabajo_final_eda.sales AS s
-- unimos con producto metodo ON
LEFT JOIN trabajo_final_eda.products AS p 
	ON s.product_id = p.product_id
-- unimos con store metodo USING
LEFT JOIN trabajo_final_eda.stores s2 
	USING(store_id) -- usamos metodo using para unir tablas
;



-------------------------
--- CREACION DE VIEWS ---
-------------------------

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



-- Visualizamos la vista: 
SELECT 
	* 
FROM vw_datos
LIMIT 10
;


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

-- Analizamos un poco el Margen

SELECT
	  to_char(sum(product_price * units), '$99,999,999') AS "Ventas Totales"
	, to_char(sum((product_price - product_cost) * units ), '$99,999,999') AS "Margen Total"
	, round((sum((product_price - product_cost) * units ) / sum(product_price * units) * 100) :: NUMERIC , 2) AS "Margen Bruto"
FROM vw_datos
;

-- Segmentamos el margen por año

SELECT
	to_char(date_trunc('year', sale_date), 'YYYY')
	, to_char(sum(product_price * units), '$99,999,999') AS "Ventas Totales"
	, to_char(sum((product_price - product_cost) * units ), '$99,999,999') AS "Margen Total"
	, round ((sum((product_price - product_cost) * units ) / sum(product_price * units) * 100) :: numeric , 2)   AS "Margen Bruto"
	, dense_rank() over(ORDER BY round ((sum((product_price - product_cost) * units ) / sum(product_price * units) * 100) :: numeric , 2) DESC) AS "Ranking Margen Bruto"
FROM vw_datos
GROUP BY date_trunc('year', sale_date)
;

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
;



-- Venta anual
SELECT 
	to_char(date_trunc('year', sale_date), 'YYYY')  AS annio
	, round(sum(product_price * units) :: NUMERIC , 2) AS venta
	, round(sum((product_price - product_cost) * units )::NUMERIC , 2) AS margen
	, dense_rank() OVER (win_margen) AS ranking_margen
	, dense_rank() OVER (win_venta) AS ranking_venta
FROM vw_datos
GROUP BY date_trunc('year', sale_date)
WINDOW 
	  win_venta AS (ORDER BY round(sum(product_price * units) :: NUMERIC , 2) DESC)
	, win_margen AS (ORDER BY round(sum((product_price - product_cost) * units )::NUMERIC , 2 ) DESC)
ORDER BY ranking_margen
;



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



-- TOP 10 productos con mayor ingreso o ventas. 
SELECT 
	product_name
	, sum(units) AS unidades
	, sum (units * product_price) AS venta
FROM vw_datos
GROUP BY product_name
ORDER BY 3 DESC 
LIMIT 10 
;


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
ORDER BY 2 DESC
LIMIT 10
;


---------------------
--- ANALISAR 2026 --- 
---------------------


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


































