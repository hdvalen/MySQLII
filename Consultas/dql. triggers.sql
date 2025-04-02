-- Triggers SQL --

-- 1. Al insertar una evaluación, calcular automáticamente la nota final.
DELIMITER //
CREATE TRIGGER tr_calcular_nota_final_evaluacion
AFTER INSERT ON calificaciones
FOR EACH ROW
BEGIN
    DECLARE v_promedio DECIMAL(5,2);
    SELECT AVG(calificacion) INTO v_promedio
    FROM calificaciones
    WHERE idMatricula = NEW.idMatricula;
    IF EXISTS (SELECT 1 FROM notaFinal WHERE idMatricula = NEW.idMatricula) THEN
        UPDATE notaFinal
        SET nota = v_promedio
        WHERE idMatricula = NEW.idMatricula;
    ELSE
        INSERT INTO notaFinal (nota, idMatricula)
        VALUES (v_promedio, NEW.idMatricula);
    END IF;
END;
//
DELIMITER ;
-- 2. Al actualizar la nota final de un módulo, verificar si el camper aprueba o reprueba.
DELIMITER $$
CREATE TRIGGER verificar_aprobacion
AFTER UPDATE ON notaFinal
FOR EACH ROW
BEGIN
    -- Verificar si la nota final es mayor o igual a 60 (aprobado) o menor a 60 (reprobado).
    IF NEW.nota >= 60 THEN
        UPDATE campers
        SET estado = 'Aprobado'
        WHERE id = (SELECT idCamper FROM matricula WHERE id = NEW.idMatricula);
    ELSE
        UPDATE campers
        SET estado = 'Reprobado'
        WHERE id = (SELECT idCamper FROM matricula WHERE id = NEW.idMatricula);
    END IF;
END$$
DELIMITER ;
-- 3. Al insertar una inscripción, cambiar el estado del camper a "Inscrito".
DELIMITER //
CREATE TRIGGER tr_actualizar_estado_camper_inscrito
AFTER INSERT ON matricula
FOR EACH ROW
BEGIN
    DECLARE estado_inscrito INT;
    -- Obtener el ID del estado "Inscrito"
    SELECT id INTO estado_inscrito 
    FROM estadoCamper 
    WHERE tipoEstado = 'Inscrito' LIMIT 1;
    -- Actualizar el estado del camper
    UPDATE campers 
    SET idEstadoCamper = estado_inscrito 
    WHERE id = NEW.idCamper;
    -- Registrar en historial
    INSERT INTO historialCamper (estadoAnterior, estadoNuevo, idCamper)
    SELECT ec.tipoEstado, 'Inscrito', NEW.idCamper
    FROM estadoCamper ec
    WHERE ec.id = (SELECT idEstadoCamper FROM campers WHERE id = NEW.idCamper);
END;
//
DELIMITER ;
-- 4. Al actualizar una evaluación, recalcular su promedio inmediatamente.
DELIMITER //
CREATE TRIGGER tr_recalcular_promedio_evaluacion
AFTER UPDATE ON calificaciones
FOR EACH ROW
BEGIN
    DECLARE promedio DECIMAL(5,2);
    
    -- Calcular el promedio de todas las calificaciones para la matrícula
    SELECT AVG(calificacion) INTO promedio
    FROM calificaciones
    WHERE idMatricula = NEW.idMatricula;
    
    -- Actualizar la nota final
    UPDATE notaFinal
    SET nota = promedio
    WHERE idMatricula = NEW.idMatricula;
    
    -- Si no existe una nota final, crearla
    IF ROW_COUNT() = 0 THEN
        INSERT INTO notaFinal (nota, idMatricula)
        VALUES (promedio, NEW.idMatricula);
    END IF;
