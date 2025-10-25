import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

# Cargar variables de entorno desde .env
load_dotenv()

def get_db_connection():
    """
    Crear conexión a la base de datos MySQL
    Lee las credenciales del archivo .env
    """
    try:
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST'),          # ant-farms-db-tec-a8de...
            port=int(os.getenv('DB_PORT')),     # 25602
            user=os.getenv('DB_USER'),          # avnadmin
            password=os.getenv('DB_PASSWORD'),  # tu password
            database=os.getenv('DB_NAME'),      # defaultdb
            ssl_disabled=False if os.getenv('DB_SSL') == 'True' else True
        )
        
        if connection.is_connected():
            return connection
    except Error as e:
        print(f"Error conectando a MySQL: {e}")
        return None

def execute_query(query, params=None, fetch=False):
    """
    Función helper para ejecutar queries SQL
    - query: El SQL a ejecutar (ej: "SELECT * FROM users WHERE id = %s")
    - params: Los parámetros seguros (ej: (1,))
    - fetch: True si quieres resultados, False si es INSERT/UPDATE/DELETE
    """
    connection = get_db_connection()
    if not connection:
        return None
    
    try:
        cursor = connection.cursor(dictionary=True)  # Retorna dict en vez de tuplas
        cursor.execute(query, params or ())
        
        if fetch:
            # Si es SELECT, obtener resultados
            result = cursor.fetchall()
        else:
            # Si es INSERT/UPDATE/DELETE, hacer commit
            connection.commit()
            result = cursor.lastrowid  # Retorna el ID del último INSERT
        
        cursor.close()
        connection.close()
        return result
    except Error as e:
        print(f"Error ejecutando query: {e}")
        return None