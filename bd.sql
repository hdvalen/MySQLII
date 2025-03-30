CREATE DATABASE proyectoMysql;
USE proyectoMysql;

CREATE TABLE IF NOT EXISTS pais (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombrePais VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS departamento(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombreDepartamento VARCHAR(50),
    idPais INT,
    CONSTRAINT id_pais_FK FOREIGN KEY (idPais) REFERENCES pais(id)
);
CREATE TABLE IF NOT EXISTS ciudad(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombreCiudad VARCHAR(50),
    idDepartamento INT,
    CONSTRAINT id_departamento_FK FOREIGN KEY (idDepartamento) REFERENCES departamento(id)
);
CREATE TABLE IF NOT EXISTS direccion(
    id INT AUTO_INCREMENT PRIMARY KEY,
    direccion VARCHAR(50),
    idCiudad INT,
    CONSTRAINT id_ciudad_FK FOREIGN KEY (idCiudad) REFERENCES ciudad(id)
);
CREATE TABLE IF NOT EXISTS empresa(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombreEmpresa VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS sedes(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombreSede VARCHAR(50),
    idEmpresa INT,
    CONSTRAINT id_empresa_FK FOREIGN KEY (idEmpresa) REFERENCES empresa(id)
);
CREATE TABLE IF NOT EXISTS direccionSede(
    id INT AUTO_INCREMENT PRIMARY KEY,
    idSede INT,
    idDireccion INT,
    CONSTRAINT id_sede_FK FOREIGN KEY (idSede) REFERENCES sedes(id),
    CONSTRAINT id_direccion_FK FOREIGN KEY (idDireccion) REFERENCES direccion(id)
);
CREATE TABLE IF NOT EXISTS habilidades(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombreHabilidad VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS horario(
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    descripcion VARCHAR(50),
    am VARCHAR(50),
    pm VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS estadoSalon(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombreEstado VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS salon(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombreSalon VARCHAR(50),
    idEstadoSalon INT,
    CONSTRAINT id_estado_salon_FK FOREIGN KEY (idEstadoSalon) REFERENCES estadoSalon(id)
);
CREATE TABLE IF NOT EXISTS sgdb(
    id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS estadoModuloR(
    id INT AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS tipoEvaluacion(
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(50),
    porcentaje VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS estadoEvaluacion(
    id INT AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS estadoCamper(
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipoEstado VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS nivelRiesgo(
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipoNivel VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS acudiente(
    id INT AUTO_INCREMENT PRIMARY KEY,
    identificacion VARCHAR(50),
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    telefono VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS trainers(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    identificacion VARCHAR(50),
    idSede INT,
    CONSTRAINT id_sedes_FK FOREIGN KEY (idSede) REFERENCES sedes(id)    
);
CREATE TABLE IF NOT EXISTS habilidadesTrainer(
    id INT AUTO_INCREMENT PRIMARY KEY,
    idTrainer INT,
    idHabilidad INT,
    CONSTRAINT id_trainer_FK FOREIGN KEY (idTrainer) REFERENCES trainers(id),
    CONSTRAINT id_habilidad_FK FOREIGN KEY (idHabilidad) REFERENCES habilidades(id)
);
CREATE TABLE IF NOT EXISTS trainerHorario(
    id INT AUTO_INCREMENT PRIMARY KEY,
    idTrainer INT,
    idHorario INT,
    idSalon INT,
    CONSTRAINT id_salon_FK FOREIGN KEY (idSalon) REFERENCES salon(id),
    CONSTRAINT id_trainers_FK FOREIGN KEY (idTrainer) REFERENCES trainers(id),
    CONSTRAINT id_horario_FK FOREIGN KEY (idHorario) REFERENCES horario(id)
);
CREATE TABLE IF NOT EXISTS rutaAprendizaje(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombreRuta VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS grupo(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombreGrupo VARCHAR(50),
    idTrainer INT,
    idRutaAprendizaje INT,
    CONSTRAINT id_trainerrs_FK FOREIGN KEY (idTrainer) REFERENCES trainers(id),
    CONSTRAINT id_ruta_aprendizaje_FK FOREIGN KEY (idRutaAprendizaje) REFERENCES rutaAprendizaje(id)
);
CREATE TABLE IF NOT EXISTS modulos(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombreModulo VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS sRuta(
    id INT AUTO_INCREMENT PRIMARY KEY,
    idSGDB INT,
    idRutaAprendizaje INT,
    idSGDBA INT,
    CONSTRAINT id_sgdb_FK FOREIGN KEY (idSGDB) REFERENCES sgdb(id),
    CONSTRAINT id_sgdba_FK FOREIGN KEY (idSGDBA) REFERENCES sgdb(id),
    CONSTRAINT id_rutas_aprendizaje_FK FOREIGN KEY (idRutaAprendizaje) REFERENCES rutaAprendizaje(id)
);
CREATE TABLE IF NOT EXISTS modulosRuta(
    id INT AUTO_INCREMENT PRIMARY KEY,
    fechaInicio DATE,
    fechaFin DATE,
    idModulo INT,
    idRutaAprendizaje INT,
    idEstadoModuloR INT,
    CONSTRAINT id_estado_modulo_FK FOREIGN KEY (idEstadoModuloR) REFERENCES estadoModuloR(id),
    CONSTRAINT id_modulo_FK FOREIGN KEY (idModulo) REFERENCES modulos(id),
    CONSTRAINT id_rutas_aprendizajes_FK FOREIGN KEY (idRutaAprendizaje) REFERENCES rutaAprendizaje(id)
);
CREATE TABLE IF NOT EXISTS evaluacion(
    id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(50),
    fecha DATE,
    idTipoEvaluacion INT,
    idModuloRuta INT,
    idEstadoEvaluacion INT,
    CONSTRAINT id_modulo_ruta_FK FOREIGN KEY (idModuloRuta) REFERENCES modulosRuta(id),
    CONSTRAINT id_tipo_evaluacion_FK FOREIGN KEY (idTipoEvaluacion) REFERENCES tipoEvaluacion(id),
    CONSTRAINT id_estado_evaluacion_FK FOREIGN KEY (idEstadoEvaluacion) REFERENCES estadoEvaluacion(id)
);
CREATE TABLE IF NOT EXISTS sesiones(
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    tema VARCHAR(50),
    idModuloRuta INT,
    CONSTRAINT id_modulos_ruta_FK FOREIGN KEY (idModuloRuta) REFERENCES modulosRuta(id)
);
CREATE TABLE IF NOT EXISTS campers(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    identificacion VARCHAR(50),
    telefono VARCHAR(50),
    fechaInscripcion DATE,
    idSede INT,
    idNivelRiesgo INT,
    idAcudiente INT,
    idEstadoCamper INT,
    idRutaAprendizaje INT,
    CONSTRAINT id_acudiente_FK FOREIGN KEY (idAcudiente) REFERENCES acudiente(id),
    CONSTRAINT id_estado_camper_FK FOREIGN KEY (idEstadoCamper) REFERENCES estadoCamper(id),    
    CONSTRAINT id_nivel_riesgo_FK FOREIGN KEY (idNivelRiesgo) REFERENCES nivelRiesgo(id),
    CONSTRAINT id_sedess_FK FOREIGN KEY (idSede) REFERENCES sedes(id),
    CONSTRAINT id_rutass_aprendizaje_FK FOREIGN KEY (idRutaAprendizaje) REFERENCES rutaAprendizaje(id)   
);
CREATE TABLE IF NOT EXISTS direccionCamper(
    id INT AUTO_INCREMENT PRIMARY KEY,
    idCamper INT,
    idDireccion INT,
    CONSTRAINT id_camper_FK FOREIGN KEY (idCamper) REFERENCES campers(id),
    CONSTRAINT id_direcciones_FK FOREIGN KEY (idDireccion) REFERENCES direccion(id)
);
CREATE TABLE IF NOT EXISTS asistencia(
    id INT AUTO_INCREMENT PRIMARY KEY,
    idCamper INT,
    idSesion INT,
    CONSTRAINT id_campers_FK FOREIGN KEY (idCamper) REFERENCES campers(id),
    CONSTRAINT id_sesion_FK FOREIGN KEY (idSesion) REFERENCES sesiones(id)
);
CREATE TABLE IF NOT EXISTS graduados(
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    idCamper INT,
    CONSTRAINT id_camperrs_FK FOREIGN KEY (idCamper) REFERENCES campers(id)
);
CREATE TABLE IF NOT EXISTS historialCamper(
    id INT AUTO_INCREMENT PRIMARY KEY,
    estadoAnterior VARCHAR(50),
    estadoNuevo VARCHAR(50),
    idCamper INT,
    CONSTRAINT id_caampers_FK FOREIGN KEY (idCamper) REFERENCES campers(id)   
);
CREATE TABLE IF NOT EXISTS detalleGrupo(
    id INT AUTO_INCREMENT PRIMARY KEY,
    idGrupo INT,
    idCamper INT,
    CONSTRAINT id_grupo_FK FOREIGN KEY (idGrupo) REFERENCES grupo(id),
    CONSTRAINT id_ccampers_FK FOREIGN KEY (idCamper) REFERENCES campers(id)
);
CREATE TABLE IF NOT EXISTS telefono(
    id INT AUTO_INCREMENT PRIMARY KEY,
    telefono VARCHAR(50),
    idCamper INT,
    CONSTRAINT id_camperss_FK FOREIGN KEY (idCamper) REFERENCES campers(id)
);
CREATE TABLE IF NOT EXISTS matricula(
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    idCamper INT,
    idModuloRuta INT,
    CONSTRAINT id_modulos_rutas_FK FOREIGN KEY (idModuloRuta) REFERENCES modulosRuta(id),
    CONSTRAINT id_camppers_FK FOREIGN KEY (idCamper) REFERENCES campers(id)
);
CREATE TABLE IF NOT EXISTS notaFinal(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nota DECIMAL,
    idMatricula INT,
    CONSTRAINT id_matricula_FK FOREIGN KEY (idMatricula) REFERENCES matricula(id)
);
CREATE TABLE IF NOT EXISTS calificaciones(
    id INT AUTO_INCREMENT PRIMARY KEY,
    calificacion DECIMAL,
    idEvaluacion INT,
    idMatricula INT,
    CONSTRAINT id_evaluacion_FK FOREIGN KEY (idEvaluacion) REFERENCES evaluacion(id),
    CONSTRAINT id_matriculas_FK FOREIGN KEY (idMatricula) REFERENCES matricula(id)
);