END;
//
DELIMITER ;
-- 5. Al eliminar una inscripción, marcar al camper como “Retirado”.
DELIMITER //
CREATE TRIGGER tr_marcar_camper_retirado
AFTER DELETE ON matricula
FOR EACH ROW
BEGIN
    DECLARE estado_retirado INT;
    DECLARE estado_anterior VARCHAR(50);
    -- Obtener el ID del estado "Retirado"
    SELECT id INTO estado_retirado 
    FROM estadoCamper 
    WHERE tipoEstado = 'Retirado' LIMIT 1;
    -- Guardar estado anterior
    SELECT tipoEstado INTO estado_anterior
    FROM estadoCamper ec
    INNER JOIN campers c ON ec.id = c.idEstadoCamper
    WHERE c.id = OLD.idCamper;
    -- Actualizar el estado del camper
    UPDATE campers 
    SET idEstadoCamper = estado_retirado 
    WHERE id = OLD.idCamper;
    -- Registrar cambio en historial
    INSERT INTO historialCamper (estadoAnterior, estadoNuevo, idCamper)
    VALUES (estado_anterior, 'Retirado', OLD.idCamper);
END;
//
DELIMITER ;
-- 6. Al insertar un nuevo módulo, registrar automáticamente su SGDB asociado.
DELIMITER //
CREATE TRIGGER tr_registrar_sgdb_modulo
AFTER INSERT ON modulos
FOR EACH ROW
BEGIN
    INSERT INTO sRuta (idSGDB, idRutaAprendizaje, idSGDBA)
    SELECT 1, id, 1 FROM rutaAprendizaje WHERE nombreRuta = 'Ruta Predeterminada' LIMIT 1;
END;
//
DELIMITER ;
-- 7. Al insertar un nuevo trainer, verificar duplicados por identificación.
DELIMITER //
CREATE TRIGGER tr_verificar_duplicado_trainer
BEFORE INSERT ON trainers
FOR EACH ROW
BEGIN
    DECLARE count_duplicate INT;
    SELECT COUNT(*) INTO count_duplicate
    FROM trainers
    WHERE identificacion = NEW.identificacion;
    IF count_duplicate > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un trainer con esta identificación';
    END IF;
END;
//
DELIMITER ;
-- 8. Al asignar un área, validar que no exceda su capacidad.
DELIMITER //
CREATE TRIGGER tr_validar_capacidad_salon
BEFORE INSERT ON trainerHorario
FOR EACH ROW
BEGIN
    DECLARE capacidad_salon INT;
    DECLARE ocupacion_actual INT;
    SELECT CAST(capacidad AS UNSIGNED) INTO capacidad_salon
    FROM salon
    WHERE id = NEW.idSalon;
    SELECT COUNT(*) INTO ocupacion_actual
    FROM trainerHorario
    WHERE idSalon = NEW.idSalon AND idHorario = NEW.idHorario;
    IF ocupacion_actual >= capacidad_salon THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El salón ha alcanzado su capacidad máxima para este horario';
    END IF;
END;
//
DELIMITER ;
-- 9. Al insertar una evaluación con nota < 60, marcar al camper como “Bajo rendimiento”.
DELIMITER //
CREATE TRIGGER tr_marcar_bajo_rendimiento
AFTER INSERT ON calificaciones
FOR EACH ROW
BEGIN
    DECLARE estado_bajo_rendimiento INT;
    DECLARE estado_anterior VARCHAR(50);
    IF NEW.calificacion < 60 THEN
        SELECT id INTO estado_bajo_rendimiento 
        FROM estadoCamper 
        WHERE tipoEstado = 'Bajo rendimiento' LIMIT 1;
        SELECT tipoEstado INTO estado_anterior
        FROM estadoCamper ec
        INNER JOIN campers c ON ec.id = c.idEstadoCamper
        INNER JOIN matricula m ON c.id = m.idCamper
        WHERE m.id = NEW.idMatricula;
        UPDATE campers 
        SET idEstadoCamper = estado_bajo_rendimiento 
        WHERE id = (SELECT idCamper FROM matricula WHERE id = NEW.idMatricula);
        INSERT INTO historialCamper (estadoAnterior, estadoNuevo, idCamper)
        VALUES (
            estado_anterior,
            'Bajo rendimiento',
            (SELECT idCamper FROM matricula WHERE id = NEW.idMatricula)
        );
    END IF;
