	
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
-- algunas columnas quedan sin usar ya que se esta probando las funciones. 
	fecha
	, EXTRACT (HOUR FROM fecha) AS hora
	, CASE 
		WHEN EXTRACT (HOUR FROM fecha) < 12 THEN 'Mañana'
		WHEN EXTRACT (HOUR FROM fecha) BETWEEN 12 AND 18 THEN 'Tarde'
		ELSE 'Noche'
	  END AS turno
	, EXTRACT(YEAR FROM datos.fecha) AS "año"
	, EXTRACT(MONTH FROM fecha) AS mes
	--, CAST(EXTRACT(MONTH FROM fecha)  + EXTRACT(YEAR FROM fecha) * 100 AS VARCHAR) AS periodo_var --castear con CAST
	--, (EXTRACT(YEAR FROM fecha):: INT * 100 + EXTRACT(MONTH FROM fecha):: INT) AS periodo
	, TO_CHAR(fecha , 'YYYYMM') AS periodo
	, nombre_producto	AS producto
	, nombre_categoria	AS categoria
	, cantidad 
	, precio_producto AS precio
FROM datos 
), ventas_mensuales AS 
(
SELECT 
	año
,	mes
,	categoria
, 	periodo
--
,	sum(cantidad::INT * precio) AS ventas
FROM datos_agrupados
GROUP BY año, mes, categoria, periodo
ORDER BY año, mes, ventas
), consulta_final AS 
(
SELECT 
	* 
,	DENSE_RANK() OVER(PARTITION BY año, mes ORDER BY ventas DESC) AS ranking_categorias
, 	SUM(ventas) OVER(PARTITION BY categoria ORDER BY año, mes) AS sum_acumulado_categoria
--,	round(AVG(ventas) OVER(PARTITION BY categoria),2) AS promedio_categoria
--- se inserto emoticones para probarlos. 
, 	CASE 
		WHEN ventas > AVG(ventas) OVER(PARTITION BY categoria)  THEN '🌞 Exitoso 🌞'
		ELSE '🆘 Bajo el promedio 🆘'
	END AS venta_mensual_contra_promedio
FROM ventas_mensuales
ORDER BY 1, 2, ventas DESC
)
SELECT
--- Le di otro formato a las monedas para probarlas. 
	periodo
,	categoria
,	ventas :: MONEY
,	ranking_categorias
,	sum_acumulado_categoria :: MONEY
,	venta_mensual_contra_promedio
FROM consulta_final
ORDER BY año , mes
;
