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
SELECT c.id AS camper_id,c.nombre, c.apellido,m.id AS modulo_id,md.nombreModulo, te.tipo AS tipo_evaluacion, cal.calificacion
FROM campers c
JOIN matricula m ON c.id = m.idCamper
JOIN modulosRuta mr ON m.idModuloRuta = mr.id
JOIN modulos md ON mr.idModulo = md.id
JOIN evaluacion e ON mr.id = e.idModuloRuta
JOIN tipoEvaluacion te ON e.idTipoEvaluacion = te.id
JOIN calificaciones cal ON e.id = cal.idEvaluacion AND m.id = cal.idMatricula
ORDER BY c.nombre, c.apellido, md.nombreModulo, te.tipo;
--2. Calcular la nota final de cada camper por módulo.
SELECT c.id AS camper_id,c.nombre,c.apellido, md.id AS modulo_id,md.nombreModulo, nf.nota AS nota_final
FROM campers c
JOIN matricula m ON c.id = m.idCamper
JOIN modulosRuta mr ON m.idModuloRuta = mr.id
JOIN modulos md ON mr.idModulo = md.id
JOIN notaFinal nf ON m.id = nf.idMatricula
ORDER BY c.nombre, c.apellido, md.nombreModulo;
--3. Mostrar los campers que reprobaron algún módulo (nota < 60).
SELECT c.id AS camper_id,c.nombre,c.apellido,md.nombreModulo,nf.nota
FROM campers c
JOIN matricula m ON c.id = m.idCamper
JOIN modulosRuta mr ON m.idModuloRuta = mr.id
JOIN modulos md ON mr.idModulo = md.id
JOIN notaFinal nf ON m.id = nf.idMatricula
WHERE nf.nota < 60
ORDER BY md.nombreModulo, nf.nota;
--4. Listar los módulos con más campers en bajo rendimiento.
SELECT md.id AS modulo_id, md.nombreModulo,COUNT(c.id) AS campersBajoRendimiento
FROM  modulos md
JOIN modulosRuta mr ON md.id = mr.idModulo
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN notaFinal nf ON m.id = nf.idMatricula
JOIN campers c ON m.idCamper = c.id
WHERE nf.nota < 60
GROUP BY md.id, md.nombreModulo
ORDER BY campersBajoRendimiento DESC;
--5. Obtener el promedio de notas finales por cada módulo.

