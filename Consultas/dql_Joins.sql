-- JOINS Basicos --

-- 1. Obtener los nombres completos de los campers junto con el nombre de la ruta a la que están inscritos.
-- 2. Mostrar los campers con sus evaluaciones (nota teórica, práctica, quizzes y nota final) por cada módulo.
-- 3. Listar todos los módulos que componen cada ruta de entrenamiento.
-- 4. Consultar las rutas con sus trainers asignados y las áreas en las que imparten clases.
-- 5. Mostrar los campers junto con el trainer responsable de su ruta actual.
-- 6. Obtener el listado de evaluaciones realizadas con nombre de camper, módulo y ruta.
-- 7. Listar los trainers y los horarios en que están asignados a las áreas de entrenamiento.
-- 8. Consultar todos los campers junto con su estado actual y el nivel de riesgo.
-- 9. Obtener todos los módulos de cada ruta junto con su porcentaje teórico, práctico y de quizzes.
-- 10. Mostrar los nombres de las áreas junto con los nombres de los campers que están asistiendo en esos espacios.

-- Joins Condiciones Especificas --

-- 1. Listar los campers que han aprobado todos los módulos de su ruta (nota_final >= 60).
-- 2. Mostrar las rutas que tienen más de 10 campers inscritos actualmente.
-- 3. Consultar las áreas que superan el 80% de su capacidad con el número actual de campers asignados.
-- 4. Obtener los trainers que imparten más de una ruta diferente.
-- 5. Listar las evaluaciones donde la nota práctica es mayor que la nota teórica.
-- 6. Mostrar campers que están en rutas cuyo SGDB principal es MySQL.
-- 7. Obtener los nombres de los módulos donde los campers han tenido bajo rendimiento.
-- 8. Consultar las rutas con más de 3 módulos asociados.
-- 9. Listar las inscripciones realizadas en los últimos 30 días con sus respectivos campers y rutas.
-- 10. Obtener los trainers que están asignados a rutas con campers en estado de “Alto Riesgo”

-- Joins Funciones de Agregacion -- 

-- 1. Obtener el promedio de nota final por módulo.
-- 2. Calcular la cantidad total de campers por ruta.
-- 3. Mostrar la cantidad de evaluaciones realizadas por cada trainer (según las rutas que imparte).
-- 4. Consultar el promedio general de rendimiento por cada área de entrenamiento.
-- 5. Obtener la cantidad de módulos asociados a cada ruta de entrenamiento.
-- 6. Mostrar el promedio de nota final de los campers en estado “Cursando”.
-- 7. Listar el número de campers evaluados en cada módulo.
-- 8. Consultar el porcentaje de ocupación actual por cada área de entrenamiento.
-- 9. Mostrar cuántos trainers tiene asignados cada área.
-- 10. Listar las rutas que tienen más campers en riesgo alto.