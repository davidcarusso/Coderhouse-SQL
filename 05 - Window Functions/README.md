# Pre-entrega: Script de análisis avanzado con Window Functions

## Qué construir / entregar

Debes entregar un **archivo `.sql`** que contenga una consulta avanzada (o un conjunto de consultas conectadas por CTEs) que responda a un escenario de análisis de ventas. El script debe generar un reporte con las siguientes columnas mínimas:

1. **Identificadores**: Mes de la venta y Categoría del producto.
2. **Métrica Base**: Venta total del mes/categoría.
3. **Ranking**: Posición de la categoría en ese mes basada en ventas (usando `RANK` o `DENSE_RANK`).
4. **Acumulado (Running Total)**: Ventas acumuladas de la categoría a lo largo de los meses.
5. **Comparativa**: Un mensaje condicional (usando `CASE WHEN`) que indique si la venta actual está "Por encima" o "Por debajo" del promedio histórico de esa categoría.

## Pasos sugeridos

1. **Limpia y agrupa**: Empieza creando una CTE que agrupe las ventas por mes y categoría. Usa `DATE_TRUNC('month', ...)` para normalizar las fechas.
2. **Calcula rankings**: Sobre esa CTE, aplica `RANK()` particionando por el mes para ver qué categorías lideran cada periodo.
3. **Crea el acumulado**: Usa `SUM(monto) OVER(PARTITION BY categoria ORDER BY mes)` para ver cómo crecen las ventas de cada producto mes a mes.
4. **Añade la lógica de negocio**: Calcula el promedio general en otra CTE y usa un `CASE WHEN` en el `SELECT` final para comparar el monto del mes contra ese promedio.

## Errores comunes a evitar

- **Olvidar el ORDER BY en el OVER**: Si haces un acumulado (`Running Total`) sin `ORDER BY` dentro de la ventana, SQL te dará el total general en cada fila en lugar de la suma progresiva.
- **Mezclar granularidad**: Asegúrate de que todas tus métricas hablen del mismo nivel (ej: nivel mes/categoría). Si intentas comparar una venta diaria con un promedio mensual sin nivelar los datos, el resultado no tendrá sentido.

​

Script SQL (.sql) con la consulta avanzada que integra CTEs, Window Functions y lógica condicional sobre un dataset de ventas.

Entregable

1. Abre tu herramienta preferida (pgAdmin 4 o DBeaver) y conéctate a tu base de datos de práctica.
2. Crea un nuevo script SQL titulado `preentrega_analisis_avanzado.sql`.
3. Utilizando las tablas de `ventas`, `productos` y `categorías` (o el dataset que has venido trabajando en el módulo 4):
    - Define una CTE llamada `ventas_mensuales` que extraiga el año/mes, el nombre de la categoría y sume el total de ventas.
    - Crea una segunda CTE llamada `metricas_ventana` que tome los datos de la anterior y calcule:
        - El ranking de las categorías más vendidas por cada mes.
        - El total acumulado (Running Total) de ventas por categoría a través del tiempo.
    - En la consulta final (SELECT principal), utiliza un `CASE WHEN` para comparar la venta mensual contra el promedio de ventas de esa misma categoría e indicar si fue un mes "Exitoso" o "Bajo el promedio".
4. Asegúrate de comentar tu código explicando qué hace cada sección.
5. Sube tu script a un repositorio de GitHub o GitLab y entrega la URL.


## Resolución: 
---

### Creación de ``SCHEMA``

Se crea el SCHEMA "entregable_05"
```sql
CREATE SCHEMA IF NOT EXISTS entregable_05;
```

### Creación de ``TABLE``

Se crean las tres tablas requeridas dentro del SCHEMA entregable_05

