-- Funciones SQL --

-- 1. Calcular el promedio ponderado de evaluaciones de un camper.
DELIMITER //
CREATE PROCEDURE CalcularPromedioPonderadoCamper(IN camper_id INT)
BEGIN
    SELECT 
        c.nombre,
        c.apellido,
        SUM(cal.calificacion * CAST(te.porcentaje AS DECIMAL) / 100) / SUM(CAST(te.porcentaje AS DECIMAL) / 100) AS promedio_ponderado
    FROM 
        campers c
    JOIN matricula m ON c.id = m.idCamper
    JOIN evaluacion e ON m.idModuloRuta = e.idModuloRuta
    JOIN tipoEvaluacion te ON e.idTipoEvaluacion = te.id
    JOIN calificaciones cal ON e.id = cal.idEvaluacion AND m.id = cal.idMatricula
    WHERE 
        c.id = camper_id
    GROUP BY 
        c.id, c.nombre, c.apellido;
END //
DELIMITER ;
-- 2. Determinar si un camper aprueba o no un módulo específico.
DELIMITER //
CREATE PROCEDURE DeterminarAprobacionModulo(IN camper_id INT, IN modulo_id INT)
BEGIN
    SELECT 
        c.nombre,
        c.apellido,
        md.nombreModulo,
        nf.nota,
        CASE WHEN nf.nota >= 60 THEN 'Aprobado' ELSE 'Reprobado' END AS resultado
    FROM 
        campers c
    JOIN matricula m ON c.id = m.idCamper
    JOIN modulosRuta mr ON m.idModuloRuta = mr.id
    JOIN modulos md ON mr.idModulo = md.id
    JOIN notaFinal nf ON m.id = nf.idMatricula
    WHERE 
        c.id = camper_id AND md.id = modulo_id;
END //
DELIMITER ;
-- 3. Evaluar el nivel de riesgo de un camper según su rendimiento promedio.
DELIMITER //
CREATE PROCEDURE EvaluarRiesgoCamper(IN camper_id INT)
BEGIN
    DECLARE promedio DECIMAL;
    
    SELECT 
        AVG(nf.nota) INTO promedio
    FROM 
        matricula m
    JOIN notaFinal nf ON m.id = nf.idMatricula
    WHERE 
        m.idCamper = camper_id;
    
    SELECT 
        c.nombre,
        c.apellido,
        promedio AS promedio_rendimiento,
        CASE 
            WHEN promedio < 50 THEN 'Alto Riesgo'
            WHEN promedio < 60 THEN 'Riesgo Medio'
            WHEN promedio < 75 THEN 'Riesgo Bajo'
            ELSE 'Sin Riesgo'
        END AS nivel_riesgo_recomendado
    FROM 
        campers c
    WHERE 
        c.id = camper_id;
END //
DELIMITER ;
-- 4. Obtener el total de campers asignados a una ruta específica.
DELIMITER //
CREATE PROCEDURE ObtenerCampersPorRuta(IN ruta_id INT)
BEGIN
    SELECT 
        ra.nombreRuta,
        COUNT(c.id) AS total_campers
    FROM 
        rutaAprendizaje ra
    LEFT JOIN campers c ON ra.id = c.idRutaAprendizaje
    WHERE 
        ra.id = ruta_id
    GROUP BY 
        ra.nombreRuta;
END //
DELIMITER ;
-- 5. Consultar la cantidad de módulos que ha aprobado un camper.
DELIMITER //
CREATE PROCEDURE ContarModulosAprobados(IN camper_id INT)
BEGIN
    SELECT 
        c.nombre,
        c.apellido,
        COUNT(DISTINCT mr.idModulo) AS modulos_aprobados
    FROM 
        campers c
    JOIN matricula m ON c.id = m.idCamper
    JOIN modulosRuta mr ON m.idModuloRuta = mr.id
    JOIN notaFinal nf ON m.id = nf.idMatricula
    WHERE 
        c.id = camper_id AND nf.nota >= 60
    GROUP BY 
        c.id, c.nombre, c.apellido;