--6. Consultar el rendimiento general por ruta de entrenamiento.
SELECT ra.id AS ruta_id, ra.nombreRuta,AVG(nf.nota) AS rendimiento_promedio, MIN(nf.nota) AS nota_minima,MAX(nf.nota) AS nota_maxima,
COUNT(CASE WHEN nf.nota >= 60 THEN 1 END) AS aprobados,
COUNT(CASE WHEN nf.nota < 60 THEN 1 END) AS reprobados
FROM  rutaAprendizaje ra
JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN notaFinal nf ON m.id = nf.idMatricula
GROUP BY ra.id, ra.nombreRuta
ORDER BY    rendimiento_promedio DESC;
--7. Mostrar los trainers responsables de campers con bajo rendimiento.
SELECT t.id AS trainer_id, t.nombre AS trainer_nombre,t.apellido AS trainer_apellido,COUNT(DISTINCT c.id) AS campers_bajo_rendimiento
FROM trainers t
JOIN grupo g ON t.id = g.idTrainer
JOIN detalleGrupo dg ON g.id = dg.idGrupo
JOIN campers c ON dg.idCamper = c.id
JOIN matricula m ON c.id = m.idCamper
JOIN notaFinal nf ON m.id = nf.idMatricula
WHERE nf.nota < 60
GROUP BY  t.id, t.nombre, t.apellido
ORDER BY campers_bajo_rendimiento DESC;
--8. Comparar el promedio de rendimiento por trainer.
SELECT  t.id AS trainer_id, t.nombre AS trainer_nombre, t.apellido AS trainer_apellido, AVG(nf.nota) AS promedio_rendimiento, COUNT(DISTINCT c.id) AS total_campers
FROM  trainers t
JOIN grupo g ON t.id = g.idTrainer
JOIN detalleGrupo dg ON g.id = dg.idGrupo
JOIN campers c ON dg.idCamper = c.id
JOIN matricula m ON c.id = m.idCamper
JOIN notaFinal nf ON m.id = nf.idMatricula
GROUP BY  t.id, t.nombre, t.apellido
ORDER BY promedio_rendimiento DESC;
--9. Listar los mejores 5 campers por nota final en cada ruta.
--10. Mostrar cuántos campers pasaron cada módulo por ruta.
SELECT ra.nombreRuta,md.nombreModulo,
COUNT(DISTINCT CASE WHEN nf.nota >= 60 THEN c.id END) AS campers_aprobados,
COUNT(DISTINCT c.id) AS total_campers,
ROUND((COUNT(DISTINCT CASE WHEN nf.nota >= 60 THEN c.id END) * 100.0 / COUNT(DISTINCT c.id)), 2) AS porcentaje_aprobacion
FROM  rutaAprendizaje ra
JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
JOIN modulos md ON mr.idModulo = md.id
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN campers c ON m.idCamper = c.id
JOIN notaFinal nf ON m.id = nf.idMatricula
GROUP BY  ra.nombreRuta, md.nombreModulo
ORDER BY ra.nombreRuta, porcentaje_aprobacion DESC;

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
SELECT  ra.nombreRuta AS area, h.fecha, h.franjaHoraria, h.descripcion
FROM  rutaAprendizaje ra
JOIN  grupo g ON ra.id = g.idRutaAprendizaje
JOIN  trainers t ON g.idTrainer = t.id
JOIN trainerHorario th ON t.id = th.idTrainer
JOIN  horario h ON th.idHorario = h.id
ORDER BY  ra.nombreRuta, h.fecha, h.franjaHoraria;
-- 9. Mostrar las áreas con más campers asignados.
SELECT  ra.id, ra.nombreRuta AS area, COUNT(c.id) AS total_campers
FROM rutaAprendizaje ra
JOIN grupo g ON ra.id = g.idRutaAprendizaje
JOIN detalleGrupo dg ON g.id = dg.idGrupo
JOIN campers c ON dg.idCamper = c.id
GROUP BY ra.id, ra.nombreRuta
ORDER BY  total_campers DESC;
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
SELECT  t.id, t.nombre, t.apellido, t.identificacion FROM trainers t
LEFT JOIN grupo g ON t.id = g.idTrainer
WHERE  g.id IS NULL;
-- 7. Mostrar cuántos módulos están a cargo de cada trainer.
SELECT t.nombre, t.apellido,m.nombreModulo FROM trainers t
INNER JOIN grupo g ON t.id = g.idTrainer
INNER JOIN rutaAprendizaje ra ON g.idRutaAprendizaje = ra.id
INNER JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
INNER JOIN modulos m ON mr.idModulo= m.id;
-- 8. Obtener el trainer con mejor rendimiento promedio de campers.
SELECT  t.id AS idTrainer,t.nombre,t.apellido,
    AVG(nf.nota) AS promedio_rendimiento FROM  trainers t
JOIN grupo g ON t.id = g.idTrainer
JOIN detalleGrupo dg ON g.id = dg.idGrupo
JOIN campers c ON dg.idCamper = c.id
JOIN matricula m ON c.id = m.idCamper
JOIN notaFinal nf ON m.id = nf.idMatricula
GROUP BY t.id, t.nombre, t.apellido
ORDER BY promedio_rendimiento DESC
LIMIT 1;
-- 9. Consultar los horarios ocupados por cada trainer.
SELECT t.nombre, t.apellido, h.franjaHoraria FROM trainers t
INNER JOIN trainerHorario th ON t.id= th.idTrainer
INNER JOIN horario h ON th.idHorario = h.id;
-- 10. Mostrar la disponibilidad semanal de cada trainer.
SELECT  t.id AS trainer_id,t.nombre,t.apellido,h.fecha,DAYNAME(h.fecha) AS dia_semana, h.franjaHoraria, h.descripcion, s.nombreSalon AS salon
FROM trainers t
LEFT JOIN trainerHorario th ON t.id = th.idTrainer
LEFT JOIN horario h ON th.idHorario = h.id
LEFT JOIN salon s ON th.idSalon = s.id
ORDER BY  t.nombre, t.apellido, YEARWEEK(h.fecha), DAYOFWEEK(h.fecha),  h.franjaHoraria;