```sql
-- Creamos las tablas:

CREATE TABLE IF NOT EXISTS entregable_05.categorias(
	id_categoria SERIAL PRIMARY KEY
,   nombre_categoria VARCHAR(120) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS entregable_05.productos(
	id_producto SERIAL PRIMARY KEY
	, nombre_producto VARCHAR(120) UNIQUE NOT NULL
	, precio_producto DECIMAL(10,2) NOT NULL CHECK (precio_producto > 0)
	, id_categoria INTEGER NOT NULL
--- conector con categoria
	, CONSTRAINT fk_categoria
		FOREIGN KEY (id_categoria)
		REFERENCES entregable_05.categorias (id_categoria)
);

CREATE TABLE IF NOT EXISTS entregable_05.venta(
	id_ventas SERIAL PRIMARY KEY
	, id_producto INTEGER NOT NULL	
	, cantidad INTEGER NOT NULL CHECK (cantidad > 0)
	, fecha TIMESTAMP NOT NULL
--- conector con tabla productos
	, CONSTRAINT fk_productos
		FOREIGN KEY (id_producto)
		REFERENCES entregable_05.productos(id_producto)
);
```

### Visualizamos las tablas: 

![[Pasted image 20260821093900.png]]

### Cargar de datos ``INSERT INTO``

```sql
-- Tabla categoría:
INSERT INTO entregable_05.categorias
(nombre_categoria)

VALUES
	('Electrodomésticos'),
	('Tecnología'),
	('Audio'),
	('Hogar'),
	('Cocina'),
	('Muebles'),
	('Iluminación'),
	('Accesorios')
;
```


```sql
-- Tabla productos:

INSERT INTO entregable_05.productos
	(nombre_producto, precio_producto, id_categoria)

VALUES
-- Electrodomésticos
('Heladera No Frost 320L', 850000.00, 1),
('Lavarropas Automático 8Kg', 620000.00, 1),
('Microondas 20L', 180000.00, 1),
('Aspiradora Robot', 450000.00, 1),

-- Tecnología
('Notebook 15 Pulgadas', 1200000.00, 2),
('Monitor LED 24 Pulgadas', 380000.00, 2),
('Tablet 10 Pulgadas', 420000.00, 2),
('Teclado Mecánico', 95000.00, 2),

-- Audio
('Auriculares Bluetooth', 85000.00, 3),
('Parlante Bluetooth', 140000.00, 3),
('Barra de Sonido', 290000.00, 3),

-- Hogar
('Ventilador de Pie', 110000.00, 4),
('Estufa Eléctrica', 125000.00, 4),
('Purificador de Aire', 210000.00, 4),

-- Cocina
('Cafetera Express', 260000.00, 5),
('Licuadora 700W', 130000.00, 5),
('Freidora de Aire 5L', 220000.00, 5),
('Batidora Planetaria', 310000.00, 5),

-- Muebles
('Escritorio 120cm', 280000.00, 6),
('Silla de Oficina', 240000.00, 6),
('Biblioteca 5 Estantes', 190000.00, 6),
  
-- Iluminación
('Lámpara de Escritorio LED', 65000.00, 7),
('Lámpara de Pie', 120000.00, 7),
('Plafón LED', 55000.00, 7),

-- Accesorios
('Mouse Inalámbrico', 45000.00, 8),
('Webcam Full HD', 90000.00, 8),
('Hub USB-C', 70000.00, 8)
;
```

```sql 
-- INSERTAR TABLA VENTAS:

INSERT INTO entregable_05.venta
	(id_producto, cantidad, fecha)

VALUES
(1, 11, '2023-10-06 10:00:00'),
(3, 2, '2024-08-18 16:35:00'),
(27, 1, '2026-05-02 16:00:00'),
(18, 2, '2023-03-03 09:30:00'),
(27, 7, '2023-12-14 11:40:00'),
(8, 4, '2025-02-09 18:20:00'),
(14, 3, '2024-11-22 13:10:00'),
... --continua hasta tener 200 ingresos
;
```

### Agrupar datos de las tres tablas: 

