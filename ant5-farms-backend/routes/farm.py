from flask import Blueprint, request, jsonify
from config.db import execute_query

farm_bp = Blueprint('farm', __name__)

@farm_bp.route('/<int:user_id>', methods=['GET'])
def get_farm(user_id):
    """
    Obtener datos de la granja del usuario
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
        description: Datos de la granja
        schema:
          type: object
          properties:
            success:
              type: boolean
            farm:
              type: object
              properties:
                id:
                  type: integer
                user_id:
                  type: integer
                ants_count:
                  type: integer
                leaves_count:
                  type: integer
                bonus_leaves_earned:
                  type: integer
                  description: Total de días únicos que ha hecho login
      404:
        description: Granja no encontrada
    """
    query = "SELECT * FROM farm WHERE user_id = %s"
    farm = execute_query(query, (user_id,), fetch=True)
    
    if not farm:
        return jsonify({'success': False, 'message': 'Granja no encontrada'}), 404
    
    return jsonify({
        'success': True,
        'farm': farm[0]
    }), 200


@farm_bp.route('/<int:user_id>/daily-production', methods=['GET'])
def get_daily_production(user_id):
    """
    Calcular cuántas hojas producirá el usuario HOY
    Fórmula: (ants_count * 5) + bonus_leaves_earned
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
        description: Producción diaria de hojas
        schema:
          type: object
          properties:
            success:
              type: boolean
            daily_production:
              type: object
              properties:
                ants_count:
                  type: integer
                  description: Número de hormigas
                bonus_leaves_earned:
                  type: integer
                  description: Bonus acumulado (días de login)
                leaves_from_ants:
                  type: integer
                  description: Hojas que dan las hormigas (ants * 5)
                leaves_from_bonus:
                  type: integer
                  description: Hojas del bonus
                total_leaves_today:
                  type: integer
                  description: Total de hojas del día
      404:
        description: Usuario no encontrado
    """
    # Obtener datos de la granja
    query = "SELECT ants_count, bonus_leaves_earned FROM farm WHERE user_id = %s"
    farm = execute_query(query, (user_id,), fetch=True)
    
    if not farm:
        return jsonify({'success': False, 'message': 'Usuario no encontrado'}), 404
    
    farm = farm[0]
    ants_count = farm['ants_count']
    bonus_leaves = farm['bonus_leaves_earned']
    
    # Calcular producción
    leaves_from_ants = ants_count * 5
    leaves_from_bonus = bonus_leaves
    total_leaves_today = leaves_from_ants + leaves_from_bonus
    
    return jsonify({
        'success': True,
        'daily_production': {
            'ants_count': ants_count,
            'bonus_leaves_earned': bonus_leaves,
            'leaves_from_ants': leaves_from_ants,
            'leaves_from_bonus': leaves_from_bonus,
            'total_leaves_today': total_leaves_today
        }
    }), 200


@farm_bp.route('/<int:user_id>/ants', methods=['POST'])
def add_ant(user_id):
    """
    Agregar una hormiga (recompensa por ahorrar)
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
        description: Hormiga agregada exitosamente
        schema:
          type: object
          properties:
            success:
              type: boolean
            farm:
              type: object
    """
    query = "UPDATE farm SET ants_count = ants_count + 1 WHERE user_id = %s"
    execute_query(query, (user_id,))
    
    farm_query = "SELECT * FROM farm WHERE user_id = %s"
    farm = execute_query(farm_query, (user_id,), fetch=True)
    
    return jsonify({
        'success': True,
        'farm': farm[0] if farm else None
    }), 200


@farm_bp.route('/<int:user_id>/leaves', methods=['POST'])
def add_leaves(user_id):
    """
    Agregar hojas (ruleta, logros, etc)
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
              description: Cantidad de hojas a agregar
              example: 50
    responses:
      200:
        description: Hojas agregadas exitosamente
        schema:
          type: object
          properties:
            success:
              type: boolean
            farm:
              type: object
    """
    data = request.get_json()
    leaves_to_add = data.get('leaves', 0)
    
    query = "UPDATE farm SET leaves_count = leaves_count + %s WHERE user_id = %s"
    execute_query(query, (leaves_to_add, user_id))
    
    farm_query = "SELECT * FROM farm WHERE user_id = %s"
    farm = execute_query(farm_query, (user_id,), fetch=True)
    
    return jsonify({
        'success': True,
        'farm': farm[0] if farm else None
    }), 200

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