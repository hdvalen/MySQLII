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
SELECT campers.nombre,apellido FROM campers 
INNER JOIN estadoCamper ON campers.idEstadoCamper = estadoCamper.id 
WHERE estadoCamper.tipoEstado = 'Cursando';
--4. Consultar los campers graduados por cada ruta.
SELECT c.nombre, c.apellido,rt.nombreRuta FROM campers c
INNER JOIN estadoCamper ec ON c.idEstadoCamper = ec.id
INNER JOIN rutaAprendizaje rt ON c.idRutaAprendizaje = rt.id
 WHERE ec.tipoEstado='Graduado';
--5. Obtener los campers que se encuentran en estado "Expulsado" o "Retirado".
SELECT campers.nombre,apellido FROM campers 
INNER JOIN estadoCamper ON campers.idEstadoCamper = estadoCamper.id 
WHERE estadoCamper.tipoEstado = 'Expulsado' OR estadoCamper.tipoEstado ='Retirado';
--6. Listar campers con nivel de riesgo “Alto”.
SELECT c.nombre,c.apellido FROM campers c
INNER JOIN nivelRiesgo ON c.idNivelRiesgo = nivelRiesgo.id
WHERE nivelRiesgo.tipoNivel = 'Alto';
--7. Mostrar el total de campers por cada nivel de riesgo.
SELECT  n.tipoNivel, COUNT(c.id) FROM campers c
INNER JOIN nivelRiesgo n ON c.idNivelRiesgo = n.id
GROUP BY n.tipoNivel;
--8. Obtener campers con más de un número telefónico registrado.
SELECT c.nombre, c.apellido, COUNT(t.telefono) FROM campers c
INNER JOIN telefono t ON c.id= t.idCamper
GROUP BY c.nombre, c.apellido
HAVING COUNT (t.telefono)>1;
--9. Listar los campers y sus respectivos acudientes y teléfonos.
SELECT c.nombre, c.apellido,a.nombre, t.telefono FROM campers c
INNER JOIN acudiente a ON c.idAcudiente = a.id
INNER JOIN telefono t ON c.id = t.idCamper;
--10. Mostrar campers que aún no han sido asignados a una ruta.
SELECT c.nombre, c.apellido,c.identificacion FROM campers c
WHERE c.idRutaAprendizaje IS NULL;

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

-- Rutas y Areas de Entrenamiento ---

-- 1. Mostrar todas las rutas de entrenamiento disponibles.
SELECT  ra.nombreRuta, emr.estado FROM rutaAprendizaje ra
INNER JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
INNER JOIN estadoModuloR emr ON mr.idEstadoModuloR = emr.id
WHERE emr.estado = 'Disponible';
-- 2. Obtener las rutas con su SGDB principal y alternativo.
SELECT ra.nombreRuta, sr.idSGDB, sr.idSGDBA FROM rutaAprendizaje ra 
INNER JOIN sRuta sr ON ra.id= sr.idRutaAprendizaje
INNER JOIN sgdb sg ON sr.idSGDB = sg.id
INNER JOIN sgdb sga ON sr.idSGDBA = sg.id;
-- 3. Listar los módulos asociados a cada ruta.
SELECT ra.nombreRuta, m.nombreModulo FROM rutaAprendizaje ra
INNER JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
INNER JOIN modulos m ON mr.idModulo = m.id;
-- 4. Consultar cuántos campers hay en cada ruta.
SELECT ra.nombreRuta, COUNT(c.id) FROM rutaAprendizaje ra
INNER JOIN campers c ON ra.id = c.idRutaAprendizaje
GROUP BY ra.nombreRuta;
-- 5. Mostrar las áreas de entrenamiento y su capacidad máxima.
SELECT ns.nombreSalon, ns.capacidad FROM salon ns;
-- 6. Obtener las áreas que están ocupadas al 100%.
SELECT s.nombreSalon, es.nombreEstado FROM salon s
INNER JOIN estadoSalon es ON s.idEstadoSalon = es.id
WHERE es.nombreEstado = 'Ocupado'; 
-- 7. Verificar la ocupación actual de cada área.
SELECT s.nombreSalon, es.nombreEstado FROM salon s
INNER JOIN estadoSalon es ON s.idEstadoSalon = es.id
WHERE es.nombreEstado = 'Ocupado' OR es.nombreEstado = 'No disponible'; 
-- 8. Consultar los horarios disponibles por cada área.
-- 9. Mostrar las áreas con más campers asignados.
-- 10. Listar las rutas con sus respectivos trainers y áreas asignadas.
SELECT ra.nombreRuta, t.nombre, sl.nombreSalon FROM rutaAprendizaje ra 
INNER JOIN campers c ON ra.id = c.idRutaAprendizaje
INNER JOIN sedes s ON c.idSede = s.id 
INNER JOIN trainers t ON s.id = t.idSede
INNER JOIN trainerHorario th ON t.id= th.idTrainer
INNER JOIN salon sl ON th.idSalon = sl.id;

-- Trainers --

-- 1. Listar todos los entrenadores registrados.
SELECT nombre,apellido FROM trainers;
-- 2. Mostrar los trainers con sus horarios asignados.
SELECT t.nombre,t.apellido, h.franjaHoraria FROM trainers t
INNER JOIN trainerHorario th ON t.id= th.idTrainer
INNER JOIN horario h ON th.idHorario = h.id;
-- 3. Consultar los trainers asignados a más de una ruta.
SELECT t.nombre, t.apellido, COUNT(g.idRutaAprendizaje) FROM trainers t
INNER JOIN grupo g ON t.id = g.idTrainer
GROUP BY t.nombre, t.apellido
HAVING COUNT (g.idRutaAprendizaje)>1;
-- 4. Obtener el número de campers por trainer.
SELECT t.nombre, t.apellido, COUNT(c.id) FROM trainers t
INNER JOIN grupo g ON t.id = g.idTrainer
INNER JOIN sedes s ON t.idSede=s.id
INNER JOIN campers c ON s.id = c.idSede
GROUP BY t.nombre, t.apellido;
-- 5. Mostrar las áreas en las que trabaja cada trainer.
SELECT t.nombre,t.apellido,s.nombreSalon FROM trainers t
INNER JOIN trainerHorario th ON t.id= th.idTrainer
INNER JOIN salon s ON th.idSalon = s.id;
-- 6. Listar los trainers sin asignación de área o ruta.
-- 7. Mostrar cuántos módulos están a cargo de cada trainer.
SELECT t.nombre, t.apellido,m.nombreModulo FROM trainers t
INNER JOIN grupo g ON t.id = g.idTrainer
INNER JOIN rutaAprendizaje ra ON g.idRutaAprendizaje = ra.id
INNER JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
INNER JOIN modulos m ON mr.idModulo= m.id;
-- 8. Obtener el trainer con mejor rendimiento promedio de campers.
-- 9. Consultar los horarios ocupados por cada trainer.
SELECT t.nombre, t.apellido, h.franjaHoraria FROM trainers t
INNER JOIN trainerHorario th ON t.id= th.idTrainer
INNER JOIN horario h ON th.idHorario = h.id;
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