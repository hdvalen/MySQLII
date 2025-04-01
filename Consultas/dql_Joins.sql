-- JOINS Basicos --

-- 1. Obtener los nombres completos de los campers junto con el nombre de la ruta a la que están inscritos.
SELECT c.nombre, c.apellido, ra.nombreRuta FROM campers c
INNER JOIN rutaAprendizaje ra ON c.idRutaAprendizaje = ra.id;
-- 2. Mostrar los campers con sus evaluaciones (nota teórica, práctica, quizzes y nota final) por cada módulo.
-- 3. Listar todos los módulos que componen cada ruta de entrenamiento.
SELECT ra.nombreRuta, m.nombreModulo FROM rutaAprendizaje ra
INNER JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
INNER JOIN modulos m ON mr.idModulo = m.id;
-- 4. Consultar las rutas con sus trainers asignados y las áreas en las que imparten clases.
SELECT ra.nombreRuta, t.nombre, sl.nombreSalon FROM rutaAprendizaje ra 
INNER JOIN campers c ON ra.id = c.idRutaAprendizaje
INNER JOIN sedes s ON c.idSede = s.id 
INNER JOIN trainers t ON s.id = t.idSede
INNER JOIN trainerHorario th ON t.id= th.idTrainer
INNER JOIN salon sl ON th.idSalon = sl.id;
-- 5. Mostrar los campers junto con el trainer responsable de su ruta actual.
SELECT c.id AS camper_id,c.nombre AS camper_nombre,c.apellido AS camper_apellido,t.nombre AS trainer_nombre,t.apellido AS trainer_apellido,ra.nombreRuta AS ruta
FROM campers c
JOIN detalleGrupo dg ON c.id = dg.idCamper
JOIN grupo g ON dg.idGrupo = g.id
JOIN trainers t ON g.idTrainer = t.id
JOIN rutaAprendizaje ra ON g.idRutaAprendizaje = ra.id
ORDER BY ra.nombreRuta, c.nombre, c.apellido;
-- 6. Obtener el listado de evaluaciones realizadas con nombre de camper, módulo y ruta.
SELECT c.nombre AS camper_nombre,c.apellido AS camper_apellido,e.descripcion AS evaluacion,e.fecha AS fecha_evaluacion,te.tipo AS tipo_evaluacion,
md.nombreModulo AS modulo,ra.nombreRuta AS ruta, cal.calificacion
FROM campers c
JOIN matricula m ON c.id = m.idCamper
JOIN modulosRuta mr ON m.idModuloRuta = mr.id
JOIN modulos md ON mr.idModulo = md.id
JOIN rutaAprendizaje ra ON mr.idRutaAprendizaje = ra.id
JOIN evaluacion e ON mr.id = e.idModuloRuta
JOIN tipoEvaluacion te ON e.idTipoEvaluacion = te.id
JOIN calificaciones cal ON e.id = cal.idEvaluacion AND m.id = cal.idMatricula
ORDER BY  c.nombre, c.apellido, ra.nombreRuta, md.nombreModulo, e.fecha;
-- 7. Listar los trainers y los horarios en que están asignados a las áreas de entrenamiento.
SELECT t.nombre AS trainer_nombre,t.apellido AS trainer_apellido,ra.nombreRuta AS area_entrenamiento,h.fecha,h.franjaHoraria,h.descripcion AS descripcion_horario,
s.nombreSalon AS salon
FROM  trainers t
JOIN grupo g ON t.id = g.idTrainer
JOIN rutaAprendizaje ra ON g.idRutaAprendizaje = ra.id
JOIN trainerHorario th ON t.id = th.idTrainer
JOIN horario h ON th.idHorario = h.id
JOIN salon s ON th.idSalon = s.id
ORDER BY t.nombre, t.apellido, ra.nombreRuta, h.fecha, h.franjaHoraria;
-- 8. Consultar todos los campers junto con su estado actual y el nivel de riesgo.
SELECT c.id AS camper_id,c.nombre,c.apellido,c.identificacion,ec.tipoEstado AS estado_actual,nr.tipoNivel AS nivel_riesgo
FROM campers c
JOIN estadoCamper ec ON c.idEstadoCamper = ec.id
JOIN nivelRiesgo nr ON c.idNivelRiesgo = nr.id
ORDER BY nr.tipoNivel DESC, c.nombre, c.apellido;
-- 9. Obtener todos los módulos de cada ruta junto con su porcentaje teórico, práctico y de quizzes.
SELECT ra.nombreRuta,md.nombreModulo,
SUM(CASE WHEN te.tipo = 'Teórico' THEN te.porcentaje ELSE 0 END) AS porcentaje_teorico,
SUM(CASE WHEN te.tipo = 'Práctico' THEN te.porcentaje ELSE 0 END) AS porcentaje_practico,
SUM(CASE WHEN te.tipo = 'Quiz' THEN te.porcentaje ELSE 0 END) AS porcentaje_quiz
FROM rutaAprendizaje ra
JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
JOIN modulos md ON mr.idModulo = md.id
JOIN evaluacion e ON mr.id = e.idModuloRuta
JOIN tipoEvaluacion te ON e.idTipoEvaluacion = te.id
GROUP BY ra.nombreRuta, md.nombreModulo
ORDER BY ra.nombreRuta, md.nombreModulo;
-- 10. Mostrar los nombres de las áreas junto con los nombres de los campers que están asistiendo en esos espacios.
SELECT  ra.nombreRuta AS area,c.nombre AS camper_nombre,c.apellido AS camper_apellido,s.nombreSalon AS salon,h.fecha,h.franjaHoraria
FROM rutaAprendizaje ra
JOIN grupo g ON ra.id = g.idRutaAprendizaje
JOIN detalleGrupo dg ON g.id = dg.idGrupo
JOIN campers c ON dg.idCamper = c.id
JOIN trainers t ON g.idTrainer = t.id
JOIN trainerHorario th ON t.id = th.idTrainer
JOIN horario h ON th.idHorario = h.id
JOIN salon s ON th.idSalon = s.id
JOIN asistencia a ON c.id = a.idCamper
JOIN sesiones ses ON a.idSesion = ses.id AND ses.fecha = h.fecha
ORDER BY ra.nombreRuta, s.nombreSalon, h.fecha, h.franjaHoraria, c.nombre, c.apellido;

