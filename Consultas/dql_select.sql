-- Campers --

--1. Obtener todos los campers inscritos actualmente.
SELECT nombre,apellido FROM campers
INNER JOIN estadoCamper ON campers.idEstadoCamper = estadoCamper.id 
WHERE estadoCamper.tipoEstado = 'inscrito';

--2. Listar los campers con estado "Aprobado".
SELECT nombre,apellido FROM campers
INNER JOIN estadoCamper ON campers.idEstadoCamper = estadoCamper.id 
WHERE estadoCamper.tipoEstado = 'Aprobado';

--3. Mostrar los campers que ya están cursando alguna ruta.
SELECT nombre,apellido FROM campers
INNER JOIN estadoCamper ON campers.idEstadoCamper = estadoCamper.id 
WHERE estadoCamper.tipoEstado = 'Cursando';

--4. Consultar los campers graduados por cada ruta.

--5. Obtener los campers que se encuentran en estado "Expulsado" o "Retirado".
--6. Listar campers con nivel de riesgo “Alto”.
SELECT nombre,apellido FROM campers
INNER JOIN nivelRiesgo ON campers.idNivelRiesgo = nivelRiesgo.id
WHERE nivelRiesgo.tipoNivel = 'Alto';

--7. Mostrar el total de campers por cada nivel de riesgo.
--8. Obtener campers con más de un número telefónico registrado.
--9. Listar los campers y sus respectivos acudientes y teléfonos.
--10. Mostrar campers que aún no han sido asignados a una ruta.

-- Evaluaciones --

--1. Obtener las notas teóricas, prácticas y quizzes de cada camper por módulo.
--2. Calcular la nota final de cada camper por módulo.
--3. Mostrar los campers que reprobaron algún módulo (nota < 60).
--4. Listar los módulos con más campers en bajo rendimiento.
--5. Obtener el promedio de notas finales por cada módulo.
--6. Consultar el rendimiento general por ruta de entrenamiento.
--7. Mostrar los trainers responsables de campers con bajo rendimiento.
--8. Comparar el promedio de rendimiento por trainer.
--9. Listar los mejores 5 campers por nota final en cada ruta.
--10. Mostrar cuántos campers pasaron cada módulo por ruta.

-- Rutas y Areas de Entrenamiento --

-- 1. Mostrar todas las rutas de entrenamiento disponibles.
-- 2. Obtener las rutas con su SGDB principal y alternativo.
-- 3. Listar los módulos asociados a cada ruta.
-- 4. Consultar cuántos campers hay en cada ruta.
-- 5. Mostrar las áreas de entrenamiento y su capacidad máxima.
-- 6. Obtener las áreas que están ocupadas al 100%.
-- 7. Verificar la ocupación actual de cada área.
-- 8. Consultar los horarios disponibles por cada área.
-- 9. Mostrar las áreas con más campers asignados.
-- 10. Listar las rutas con sus respectivos trainers y áreas asignadas.

-- Trainers --

-- 1. Listar todos los entrenadores registrados.
-- 2. Mostrar los trainers con sus horarios asignados.
-- 3. Consultar los trainers asignados a más de una ruta.
-- 4. Obtener el número de campers por trainer.
-- 5. Mostrar las áreas en las que trabaja cada trainer.
-- 6. Listar los trainers sin asignación de área o ruta.
-- 7. Mostrar cuántos módulos están a cargo de cada trainer.
-- 8. Obtener el trainer con mejor rendimiento promedio de campers.
-- 9. Consultar los horarios ocupados por cada trainer.
-- 10. Mostrar la disponibilidad semanal de cada trainer.


--  Subconsultas y Cálculos Avanzados --

-- 1. Obtener los campers con la nota más alta en cada módulo.
-- 2. Mostrar el promedio general de notas por ruta y comparar con el promedio global.
-- 3. Listar las áreas con más del 80% de ocupación.
-- 4. Mostrar los trainers con menos del 70% de rendimiento promedio.
-- 5. Consultar los campers cuyo promedio está por debajo del promedio general.
-- 6. Obtener los módulos con la menor tasa de aprobación.
-- 7. Listar los campers que han aprobado todos los módulos de su ruta.
-- 8. Mostrar rutas con más de 10 campers en bajo rendimiento.
-- 9. Calcular el promedio de rendimiento por SGDB principal.
-- 10. Listar los módulos con al menos un 30% de campers reprobados.
-- 11. Mostrar el módulo más cursado por campers con riesgo alto.
-- 12. Consultar los trainers con más de 3 rutas asignadas.
-- 13. Listar los horarios más ocupados por áreas.
-- 14. Consultar las rutas con el mayor número de módulos.
-- 15. Obtener los campers que han cambiado de estado más de una vez.
-- 16. Mostrar las evaluaciones donde la nota teórica sea mayor a la práctica.
-- 17. Listar los módulos donde la media de quizzes supera el 9.
-- 18. Consultar la ruta con mayor tasa de graduación.
-- 19. Mostrar los módulos cursados por campers de nivel de riesgo medio o alto.
-- 20. Obtener la diferencia entre capacidad y ocupación en cada área.