- Input
```sql
WITH datos AS
(
SELECT
	*
FROM entregable_05.venta AS v
-- union de las tres tablas usando USING por igualdad de name campo. 
	LEFT JOIN entregable_05.productos AS P USING (id_producto)
	LEFT JOIN entregable_05.categorias AS c USING (id_categoria)
), datos_agrupados AS
(
SELECT
	fecha
	, EXTRACT (HOUR FROM fecha) AS hora
	, CASE
		WHEN EXTRACT (HOUR FROM fecha) < 12 THEN 'Mañana'
		WHEN EXTRACT (HOUR FROM fecha) BETWEEN 12 AND 18 THEN 'Tarde'
		ELSE 'Noche'
	END AS turno
	, EXTRACT(YEAR FROM datos.fecha) AS "año"
	, EXTRACT(MONTH FROM fecha) AS mes
	--, CAST(EXTRACT(MONTH FROM fecha) + EXTRACT(YEAR FROM fecha) * 100 AS VARCHAR) AS periodo_var --castear con CAST
	, (EXTRACT(YEAR FROM fecha):: INT * 100 + EXTRACT(MONTH FROM fecha):: INT) AS periodo
	, nombre_producto AS producto
	, nombre_categoria AS categoria
	, cantidad
	, precio_producto AS precio
FROM datos
)
	SELECT * FROM datos_agrupados
;
```

- Output

| fecha                   | hora | turno  | año   | mes | periodo | producto               | categoria         | cantidad | precio  |
| ----------------------- | ---- | ------ | ----- | --- | ------- | ---------------------- | ----------------- | -------- | ------- |
| 2023-10-06 10:00:00.000 | 10   | Mañana | 2,023 | 10  | 202,310 | Heladera No Frost 320L | Electrodomésticos | 11       | 850,000 |
| 2024-08-18 16:35:00.000 | 16   | Tarde  | 2,024 | 8   | 202,408 | Microondas 20L         | Electrodomésticos | 2        | 180,000 |
| 2026-05-02 16:00:00.000 | 16   | Tarde  | 2,026 | 5   | 202,605 | Hub USB-C              | Accesorios        | 1        | 70,000  |
| 2023-03-03 09:30:00.000 | 9    | Mañana | 2,023 | 3   | 202,303 | Batidora Planetaria    | Cocina            | 2        | 310,000 |
| 2023-12-14 11:40:00.000 | 11   | Mañana | 2,023 | 12  | 202,312 | Hub USB-C              | Accesorios        | 7        | 70,000  |

### Creamos el CTE `ventas_mensuales`

> [!Question]
> - Define una CTE llamada `ventas_mensuales` que extraiga el año/mes, el nombre de la categoría y sume el total de ventas.

```sql
WITH datos AS
(
SELECT
	*
FROM entregable_05.venta AS v
	LEFT JOIN entregable_05.productos AS P USING (id_producto)
	LEFT JOIN entregable_05.categorias AS c USING (id_categoria)
), datos_agrupados AS
(
SELECT
	fecha
	, EXTRACT (HOUR FROM fecha) AS hora
	, CASE
		WHEN EXTRACT (HOUR FROM fecha) < 12 THEN 'Mañana'
		WHEN EXTRACT (HOUR FROM fecha) BETWEEN 12 AND 18 THEN 'Tarde'
		ELSE 'Noche'
	  END AS turno
	, EXTRACT(YEAR FROM datos.fecha) AS "año"
	, EXTRACT(MONTH FROM fecha) AS mes
	, (EXTRACT(YEAR FROM fecha):: INT * 100 + EXTRACT(MONTH FROM fecha):: INT) AS periodo
	, nombre_producto AS producto
	, nombre_categoria AS categoria
	, cantidad
	, precio_producto AS precio
FROM datos
), ventas_mensuales AS                            -- creamos el CTE solicitado
(
SELECT
	año
	, mes
	, categoria
	--
	, sum(cantidad::INT * precio) AS ventas
FROM datos_agrupados
GROUP BY año, mes, categoria
ORDER BY año, mes, ventas
)
	SELECT * FROM ventas_mensuales                -- consutla de CTE
;
```

