# Coderhouse SQL — Portfolio de entregables

Repositorio que reúne los trabajos prácticos y pre-entregas desarrollados durante el curso de **SQL de Coderhouse**.

El proyecto muestra una progresión desde la creación y modelado de estructuras relacionales hasta consultas orientadas al análisis de datos, incorporando progresivamente herramientas de SQL como `JOIN`, agregaciones, CTEs y **Window Functions**.

> **Objetivo:** documentar el proceso de aprendizaje y demostrar la aplicación práctica de SQL sobre distintos escenarios de análisis.

---

## 🧰 Tecnologías y herramientas

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge\&logo=postgresql\&logoColor=white)
![DBeaver](https://img.shields.io/badge/DBeaver-382923?style=for-the-badge\&logo=dbeaver\&logoColor=white)
![Neon](https://img.shields.io/badge/Neon-00E599?style=for-the-badge\&logo=neon\&logoColor=black)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge\&logo=git\&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge\&logo=github\&logoColor=white)

* **PostgreSQL** — motor de base de datos.
* **DBeaver** — entorno principal de desarrollo y ejecución de consultas.
* **Neon** — entorno PostgreSQL utilizado para trabajar con las bases de datos.
* **Git / GitHub** — control de versiones y documentación del proyecto.

---

## 📂 Estructura del repositorio

Cada entrega se encuentra organizada en su propia carpeta y cuenta con los scripts y documentación correspondientes.

```text
Coderhouse-SQL/
│
├── README.md
│
├── 02 - Tablas principales con restricciones y datos iniciales/
│   └── pre-entrega-modulo2.sql
│
├── 03 - Limpieza de Datos de Inventario/
│   ├── pre-entrega-modulo3.sql
│   └── README.md
│
├── 04 - Consultas multicapa para análisis de negocio/
│   ├── Carga de datos en tablas para entrega-04.sql
│   ├── pre-entrega-modulo4.sql
│   ├── README.md
│   └── images/
│       └── neondb - neondb - entregable_04.png
│
└── 05 - Window Functions/
    ├── 01 - Entregable 05 - Creación de tablas.sql
    ├── 02 - Entregable 05 - Carga de datos.sql
    ├── 03 - Entregable 05 - Solucion con date_trunc().sql
    ├── preentrega_analisis_avanzado.sql
    ├── README.md
    └── images/
        └── entregable_05_relaciones_tablas.png
```

---

## 📚 Entregas

| Entrega | Tema                                                                                                                                    | Principales conceptos                                                                                          |
| ------- | --------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| **02**  | [Tablas principales con restricciones y datos iniciales](./02%20-%20Tablas%20principales%20con%20restricciones%20y%20datos%20iniciales) | Modelado relacional, `PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `NOT NULL`, `UNIQUE`, `INSERT`, `UPDATE`, `DELETE` |
| **03**  | [Limpieza de Datos de Inventario](./03%20-%20Limpieza%20de%20Datos%20de%20Inventario)                                                   | Limpieza de datos, `NULL`, `COALESCE`, normalización de valores y categorías                                   |
| **04**  | [Consultas multicapa para análisis de negocio](./04%20-%20Consultas%20multicapa%20para%20análisis%20de%20negocio)                       | `JOIN`, `GROUP BY`, `HAVING`, subconsultas y análisis de clientes y ventas                                     |
| **05**  | [Window Functions](./05%20-%20Window%20Functions)                                                                                       | CTEs, `RANK`, `DENSE_RANK`, `ROW_NUMBER`, `SUM() OVER`, acumulados y comparación contra promedios              |

---

## 📈 Evolución del aprendizaje

Las entregas siguen una progresión de complejidad:

**Modelado → Limpieza → Análisis → Análisis avanzado**

### 🗃️ Modelado relacional

Creación de estructuras de base de datos y aplicación de restricciones para mantener la integridad de los datos.

Se trabajan conceptos como:

* Claves primarias y foráneas.
* Restricciones `NOT NULL`, `UNIQUE` y `CHECK`.
* Relaciones entre tablas.
* Carga y modificación de datos.

### 🧹 Limpieza de datos

Aplicación de técnicas básicas de **data cleaning** directamente mediante SQL.

Entre otros conceptos:

* Tratamiento de valores `NULL`.
* `COALESCE`.
* Normalización de precios.
* Tratamiento de categorías faltantes.

### 🔎 Consultas para análisis de negocio

Construcción de consultas orientadas a responder preguntas de negocio a partir de múltiples tablas.

Algunos ejemplos:

* Rentabilidad por categoría.
* Clientes sin compras.
* Ranking de compras por cliente.
* Agregaciones y filtros sobre resultados agrupados.

### 📊 Análisis avanzado con Window Functions

La última entrega incorpora funciones de ventana para realizar análisis sobre el conjunto de datos sin perder el nivel de detalle de cada registro.

Se utilizan:

* `ROW_NUMBER()`
* `RANK()`
* `DENSE_RANK()`
* `SUM() OVER()`
* `AVG() OVER()`
* `PARTITION BY`
* `ORDER BY`
* CTEs encadenadas.

Entre los análisis realizados se encuentran rankings, acumulados y comparaciones de resultados contra valores históricos.

---

## 🗂️ Organización de cada entrega

Cada entrega busca mantener una estructura independiente para que pueda ser ejecutada y revisada de forma individual.

La documentación de cada trabajo incluye, según corresponda:

1. Enunciado del ejercicio.
2. Objetivo del análisis.
3. Modelo o estructura de datos.
4. Scripts SQL.
5. Consultas desarrolladas.
6. Explicación de los principales conceptos utilizados.
7. Resultados o conclusiones.

Los scripts están organizados para permitir reconstruir el entorno de cada entrega desde cero.

---

## 🚀 Cómo reproducir el proyecto

No se proporciona acceso a una base de datos compartida.

Cada entrega contiene sus propios scripts para crear las estructuras y cargar los datos necesarios.

### 1. Crear un entorno PostgreSQL

Podés utilizar:

* PostgreSQL local.
* Docker.
* Neon.
* Otro servicio compatible con PostgreSQL.

### 2. Clonar el repositorio

```bash
git clone https://github.com/davidcarusso/Coderhouse-SQL.git
cd Coderhouse-SQL
```

### 3. Elegir una entrega

Ingresá a la carpeta correspondiente al trabajo que quieras reproducir.

### 4. Ejecutar los scripts

Ejecutá los archivos `.sql` respetando el orden indicado dentro de cada entrega.

En general, el flujo es:

```text
SCHEMA
   ↓
TABLAS
   ↓
DATOS
   ↓
CONSULTAS
   ↓
ANÁLISIS
```

Cada entrega utiliza su propio `SCHEMA` (`entregable_03`, `entregable_04`, `entregable_05`, etc.) para mantener los ejercicios separados.

---

## 🧠 Principales conceptos trabajados

```text
SQL
├── DDL
│   ├── CREATE
│   ├── ALTER
│   └── DROP
│
├── DML
│   ├── INSERT
│   ├── UPDATE
│   └── DELETE
│
├── Consultas
│   ├── SELECT
│   ├── WHERE
│   ├── GROUP BY
│   ├── HAVING
│   └── ORDER BY
│
├── Relaciones
│   ├── JOIN
│   ├── LEFT JOIN
│   └── FOREIGN KEY
│
├── Limpieza
│   ├── NULL
│   ├── COALESCE
│   └── CAST
│
├── Consultas avanzadas
│   ├── CTE
│   ├── Subconsultas
│   └── Window Functions
│
└── Análisis
    ├── RANK
    ├── DENSE_RANK
    ├── ROW_NUMBER
    ├── SUM() OVER
    └── AVG() OVER
```

---

## 🔮 Próximas entregas

Este repositorio continuará creciendo a medida que avance el curso.

La estructura está pensada para incorporar nuevos trabajos manteniendo una organización consistente entre:

* Scripts SQL.
* Documentación.
* Modelos de datos.
* Imágenes y evidencias.
* Análisis y resultados.

---

## 🔗 Repositorio

**GitHub:** [Coderhouse-SQL](https://github.com/davidcarusso/Coderhouse-SQL)

---

## 👤 Autor

**David Carusso**

Proyecto desarrollado como parte del curso de **SQL de Coderhouse**, con foco en el aprendizaje práctico de PostgreSQL y el desarrollo de consultas orientadas al análisis de datos.

---

## 📄 Licencia

Proyecto desarrollado con fines educativos y de portfolio.
