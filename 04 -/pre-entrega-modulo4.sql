
-- Datos unidos -- 

SELECT 
 	c.nombre_completo 						AS nombre_cliente
,	c.email 								AS email_cliente
, 	p.nombre_producto 						AS nombre_producto
, 	p.categoria 							AS categoria_producto
,	COALESCE (v.cantidad, 0) 				AS cantidad_venta
, 	COALESCE (p.precio , 0) 				AS precio_producto
FROM entregable_04.ventas AS v
LEFT JOIN entregable_04.clientes AS c 		ON v.id_cliente = c.id_cliente  
LEFT JOIN 	entregable_04.productos AS p	ON v.id_producto = p.id_producto 
;	



/* 4. Desarrolla la consulta de 'Rentabilidad por Categoría' uniendo las tablas ventas, productos y categorias. Aplica filtros con HAVING. */

-- rentabilidad <> Ingreso Total = precio * cantidad (datos disponible) 
-- para sacar rentabilidad seria necesario el costo

SELECT 
 	p.categoria 							AS categoria_producto
, 	sum(COALESCE (v.cantidad, 0) * COALESCE (p.precio , 0)) AS ingreso_total
FROM entregable_04.ventas AS v
LEFT JOIN entregable_04.clientes AS c 		ON v.id_cliente = c.id_cliente  
LEFT JOIN 	entregable_04.productos AS p	ON v.id_producto = p.id_producto 
GROUP BY p.categoria
HAVING sum(COALESCE (v.cantidad, 0) * COALESCE (p.precio , 0)) > 7000
;


/*Desarrolla la consulta de 'Clientes Escurridizos' usando LEFT JOIN para hallar registros sin coincidencias en ventas.*/

/* Desde la tabla de clientes, unimos con un LEFT JOIN Clientes y Ventas, ponderando la tabla clientes. 
 * Con esto nos permitiria visualizar si algun cliente no tiene venta (id_venta) ya que figuraria NULL */

SELECT 
	c.nombre_completo  AS cliente 
, 	v.id_producto  AS compra
FROM entregable_04.clientes AS c 
LEFT JOIN entregable_04.ventas AS v		ON c.id_cliente = v.id_cliente  
WHERE v.id_ventas  IS NULL 
;



/*Desarrolla el 'Top Ranking' uniendo clientes y ventas.*/

-- Creamos una query para crean un ranking con los 10 clientes donde mas compran y menos compras realicen.
-- Con eso podemos fomentar a los promotores y mejorar la imagne de los detractores o con poco interes. 

SELECT 
 	c.nombre_completo 						AS nombre_cliente
, 	c.email 								AS email
, 	sum(COALESCE (p.precio , 0) * COALESCE (v.cantidad, 0)) AS Gasto_total
FROM entregable_04.ventas AS v
LEFT JOIN entregable_04.clientes AS c 		ON v.id_cliente = c.id_cliente  
LEFT JOIN 	entregable_04.productos AS p	ON v.id_producto = p.id_producto 
GROUP BY  c.nombre_completo, c.email 
ORDER BY gasto_total DESC 				-- top 10 mas gasto
--ORDER BY gasto_total DESC				-- top 10 menos gasto
LIMIT 10
;