- Output: 

| año   | mes | categoria         | ventas    |
| ----- | --- | ----------------- | --------- |
| 2,023 | 2   | Electrodomésticos | 810,000   |
| 2,023 | 2   | Cocina            | 1,300,000 |
| 2,023 | 3   | Accesorios        | 90,000    |
| 2,023 | 3   | Hogar             | 375,000   |
## Segunda instancia de CTE

> [!Question]
> - Crea una segunda CTE llamada `metricas_ventana` que tome los datos de la anterior y calcule:
> 	1. El ranking de las categorías más vendidas por cada mes.
> 	2. El total acumulado (Running Total) de ventas por categoría a través del tiempo.

- El ranking de las categorías más vendidas por cada mes.
```sql
SELECT
	*
	, DENSE_RANK() OVER(PARTITION BY año, mes ORDER BY ventas DESC) AS ranking_categorias
FROM ventas_mensuales
ORDER BY 1, 2, ventas DESC
;
```

> [!Interesante]
> ```sql
> DENSE_RANK() OVER(PARTITION BY año, mes ORDER BY ventas DESC) AS ranking_categorias
> ```
> ``DENSE_RANK()`` agrego la ``PARTITION BY`` por dos campos. Primero por año y luego por mes. De esta forma me da la mayor venta por mes dentro de cada año. Se podría usar el periodo, generado en la agrupación anterior. 

- Output

| año   | mes | categoria         | ventas    | ranking_categorias |
| ----- | --- | ----------------- | --------- | ------------------ |
| 2,023 | 1   | Tecnología        | 2,100,000 | 1                  |
| 2,023 | 1   | Cocina            | 1,240,000 | 2                  |
| 2,023 | 1   | Audio             | 560,000   | 3                  |
| 2,023 | 1   | Iluminación       | 220,000   | 4                  |
| 2,023 | 2   | Cocina            | 1,300,000 | 1                  |
| 2,023 | 2   | Electrodomésticos | 810,000   | 2                  |
| 2,023 | 2   | Tecnología        | 380,000   | 3                  |
| 2,023 | 2   | Accesorios        | 90,000    | 4                  |


- El total acumulado (Running Total) de ventas por categoría a través del tiempo.
```SQL
SELECT
*
	, DENSE_RANK() OVER(PARTITION BY año, mes ORDER BY ventas DESC) AS ranking_categorias
	, SUM(ventas) OVER(PARTITION BY categoria ORDER BY año, mes) AS sum_acum
FROM ventas_mensuales
ORDER BY 1, 2, ventas DESC
;
```

Del mismo modo separo la suma con la categoría y lo ordeno primero por año y luego por mes. 
```sql
	SUM(ventas) OVER(PARTITION BY categoria ORDER BY año, mes) AS sum_acum
```

- Output
Ejemplo de acumulado accesorios. 

|año|mes|categoria|ventas|ranking_categorias|sum_acum|
|---|---|---|---|---|---|
|2,023|7|Accesorios|270,000|2|675,000|
|2,023|8|Accesorios|450,000|4|1,125,000|
|2,023|11|Accesorios|90,000|4|1,215,000|
|2,023|12|Accesorios|490,000|4|1,705,000|
|2,024|2|Accesorios|90,000|3|1,795,000|
|2,024|6|Accesorios|360,000|5|2,155,000|
|2,024|9|Accesorios|45,000|5|2,200,000|
|2,024|11|Accesorios|135,000|5|2,335,000|
|2,024|12|Accesorios|485,000|4|2,820,000|
|2,025|2|Accesorios|350,000|3|3,170,000|
|2,025|4|Accesorios|630,000|2|3,800,000|
|2,025|6|Accesorios|560,000|3|4,360,000|
|2,025|9|Accesorios|210,000|3|4,570,000|
|2,025|10|Accesorios|315,000|3|4,885,000|
|2,025|11|Accesorios|140,000|4|5,025,000|
|2,025|12|Accesorios|630,000|3|5,655,000|
|2,026|3|Accesorios|360,000|3|6,015,000|
|2,026|4|Accesorios|140,000|5|6,155,000|
|2,026|5|Accesorios|250,000|6|6,405,000|
|2,026|6|Accesorios|270,000|6|6,675,000|
|2,026|7|Accesorios|790,000|4|7,465,000|

