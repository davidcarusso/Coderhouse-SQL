
-- Para analizar clientes tenemos que tener regiones: 
CREATE TABLE IF NOT EXISTS entregable_04.regiones(
	id_region SERIAL PRIMARY KEY 
,	nombre_region VARCHAR(100) NOT NULL UNIQUE 
);

-- Cargamos regiones: 

INSERT INTO entregable_04.regiones 
	(nombre_region) 
VALUES
    ('Centro'),
    ('Cuyo'),
    ('Noreste (NEA)'),
    ('Noroeste (NOA)'),
    ('Pampeana'),
    ('Patagonia')
;

-- Creamos tabla puente para clientes_regiones

CREATE TABLE IF NOT EXISTS entregable_04.clientes_regiones(
	id_registros SERIAL PRIMARY KEY 
,	id_cliente INTEGER NOT NULL 
,	id_region INTEGER NOT NULL 
,   CONSTRAINT fk_cr_cliente 
		FOREIGN KEY (id_cliente) 
		REFERENCES entregable_04.clientes(id_cliente) 
		ON DELETE CASCADE
,   CONSTRAINT fk_cr_region 
		FOREIGN KEY (id_region) 
		REFERENCES entregable_04.regiones(id_region) 
		ON DELETE CASCADE
,   CONSTRAINT uq_cliente_region UNIQUE (id_cliente, id_region) -- Evita duplicar el mismo cliente en la misma región
);

-- con esto trae un valor random  de id_region
SELECT 
	 r.id_region
FROM entregable_04.regiones AS r 
ORDER BY RANDOM()
LIMIT 1 
;

--
SELECT 
	DISTINCT c.id_cliente
,	FLOOR(RANDOM() * 6) + 1 AS id_region -- valor aletorio entre 1 y 6
FROM entregable_04.clientes AS c 
;

INSERT INTO entregable_04.clientes_regiones
	(id_cliente, id_region)
SELECT 
	DISTINCT c.id_cliente
,	FLOOR(RANDOM() * 6) + 1 AS id_region
FROM entregable_04.clientes AS c 
;

-- comprobamos que se cargaran las instrucciones. 
SELECT * FROM entregable_04.clientes_regiones; -- OK 


----------------------------------------
-- Consulta solicitada por el ejercio --
----------------------------------------

WITH datos AS 
-- Unimos todas las tablas para sacar lo que necesitamos.  
(
SELECT 
	* 
FROM entregable_04.ventas AS v
	LEFT JOIN entregable_04.clientes 			USING (id_cliente)	
	LEFT JOIN entregable_04.productos 			USING (id_producto) 
	LEFT JOIN entregable_04.clientes_regiones 	USING (id_cliente)
	LEFT JOIN entregable_04.regiones 			USING (id_region)
)

, ventas_por_region AS 
-- agrupamos por region y calculamos la cantidad
(
SELECT 
	nombre_region
,	sum(cantidad * precio) AS venta
FROM datos
GROUP BY nombre_region	

-- CTE como variable fija para reutilizar en un WHERE en proxima parte. 
), venta_global_promedio AS (SELECT AVG(venta) FROM ventas_por_region) 

, consulta_final AS
-- aca filtramos las tiendas donde la venta es mayor al promedio global 
(
SELECT 
	*
FROM ventas_por_region
WHERE venta > (SELECT * FROM venta_global_promedio) -- aca use un CTE como condicion de where para que sea mayor que el promedio
)
SELECT * FROM consulta_final
ORDER BY venta DESC -- orden  por venta DESC
;

/*
nombre_region	venta
Pampeana		6,812.48
Cuyo			4,522.75
Noreste (NEA)	3,954.6

Con la informacióm brindada, entendemos que las 3 regiones que venden por encima del promedio global son: Pampeana, Cuyo y NEA. 







