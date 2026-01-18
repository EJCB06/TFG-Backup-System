import mysql.connector
from datetime import datetime
import sys
import config  # Importamos el archivo que acabas de crear

def registrar_log_db(estado, mensaje, nombre_archivo="N/A", destino="AMBOS"):
    """
    Conecta con la BD en AWS y guarda el resultado del log.
    """
    print(f"[DB] Intentando registrar: {estado} - {mensaje}...")
    
    conexion = None
    try:
        # 1. Establecer conexión
        conexion = mysql.connector.connect(
            host=config.DB_HOST,
            user=config.DB_USER,
            password=config.DB_PASS,
            database=config.DB_NAME,
            connection_timeout=5
        )

        # 2. Preparar la sentencia SQL
        cursor = conexion.cursor()
        sql = """
            INSERT INTO backup_logs 
            (fecha_ejecucion, nombre_archivo, origen_datos, destino_almacenamiento, estado, mensaje_error)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        
        # 3. Datos a insertar
        fecha_actual = datetime.now()
        val = (fecha_actual, nombre_archivo, config.DIRECTORIO_ORIGEN, destino, estado, mensaje)
        
        # 4. Ejecutar y guardar
        cursor.execute(sql, val)
        conexion.commit()
        
        print("✅ [DB] Log guardado correctamente en AWS.")
        
    except Exception as e:
        print(f"❌ [DB] Error crítico conectando a la base de datos: {e}")
    
    finally:
        if conexion and conexion.is_connected():
            conexion.close()

# --- PRUEBA RÁPIDA ---
if __name__ == "__main__":
    print("--- TEST DE CONEXIÓN: LOCAL -> AWS ---")
    
    # Probamos a enviar un log de prueba
    registrar_log_db("EN_PROCESO", "Prueba de conexión inicial desde VS Code")