END //
DELIMITER ;
-- 6. Validar si hay cupos disponibles en una determinada área.
DELIMITER //
CREATE PROCEDURE ValidarCuposDisponibles(IN salon_id INT)
BEGIN
    SELECT 
        s.nombreSalon,
        s.capacidad,
        COUNT(DISTINCT c.id) AS campers_asignados,
        s.capacidad - COUNT(DISTINCT c.id) AS cupos_disponibles,
        CASE WHEN s.capacidad > COUNT(DISTINCT c.id) THEN 'Disponible' ELSE 'Sin cupos' END AS estado
    FROM 
        salon s
    LEFT JOIN trainerHorario th ON s.id = th.idSalon
    LEFT JOIN trainers t ON th.idTrainer = t.id
    LEFT JOIN grupo g ON t.id = g.idTrainer
    LEFT JOIN detalleGrupo dg ON g.id = dg.idGrupo
    LEFT JOIN campers c ON dg.idCamper = c.id
    WHERE 
        s.id = salon_id
    GROUP BY 
        s.nombreSalon, s.capacidad;
END //
DELIMITER ;
-- 7. Calcular el porcentaje de ocupación de un área de entrenamiento.
DELIMITER //
CREATE PROCEDURE CalcularOcupacionArea(IN salon_id INT)
BEGIN
    SELECT 
        s.nombreSalon,
        s.capacidad,
        COUNT(DISTINCT c.id) AS campers_asignados,
        (COUNT(DISTINCT c.id) * 100.0 / CAST(s.capacidad AS DECIMAL)) AS porcentaje_ocupacion
    FROM 
        salon s
    LEFT JOIN trainerHorario th ON s.id = th.idSalon
    LEFT JOIN trainers t ON th.idTrainer = t.id
    LEFT JOIN grupo g ON t.id = g.idTrainer
    LEFT JOIN detalleGrupo dg ON g.id = dg.idGrupo
    LEFT JOIN campers c ON dg.idCamper = c.id
    WHERE 
        s.id = salon_id
    GROUP BY 
        s.nombreSalon, s.capacidad;
END //
DELIMITER ;
-- 8. Determinar la nota más alta obtenida en un módulo.
DELIMITER //
CREATE PROCEDURE ObtenerNotaMasAltaModulo(IN modulo_id INT)
BEGIN
    SELECT 
        md.nombreModulo,
        MAX(nf.nota) AS nota_maxima,
        c.nombre,
        c.apellido
    FROM 
        modulos md
    JOIN modulosRuta mr ON md.id = mr.idModulo
    JOIN matricula m ON mr.id = m.idModuloRuta
    JOIN notaFinal nf ON m.id = nf.idMatricula
    JOIN campers c ON m.idCamper = c.id
    WHERE 
        md.id = modulo_id
    GROUP BY 
        md.nombreModulo, c.nombre, c.apellido
    ORDER BY 
        nota_maxima DESC
    LIMIT 1;
END //
DELIMITER ;
-- 9. Calcular la tasa de aprobación de una ruta.
DELIMITER //
CREATE PROCEDURE CalcularTasaAprobacionRuta(IN ruta_id INT)
BEGIN
    SELECT 
        ra.nombreRuta,
        COUNT(DISTINCT m.id) AS total_matriculas,
        COUNT(DISTINCT CASE WHEN nf.nota >= 60 THEN m.id END) AS matriculas_aprobadas,
        (COUNT(DISTINCT CASE WHEN nf.nota >= 60 THEN m.id END) * 100.0 / COUNT(DISTINCT m.id)) AS tasa_aprobacion
    FROM 
        rutaAprendizaje ra
    JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
    JOIN matricula m ON mr.id = m.idModuloRuta
    JOIN notaFinal nf ON m.id = nf.idMatricula
    WHERE 
        ra.id = ruta_id
    GROUP BY 
        ra.nombreRuta;
END //
DELIMITER ;
-- 10. Verificar si un trainer tiene horario disponible.
DELIMITER //
CREATE PROCEDURE VerificarDisponibilidadTrainer(IN trainer_id INT, IN fecha DATE, IN franja VARCHAR(50))
BEGIN
    SELECT 
        t.nombre,
        t.apellido,
        h.fecha,
        h.franjaHoraria,
        CASE WHEN h.id IS NULL THEN 'Disponible' ELSE 'Ocupado' END AS estado
    FROM 
        trainers t
    LEFT JOIN trainerHorario th ON t.id = th.idTrainer
    LEFT JOIN horario h ON th.idHorario = h.id AND h.fecha = fecha AND h.franjaHoraria = franja
    WHERE 
        t.id = trainer_id;
