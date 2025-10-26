from flask import Blueprint, request, jsonify
from config.db import execute_query
from datetime import date

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['PUT'])
def login():
    """
    Login de usuario con sistema de bonus diario
    ---
    tags:
      - Authentication
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - username
            - password
          properties:
            username:
              type: string
              example: testuser
            password:
              type: string
              example: pass123
    responses:
      200:
        description: Login exitoso con información de bonus
        schema:
          type: object
          properties:
            success:
              type: boolean
            user:
              type: object
              properties:
                id:
                  type: integer
                username:
                  type: string
            farm:
              type: object
            bonus_info:
              type: object
              properties:
                leaves_earned_today:
                  type: integer
                  description: Hojas ganadas en este login
                total_login_days:
                  type: integer
                  description: Total de días únicos que ha hecho login
      401:
        description: Credenciales inválidas
    """
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    
    if not username or not password:
        return jsonify({'success': False, 'message': 'Username and password are required'}), 400
    
    # Buscar usuario
    query = "SELECT * FROM users WHERE username = %s AND password = %s"
    user = execute_query(query, (username, password), fetch=True)
    
    if not user:
        return jsonify({'success': False, 'message': 'Invalid credentials'}), 401
    
    user = user[0]
    user_id = user['id']
    last_login = user.get('last_login_date')
    today = date.today()
    todayyyy = True
    # Variables para la respuesta
    leaves_earned_today = 0

    # Sumar cantidad total de hormigas del usuario
    query_ants = """
        SELECT COALESCE(SUM(cant), 0) AS ants_count
        FROM ant_farm
        WHERE user_id = %s
    """
    ants_data = execute_query(query_ants, (user_id,), fetch=True)
    ants_count = ants_data[0]['ants_count'] if ants_data else 0
    ants_count = ants_count * 2
    # ===== NUEVA LÓGICA: Bonus por día único =====
    if last_login is None or last_login != today:
        # Es un día diferente (o primer login ever)
        todayyyy = False
        # Obtener la granja actual
        query_farm = "SELECT bonus_leaves_earned, leaves_count FROM farm WHERE user_id = %s"
        farm = execute_query(query_farm, (user_id,), fetch=True)
        
        if farm:
            current_bonus_leaves = farm[0]['bonus_leaves_earned']
            
            # El bonus incrementa: día 1 = 1 hoja, día 2 = 2 hojas, etc.
            new_bonus_leaves = current_bonus_leaves + 1
            leaves_earned_today = new_bonus_leaves + ants_count
            
            # Actualizar la granja
            update_farm = """
                UPDATE farm 
                SET bonus_leaves_earned = %s,
                    leaves_count = leaves_count + %s
                WHERE user_id = %s
            """
            execute_query(update_farm, (new_bonus_leaves, leaves_earned_today, user_id))
        
        # Actualizar último login
        update_user = "UPDATE users SET last_login_date = %s WHERE id = %s"
        execute_query(update_user, (today, user_id))
    else:
        # Ya hizo login hoy - no dar hojas
        leaves_earned_today = 0
    
    # Obtener datos actualizados de la granja
    query_farm = "SELECT * FROM farm WHERE user_id = %s"
    farm_data = execute_query(query_farm, (user_id,), fetch=True)
    
    return jsonify({
        'success': True,
        'id': user['id'],
        'today_logged' : todayyyy,
        'leaves_earned_today': leaves_earned_today
    }), 200

@auth_bp.route('/register', methods=['POST'])
def register():
    """
    Registrar nuevo usuario
    ---
    tags:
      - Authentication
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - username
            - password
          properties:
            username:
              type: string
              example: newuser
            password:
              type: string
              example: mypassword
    responses:
      201:
        description: Usuario registrado exitosamente
      409:
        description: Usuario ya existe
    """
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    
    if not username or not password:
        return jsonify({'success': False, 'message': 'Username y password requeridos'}), 400
    
    # Verificar si el usuario ya existe
    check_query = "SELECT id FROM users WHERE username = %s"
    existing_user = execute_query(check_query, (username,), fetch=True)
    
    if existing_user:
        return jsonify({'success': False, 'message': 'Usuario ya existe'}), 409
    
    # Crear usuario
    insert_user = "INSERT INTO users (username, password, last_login_date) VALUES (%s, %s, NULL)"
    user_id = execute_query(insert_user, (username, password))
    
    # Crear granja (sin current_streak, bonus_leaves_earned inicia en 0)
    insert_farm = "INSERT INTO farm (user_id, ants_count, leaves_count, bonus_leaves_earned) VALUES (%s, 1, 0, 0)"
    execute_query(insert_farm, (user_id,))
    
    # Crear metas iniciales en $0 para las 6 categorías
    insert_goals = """
        INSERT INTO goal (user_id, category_id, money)
        SELECT %s, id, 0.00 FROM category
    """
    execute_query(insert_goals, (user_id,))
    
    return jsonify({
        'success': True,
        'message': 'Usuario registrado exitosamente',
        'user_id': user_id
    }), 201