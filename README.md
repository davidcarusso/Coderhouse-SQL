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

![Relaciones entre tablas](./05%20-%20Window%20Functions/images/entregable_05_relaciones_tablas.png)

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

<details>
<summary>📊 Ver tabla completa</summary>

- Output

| fecha                   | hora | turno  | año   | mes | periodo | producto               | categoria         | cantidad | precio  |
| ----------------------- | ---- | ------ | ----- | --- | ------- | ---------------------- | ----------------- | -------- | ------- |
| 2023-10-06 10:00:00.000 | 10   | Mañana | 2,023 | 10  | 202,310 | Heladera No Frost 320L | Electrodomésticos | 11       | 850,000 |
| 2024-08-18 16:35:00.000 | 16   | Tarde  | 2,024 | 8   | 202,408 | Microondas 20L         | Electrodomésticos | 2        | 180,000 |
| 2026-05-02 16:00:00.000 | 16   | Tarde  | 2,026 | 5   | 202,605 | Hub USB-C              | Accesorios        | 1        | 70,000  |
| 2023-03-03 09:30:00.000 | 9    | Mañana | 2,023 | 3   | 202,303 | Batidora Planetaria    | Cocina            | 2        | 310,000 |
| 2023-12-14 11:40:00.000 | 11   | Mañana | 2,023 | 12  | 202,312 | Hub USB-C              | Accesorios        | 7        | 70,000  |

</details>

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

<details>
<summary>📊 Ejemplo de acumulado accesorios.</summary>

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

</details>

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


> se comprueba que el `CASE` evalúa correctamente la salida cuando es menor o mayor al promedio.


### Query Final:

```sql
WITH datos AS
(
SELECT
	*
FROM entregable_05.venta AS v
	LEFT JOIN entregable_05.productos AS P USING (id_producto)
	LEFT JOIN entregable_05.categorias AS c USING (id_categoria)
), 
	datos_agrupados AS
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
), 
	ventas_mensuales AS
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
), 
	consulta_final AS
(
SELECT
	*
	, DENSE_RANK() OVER(PARTITION BY año, mes ORDER BY ventas DESC) AS ranking_categorias
	, SUM(ventas) OVER(PARTITION BY categoria ORDER BY año, mes) AS sum_acumulado_categoria
	--, round(AVG(ventas) OVER(PARTITION BY categoria),2) AS promedio_categoria
	, CASE
		WHEN ventas > AVG(ventas) OVER(PARTITION BY categoria) THEN 'Exitoso'
		ELSE 'Bajo el promedio'
	END AS venta_mensual_contra_promedio
FROM ventas_mensuales
ORDER BY 1, 2, ventas DESC
)
SELECT
	*
FROM consulta_final
;
```


- Output

<div>

<details>
<summary>📊 Ver tabla completa</summary>

