import os
import boto3
import datetime
from cryptography.fernet import Fernet
# import mysql.connector (Lo activaremos luego)

# --- CONFIGURACIÓN (Luego moveremos esto a variables de entorno para seguridad) ---
DIRECTORIO_ORIGEN = "/home/ejcb/documentos_importantes" # Carpeta a copiar
NOMBRE_BUCKET = "AQUI_TU_NOMBRE_DE_BUCKET"
TEMP_DIR = "/tmp/backups"

def generar_backup_local():
    """
    1. Comprime la carpeta de origen en un archivo .zip
    Return: ruta del archivo zip generado
    """
    print(f"[INFO] Iniciando compresión de {DIRECTORIO_ORIGEN}...")
    # TODO: Implementar lógica de compresión
    pass

def cifrar_archivo(ruta_archivo):
    """
    2. Cifra el archivo .zip usando una clave simétrica
    Return: ruta del archivo cifrado
    """
    print("[INFO] Cifrando archivo para cumplimiento RGPD...")
    # TODO: Implementar cifrado con Cryptography
    pass

def subir_a_s3(ruta_archivo_cifrado):
    """
    3. Sube el archivo cifrado al bucket S3 de AWS
    """
    print(f"[INFO] Subiendo {ruta_archivo_cifrado} a AWS S3...")
    # TODO: Implementar conexión con boto3
    pass

def registrar_log_db(estado, mensaje):
    """
    4. Conecta con la BD en EC2 y guarda el resultado
    """
    print(f"[DB] Registrando evento: {estado} - {mensaje}")
    # TODO: Implementar conexión MySQL
    pass

# --- FLUJO PRINCIPAL ---
if __name__ == "__main__":
    print("--- INICIO DE SISTEMA DE BACKUP AUTOMATIZADO ---")
    
    # Simulación de pasos (para probar que el script corre)
    try:
        archivo_zip = generar_backup_local()
        archivo_cifrado = cifrar_archivo(archivo_zip)
        subir_a_s3(archivo_cifrado)
        registrar_log_db("EXITO", "Copia realizada correctamente")
        
    except Exception as e:
        print(f"[ERROR] Ha ocurrido un fallo: {e}")
        registrar_log_db("ERROR", str(e))