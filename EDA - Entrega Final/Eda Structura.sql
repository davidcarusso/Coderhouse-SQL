--

--------------------------
--- CREACION DE SCHEMA ---
--------------------------


CREATE SCHEMA trabajo_final_eda;


---------------------------------------
--- crear tablas e importar la info --- 
---------------------------------------

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


--------------------------
--- Importar los datos ---
--------------------------

-- Mediante la funcion de import en DBreave



----------------------------
--- ALTERACIÓN DE TABLAS ---
----------------------------


--- CAMBIOS EN LA TABLA DE PRODUCTS ---

BEGIN;

-- modificamos la columna precio a tipo decimal 
ALTER TABLE trabajo_final_eda.products 
ALTER COLUMN product_price TYPE DECIMAL
USING product_price:: decimal 
;

COMMIT;


-- abrimos el BEGIN para evitar errores. 
BEGIN;

-- Modificamos la columna costo
ALTER TABLE trabajo_final_eda.products 
ALTER COLUMN product_cost TYPE DECIMAL(10,2)
USING REPLACE (product_cost, '$', '') :: DECIMAL (10,2)
;

-- Verificamos cambios
SELECT DISTINCT product_cost
FROM trabajo_final_eda.products
;

-- Cerramos el BEGIN
COMMIT;



--- CAMBIOS EN LA TABLA DE STORE ---

-- creamos el bk
BEGIN;

-- modificamos la tabla
ALTER TABLE trabajo_final_eda.stores 
ALTER COLUMN store_open_date TYPE DATE
USING store_open_date :: date
;

-- verificamos el cambio
SELECT * FROM trabajo_final_eda.stores;
-- fechas ok 

-- cerramos el bk
COMMIT;



--- CAMBIOS EN LA TABLA DE SALES ---

-- abrimos transaccion 
BEGIN;

-- Cambiamos el tipo de dato en la tabla sales de date. 
ALTER TABLE trabajo_final_eda.sales
ALTER COLUMN "Date" TYPE date
USING TO_DATE("Date", 'DD-MM-YYYY')
;

-- cerramos 
COMMIT;


--- abrimos transaccion
BEGIN;

-- modificar columna unidades
ALTER TABLE trabajo_final_eda.sales
ALTER COLUMN units TYPE INTEGER
USING units::INTEGER
;


-- Verificamos 

SELECT 
	column_name, 
	data_type
FROM information_schema.columns
WHERE table_schema = 'trabajo_final_eda'
  AND table_name = 'sales'
  AND column_name = 'units'
;

-- column_name		data_type
-- units			integer

-- cerramos 
COMMIT;



