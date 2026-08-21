	
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
	--, CAST(EXTRACT(MONTH FROM fecha)  + EXTRACT(YEAR FROM fecha) * 100 AS VARCHAR) AS periodo_var --castear con CAST
	, (EXTRACT(YEAR FROM fecha):: INT * 100 + EXTRACT(MONTH FROM fecha):: INT) AS periodo
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
--
,	sum(cantidad::INT * precio) AS ventas
FROM datos_agrupados
GROUP BY año, mes, categoria
ORDER BY año, mes, ventas
), consulta_final AS 
(
SELECT 
	* 
,	DENSE_RANK() OVER(PARTITION BY año, mes ORDER BY ventas DESC) AS ranking_categorias
, 	SUM(ventas) OVER(PARTITION BY categoria ORDER BY año, mes) AS sum_acumulado_categoria
--,	round(AVG(ventas) OVER(PARTITION BY categoria),2) AS promedio_categoria
, 	CASE 
		WHEN ventas > AVG(ventas) OVER(PARTITION BY categoria)  THEN 'Exitoso'
		ELSE 'Bajo el promedio'
	END AS venta_mensual_contra_promedio
FROM ventas_mensuales
ORDER BY 1, 2, ventas DESC
)
SELECT 
	*
FROM consulta_final
;
