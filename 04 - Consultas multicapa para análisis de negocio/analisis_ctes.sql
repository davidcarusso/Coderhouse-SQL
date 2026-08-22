
/*Propósito del ejercicio
Este ejercicio tiene como objetivo que apliques tus conocimientos sobre CTEs para resolver un problema de análisis de ventas real, transformando una consulta que habitualmente sería difícil de leer en una estructura modular y profesional.

Qué construir
Vas a extender el repositorio que creaste en el Módulo 4 ("Análisis Agregado Multicapa"). Deberás crear un nuevo script llamado analisis_ctes.sql donde realices un informe de rendimiento regional.

Pasos sugeridos
Conexión y Contexto: Asegúrate de estar conectado a tu base de datos de PostgreSQL donde tienes las tablas de ventas, regiones y productos (creadas en módulos anteriores).

Definición de la CTE: Crea una CTE llamada ventas_por_region. Dentro de ella, debes unir las tablas necesarias para obtener el nombre de la región y la suma total de las ventas (SUM(monto)).

Consulta Principal: Utiliza la CTE creada en una sentencia SELECT final. En este paso final, filtra los resultados para mostrar solo las regiones cuyo gran total de ventas sea superior al promedio general de todas las ventas (puedes usar una subconsulta simple dentro del WHERE para este promedio).

Ordenamiento: Asegúrate de que el resultado final esté ordenado de mayor a menor venta.
Criterios de aceptación

El script debe utilizar obligatoriamente la cláusula WITH.

La lógica debe estar dividida: la agregación (SUM) debe ocurrir dentro de la CTE y el filtrado/ordenamiento en la consulta principal.

El código debe estar debidamente indentado y comentado siguiendo las buenas prácticas vistas en clase.

El archivo debe subirse al mismo repositorio del proyecto final, en una carpeta llamada modulo_5/.
Errores comunes a evitar
No poner alias a las columnas calculadas dentro de la CTE (esto hará que no puedas llamarlas en la consulta principal).
Olvidar cerrar el paréntesis de la definición de la CTE antes de iniciar el SELECT final.
Intentar usar WITH más de una vez para definir varias CTEs (recuerda que solo se usa una vez al principio y las CTEs se separan por comas).*/

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



WITH datos AS 
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
(
SELECT 
	nombre_region
,	sum(cantidad * precio) AS venta
--, 	AVG(sum(cantidad * precio)) OVER() AS promedio
FROM datos
GROUP BY nombre_region
), venta_global_promedio AS (SELECT AVG(venta) FROM ventas_por_region) -- CTE como variable fija
, consulta_final AS 
(
SELECT 
	*
FROM ventas_por_region
WHERE venta > (SELECT * FROM venta_global_promedio) -- aca use un CTE como condicion de where
)
SELECT * FROM consulta_final
ORDER BY 2 DESC
;

/*
nombre_region	venta
Pampeana		6,812.48
Cuyo			4,522.75
Noreste (NEA)	3,954.6

Con la informacióm brindada, entendemos que las 3 regiones que venden por encima del promedio global son: Pampeana, Cuyo y NEA. 







