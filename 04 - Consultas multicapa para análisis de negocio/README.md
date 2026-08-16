
# Pre-entrega: Consultas multicapa para análisis de negocio

**Objetivo** Extraer inteligencia de negocio combinando múltiples tablas mediante: 
	JOINs, GROUP BY y HAVING.

**Qué entregar** Un archivo `.sql` con 3 consultas, cada una comentada explicando qué problema de negocio resuelve.

### **Las 3 consultas requeridas**

1. **Rentabilidad por categoría:** unir `ventas`, `productos` y `categorias`; mostrar nombre de categoría, unidades vendidas e ingreso total; filtrar por categorías que superen un umbral de ventas que vos definas.
2. **Clientes sin compras:** usando `LEFT JOIN` o subconsulta, identificar clientes registrados que aún no realizaron ninguna compra.
3. **Top de compras por cliente:** unir `clientes`, `ventas` y `productos`; mostrar nombre del cliente, producto que más veces compró y fecha de su última transacción.

### **Criterios de aceptación**

- Al menos una consulta une 3 o más tablas.
- Todas las consultas usan alias de tabla (ej. `v` para `ventas`, `c` para `clientes`).
- `GROUP BY` presente en toda consulta que use funciones de agregación (`SUM`, `COUNT`, `AVG`).
- Condiciones sobre resultados agregados van en `HAVING`, no en `WHERE`.
- Cada bloque tiene un comentario explicando el problema de negocio que resuelve.
- Los `LEFT JOIN` manejan nulos con `COALESCE` (ej. mostrar `0` en lugar de `NULL`).

**Qué evitar**

- Columnas ambiguas: si `clientes` y `productos` tienen ambas una columna `nombre`, siempre usar `c.nombre` / `p.nombre`.
- Funciones de agregación en `WHERE`: filtrar por resultados de `SUM` o `COUNT` va en `HAVING`; en `WHERE` genera error.

Un repositorio que contenga las consultas multicapa comentadas para resolver los 3 desafíos de negocio planteados.

Entregable

1. Abre tu herramienta de gestión de base de datos (pgAdmin o DBeaver).
2. Asegúrate de tener las tablas del módulo anterior cargadas con datos.
3. Crea un nuevo script SQL llamado `pre-entrega-modulo4.sql`.
4. Desarrolla la consulta de 'Rentabilidad por Categoría' uniendo las tablas ventas, productos y categorias. Aplica filtros con HAVING.
5. Desarrolla la consulta de 'Clientes Escurridizos' usando LEFT JOIN para hallar registros sin coincidencias en ventas.
6. Desarrolla el 'Top Ranking' uniendo clientes y ventas.
7. Comenta cada consulta explicando la lógica aplicada.
8. Sube tu script a tu repositorio del curso para revisión.
 
---

> [!Question]
> Desarrolla la consulta de 'Rentabilidad por Categoría' uniendo las tablas ventas, productos y categorias. Aplica filtros con HAVING.

```sql
SELECT

	p.categoria AS categoria_producto
	, sum(COALESCE (v.cantidad, 0) * COALESCE (p.precio , 0)) AS ingreso_total
FROM entregable_04.ventas AS v
	LEFT JOIN entregable_04.clientes AS c ON v.id_cliente = c.id_cliente
	LEFT JOIN entregable_04.productos AS p ON v.id_producto = p.id_producto
GROUP BY p.categoria
HAVING sum(COALESCE (v.cantidad, 0) * COALESCE (p.precio , 0)) > 7000
;
```

- Output: 

| categoria_producto       | ingreso_total |
| ------------------------ | ------------- |
| Periféricos y Accesorios | 8,566.6       |

---

> [!Question]
> Desarrolla la consulta de 'Clientes Escurridizos' usando LEFT JOIN para hallar registros sin coincidencias en ventas.

Desde la tabla de clientes, unimos con un LEFT JOIN Clientes y Ventas, ponderando la tabla clientes. Con esto nos permitiría visualizar si algún cliente no tiene venta (id_venta) ya que figuraría NULL

```sql
SELECT
	c.nombre_completo AS cliente
	, v.id_producto AS compra
FROM entregable_04.clientes AS c
	LEFT JOIN entregable_04.ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_ventas IS NULL
;
```

- Output: 

| cliente          | compra |
| ---------------- | ------ |
| Camila Torres    | [NULL] |
| Diego Ferreyra   | [NULL] |
| Federico Navarro | [NULL] |
| Julieta Molina   | [NULL] |
| Martín Cabrera   | [NULL] |


---

> [!Question]
> Desarrolla el 'Top Ranking' uniendo clientes y ventas.

Creamos una query para crean un ranking con los 10 clientes donde mas compran y menos compras realicen.
Con eso podemos identificar a los promotores y mejorar la imagen de los detractores o con poco interes.

```sql
SELECT
	c.nombre_completo AS nombre_cliente
	, c.email AS email
	, sum(COALESCE (p.precio , 0) * COALESCE (v.cantidad, 0)) AS Gasto_total
FROM entregable_04.ventas AS v
	LEFT JOIN entregable_04.clientes AS c ON v.id_cliente = c.id_cliente
	LEFT JOIN entregable_04.productos AS p ON v.id_producto = p.id_producto
GROUP BY c.nombre_completo, c.email
ORDER BY gasto_total DESC
LIMIT 10
;
```

- Output: 

|nombre_cliente|email|gasto_total|
|---|---|---|
|Mariana Lozano|mariana.lozano@example.com|1,591.75|
|Milagros Ponce|milagros.ponce@example.com|1,549.93|
|Carolina Navarro|carolina.navarro@example.com|1,249.92|
|Martín Torres|martin.torres@example.com|1,194.9|
|Valentina Ruiz|valentina.ruiz@example.com|974.92|
|Andrés Medina|andres.medina@example.com|918.92|
|Emilia Sosa|emilia.sosa@example.com|831.78|
|Leandro Correa|leandro.correa@example.com|819.78|
|Gabriel Herrera|gabriel.herrera@example.com|779.76|
|Lucía Álvarez|lucia.alvarez@example.com|659.93|


## Tablas: 

![Relación de las tablas](./images/neondb%20-%20neondb%20-%20entregable_04.png)



## 🔗 Recursos

**Repositorio:** [Coderhouse-SQL](https://github.com/davidcarusso/Coderhouse-SQL)

**Trabajo Práctico 04:** [Limpieza de Datos de Inventario](https://github.com/davidcarusso/Coderhouse-SQL/tree/master/04%20-%20Consultas%20multicapa%20para%20an%C3%A1lisis%20de%20negocio)

> 📌 **Tecnología:** PostgreSQL  
> 🗄️ **Base de datos:** Neon  
> 📂 **Schema:** `entregable_04`