END;
//
DELIMITER ;
-- 10. Al cambiar de estado a “Graduado”, mover registro a la tabla de egresados.
DELIMITER //
CREATE TRIGGER tr_mover_a_egresados
AFTER UPDATE ON campers
FOR EACH ROW
BEGIN
    DECLARE estado_graduado INT;
    SELECT id INTO estado_graduado
    FROM estadoCamper
    WHERE tipoEstado = 'Graduado';
    IF NEW.idEstadoCamper = estado_graduado AND OLD.idEstadoCamper != estado_graduado THEN
        INSERT INTO graduados (fecha, idCamper)
        VALUES (CURDATE(), NEW.id);
        INSERT INTO historialCamper (estadoAnterior, estadoNuevo, idCamper)
        SELECT tipoEstado, 'Graduado', NEW.id
        FROM estadoCamper
        WHERE id = OLD.idEstadoCamper;
    END IF;
END;
//
DELIMITER ;
-- 11. Al modificar horarios de trainer, verificar solapamiento con otros.
DELIMITER //
CREATE TRIGGER tr_verificar_solapamiento_horarios
BEFORE UPDATE ON trainerHorario
FOR EACH ROW
BEGIN
    DECLARE count_overlap INT;
    SELECT COUNT(*) INTO count_overlap
    FROM trainerHorario th
    INNER JOIN horario h1 ON th.idHorario = h1.id
    INNER JOIN horario h2 ON NEW.idHorario = h2.id
    WHERE th.idTrainer = NEW.idTrainer
    AND th.id != NEW.id
    AND h1.fecha = h2.fecha
    AND h1.franjaHoraria = h2.franjaHoraria;
    IF count_overlap > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Existe solapamiento con otro horario del trainer';
    END IF;
END;
//
DELIMITER ;
-- 12. Al eliminar un trainer, liberar sus horarios y rutas asignadas.
DELIMITER //
CREATE TRIGGER tr_liberar_asignaciones_trainer
BEFORE DELETE ON trainers
FOR EACH ROW
BEGIN
    DELETE FROM trainerHorario 
    WHERE idTrainer = OLD.id;
    UPDATE grupo 
    SET idTrainer = NULL 
    WHERE idTrainer = OLD.id;
    DELETE FROM habilidadesTrainer
    WHERE idTrainer = OLD.id;
END;
//
DELIMITER ;
-- 13. Al cambiar la ruta de un camper, actualizar automáticamente sus módulos.
DELIMITER //
CREATE TRIGGER tr_actualizar_modulos_camper
AFTER UPDATE ON campers
FOR EACH ROW
BEGIN
    IF NEW.idRutaAprendizaje != OLD.idRutaAprendizaje THEN
        DELETE FROM matricula 
        WHERE idCamper = NEW.id;
        INSERT INTO matricula (fecha, idCamper, idModuloRuta)
        SELECT CURDATE(), NEW.id, mr.id
        FROM modulosRuta mr
        WHERE mr.idRutaAprendizaje = NEW.idRutaAprendizaje;
        UPDATE detalleGrupo dg
        INNER JOIN grupo g ON dg.idGrupo = g.id
        SET dg.idGrupo = (
            SELECT id FROM grupo 
            WHERE idRutaAprendizaje = NEW.idRutaAprendizaje
            LIMIT 1
        )
        WHERE dg.idCamper = NEW.id;
    END IF;
END;
//
DELIMITER ;
-- 14. Al insertar un nuevo camper, verificar si ya existe por número de documento.
DELIMITER //
CREATE TRIGGER tr_verificar_duplicado_camper
BEFORE INSERT ON campers
FOR EACH ROW
BEGIN
    DECLARE count_duplicate INT;
    SELECT COUNT(*) INTO count_duplicate
    FROM campers
    WHERE identificacion = NEW.identificacion;
    IF count_duplicate > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un camper con este número de documento';
    END IF;
END;
//
DELIMITER ;
-- 15. Al actualizar la nota final, recalcular el estado del módulo automáticamente.
DELIMITER //
CREATE TRIGGER tr_recalcular_estado_modulo
AFTER UPDATE ON notaFinal
FOR EACH ROW
BEGIN
    DECLARE id_estado_aprobado INT;
    DECLARE id_estado_reprobado INT;
    DECLARE id_modulo_ruta INT;
    SELECT id INTO id_estado_aprobado FROM estadoModuloR WHERE estado = 'Aprobado' LIMIT 1;
    SELECT id INTO id_estado_reprobado FROM estadoModuloR WHERE estado = 'Reprobado' LIMIT 1;
    SELECT idModuloRuta INTO id_modulo_ruta
    FROM matricula
    WHERE id = NEW.idMatricula;
    IF NEW.nota >= 60 THEN
        UPDATE modulosRuta
        SET idEstadoModuloR = id_estado_aprobado
        WHERE id = id_modulo_ruta;
    ELSE
        UPDATE modulosRuta
        SET idEstadoModuloR = id_estado_reprobado
        WHERE id = id_modulo_ruta;
    END IF;
