-- Procedimientos Almacenados --

-- 1. Registrar un nuevo camper con toda su información personal y estado inicial.
DELIMITER //
CREATE PROCEDURE RegistrarCamper(
    IN p_nombre VARCHAR(50), 
    IN p_apellido VARCHAR(50), 
    IN p_identificacion VARCHAR(20), 
    IN p_telefono VARCHAR(15),
    IN p_fechaInscripcion DATE,
    IN p_idSede INT,
    IN p_idNivelRiesgo INT,
    IN p_idAcudiente INT,
    IN p_idEstadoCamper INT,
    IN p_idRutaAprendizaje INT
)
BEGIN
    INSERT INTO campers (nombre, apellido, identificacion, telefono, fechaInscripcion, idSede, idNivelRiesgo, idAcudiente, idEstadoCamper, idRutaAprendizaje) 
    VALUES (p_nombre, p_apellido, p_identificacion, p_telefono, p_fechaInscripcion, p_idSede, p_idNivelRiesgo, p_idAcudiente, p_idEstadoCamper, p_idRutaAprendizaje);
END //
DELIMITER ;
CALL RegistrarCamper('Juan', 'Pérez', '123456789', '3001234567', CURDATE(), 1, 2, 3, 1, 4);
-- 2. Actualizar el estado de un camper luego de completar el proceso de ingreso.
DELIMITER //
CREATE PROCEDURE ActualizarEstadoIngreso(
    IN p_identificacion VARCHAR(20)
)
BEGIN
    DECLARE v_nuevoEstado INT;
    SELECT id INTO v_nuevoEstado FROM estadoCamper WHERE tipoEstado = 'En Formación' LIMIT 1;
    UPDATE campers 
    SET idEstadoCamper = v_nuevoEstado
    WHERE identificacion = p_identificacion;
END //
DELIMITER ;
CALL ActualizarEstadoIngreso('123456789');

-- 3. Procesar la inscripción de un camper a una ruta específica.
DELIMITER //
CREATE PROCEDURE InscribirCamperRuta(
    IN p_identificacion VARCHAR(20), 
    IN p_idRuta INT
)
BEGIN
    UPDATE campers 
    SET idRutaAprendizaje = p_idRuta
    WHERE identificacion = p_identificacion;
END //
DELIMITER ;
CALL InscribirCamperRuta('123456789', 3);

-- 4. Registrar una evaluación completa (teórica, práctica y quizzes) para un camper.
DELIMITER //
CREATE PROCEDURE RegistrarEvaluacionCompleta(
    IN p_idMatricula INT, 
    IN p_teorica FLOAT, 
    IN p_practica FLOAT, 
    IN p_quiz FLOAT
)
BEGIN
    INSERT INTO evaluaciones (idMatricula, teorica, practica, quiz, fecha)
    VALUES (p_idMatricula, p_teorica, p_practica, p_quiz, CURDATE());
END //
DELIMITER ;
CALL RegistrarEvaluacionCompleta(1, 4.5, 4.8, 4.3);

-- 5. Calcular y registrar automáticamente la nota final de un módulo.
DELIMITER //
CREATE PROCEDURE CalcularNotaFinal(
    IN p_idMatricula INT
)
BEGIN
    DECLARE v_promedio FLOAT;
    
    -- Calcular el promedio de notas
    SELECT AVG((teorica + practica + quiz) / 3) INTO v_promedio
    FROM evaluaciones
    WHERE idMatricula = p_idMatricula;
    
    -- Insertar la nota final
    INSERT INTO notaFinal (nota, idMatricula) 
    VALUES (v_promedio, p_idMatricula);
END //
DELIMITER ;
CALL CalcularNotaFinal(1);

-- 6. Asignar campers aprobados a una ruta de acuerdo con la disponibilidad del área.
DELIMITER //
CREATE PROCEDURE AsignarAprobadosARuta(
    IN p_idRutaNueva INT
)
BEGIN
    UPDATE campers 
    SET idRutaAprendizaje = p_idRutaNueva
    WHERE idEstadoCamper = (SELECT id FROM estadoCamper WHERE tipoEstado = 'Aprobado');
END //
DELIMITER ;
CALL AsignarAprobadosARuta(3);

-- 7. Asignar un trainer a una ruta y área específica, validando el horario.
DELIMITER //
CREATE PROCEDURE AsignarTrainer(
    IN p_idTrainer INT, 
    IN p_idHorario INT, 
    IN p_idSalon INT
)
BEGIN
    INSERT INTO trainerHorario (idTrainer, idHorario, idSalon) 
    VALUES (p_idTrainer, p_idHorario, p_idSalon);
