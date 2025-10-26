from flask import Blueprint, request, jsonify
from config.db import execute_query

farm_bp = Blueprint('farm', __name__)

@farm_bp.route('/<int:user_id>', methods=['GET'])
def get_farm(user_id):
    """
    Obtener conteo de hormigas y hojas de la granja del usuario
    ---
    tags:
      - Farm
    parameters:
      - in: path
        name: user_id
        type: integer
        required: true
        description: ID del usuario
        example: 1
    responses:
      200:
        description: Conteo de hormigas y hojas
        schema:
          type: object
          properties:
            ants_count:
              type: integer
            leaves_count:
              type: integer
            ants:
              type: array
              items:
                type: object
                properties:
                  name:
                    type: string
                  quantity:
                    type: integer
      404:
        description: Granja no encontrada
    """
    # Obtener información básica de la granja
    query_farm = "SELECT leaves_count FROM farm WHERE user_id = %s"
    farm = execute_query(query_farm, (user_id,), fetch=True)
    
    if not farm:
        return jsonify({'success': False, 'message': 'Granja no encontrada'}), 404

    # Obtener conteo total de hormigas
    query_ants_count = """
        SELECT COALESCE(SUM(cant), 0) AS ants_count
        FROM ant_farm
        WHERE user_id = %s
    """
    ants_data = execute_query(query_ants_count, (user_id,), fetch=True)
    ants_count = ants_data[0]['ants_count'] if ants_data else 0

    # Obtener lista detallada de hormigas con su nombre y cantidad
    query_ants_detail = """
        SELECT a.name, af.cant AS cant
        FROM ant_farm af
        INNER JOIN ants a ON af.id_ant = a.id_ant
        WHERE af.user_id = %s
        ORDER BY a.name
    """
    ants_list = execute_query(query_ants_detail, (user_id,), fetch=True)

    # Devolver respuesta completa
    return jsonify({
        'ants_count': ants_count,
        'leaves_count': farm[0]['leaves_count'],
        'ants': ants_list if ants_list else []
    }), 200


# @farm_bp.route('/<int:user_id>/daily-production', methods=['GET'])
# def get_daily_production(user_id):
#     """
#     Calcular cuántas hojas producirá el usuario HOY
#     Fórmula: (ants_count * 5) + bonus_leaves_earned
#     """
#     # Obtener bonus del usuario desde la tabla farm
#     query_farm = """
#         SELECT bonus_leaves_earned
#         FROM farm
#         WHERE user_id = %s
#     """
#     farm = execute_query(query_farm, (user_id,), fetch=True)

#     if not farm:
#         return jsonify({'success': False, 'message': 'Usuario no encontrado'}), 404

#     bonus_leaves = farm[0]['bonus_leaves_earned']

#     # Sumar cantidad total de hormigas del usuario
#     query_ants = """
#         SELECT COALESCE(SUM(cant), 0) AS ants_count
#         FROM ant_farm
#         WHERE user_id = %s
#     """
#     ants_data = execute_query(query_ants, (user_id,), fetch=True)
#     ants_count = ants_data[0]['ants_count'] if ants_data else 0

#     # Calcular producción
#     leaves_from_ants = ants_count * 5
#     leaves_from_bonus = bonus_leaves
#     total_leaves_today = leaves_from_ants + leaves_from_bonus

#     return jsonify({
#         'success': True,
#         'daily_production': {
#             'ants_count': ants_count,
#             'bonus_leaves_earned': bonus_leaves,
#             'leaves_from_ants': leaves_from_ants,
#             'leaves_from_bonus': leaves_from_bonus,
#             'total_leaves_today': total_leaves_today
#         }
#     }), 200



@farm_bp.route('/<int:user_id>/ants/<int:ant_id>', methods=['PUT'])
def add_ant(user_id, ant_id):
    """
    Actualizar una hormiga (recompensa por ahorrar)
    ---
    tags:
      - Farm
    parameters:
      - in: path
        name: user_id
        type: integer
        required: true
        description: ID del usuario
        example: 1
      - in: path
        name: ant_id
        type: integer
        required: true
        description: ID del tipo de hormiga
        example: 2
    responses:
      200:
        description: Hormiga agregada exitosamente
        schema:
          type: object
          properties:
            success:
              type: boolean
            ant_name:
              type: string
            quantity:
              type: integer
      404:
        description: Hormiga no encontrada
    """
    # Verificar que la hormiga existe en la tabla ants
    check_ant_query = "SELECT name FROM ants WHERE id_ant = %s"
    ant = execute_query(check_ant_query, (ant_id,), fetch=True)
    
    if not ant:
        return jsonify({'success': False, 'message': 'Hormiga no encontrada'}), 404
    
    # Verificar si el usuario ya tiene esta hormiga
    check_query = "SELECT cant FROM ant_farm WHERE user_id = %s AND id_ant = %s"
    existing_ant = execute_query(check_query, (user_id, ant_id), fetch=True)
    
    if existing_ant:
        # Si ya existe, incrementar la cantidad
        update_query = "UPDATE ant_farm SET cant = cant + 1 WHERE user_id = %s AND id_ant = %s"
        execute_query(update_query, (user_id, ant_id))
        new_quantity = existing_ant[0]['cant'] + 1
    else:
        # Si no existe, crear nueva entrada
        insert_query = "INSERT INTO ant_farm (user_id, id_ant, cant) VALUES (%s, %s, 1)"
        execute_query(insert_query, (user_id, ant_id))
        new_quantity = 1
    
    return jsonify({
        'success': True
    }), 200