END //
DELIMITER ;
-- 11. Obtener el promedio de notas por ruta.
DELIMITER //
CREATE PROCEDURE ObtenerPromedioNotasPorRuta()
BEGIN
    SELECT 
        ra.nombreRuta,
        AVG(nf.nota) AS promedio_notas
    FROM 
        rutaAprendizaje ra
    JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
    JOIN matricula m ON mr.id = m.idModuloRuta
    JOIN notaFinal nf ON m.id = nf.idMatricula
    GROUP BY 
        ra.nombreRuta
    ORDER BY 
        promedio_notas DESC;
END //
DELIMITER ;
-- 12. Calcular cuántas rutas tiene asignadas un trainer.
DELIMITER //
CREATE PROCEDURE ContarRutasPorTrainer(IN trainer_id INT)
BEGIN
    SELECT 
        t.nombre,
        t.apellido,
        COUNT(DISTINCT g.idRutaAprendizaje) AS total_rutas
    FROM 
        trainers t
    LEFT JOIN grupo g ON t.id = g.idTrainer
    WHERE 
        t.id = trainer_id
    GROUP BY 
        t.nombre, t.apellido;
END //
DELIMITER ;
-- 13. Verificar si un camper puede ser graduado.
DELIMITER //
CREATE PROCEDURE VerificarGraduacionCamper(IN camper_id INT)
BEGIN
    DECLARE total_modulos INT;
    DECLARE modulos_aprobados INT;
    -- Contar total de módulos 
    SELECT 
        COUNT(DISTINCT mr.idModulo) INTO total_modulos
    FROM 
        campers c
    JOIN rutaAprendizaje ra ON c.idRutaAprendizaje = ra.id
    JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
    WHERE 
        c.id = camper_id;
    -- Contar módulos aprobados
    SELECT 
        COUNT(DISTINCT mr.idModulo) INTO modulos_aprobados
    FROM 
        campers c
    JOIN matricula m ON c.id = m.idCamper
    JOIN modulosRuta mr ON m.idModuloRuta = mr.id
    JOIN notaFinal nf ON m.id = nf.idMatricula
    WHERE 
        c.id = camper_id AND nf.nota >= 60;
    SELECT 
        c.nombre,
        c.apellido,
        total_modulos,
        modulos_aprobados,
        (modulos_aprobados = total_modulos) AS puede_graduarse
    FROM 
        campers c
    WHERE 
        c.id = camper_id;
END //
DELIMITER ;
-- 14. Obtener el estado actual de un camper en función de sus evaluaciones.
DELIMITER //
CREATE PROCEDURE ObtenerEstadoCamper(IN camper_id INT)
BEGIN
    DECLARE promedio DECIMAL;
    
    SELECT 
        AVG(nf.nota) INTO promedio
    FROM 
        matricula m
    JOIN notaFinal nf ON m.id = nf.idMatricula
    WHERE 
        m.idCamper = camper_id;
    
    SELECT 
        c.nombre,
        c.apellido,
        ec.tipoEstado AS estado_actual,
        promedio,
        CASE 
            WHEN promedio IS NULL THEN 'Sin evaluaciones'
            WHEN promedio < 60 THEN 'En riesgo'
            WHEN promedio >= 60 AND promedio < 75 THEN 'Regular'
            WHEN promedio >= 75 AND promedio < 85 THEN 'Bueno'
            WHEN promedio >= 85 THEN 'Excelente'
        END AS rendimiento_actual
    FROM 
        campers c
    JOIN estadoCamper ec ON c.idEstadoCamper = ec.id
    WHERE 
        c.id = camper_id;
END //
DELIMITER ;
-- 15. Calcular la carga horaria semanal de un trainer.
DELIMITER //
CREATE PROCEDURE CalcularCargaHorariaTrainer(IN trainer_id INT)
BEGIN
    SELECT 
        t.nombre,
        t.apellido,
        YEARWEEK(h.fecha) AS semana,
        COUNT(h.id) AS total_horas
    FROM 
        trainers t
    JOIN trainerHorario th ON t.id = th.idTrainer
    JOIN horario h ON th.idHorario = h.id
    WHERE 
        t.id = trainer_id
    GROUP BY 
        t.nombre, t.apellido, YEARWEEK(h.fecha)
    ORDER BY 
        semana;
