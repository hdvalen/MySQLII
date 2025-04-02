# Proyecto MySQL II

## 📌 Descripción del Proyecto

Este proyecto tiene como objetivo diseñar y desarrollar una base de datos que permita gestionar de manera eficiente todas las operaciones relacionadas con el seguimiento académico de los campers matriculados en el programa intensivo de programación de **CampusLands**.

La base de datos facilita la gestión de:

- ✅ Inscripción y seguimiento de campers
- ✅ Gestión de rutas de aprendizaje y módulos
- ✅ Evaluaciones y calificaciones
- ✅ Asignación de trainers y áreas de entrenamiento
- ✅ Seguimiento de progreso académico
- ✅ Generación de reportes de rendimiento

---

## 🛠 Requisitos del Sistema
Para ejecutar este proyecto, es necesario contar con el siguiente software:

- **MySQL** 
- **MySQL Workbench** *(opcional para visualización gráfica)*
- Un entorno de desarrollo compatible con SQL

---

## 🚀 Instalación y Configuración

Para configurar el entorno y ejecutar los scripts SQL, sigue estos pasos:

### 1️⃣ Crear la Base de Datos
Ejecutar el archivo **ddl.sql** para generar la estructura de la base de datos:
```sql
SOURCE ddl.sql;
```

### 2️⃣ Cargar Datos Iniciales
Ejecutar el archivo **dml.sql** para insertar registros de prueba:
```sql
SOURCE dml.sql;
```

### 3️⃣ Ejecutar Consultas SQL
Para realizar consultas predefinidas, ejecutar:
```sql
SOURCE dql_select.sql;
```

### 4️⃣ Ejecutar Procedimientos Almacenados
Para automatizar tareas esenciales:
```sql
SOURCE dql_procedimientos.sql;
```

### 5️⃣ Ejecutar Funciones SQL
Para realizar cálculos personalizados:
```sql
SOURCE dql_funciones.sql;
```

### 6️⃣ Ejecutar Triggers SQL
Para la gestión automática de eventos dentro de la base de datos:
```sql
SOURCE dql_triggers.sql;
```

### 7️⃣ Ejecutar Eventos SQL
Para programar tareas automáticas:
```sql
SOURCE dql_eventos.sql;
```

---