END;
//
DELIMITER ;
-- 16. Al asignar un módulo, verificar que el trainer tenga ese conocimiento.
DELIMITER //
CREATE TRIGGER tr_verificar_conocimiento_trainer
BEFORE INSERT ON modulosRuta
FOR EACH ROW
BEGIN
    DECLARE trainer_id INT;
    DECLARE count_habilidades INT;
    SELECT idTrainer INTO trainer_id
    FROM grupo
    WHERE idRutaAprendizaje = NEW.idRutaAprendizaje
    LIMIT 1;
    IF trainer_id IS NOT NULL THEN
        SELECT COUNT(*) INTO count_habilidades
        FROM habilidadesTrainer ht
        WHERE ht.idTrainer = trainer_id
        AND ht.idHabilidad IN (
            SELECT id FROM habilidades WHERE nombreHabilidad LIKE CONCAT('%', (
                SELECT nombreModulo FROM modulos WHERE id = NEW.idModulo
            ), '%')
        );
        IF count_habilidades = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El trainer asignado no tiene las habilidades requeridas para este módulo';
        END IF;
    END IF;
END;
//
DELIMITER ;
-- 17. Al cambiar el estado de un área a inactiva, liberar campers asignados.
DELIMITER //
CREATE TRIGGER tr_liberar_campers_salon_inactivo
AFTER UPDATE ON estadoSalon
FOR EACH ROW
BEGIN
    IF NEW.nombreEstado = 'Inactivo' AND OLD.nombreEstado != 'Inactivo' THEN
        DELETE FROM trainerHorario
        WHERE idSalon IN (
            SELECT id FROM salon WHERE idEstadoSalon = NEW.id
        );
    END IF;
END;
//
DELIMITER ;
-- 18. Al crear una nueva ruta, clonar la plantilla base de módulos y SGDBs.
DELIMITER //
CREATE TRIGGER tr_clonar_plantilla_ruta
AFTER INSERT ON rutaAprendizaje
FOR EACH ROW
BEGIN
    DECLARE ruta_plantilla_id INT;
    SET ruta_plantilla_id = 1;
    INSERT INTO modulosRuta (fechaInicio, fechaFin, idModulo, idRutaAprendizaje, idEstadoModuloR)
    SELECT fechaInicio, fechaFin, idModulo, NEW.id, idEstadoModuloR
    FROM modulosRuta
    WHERE idRutaAprendizaje = ruta_plantilla_id;
    INSERT INTO sRuta (idSGDB, idRutaAprendizaje, idSGDBA)
    SELECT idSGDB, NEW.id, idSGDBA
    FROM sRuta
    WHERE idRutaAprendizaje = ruta_plantilla_id;
END;
//
DELIMITER ;
-- 19. Al registrar la nota práctica, verificar que no supere 60% del total.
DELIMITER //
CREATE TRIGGER tr_validar_porcentaje_nota_practica
BEFORE INSERT ON calificaciones
FOR EACH ROW
BEGIN
    DECLARE tipo_evaluacion VARCHAR(50);
    DECLARE porcentaje DECIMAL(5,2);
    DECLARE nota_maxima DECIMAL(5,2) DEFAULT 100.0;
    SELECT te.tipo, CAST(te.porcentaje AS DECIMAL(5,2))
    INTO tipo_evaluacion, porcentaje
    FROM evaluacion e
    JOIN tipoEvaluacion te ON e.idTipoEvaluacion = te.id
    WHERE e.id = NEW.idEvaluacion;
    IF tipo_evaluacion = 'Practica' AND porcentaje > 0.6 THEN
        IF NEW.calificacion > (nota_maxima * 0.6) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La nota práctica no puede superar el 60% del total';
        END IF;
    END IF;
END;
//
DELIMITER ;
-- 20. Al modificar una ruta, notificar cambios a los trainers asignados.