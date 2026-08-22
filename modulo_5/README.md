# Análisis de Ventas por Región

## Descripción

En este ejercicio se extiende el modelo desarrollado en el Módulo 4 para incorporar información geográfica de los clientes y realizar un análisis de ventas utilizando **CTEs (Common Table Expressions)**.

El objetivo es identificar qué regiones presentan un volumen de ventas superior al promedio global de ventas entre todas las regiones.

---

## Objetivos

* Incorporar regiones al modelo de datos.
* Relacionar cada cliente con una región.
* Generar datos de prueba asignando aleatoriamente una región a cada cliente.
* Utilizar `WITH` para construir consultas mediante CTEs.
* Calcular el total de ventas por región.
* Calcular el promedio global de ventas regionales.
* Filtrar las regiones que superan dicho promedio.
* Ordenar los resultados de mayor a menor venta.

---

## Estructura utilizada

Para realizar el análisis se utilizaron las siguientes tablas:

```text
ventas
   │
   ├── clientes
   │       │
   │       └── clientes_regiones
   │                  │
   │                  └── regiones
   │
   └── productos
```

La tabla `clientes_regiones` funciona como tabla intermedia para relacionar clientes con regiones.

---

## Generación de datos

Se creó la tabla `regiones` con seis regiones:

* Centro
* Cuyo
* Noreste (NEA)
* Noroeste (NOA)
* Pampeana
* Patagonia

Para generar datos de prueba, cada cliente recibe una región de manera aleatoria utilizando:

```sql
FLOOR(RANDOM() * 6) + 1
```

Esto permite generar un valor entero entre `1` y `6`, correspondiente a los identificadores de las regiones.

---

## Consulta analítica

La consulta utiliza varias CTEs para dividir el análisis en etapas:

### 1. `datos`

Se combinan las tablas necesarias para disponer de la información de ventas, productos, clientes y regiones en una misma consulta.

### 2. `ventas_por_region`

Se agrupan las ventas por región y se calcula el total mediante:

```sql
SUM(cantidad * precio)
```

### 3. `venta_global_promedio`

Se calcula el promedio de las ventas totales de todas las regiones:

```sql
AVG(venta)
```

### 4. `consulta_final`

Se filtran únicamente las regiones cuyo total de ventas es superior al promedio global.

Finalmente, los resultados se ordenan de mayor a menor mediante:

```sql
ORDER BY venta DESC
```

---

## Resultado

El análisis obtuvo los siguientes resultados:

| Región        |    Venta |
| ------------- | -------: |
| Pampeana      | 6,812.48 |
| Cuyo          | 4,522.75 |
| Noreste (NEA) | 3,954.60 |

De acuerdo con los datos generados, las regiones que presentan ventas superiores al promedio global son:

**Pampeana, Cuyo y Noreste (NEA).**

> Los resultados pueden variar si se vuelve a ejecutar la carga de datos, debido a que las regiones de los clientes se asignan aleatoriamente.

---

## Conceptos aplicados

* `WITH`
* CTEs
* `JOIN`
* `GROUP BY`
* `SUM()`
* `AVG()`
* Subconsultas
* `WHERE`
* `ORDER BY`
* `RANDOM()`
* `FLOOR()`
* Relaciones mediante claves foráneas

---

## Conclusión

El ejercicio permite transformar una consulta de análisis de ventas en una estructura más modular utilizando CTEs.

Cada etapa tiene una responsabilidad específica: primero se integran los datos, luego se calculan las ventas por región, posteriormente se obtiene el promedio y finalmente se filtran y ordenan los resultados.

Esto facilita la lectura, comprensión y mantenimiento de consultas analíticas más complejas.
