# Coderhouse SQL — Portfolio de entregables

Repositorio con los ejercicios y pre-entregas del curso de SQL de Coderhouse. Cada módulo agrega una capa nueva: modelado relacional, limpieza de datos, consultas multicapa para análisis de negocio y, finalmente, Window Functions sobre un dataset de ventas.

> 📌 **Tecnología:** PostgreSQL
> 🗄️ **Entorno de desarrollo:** [Neon](https://neon.tech) (Postgres serverless)
> 🧰 **Herramientas:** pgAdmin 4 / DBeaver

No se comparte acceso a una base de datos en vivo (ver sección [Cómo reproducirlo](#-cómo-reproducirlo-localmente)) — cada módulo trae sus propios scripts de creación y carga de datos para levantar el entorno desde cero.

## 📂 Estructura del repositorio

| Módulo | Tema | Contenido |
|---|---|---|
| [`02 - Tablas principales...`](./02%20-%20Tablas%20principales%20con%20restricciones%20y%20datos%20iniciales) | Modelado relacional | Creación de tablas con `PRIMARY KEY`, `FOREIGN KEY` y `CHECK`; carga inicial de datos; `UPDATE`/`DELETE` transaccionales. |
| [`03 - Limpieza de Datos de Inventario`](./03%20-%20Limpieza%20de%20Datos%20de%20Inventario) | Data cleaning | Manejo de valores `NULL` con `COALESCE`, normalización de precios y categorías faltantes. |
| [`04 - Consultas multicapa...`](./04%20-%20Consultas%20multicapa%20para%20análisis%20de%20negocio) | JOINs y agregaciones | Rentabilidad por categoría, clientes sin compras, top de compras por cliente. `JOIN`, `GROUP BY`, `HAVING`. |
| [`05 - Window Functions`](./05%20-%20Window%20Functions) | Análisis avanzado | CTEs encadenadas, `RANK`/`DENSE_RANK`, running totals con `SUM() OVER`, comparación contra promedio histórico. |

Cada carpeta tiene su propio `README.md` con el enunciado del ejercicio y la resolución comentada paso a paso.

## 🚀 Cómo reproducirlo localmente

1. Levantá una base PostgreSQL (Docker, instalación local, o gratis en [Neon](https://neon.tech)/[Supabase](https://supabase.com)).
2. Entrá a la carpeta del módulo que te interese y ejecutá los scripts en el orden en que aparecen (creación de schema → tablas → carga de datos → consultas).
3. Cada módulo usa su propio `SCHEMA` (`entregable_03`, `entregable_04`, `entregable_05`, etc.) para no pisar datos entre entregas.

## 🔗 Recursos

**Repositorio:** [Coderhouse-SQL](https://github.com/davidcarusso/Coderhouse-SQL)