END //
DELIMITER ;
-- 16. Determinar si una ruta tiene módulos pendientes por evaluación.
DELIMITER //
CREATE PROCEDURE VerificarModulosPendientesRuta(IN ruta_id INT)
BEGIN
    SELECT 
        ra.nombreRuta,
        md.nombreModulo,
        CASE WHEN e.id IS NULL THEN 'Pendiente' ELSE 'Evaluado' END AS estado_evaluacion
    FROM 
        rutaAprendizaje ra
    JOIN modulosRuta mr ON ra.id = mr.idRutaAprendizaje
    JOIN modulos md ON mr.idModulo = md.id
    LEFT JOIN evaluacion e ON mr.id = e.idModuloRuta
    WHERE 
        ra.id = ruta_id
    ORDER BY 
        md.nombreModulo;
END //
DELIMITER ;
-- 17. Calcular el promedio general del programa.
DELIMITER //
CREATE PROCEDURE CalcularPromedioGeneralPrograma()
BEGIN
    SELECT 
        AVG(nf.nota) AS promedio_general,
        MIN(nf.nota) AS nota_minima,
        MAX(nf.nota) AS nota_maxima,
        COUNT(DISTINCT m.idCamper) AS total_campers_evaluados
    FROM 
        matricula m
    JOIN notaFinal nf ON m.id = nf.idMatricula;
END //
DELIMITER ;
-- 18. Verificar si un horario choca con otros entrenadores en el área.
DELIMITER //
CREATE PROCEDURE VerificarChoqueHorario(IN salon_id INT, IN fecha DATE, IN franja VARCHAR(50))
BEGIN
    SELECT 
        th.id AS horario_id,
        t.nombre AS trainer_nombre,
        t.apellido AS trainer_apellido,
        h.fecha,
        h.franjaHoraria,
        s.nombreSalon
    FROM 
        trainerHorario th
    JOIN trainers t ON th.idTrainer = t.id
    JOIN horario h ON th.idHorario = h.id
    JOIN salon s ON th.idSalon = s.id
    WHERE 
        th.idSalon = salon_id AND 
        h.fecha = fecha AND 
        h.franjaHoraria = franja;
END //
DELIMITER ;
-- 19. Calcular cuántos campers están en riesgo en una ruta específica.
DELIMITER //
CREATE PROCEDURE ContarCampersEnRiesgoRuta(IN ruta_id INT)
BEGIN
    SELECT 
        ra.nombreRuta,
        COUNT(DISTINCT CASE WHEN nr.tipoNivel = 'Alto Riesgo' THEN c.id END) AS campers_alto_riesgo,
        COUNT(DISTINCT CASE WHEN nr.tipoNivel = 'Riesgo Medio' THEN c.id END) AS campers_riesgo_medio,
        COUNT(DISTINCT CASE WHEN nr.tipoNivel = 'Riesgo Bajo' THEN c.id END) AS campers_riesgo_bajo,
        COUNT(DISTINCT c.id) AS total_campers
    FROM 
        rutaAprendizaje ra
    JOIN campers c ON ra.id = c.idRutaAprendizaje
    JOIN nivelRiesgo nr ON c.idNivelRiesgo = nr.id
    WHERE 
        ra.id = ruta_id
    GROUP BY 
        ra.nombreRuta;
END //
DELIMITER ;
-- 20. Consultar el número de módulos evaluados por un camper.
DELIMITER //
CREATE PROCEDURE ContarModulosEvaluadosCamper(IN camper_id INT)
BEGIN
    SELECT 
        c.nombre,
        c.apellido,
        COUNT(DISTINCT mr.idModulo) AS modulos_evaluados,
        COUNT(DISTINCT CASE WHEN nf.nota >= 60 THEN mr.idModulo END) AS modulos_aprobados,
        COUNT(DISTINCT CASE WHEN nf.nota < 60 THEN mr.idModulo END) AS modulos_reprobados
    FROM 
        campers c
    JOIN matricula m ON c.id = m.idCamper
    JOIN modulosRuta mr ON m.idModuloRuta = mr.id
    JOIN notaFinal nf ON m.id = nf.idMatricula
    WHERE 
        c.id = camper_id
    GROUP BY 
        c.nombre, c.apellido;
END //
DELIMITER ;