|año|mes|categoria|ventas|ranking_categorias|sum_acumulado_categoria|venta_mensual_contra_promedio|
|---|---|---|---|---|---|---|
|2,023|1|Tecnología|2,100,000|1|2,100,000|Bajo el promedio|
|2,023|1|Cocina|1,240,000|2|1,240,000|Bajo el promedio|
|2,023|1|Audio|560,000|3|560,000|Bajo el promedio|
|2,023|1|Iluminación|220,000|4|220,000|Bajo el promedio|
|2,023|2|Cocina|1,300,000|1|2,540,000|Exitoso|
|2,023|2|Electrodomésticos|810,000|2|810,000|Bajo el promedio|
|2,023|2|Tecnología|380,000|3|2,480,000|Bajo el promedio|
|2,023|2|Accesorios|90,000|4|90,000|Bajo el promedio|
|2,023|3|Tecnología|5,370,000|1|7,850,000|Exitoso|
|2,023|3|Muebles|2,240,000|2|2,240,000|Exitoso|
|2,023|3|Cocina|620,000|3|3,160,000|Bajo el promedio|
|2,023|3|Hogar|375,000|4|375,000|Bajo el promedio|
|2,023|3|Accesorios|90,000|5|180,000|Bajo el promedio|
|2,023|4|Audio|3,395,000|1|3,955,000|Exitoso|
|2,023|4|Muebles|480,000|2|2,720,000|Bajo el promedio|
|2,023|5|Tecnología|4,620,000|1|12,470,000|Exitoso|
|2,023|5|Cocina|440,000|2|3,600,000|Bajo el promedio|
|2,023|5|Hogar|330,000|3|705,000|Bajo el promedio|
|2,023|5|Accesorios|45,000|4|225,000|Bajo el promedio|
|2,023|6|Electrodomésticos|1,620,000|1|2,430,000|Bajo el promedio|
|2,023|6|Muebles|1,140,000|2|3,860,000|Bajo el promedio|
|2,023|6|Iluminación|520,000|3|740,000|Exitoso|
|2,023|6|Accesorios|180,000|4|405,000|Bajo el promedio|
|2,023|7|Electrodomésticos|7,770,000|1|10,200,000|Exitoso|
|2,023|7|Accesorios|270,000|2|675,000|Bajo el promedio|
|2,023|7|Iluminación|195,000|3|935,000|Bajo el promedio|
|2,023|7|Audio|85,000|4|4,040,000|Bajo el promedio|
|2,023|8|Electrodomésticos|1,860,000|1|12,060,000|Bajo el promedio|
|2,023|8|Cocina|1,100,000|2|4,700,000|Bajo el promedio|
|2,023|8|Hogar|840,000|3|1,545,000|Exitoso|
|2,023|8|Accesorios|450,000|4|1,125,000|Exitoso|
|2,023|8|Iluminación|110,000|5|1,045,000|Bajo el promedio|
|2,023|9|Tecnología|5,960,000|1|18,430,000|Exitoso|
|2,023|9|Hogar|750,000|2|2,295,000|Exitoso|
|2,023|9|Iluminación|110,000|3|1,155,000|Bajo el promedio|
|2,023|10|Electrodomésticos|9,350,000|1|21,410,000|Exitoso|
|2,023|10|Tecnología|1,520,000|2|19,950,000|Bajo el promedio|
|2,023|10|Iluminación|1,080,000|3|2,235,000|Exitoso|
|2,023|10|Audio|280,000|4|4,320,000|Bajo el promedio|
|2,023|10|Cocina|260,000|5|4,960,000|Bajo el promedio|
|2,023|11|Muebles|2,920,000|1|6,780,000|Exitoso|
|2,023|11|Iluminación|325,000|2|2,560,000|Bajo el promedio|
|2,023|11|Hogar|125,000|3|2,420,000|Bajo el promedio|
|2,023|11|Accesorios|90,000|4|1,215,000|Bajo el promedio|
|2,023|12|Electrodomésticos|1,260,000|1|22,670,000|Bajo el promedio|
|2,023|12|Muebles|950,000|2|7,730,000|Bajo el promedio|
|2,023|12|Hogar|840,000|3|3,260,000|Exitoso|
|2,023|12|Accesorios|490,000|4|1,705,000|Exitoso|
|2,023|12|Tecnología|285,000|5|20,235,000|Bajo el promedio|
|2,024|1|Electrodomésticos|1,350,000|1|24,020,000|Bajo el promedio|
|2,024|1|Hogar|1,130,000|2|4,390,000|Exitoso|
|2,024|1|Audio|680,000|3|5,000,000|Bajo el promedio|
|2,024|2|Audio|1,820,000|1|6,820,000|Exitoso|
|2,024|2|Electrodomésticos|1,800,000|2|25,820,000|Bajo el promedio|
|2,024|2|Accesorios|90,000|3|1,795,000|Bajo el promedio|
|2,024|3|Tecnología|3,580,000|1|23,815,000|Bajo el promedio|
|2,024|3|Muebles|1,400,000|2|9,130,000|Exitoso|
|2,024|3|Iluminación|815,000|3|3,375,000|Exitoso|
|2,024|3|Cocina|780,000|4|5,740,000|Bajo el promedio|
|2,024|4|Hogar|630,000|1|5,020,000|Bajo el promedio|
|2,024|4|Muebles|560,000|2|9,690,000|Bajo el promedio|
|2,024|4|Tecnología|285,000|3|24,100,000|Bajo el promedio|
|2,024|4|Iluminación|65,000|4|3,440,000|Bajo el promedio|
|2,024|5|Tecnología|3,895,000|1|27,995,000|Exitoso|
|2,024|5|Muebles|2,240,000|2|11,930,000|Exitoso|
|2,024|5|Audio|340,000|3|7,160,000|Bajo el promedio|
|2,024|5|Hogar|125,000|4|5,145,000|Bajo el promedio|
|2,024|6|Cocina|2,170,000|1|7,910,000|Exitoso|
|2,024|6|Electrodomésticos|1,860,000|2|27,680,000|Bajo el promedio|
|2,024|6|Hogar|630,000|3|5,775,000|Bajo el promedio|
|2,024|6|Tecnología|420,000|4|28,415,000|Bajo el promedio|
|2,024|6|Accesorios|360,000|5|2,155,000|Exitoso|
|2,024|6|Iluminación|260,000|6|3,700,000|Bajo el promedio|
|2,024|7|Electrodomésticos|2,480,000|1|30,160,000|Bajo el promedio|
|2,024|7|Muebles|1,960,000|2|13,890,000|Exitoso|
|2,024|7|Hogar|1,510,000|3|7,285,000|Exitoso|
|2,024|7|Cocina|260,000|4|8,170,000|Bajo el promedio|
|2,024|8|Cocina|880,000|1|9,050,000|Bajo el promedio|
|2,024|8|Audio|870,000|2|8,030,000|Exitoso|
|2,024|8|Hogar|660,000|3|7,945,000|Bajo el promedio|
|2,024|8|Tecnología|380,000|4|28,795,000|Bajo el promedio|
|2,024|8|Electrodomésticos|360,000|5|30,520,000|Bajo el promedio|
|2,024|9|Muebles|1,580,000|1|15,470,000|Exitoso|
|2,024|9|Cocina|930,000|2|9,980,000|Bajo el promedio|
|2,024|9|Audio|580,000|3|8,610,000|Bajo el promedio|
|2,024|9|Iluminación|130,000|4|3,830,000|Bajo el promedio|
|2,024|9|Accesorios|45,000|5|2,200,000|Bajo el promedio|
|2,024|10|Tecnología|4,395,000|1|33,190,000|Exitoso|
|2,024|10|Muebles|1,200,000|2|16,670,000|Bajo el promedio|
|2,024|10|Audio|290,000|3|8,900,000|Bajo el promedio|
|2,024|11|Electrodomésticos|2,480,000|1|33,000,000|Bajo el promedio|
|2,024|11|Cocina|1,170,000|2|11,150,000|Bajo el promedio|
|2,024|11|Hogar|630,000|3|8,575,000|Bajo el promedio|
|2,024|11|Muebles|190,000|4|16,860,000|Bajo el promedio|
|2,024|11|Accesorios|135,000|5|2,335,000|Bajo el promedio|
|2,024|12|Cocina|1,320,000|1|12,470,000|Exitoso|
|2,024|12|Tecnología|1,140,000|2|34,330,000|Bajo el promedio|
|2,024|12|Audio|850,000|3|9,750,000|Exitoso|
|2,024|12|Accesorios|485,000|4|2,820,000|Exitoso|
|2,025|1|Tecnología|6,000,000|1|40,330,000|Exitoso|
|2,025|1|Electrodomésticos|5,720,000|2|38,720,000|Exitoso|
|2,025|1|Audio|580,000|3|10,330,000|Bajo el promedio|
|2,025|1|Cocina|310,000|4|12,780,000|Bajo el promedio|
|2,025|2|Tecnología|13,580,000|1|53,910,000|Exitoso|
|2,025|2|Cocina|1,240,000|2|14,020,000|Bajo el promedio|
|2,025|2|Accesorios|350,000|3|3,170,000|Exitoso|
|2,025|2|Audio|170,000|4|10,500,000|Bajo el promedio|
|2,025|3|Cocina|1,100,000|1|15,120,000|Bajo el promedio|
|2,025|3|Muebles|840,000|2|17,700,000|Bajo el promedio|
|2,025|3|Iluminación|535,000|3|4,365,000|Exitoso|
|2,025|3|Audio|510,000|4|11,010,000|Bajo el promedio|
|2,025|4|Electrodomésticos|2,700,000|1|41,420,000|Bajo el promedio|
|2,025|4|Accesorios|630,000|2|3,800,000|Exitoso|
|2,025|4|Audio|580,000|3|11,590,000|Bajo el promedio|
|2,025|4|Hogar|330,000|4|8,905,000|Bajo el promedio|
|2,025|5|Muebles|2,640,000|1|20,340,000|Exitoso|
|2,025|5|Electrodomésticos|1,350,000|2|42,770,000|Bajo el promedio|
|2,025|5|Cocina|650,000|3|15,770,000|Bajo el promedio|
|2,025|5|Hogar|550,000|4|9,455,000|Bajo el promedio|
|2,025|5|Iluminación|240,000|5|4,605,000|Bajo el promedio|
|2,025|6|Electrodomésticos|7,120,000|1|49,890,000|Exitoso|
|2,025|6|Audio|3,190,000|2|14,780,000|Exitoso|
|2,025|6|Accesorios|560,000|3|4,360,000|Exitoso|
|2,025|7|Electrodomésticos|5,700,000|1|55,590,000|Exitoso|
|2,025|7|Muebles|1,050,000|2|21,390,000|Bajo el promedio|
|2,025|7|Cocina|520,000|3|16,290,000|Bajo el promedio|
|2,025|7|Iluminación|440,000|4|5,045,000|Exitoso|
|2,025|8|Electrodomésticos|1,700,000|1|57,290,000|Bajo el promedio|
|2,025|8|Muebles|1,200,000|2|22,590,000|Bajo el promedio|
|2,025|8|Audio|735,000|3|15,515,000|Bajo el promedio|
|2,025|8|Cocina|390,000|4|16,680,000|Bajo el promedio|
|2,025|9|Tecnología|9,660,000|1|63,570,000|Exitoso|
|2,025|9|Cocina|1,760,000|2|18,440,000|Exitoso|
|2,025|9|Accesorios|210,000|3|4,570,000|Bajo el promedio|
|2,025|9|Audio|170,000|4|15,685,000|Bajo el promedio|
|2,025|10|Tecnología|5,880,000|1|69,450,000|Exitoso|
|2,025|10|Electrodomésticos|1,080,000|2|58,370,000|Bajo el promedio|
|2,025|10|Accesorios|315,000|3|4,885,000|Exitoso|
|2,025|11|Cocina|1,980,000|1|20,420,000|Exitoso|
|2,025|11|Electrodomésticos|900,000|2|59,270,000|Bajo el promedio|
|2,025|11|Tecnología|665,000|3|70,115,000|Bajo el promedio|
|2,025|11|Accesorios|140,000|4|5,025,000|Bajo el promedio|
|2,025|12|Cocina|1,630,000|1|22,050,000|Exitoso|
|2,025|12|Tecnología|1,520,000|2|71,635,000|Bajo el promedio|
|2,025|12|Accesorios|630,000|3|5,655,000|Exitoso|
|2,026|1|Tecnología|10,800,000|1|82,435,000|Exitoso|
|2,026|1|Electrodomésticos|6,490,000|2|65,760,000|Exitoso|
|2,026|1|Cocina|520,000|3|22,570,000|Bajo el promedio|
|2,026|1|Iluminación|380,000|4|5,425,000|Exitoso|
|2,026|2|Tecnología|3,635,000|1|86,070,000|Bajo el promedio|
|2,026|2|Cocina|1,430,000|2|24,000,000|Exitoso|
|2,026|2|Iluminación|360,000|3|5,785,000|Exitoso|
|2,026|3|Cocina|5,200,000|1|29,200,000|Exitoso|
|2,026|3|Electrodomésticos|2,760,000|2|68,520,000|Bajo el promedio|
|2,026|3|Accesorios|360,000|3|6,015,000|Exitoso|
|2,026|4|Electrodomésticos|5,650,000|1|74,170,000|Exitoso|
|2,026|4|Tecnología|2,520,000|2|88,590,000|Bajo el promedio|
|2,026|4|Cocina|2,020,000|3|31,220,000|Exitoso|
|2,026|4|Iluminación|455,000|4|6,240,000|Exitoso|
|2,026|4|Accesorios|140,000|5|6,155,000|Bajo el promedio|
|2,026|5|Cocina|3,360,000|1|34,580,000|Exitoso|
|2,026|5|Electrodomésticos|900,000|2|75,070,000|Bajo el promedio|
|2,026|5|Tecnología|840,000|3|89,430,000|Bajo el promedio|
|2,026|5|Audio|420,000|4|16,105,000|Bajo el promedio|
|2,026|5|Iluminación|330,000|5|6,570,000|Bajo el promedio|
|2,026|5|Accesorios|250,000|6|6,405,000|Bajo el promedio|
|2,026|5|Hogar|250,000|6|9,705,000|Bajo el promedio|
|2,026|6|Tecnología|2,100,000|1|91,530,000|Bajo el promedio|
|2,026|6|Electrodomésticos|1,880,000|2|76,950,000|Bajo el promedio|
|2,026|6|Hogar|1,465,000|3|11,170,000|Exitoso|
|2,026|6|Muebles|950,000|4|23,540,000|Bajo el promedio|
|2,026|6|Audio|425,000|5|16,530,000|Bajo el promedio|
|2,026|6|Accesorios|270,000|6|6,675,000|Bajo el promedio|
|2,026|7|Tecnología|3,420,000|1|94,950,000|Bajo el promedio|
|2,026|7|Muebles|1,400,000|2|24,940,000|Exitoso|
|2,026|7|Hogar|1,260,000|3|12,430,000|Exitoso|
|2,026|7|Accesorios|790,000|4|7,465,000|Exitoso|
|2,026|7|Audio|420,000|5|16,950,000|Bajo el promedio|
|2,026|8|Electrodomésticos|3,460,000|1|80,410,000|Exitoso|
|2,026|8|Audio|870,000|2|17,820,000|Exitoso|
|2,026|8|Hogar|500,000|3|12,930,000|Bajo el promedio|
|2,026|8|Cocina|260,000|4|34,840,000|Bajo el promedio|
|2,026|8|Iluminación|165,000|5|6,735,000|Bajo el promedio|

</details>

</div>

## 🔗 Recursos

**Repositorio:** [Coderhouse-SQL](https://github.com/davidcarusso/Coderhouse-SQL)

> 📌 **Tecnología:** PostgreSQL  
> 🗄️ **Base de datos:** Neon  
> 📂 **Schema:** `entregable_05`