### Consulta Final

> [!Question]
> En la consulta final (SELECT principal), utiliza un `CASE WHEN` para comparar la venta mensual contra el promedio de ventas de esa misma categoría e indicar si fue un mes "Exitoso" o "Bajo el promedio".


```sql
SELECT
	*
	, DENSE_RANK() OVER(PARTITION BY año, mes ORDER BY ventas DESC) AS ranking_categorias
	, SUM(ventas) OVER(PARTITION BY categoria ORDER BY año, mes) AS sum_acumulado_categoria
	, round(AVG(ventas) OVER(PARTITION BY categoria),2) AS promedio_categoria
	, CASE
		WHEN ventas > AVG(ventas) OVER(PARTITION BY categoria) THEN 'Exitoso'
		ELSE 'Bajo el promedio'
	  END AS venta_mensual_contra_promedio
FROM ventas_mensuales
ORDER BY 1, 2, ventas DESC
```

Con esta sentencia creamos una columna con el promedio por cada categoria. 
```sql
	round(AVG(ventas) OVER(PARTITION BY categoria),2) AS promedio_categoria
```

- Comprobamos con categoría "Cocina"
```sql
SELECT
	count(ventas) AS Q
	, sum(ventas) AS sumatoria_venta
	, round(avg(ventas), 2) AS promedio
FROM consulta_final
WHERE categoria = 'Cocina'
```

| q   | sumatoria_venta | promedio     |
| --- | --------------- | ------------ |
| 28  | 34,840,000      | 1,244,285.71 |

- Comprobación de promedios.
```sql
SELECT
	año
	, mes
	, categoria
	, ventas
	, promedio_categoria
FROM consulta_final
WHERE categoria = 'Cocina'
LIMIT 5
```

| año   | mes | categoria | ventas    | promedio_categoria |
| ----- | --- | --------- | --------- | ------------------ |
| 2,023 | 1   | Cocina    | 1,240,000 | 1,244,285.71       |
| 2,023 | 2   | Cocina    | 1,300,000 | 1,244,285.71       |
| 2,023 | 3   | Cocina    | 620,000   | 1,244,285.71       |
| 2,023 | 5   | Cocina    | 440,000   | 1,244,285.71       |
| 2,023 | 8   | Cocina    | 1,100,000 | 1,244,285.71       |

```sql
	CASE
		WHEN ventas > AVG(ventas) OVER(PARTITION BY categoria) THEN 'Exitoso'
		ELSE 'Bajo el promedio'
	END AS venta_mensual_contra_promedio
```

- Achicamos la salida para corroborar:
```sql
SELECT
	año
	, mes
	, ventas
	, promedio_categoria
	, venta_mensual_contra_promedio
FROM consulta_final
WHERE categoria = 'Cocina'
LIMIT 5
```

| año   | mes | ventas    | promedio_categoria | venta_mensual_contra_promedio |
| ----- | --- | --------- | ------------------ | ----------------------------- |
| 2,023 | 1   | 1,240,000 | 1,244,285.71       | Bajo el promedio              |
| 2,023 | 2   | 1,300,000 | 1,244,285.71       | Exitoso                       |
| 2,023 | 3   | 620,000   | 1,244,285.71       | Bajo el promedio              |
| 2,023 | 5   | 440,000   | 1,244,285.71       | Bajo el promedio              |
| 2,023 | 8   | 1,100,000 | 1,244,285.71       | Bajo el promedio              |
se comprueba que el `CASE` evalúa correctamente la salida cuando es menor o mayor al promedio.


### Query Final:

```sql

```