END //
DELIMITER ;
CALL AsignarTrainer(1, 2, 3);

-- 8. Registrar una nueva ruta con sus módulos y SGDB asociados.
DELIMITER //
CREATE PROCEDURE RegistrarRuta(
    IN p_nombreRuta VARCHAR(50)
)
BEGIN
    INSERT INTO rutaAprendizaje (nombreRuta) VALUES (p_nombreRuta);
END //
DELIMITER ;
CALL RegistrarRuta('Full Stack Developer');

-- 9. Registrar una nueva área de entrenamiento con su capacidad y horarios.

-- 10. Consultar disponibilidad de horario en un área determinada.
DELIMITER //
CREATE PROCEDURE ActualizarEstadoSegunNota()
BEGIN
    UPDATE campers 
    SET idEstadoCamper = 
        CASE 
            WHEN (SELECT AVG(n.nota) FROM notaFinal n 
                  JOIN matricula m ON n.idMatricula = m.id 
                  WHERE m.idCamper = campers.id) >= 3.5 
            THEN (SELECT id FROM estadoCamper WHERE tipoEstado = 'Aprobado')
            ELSE (SELECT id FROM estadoCamper WHERE tipoEstado = 'Reprobado')
        END;
END //
DELIMITER ;
CALL ActualizarEstadoSegunNota();

-- 11. Reasignar a un camper a otra ruta en caso de bajo rendimiento.
DELIMITER //
CREATE PROCEDURE ReasignarPorBajoRendimiento(
    IN p_idCamper INT, 
    IN p_idNuevaRuta INT
)
BEGIN
    UPDATE campers 
    SET idRutaAprendizaje = p_idNuevaRuta
    WHERE idCamper = p_idCamper AND 
          (SELECT AVG(nota) FROM notaFinal WHERE idMatricula IN 
          (SELECT id FROM matricula WHERE idCamper = p_idCamper)) < 3.0;
END //
DELIMITER ;
CALL ReasignarPorBajoRendimiento(2, 6);

-- 12. Cambiar el estado de un camper a “Graduado” al finalizar todos los módulos.
DELIMITER //
CREATE PROCEDURE GraduarCamper(
    IN p_idCamper INT
)
BEGIN
    DECLARE v_estadoGraduado INT;
    
    -- Obtener el ID del estado 'Graduado'
    SELECT id INTO v_estadoGraduado FROM estadoCamper WHERE tipoEstado = 'Graduado' LIMIT 1;
    
    -- Actualizar estado si completó todos los módulos
    UPDATE campers 
    SET idEstadoCamper = v_estadoGraduado
    WHERE idCamper = p_idCamper AND NOT EXISTS 
    (SELECT 1 FROM matricula m 
     LEFT JOIN notaFinal n ON m.id = n.idMatricula
     WHERE m.idCamper = p_idCamper AND n.nota IS NULL);
END //
DELIMITER ;
-- 13. Consultar y exportar todos los datos de rendimiento de un camper.
DELIMITER //
CREATE PROCEDURE ConsultarRendimientoCamper(
    IN p_identificacion VARCHAR(20)
)
BEGIN
    SELECT c.idCamper, c.nombre, c.apellido, r.nombreRuta, 
           n.nota, n.idMatricula, m.idModulo
    FROM campers c
    JOIN matricula m ON c.idCamper = m.idCamper
    JOIN notaFinal n ON m.id = n.idMatricula
    JOIN rutaAprendizaje r ON c.idRutaAprendizaje = r.idRuta
    WHERE c.identificacion = p_identificacion;
END //
DELIMITER ;
CALL ConsultarRendimientoCamper('123456789');

-- 14. Registrar la asistencia a clases por área y horario.
DELIMITER //
CREATE PROCEDURE RegistrarAsistencia(
    IN p_idCamper INT, 
    IN p_idSesion INT
)
BEGIN
    INSERT INTO asistencia (idCamper, idSesion, fecha) 
    VALUES (p_idCamper, p_idSesion, CURDATE());
END //
DELIMITER ;