-- Joins Condiciones Especificas --

-- 1. Listar los campers que han aprobado todos los módulos de su ruta (nota_final >= 60).
SELECT c.id,c.nombre,c.apellido,ra.nombreRuta
FROM campers c
JOIN rutaAprendizaje ra ON c.idRutaAprendizaje = ra.id
WHERE NOT EXISTS (
    SELECT 1
    FROM modulosRuta mr
    JOIN matricula m ON mr.id = m.idModuloRuta
    JOIN notaFinal nf ON m.id = nf.idMatricula
    WHERE mr.idRutaAprendizaje = ra.id
    AND m.idCamper = c.id
    AND nf.nota < 60
)
AND EXISTS (
    SELECT 1
    FROM modulosRuta mr
    JOIN matricula m ON mr.id = m.idModuloRuta
    WHERE mr.idRutaAprendizaje = ra.id
    AND m.idCamper = c.id
);
-- 2. Mostrar las rutas que tienen más de 10 campers inscritos actualmente.
SELECT ra.id,ra.nombreRuta,COUNT(c.id) AS total_campers
FROM rutaAprendizaje ra
JOIN campers c ON ra.id = c.idRutaAprendizaje
GROUP BY ra.id, ra.nombreRuta
HAVING COUNT(c.id) > 10
ORDER BY total_campers DESC;
-- 3. Consultar las áreas que superan el 80% de su capacidad con el número actual de campers asignados.
SELECT s.nombreSalon AS area,s.capacidad,COUNT(DISTINCT c.id) AS campers_asignados,(COUNT(DISTINCT c.id) * 100.0 / CAST(s.capacidad AS DECIMAL)) AS porcentaje_ocupacion
FROM salon s
JOIN trainerHorario th ON s.id = th.idSalon
JOIN trainers t ON th.idTrainer = t.id
JOIN grupo g ON t.id = g.idTrainer
JOIN detalleGrupo dg ON g.id = dg.idGrupo
JOIN campers c ON dg.idCamper = c.id
GROUP BY s.nombreSalon, s.capacidad
HAVING (COUNT(DISTINCT c.id) * 100.0 / CAST(s.capacidad AS DECIMAL)) > 80
ORDER BY porcentaje_ocupacion DESC;
-- 4. Obtener los trainers que imparten más de una ruta diferente.
SELECT t.id,t.nombre,t.apellido,COUNT(DISTINCT g.idRutaAprendizaje) AS total_rutas
FROM trainers t
JOIN grupo g ON t.id = g.idTrainer
GROUP BY t.id, t.nombre, t.apellido
HAVING  COUNT(DISTINCT g.idRutaAprendizaje) > 1
ORDER BY  total_rutas DESC;
-- 5. Listar las evaluaciones donde la nota práctica es mayor que la nota teórica.
SELECT c.nombre AS camper_nombre,c.apellido AS camper_apellido,md.nombreModulo,cal_practica.calificacion AS nota_practica,cal_teorica.calificacion AS nota_teorica
FROM campers c
JOIN matricula m ON c.id = m.idCamper
JOIN (
    SELECT 
        cal.idMatricula, 
        cal.calificacion
     FROM 
        evaluacion e
     JOIN tipoEvaluacion te ON e.idTipoEvaluacion = te.id
     JOIN calificaciones cal ON e.id = cal.idEvaluacion
     WHERE 
        te.tipo = 'Práctico'
    ) AS cal_practica ON m.id = cal_practica.idMatricula