--  Subconsultas y Cálculos Avanzados --

-- 1. Obtener los campers con la nota más alta en cada módulo.
SELECT c.nombre, c.apellido, md.nombreModulo, nf.nota
FROM campers c
JOIN matricula m ON c.id = m.idCamper
JOIN modulosRuta mr ON m.idModuloRuta = mr.id
JOIN modulos md ON mr.idModulo = md.id
JOIN notaFinal nf ON m.id = nf.idMatricula
WHERE nf.nota = (SELECT MAX(nf2.nota) FROM notaFinal nf2
                 JOIN matricula m2 ON nf2.idMatricula = m2.id
                 JOIN modulosRuta mr2 ON m2.idModuloRuta = mr2.id
                 WHERE mr2.idModulo = mr.idModulo)
ORDER BY md.nombreModulo, nf.nota DESC;

-- 2. Mostrar el promedio general de notas por ruta y comparar con el promedio global.
WITH PromedioGlobal AS (
    SELECT AVG(nf.nota) AS promedio_global
    FROM notaFinal nf
)
SELECT 
    ra.nombreRuta AS ruta,
    AVG(nf.nota) AS promedio_ruta,
    pg.promedio_global,
    CASE 
        WHEN AVG(nf.nota) > pg.promedio_global THEN 'Por encima del promedio global'
        WHEN AVG(nf.nota) < pg.promedio_global THEN 'Por debajo del promedio global'
        ELSE 'Igual al promedio global'
    END AS comparacion
FROM rutaAprendizaje ra
JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN notaFinal nf ON m.id = nf.idMatricula
CROSS JOIN PromedioGlobal pg
GROUP BY ra.nombreRuta, pg.promedio_global
ORDER BY promedio_ruta DESC;
-- 3. Listar las áreas con más del 80% de ocupación.
SELECT 
    s.nombreSalon AS area,
    s.capacidad,
    COUNT(c.id) AS ocupacion_actual,
    ROUND((COUNT(c.id) * 100.0 / s.capacidad), 2) AS porcentaje_ocupacion
FROM salon s
LEFT JOIN detalleGrupo dg ON s.id = dg.id
LEFT JOIN campers c ON dg.idCamper = c.id
GROUP BY s.id, s.nombreSalon, s.capacidad
HAVING ROUND((COUNT(c.id) * 100.0 / s.capacidad), 2) > 80
ORDER BY porcentaje_ocupacion DESC;
-- 4. Mostrar los trainers con menos del 70% de rendimiento promedio.
SELECT 
    t.id AS trainer_id,
    t.nombre AS trainer_nombre,
    t.apellido AS trainer_apellido,
    AVG(nf.nota) AS promedio_rendimiento
FROM trainers t
JOIN grupo g ON t.id = g.idTrainer
JOIN detalleGrupo dg ON g.id = dg.idGrupo
JOIN campers c ON dg.idCamper = c.id
JOIN matricula m ON c.id = m.idCamper
JOIN notaFinal nf ON m.id = nf.idMatricula
GROUP BY t.id, t.nombre, t.apellido
HAVING AVG(nf.nota) < 70
ORDER BY promedio_rendimiento ASC;
-- 5. Consultar los campers cuyo promedio está por debajo del promedio general.
WITH PromedioGlobal AS (
    SELECT AVG(nf.nota) AS promedio_global
    FROM notaFinal nf
)
SELECT 
    c.id AS camper_id,
    c.nombre AS camper_nombre,
    c.apellido AS camper_apellido,
    AVG(nf.nota) AS promedio_camper,
    pg.promedio_global
FROM campers c
JOIN matricula m ON c.id = m.idCamper
JOIN notaFinal nf ON m.id = nf.idMatricula
CROSS JOIN PromedioGlobal pg
GROUP BY c.id, c.nombre, c.apellido, pg.promedio_global
HAVING AVG(nf.nota) < pg.promedio_global
ORDER BY promedio_camper ASC;
-- 6. Obtener los módulos con la menor tasa de aprobación.
SELECT 
    md.id AS modulo_id,
    md.nombreModulo,
    COUNT(CASE WHEN nf.nota >= 60 THEN 1 END) AS campers_aprobados,
    COUNT(nf.nota) AS total_campers,
    ROUND((COUNT(CASE WHEN nf.nota >= 60 THEN 1 END) * 100.0 / COUNT(nf.nota)), 2) AS porcentaje_aprobacion
