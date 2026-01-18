/*
  TFG - SISTEMA DE BACKUP AUTOMATIZADO
  Diseño de Base de Datos (MySQL)
  Autor: Edwin Javier Cueva Berenguer
*/

CREATE DATABASE IF NOT EXISTS backup_db;
USE backup_db;

-- Tabla de ejecución del script
CREATE TABLE IF NOT EXISTS backup_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha_ejecucion DATETIME DEFAULT CURRENT_TIMESTAMP,
    nombre_archivo VARCHAR(255) NOT NULL,
    origen_datos VARCHAR(255),
    destino_almacenamiento ENUM('S3', 'LOCAL', 'AMBOS') DEFAULT 'S3',
    tamano_kb DECIMAL(10,2),
    estado ENUM('EXITO', 'ERROR', 'EN_PROCESO') NOT NULL,
    mensaje_error TEXT,
    hash_verificacion VARCHAR(64) -- Para comprobar integridad (SHA256)
);

-- Usuario con permisos mínimos (Seguridad: Principio de menor privilegio)
-- NOTA: Cambiar 'ContrasenaSegura' al implementar
-- CREATE USER 'agente_python'@'%' IDENTIFIED BY 'ContrasenaSegura';
-- GRANT INSERT, SELECT ON backup_db.backup_logs TO 'agente_python'@'%';
-- FLUSH PRIVILEGES;