-- 15. Generar reporte mensual de notas por ruta.
DELIMITER //
CREATE PROCEDURE ReporteMensualNota(
    IN p_mes INT, 
    IN p_anio INT
)
BEGIN
    SELECT r.nombreRuta, c.nombre, c.apellido, n.nota, m.idModulo
    FROM notaFinal n
    JOIN matricula m ON n.idMatricula = m.id
    JOIN campers c ON m.idCamper = c.idCamper
    JOIN rutaAprendizaje r ON c.idRutaAprendizaje = r.idRuta
    WHERE MONTH(n.fecha) = p_mes AND YEAR(n.fecha) = p_anio;
END //
DELIMITER ;
CALL ReporteMensualNota(3, 2025);

-- 16. Validar y registrar la asignación de un salón a una ruta sin exceder la capacidad.
DELIMITER //
CREATE PROCEDURE AsignarSalonRuta(
    IN p_idRuta INT, 
    IN p_idSalon INT
)
BEGIN
    DECLARE v_capacidad INT;
    DECLARE v_inscritos INT;
    SELECT capacidad INTO v_capacidad FROM salones WHERE idSalon = p_idSalon;
    SELECT COUNT(*) INTO v_inscritos FROM campers WHERE idRutaAprendizaje = p_idRuta;
    IF v_inscritos <= v_capacidad THEN
        UPDATE rutasAprendizaje 
        SET idSalon = p_idSalon 
        WHERE idRuta = p_idRuta;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Capacidad del salón excedida.';
    END IF;
END //
DELIMITER ;

-- 17. Registrar cambio de horario de un trainer.
DELIMITER //
CREATE PROCEDURE CambiarHorarioTrainer(
    IN p_idTrainer INT, 
    IN p_nuevoHorario VARCHAR(20)
)
BEGIN
    UPDATE trainers 
    SET horario = p_nuevoHorario 
    WHERE idTrainer = p_idTrainer;
END //
DELIMITER ;

-- 18. Eliminar la inscripción de un camper a una ruta (en caso de retiro).
DELIMITER //
CREATE PROCEDURE EliminarInscripcionCamper(
    IN p_idCamper INT
)
BEGIN
    UPDATE campers 
    SET idRutaAprendizaje = NULL 
    WHERE idCamper = p_idCamper;
END //
DELIMITER ;

-- 19. Recalcular el estado de todos los campers según su rendimiento acumulado.
DELIMITER //
CREATE PROCEDURE RecalcularEstadosCampers()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_idCamper INT;
    DECLARE v_promedio FLOAT;
    DECLARE v_cursor CURSOR FOR SELECT idCamper FROM campers;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN v_cursor;
    read_loop: LOOP
        FETCH v_cursor INTO v_idCamper;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT AVG(nota) INTO v_promedio FROM notaFinal WHERE idMatricula IN 
            (SELECT id FROM matricula WHERE idCamper = v_idCamper);
        IF v_promedio >= 4.0 THEN
            UPDATE campers SET idEstadoCamper = (SELECT id FROM estadoCamper WHERE tipoEstado = 'Aprobado') WHERE idCamper = v_idCamper;
        ELSEIF v_promedio >= 3.0 THEN
            UPDATE campers SET idEstadoCamper = (SELECT id FROM estadoCamper WHERE tipoEstado = 'En Formación') WHERE idCamper = v_idCamper;
        ELSE
            UPDATE campers SET idEstadoCamper = (SELECT id FROM estadoCamper WHERE tipoEstado = 'Reprobado') WHERE idCamper = v_idCamper;
        END IF;
    END LOOP;

    CLOSE v_cursor;
END //
DELIMITER ;

-- 20. Asignar horarios automáticamente a trainers disponibles según sus áreas
DELIMITER //
CREATE PROCEDURE AsignarHorariosTrainers()
BEGIN
    DECLARE v_idTrainer INT;
    DECLARE v_idArea INT;
    DECLARE v_horarioDisponible VARCHAR(20);
    
    DECLARE trainer_cursor CURSOR FOR 
    SELECT idTrainer, idArea FROM trainers WHERE horario IS NULL;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_idTrainer = NULL;

    OPEN trainer_cursor;
    read_loop: LOOP
        FETCH trainer_cursor INTO v_idTrainer, v_idArea;
        IF v_idTrainer IS NULL THEN
            LEAVE read_loop;
        END IF;

        SELECT horario INTO v_horarioDisponible FROM horarios WHERE idArea = v_idArea LIMIT 1;
        IF v_horarioDisponible IS NOT NULL THEN
            UPDATE trainers 
            SET horario = v_horarioDisponible 
            WHERE idTrainer = v_idTrainer;
        END IF;
    END LOOP;

    CLOSE trainer_cursor;
END //
DELIMITER ;