FROM modulos md
JOIN modulosRuta mr ON md.id = mr.idModulo
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN notaFinal nf ON m.id = nf.idMatricula
GROUP BY md.id, md.nombreModulo
ORDER BY porcentaje_aprobacion ASC;
-- 7. Listar los campers que han aprobado todos los módulos de su ruta.
SELECT 
    c.id AS camper_id,
    c.nombre AS camper_nombre,
    c.apellido AS camper_apellido,
    ra.nombreRuta AS ruta
FROM campers c
JOIN matricula m ON c.id = m.idCamper
JOIN modulosRuta mr ON m.idModuloRuta = mr.id
JOIN rutaAprendizaje ra ON mr.idRutaAprendizaje = ra.id
JOIN notaFinal nf ON m.id = nf.idMatricula
GROUP BY c.id, c.nombre, c.apellido, ra.nombreRuta
HAVING MIN(nf.nota) >= 60
ORDER BY c.nombre, c.apellido;
-- 8. Mostrar rutas con más de 10 campers en bajo rendimiento.
SELECT 
    ra.id AS ruta_id,
    ra.nombreRuta AS ruta,
    COUNT(c.id) AS campers_bajo_rendimiento
FROM rutaAprendizaje ra
JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN notaFinal nf ON m.id = nf.idMatricula
JOIN campers c ON m.idCamper = c.id
WHERE nf.nota < 60
GROUP BY ra.id, ra.nombreRuta
HAVING COUNT(c.id) > 10
ORDER BY campers_bajo_rendimiento DESC;
-- 9. Calcular el promedio de rendimiento por SGDB principal.
SELECT 
    sg.descripcion AS sgdb_principal,
    AVG(nf.nota) AS promedio_rendimiento
FROM rutaAprendizaje ra
JOIN sRuta sr ON ra.id = sr.idRutaAprendizaje
JOIN sgdb sg ON sr.idSGDB = sg.id
JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN notaFinal nf ON m.id = nf.idMatricula
GROUP BY sg.descripcion
ORDER BY promedio_rendimiento DESC;
-- 10. Listar los módulos con al menos un 30% de campers reprobados.
SELECT 
    md.id AS modulo_id,
    md.nombreModulo,
    COUNT(CASE WHEN nf.nota < 60 THEN 1 END) AS campers_reprobados,
    COUNT(nf.nota) AS total_campers,
    ROUND((COUNT(CASE WHEN nf.nota < 60 THEN 1 END) * 100.0 / COUNT(nf.nota)), 2) AS porcentaje_reprobados
FROM modulos md
JOIN modulosRuta mr ON md.id = mr.idModulo
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN notaFinal nf ON m.id = nf.idMatricula
GROUP BY md.id, md.nombreModulo
HAVING ROUND((COUNT(CASE WHEN nf.nota < 60 THEN 1 END) * 100.0 / COUNT(nf.nota)), 2) >= 30
ORDER BY porcentaje_reprobados DESC;
-- 11. Mostrar el módulo más cursado por campers con riesgo alto.
SELECT 
    md.id AS modulo_id,
    md.nombreModulo,
    COUNT(c.id) AS total_campers_riesgo_alto
FROM modulos md
JOIN modulosRuta mr ON md.id = mr.idModulo
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN campers c ON m.idCamper = c.id
JOIN nivelRiesgo nr ON c.idNivelRiesgo = nr.id
WHERE nr.tipoNivel = 'Alto'
GROUP BY md.id, md.nombreModulo
ORDER BY total_campers_riesgo_alto DESC
LIMIT 1;
-- 12. Consultar los trainers con más de 3 rutas asignadas.
SELECT 
    t.id AS trainer_id,
    t.nombre AS trainer_nombre,
    t.apellido AS trainer_apellido,
    COUNT(g.idRutaAprendizaje) AS total_rutas_asignadas
