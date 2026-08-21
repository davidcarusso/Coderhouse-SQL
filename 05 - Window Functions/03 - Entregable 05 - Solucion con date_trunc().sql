
WITH datos AS 
(
SELECT 
	* 
FROM entregable_05.venta AS v
	LEFT JOIN entregable_05.productos AS P USING (id_producto)
	LEFT JOIN entregable_05.categorias AS c USING (id_categoria)
), datos_agrupados AS 
(SELECT 
	fecha	--como viene
	, date_trunc('month', fecha) AS fecha_truncada 
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
ORDER BY fecha_truncada)
, consulta_final AS 
(
SELECT 
	TO_CHAR(fecha_truncada, 'YYYY-MM') AS periodo
,	categoria 
,	sum(cantidad * precio) AS venta
, 	rank() over(PARTITION BY fecha_truncada ORDER BY sum(cantidad * precio) DESC)
, 	sum(sum(cantidad * precio)) over(PARTITION BY categoria ORDER BY fecha_truncada)
FROM datos_agrupados
GROUP BY  fecha_truncada, categoria
ORDER BY fecha_truncada, 3 DESC
)
	SELECT * FROM consulta_final
;

/* 	Solucion con rank() y date_trunc
 * 	periodo		categoria		venta		rank	sum
	2023-01		Tecnología		2,100,000		1	2,100,000
	2023-01		Cocina			1,240,000		2	1,240,000
	2023-01		Audio			560,000			3	560,000
	2023-01		Iluminación		220,000			4	220,000
	2023-02		Cocina			1,300,000		1	2,540,000 
*/