# @farm_bp.route('/<int:user_id>/leaves', methods=['POST'])
# def add_leaves(user_id):
#     """
#     Agregar hojas (ruleta, logros, etc)
#     ---
#     tags:
#       - Farm
#     parameters:
#       - in: path
#         name: user_id
#         type: integer
#         required: true
#         description: ID del usuario
#         example: 1
#       - in: body
#         name: body
#         required: true
#         schema:
#           type: object
#           required:
#             - leaves
#           properties:
#             leaves:
#               type: integer
#               description: Cantidad de hojas a agregar
#               example: 50
#     responses:
#       200:
#         description: Hojas agregadas exitosamente
#         schema:
#           type: object
#           properties:
#             success:
#               type: boolean
#             farm:
#               type: object
#     """
#     data = request.get_json()
#     leaves_to_add = data.get('leaves', 0)
    
#     query = "UPDATE farm SET leaves_count = leaves_count + %s WHERE user_id = %s"
#     execute_query(query, (leaves_to_add, user_id))
    
#     farm_query = "SELECT * FROM farm WHERE user_id = %s"
#     farm = execute_query(farm_query, (user_id,), fetch=True)
    
#     return jsonify({
#         'success': True,
#         'farm': farm[0] if farm else None
#     }), 200

@farm_bp.route('/<int:user_id>/leaves', methods=['PUT'])
def update_leaves(user_id):
    """
    Actualizar cantidad de hojas (sumar o restar)
    ---
    tags:
      - Farm
    parameters:
      - in: path
        name: user_id
        type: integer
        required: true
        description: ID del usuario
        example: 1
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - leaves
          properties:
            leaves:
              type: integer
              description: Cantidad a sumar (positivo) o restar (negativo)
              example: -50
    responses:
      200:
        description: Hojas actualizadas exitosamente
      400:
        description: Datos inválidos o saldo insuficiente
      404:
        description: Usuario no encontrado
    """
    data = request.get_json() or {}
    leaves_change = data.get('leaves')
    
    # Validar que se envió la cantidad
    if leaves_change is None:
        return jsonify({
            'success': False, 
            'message': 'Campo "leaves" requerido'
        }), 400
    
    # Validar que sea un número válido
    try:
        leaves_change = int(leaves_change)
    except (ValueError, TypeError):
        return jsonify({
            'success': False,
            'message': 'El campo "leaves" debe ser un número entero'
        }), 400
    
    # Obtener cantidad actual de hojas
    query_current = "SELECT leaves_count FROM farm WHERE user_id = %s"
    farm = execute_query(query_current, (user_id,), fetch=True)
    
    if not farm:
        return jsonify({
            'success': False,
            'message': 'Usuario no encontrado'
        }), 404
    
    current_leaves = farm[0]['leaves_count']
    new_leaves = current_leaves + leaves_change
    
    # Validar que no quede negativo
    if new_leaves < 0:
        return jsonify({
            'success': False,
            'message': 'Saldo insuficiente',
            'current_leaves': current_leaves,
            'attempted_change': leaves_change,
            'required': abs(leaves_change)
        }), 400
    
    # Actualizar hojas
    update_query = "UPDATE farm SET leaves_count = %s WHERE user_id = %s"
    execute_query(update_query, (new_leaves, user_id))
    
    # Obtener datos actualizados
    farm_query = "SELECT * FROM farm WHERE user_id = %s"
    updated_farm = execute_query(farm_query, (user_id,), fetch=True)
    
    return jsonify({
        'success': True,
        'previous_leaves': current_leaves,
        'leaves_change': leaves_change,
        'new_leaves': new_leaves,
        'farm': updated_farm[0] if updated_farm else None
    }), 200