FROM trainers t
JOIN grupo g ON t.id = g.idTrainer
GROUP BY t.id, t.nombre, t.apellido
HAVING COUNT(g.idRutaAprendizaje) > 3
ORDER BY total_rutas_asignadas DESC;
-- 13. Listar los horarios más ocupados por áreas.
SELECT 
    s.nombreSalon AS area,
    h.franjaHoraria,
    COUNT(dg.idCamper) AS total_campers
FROM salon s
JOIN trainerHorario th ON s.id = th.idSalon
JOIN horario h ON th.idHorario = h.id
JOIN detalleGrupo dg ON th.idTrainer = dg.id
GROUP BY s.nombreSalon, h.franjaHoraria
ORDER BY total_campers DESC;
-- 14. Consultar las rutas con el mayor número de módulos.
SELECT 
    ra.id AS ruta_id,
    ra.nombreRuta AS ruta,
    COUNT(mr.idModulo) AS total_modulos
FROM rutaAprendizaje ra
JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
GROUP BY ra.id, ra.nombreRuta
ORDER BY total_modulos DESC;
-- 15. Obtener los campers que han cambiado de estado más de una vez.
SELECT 
    c.id AS camper_id,
    c.nombre AS camper_nombre,
    c.apellido AS camper_apellido,
    COUNT(hc.EstadoAnterior) AS cambios_estado
FROM campers c
JOIN historialCamper hc ON c.id = hc.idCamper
GROUP BY c.id, c.nombre, c.apellido
HAVING COUNT(hc.EstadoAnterior) > 1
ORDER BY cambios_estado DESC;
-- 16. Mostrar las evaluaciones donde la nota teórica sea mayor a la práctica.
-- 17. Listar los módulos donde la media de quizzes supera el 9.
SELECT 
    md.id AS modulo_id,
    md.nombreModulo,
    AVG(cal.calificacion) AS promedio_quizzes
FROM modulos md
JOIN modulosRuta mr ON md.id = mr.idModulo
JOIN evaluacion e ON mr.id = e.idModuloRuta
JOIN tipoEvaluacion te ON e.idTipoEvaluacion = te.id
JOIN calificaciones cal ON e.id = cal.idEvaluacion
WHERE te.tipo = 'Quiz'
GROUP BY md.id, md.nombreModulo
HAVING AVG(cal.calificacion) > 9
ORDER BY promedio_quizzes DESC;
-- 18. Consultar la ruta con mayor tasa de graduación.
SELECT 
    ra.id AS ruta_id,
    ra.nombreRuta AS ruta,
    COUNT(CASE WHEN ec.tipoEstado = 'Graduado' THEN c.id END) AS total_graduados,
    COUNT(c.id) AS total_campers,
    ROUND((COUNT(CASE WHEN ec.tipoEstado = 'Graduado' THEN c.id END) * 100.0 / COUNT(c.id)), 2) AS tasa_graduacion
FROM rutaAprendizaje ra
JOIN campers c ON ra.id = c.idRutaAprendizaje
JOIN estadoCamper ec ON c.idEstadoCamper = ec.id
GROUP BY ra.id, ra.nombreRuta
ORDER BY tasa_graduacion DESC
LIMIT 1;
-- 19. Mostrar los módulos cursados por campers de nivel de riesgo medio o alto.
SELECT 
    md.id AS modulo_id,
    md.nombreModulo,
    c.id AS camper_id,
    c.nombre AS camper_nombre,
    c.apellido AS camper_apellido,
    nr.tipoNivel AS nivel_riesgo
FROM modulos md
JOIN modulosRuta mr ON md.id = mr.idModulo
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN campers c ON m.idCamper = c.id
JOIN nivelRiesgo nr ON c.idNivelRiesgo = nr.id
WHERE nr.tipoNivel IN ('Medio', 'Alto')
ORDER BY md.nombreModulo, c.nombre, c.apellido;
-- 20. Obtener la diferencia entre capacidad y ocupación en cada área.
SELECT 
    s.nombreSalon AS area,
    s.capacidad AS capacidad_maxima,
    COUNT(dg.idCamper) AS ocupacion_actual,
    (s.capacidad - COUNT(dg.idCamper)) AS diferencia
FROM salon s
LEFT JOIN detalleGrupo dg ON s.idEstadoSalon = dg.id
GROUP BY s.id, s.nombreSalon, s.capacidad
ORDER BY diferencia DESC;