JOIN 
    (SELECT 
        cal.idMatricula, 
        cal.calificacion
     FROM 
        evaluacion e
     JOIN tipoEvaluacion te ON e.idTipoEvaluacion = te.id
     JOIN calificaciones cal ON e.id = cal.idEvaluacion
     WHERE 
        te.tipo = 'Teórico'
    ) AS cal_teorica ON m.id = cal_teorica.idMatricula
JOIN modulosRuta mr ON m.idModuloRuta = mr.id
JOIN modulos md ON mr.idModulo = md.id
WHERE cal_practica.calificacion > cal_teorica.calificacion
ORDER BY (cal_practica.calificacion - cal_teorica.calificacion) DESC;
-- 6. Mostrar campers que están en rutas cuyo SGDB principal es MySQL.
SELECT c.id,c.nombre,c.apellido,ra.nombreRuta,s.descripcion AS sgdb
FROM campers c
JOIN rutaAprendizaje ra ON c.idRutaAprendizaje = ra.id
JOIN sRuta sr ON ra.id = sr.idRutaAprendizaje
JOIN sgdb s ON sr.idSGDB = s.id
WHERE s.descripcion = 'MySQL'
ORDER BY ra.nombreRuta, c.nombre, c.apellido;
-- 7. Obtener los nombres de los módulos donde los campers han tenido bajo rendimiento.
SELECT md.id,md.nombreModulo,AVG(nf.nota) AS promedio_nota,COUNT(DISTINCT CASE WHEN nf.nota < 60 THEN m.idCamper END) AS campers_reprobados,
COUNT(DISTINCT m.idCamper) AS total_campers,
(COUNT(DISTINCT CASE WHEN nf.nota < 60 THEN m.idCamper END) * 100.0 / COUNT(DISTINCT m.idCamper)) AS porcentaje_reprobados
FROM modulos md
JOIN modulosRuta mr ON md.id = mr.idModulo
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN notaFinal nf ON m.id = nf.idMatricula
GROUP BY  md.id, md.nombreModulo
HAVING AVG(nf.nota) < 70 OR(COUNT(DISTINCT CASE WHEN nf.nota < 60 THEN m.idCamper END) * 100.0 / COUNT(DISTINCT m.idCamper)) > 30
ORDER BY porcentaje_reprobados DESC, promedio_nota ASC;
-- 8. Consultar las rutas con más de 3 módulos asociados.
SELECT ra.id,ra.nombreRuta,COUNT(DISTINCT mr.idModulo) AS total_modulos
FROM rutaAprendizaje ra
JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
GROUP BY ra.id, ra.nombreRuta
HAVING COUNT(DISTINCT mr.idModulo) > 3
ORDER BY total_modulos DESC;
-- 9. Listar las inscripciones realizadas en los últimos 30 días con sus respectivos campers y rutas.
SELECT c.id AS camper_id,c.nombre,c.apellido,c.fechaInscripcion,ra.nombreRuta
FROM campers c
JOIN rutaAprendizaje ra ON c.idRutaAprendizaje = ra.id
WHERE  c.fechaInscripcion >= CURDATE() - INTERVAL 30 DAY
ORDER BY c.fechaInscripcion DESC;
-- 10. Obtener los trainers que están asignados a rutas con campers en estado de “Alto Riesgo”
SELECT DISTINCT t.id,t.nombre,t.apellido,ra.nombreRuta
FROM trainers t
JOIN grupo g ON t.id = g.idTrainer
JOIN rutaAprendizaje ra ON g.idRutaAprendizaje = ra.id
JOIN detalleGrupo dg ON g.id = dg.idGrupo
JOIN campers c ON dg.idCamper = c.id
JOIN nivelRiesgo nr ON c.idNivelRiesgo = nr.id
WHERE nr.tipoNivel = 'Alto Riesgo'
ORDER BY  ra.nombreRuta, t.nombre, t.apellido;


-- Joins Funciones de Agregacion -- 

-- 1. Obtener el promedio de nota final por módulo.
SELECT md.id,md.nombreModulo,AVG(nf.nota) AS promedio_nota_final
FROM modulos md
JOIN modulosRuta mr ON md.id = mr.idModulo
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN notaFinal nf ON m.id = nf.idMatricula
GROUP BY md.id, md.nombreModulo
ORDER BY promedio_nota_final DESC;
-- 2. Calcular la cantidad total de campers por ruta.
SELECT ra.id,ra.nombreRuta,COUNT(c.id) AS total_campers
FROM  rutaAprendizaje ra
LEFT JOIN campers c ON ra.id = c.idRutaAprendizaje
GROUP BY  ra.id, ra.nombreRuta
ORDER BY total_campers DESC;
-- 3. Mostrar la cantidad de evaluaciones realizadas por cada trainer (según las rutas que imparte).
SELECT t.id, t.nombre,t.apellido, COUNT(e.id) AS total_evaluaciones
FROM trainers t
JOIN grupo g ON t.id = g.idTrainer
JOIN rutaAprendizaje ra ON g.idRutaAprendizaje = ra.id
JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
JOIN evaluacion e ON mr.id = e.idModuloRuta
GROUP BY t.id, t.nombre, t.apellido
ORDER BY    total_evaluaciones DESC;
-- 4. Consultar el promedio general de rendimiento por cada área de entrenamiento.
SELECT ra.id,ra.nombreRuta AS area_entrenamiento,AVG(nf.nota) AS promedio_rendimiento
FROM  rutaAprendizaje ra
JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN notaFinal nf ON m.id = nf.idMatricula
GROUP BY  ra.id, ra.nombreRuta
ORDER BY promedio_rendimiento DESC;
-- 5. Obtener la cantidad de módulos asociados a cada ruta de entrenamiento.
SELECT ra.id,ra.nombreRuta,COUNT(DISTINCT mr.idModulo) AS total_modulos
FROM rutaAprendizaje ra
LEFT JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
GROUP BY ra.id, ra.nombreRuta
ORDER BY total_modulos DESC;
-- 6. Mostrar el promedio de nota final de los campers en estado “Cursando”.
SELECT AVG(nf.nota) AS promedio_campers_cursando
FROM campers c
JOIN estadoCamper ec ON c.idEstadoCamper = ec.id
JOIN matricula m ON c.id = m.idCamper
JOIN notaFinal nf ON m.id = nf.idMatricula
WHERE  ec.tipoEstado = 'Cursando';
-- 7. Listar el número de campers evaluados en cada módulo.
SELECT md.id,md.nombreModulo,COUNT(DISTINCT m.idCamper) AS campers_evaluados
FROM modulos md
JOIN modulosRuta mr ON md.id = mr.idModulo
JOIN matricula m ON mr.id = m.idModuloRuta
JOIN evaluacion e ON mr.id = e.idModuloRuta
JOIN calificaciones cal ON e.id = cal.idEvaluacion AND m.id = cal.idMatricula
GROUP BY md.id, md.nombreModulo
ORDER BY campers_evaluados DESC;
-- 8. Consultar el porcentaje de ocupación actual por cada área de entrenamiento.
SELECT s.nombreSalon AS area_entrenamiento,s.capacidad,COUNT(DISTINCT c.id) AS campers_asignados,(COUNT(DISTINCT c.id) * 100.0 / CAST(s.capacidad AS DECIMAL)) AS porcentaje_ocupacion
FROM salon s
JOIN trainerHorario th ON s.id = th.idSalon
JOIN trainers t ON th.idTrainer = t.id
JOIN grupo g ON t.id = g.idTrainer
JOIN detalleGrupo dg ON g.id = dg.idGrupo
JOIN campers c ON dg.idCamper = c.id
GROUP BY s.nombreSalon, s.capacidad
ORDER BY porcentaje_ocupacion DESC;
-- 9. Mostrar cuántos trainers tiene asignados cada área.
SELECT ra.id,ra.nombreRuta AS area,COUNT(DISTINCT t.id) AS total_trainers
FROM rutaAprendizaje ra
JOIN grupo g ON ra.id = g.idRutaAprendizaje
JOIN trainers t ON g.idTrainer = t.id
GROUP BY ra.id, ra.nombreRuta
ORDER BY total_trainers DESC;
-- 10. Listar las rutas que tienen más campers en riesgo alto.
SELECT ra.id,ra.nombreRuta,COUNT(c.id) AS campers_riesgo_alto
FROM  rutaAprendizaje ra
JOIN campers c ON ra.id = c.idRutaAprendizaje
JOIN nivelRiesgo nr ON c.idNivelRiesgo = nr.id
WHERE  nr.tipoNivel = 'Alto Riesgo'
GROUP BY ra.id, ra.nombreRuta
ORDER BY campers_riesgo_alto DESC;