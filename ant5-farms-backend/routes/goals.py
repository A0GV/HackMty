from flask import Blueprint, request, jsonify
from config.db import execute_query

goals_bp = Blueprint('goals', __name__)

@goals_bp.route('/<int:user_id>', methods=['GET'])
def get_goals(user_id):
    """
    Obtener las metas del usuario (por categoría)
    ---
    tags:
      - Goals
    parameters:
      - in: path
        name: user_id
        type: integer
        required: true
        description: ID del usuario
        example: 1
    responses:
      200:
        description: Lista de metas del usuario (siempre 6 categorías)
        schema:
          type: object
          properties:
            success:
              type: boolean
            goals:
              type: array
              items:
                type: object
                properties:
                  id:
                    type: integer
                  user_id:
                    type: integer
                  category_id:
                    type: integer
                  category_name:
                    type: string
                  money:
                    type: number
    """
    query = """
        SELECT g.id, g.user_id, g.category_id, c.name AS category_name, g.money
        FROM goal g
        JOIN category c ON c.id = g.category_id
        WHERE g.user_id = %s
        ORDER BY c.id
    """
    rows = execute_query(query, (user_id,), fetch=True) or []
    
    # Verificar que el usuario tenga las 6 metas (por si acaso)
    if len(rows) < 6:
        return jsonify({
            'success': False, 
            'message': 'Usuario no tiene metas inicializadas. Contacta soporte.'
        }), 500
    
    return jsonify({'success': True, 'goals': rows}), 200


@goals_bp.route('/bulk/<int:user_id>', methods=['PUT'])
def update_goals_bulk(user_id):
    """
    Actualizar múltiples metas a la vez (pantalla de Goals)
    ---
    tags:
      - Goals
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
            - goals
          properties:
            goals:
              type: array
              description: Array con las 6 categorías y sus montos
              items:
                type: object
                required:
                  - category_id
                  - money
                properties:
                  category_id:
                    type: integer
                    example: 1
                  money:
                    type: number
                    example: 500.00
              example:
                - category_id: 1
                  money: 500.00
                - category_id: 2
                  money: 350.00
                - category_id: 3
                  money: 0.00
                - category_id: 4
                  money: 350.00
                - category_id: 5
                  money: 350.00
                - category_id: 6
                  money: 50.00
    responses:
      200:
        description: Metas actualizadas exitosamente
      400:
        description: Datos inválidos (deben ser 6 metas)
    """
    data = request.get_json() or {}
    goals = data.get('goals', [])

    # Validar que sean exactamente 6 metas
    if len(goals) != 6:
        return jsonify({
            'success': False, 
            'message': 'Deben enviarse exactamente 6 metas (una por categoría)'
        }), 400

    # Validar que el usuario exista
    if not execute_query("SELECT id FROM users WHERE id=%s", (user_id,), fetch=True):
        return jsonify({'success': False, 'message': 'Usuario no existe'}), 404

    # Validar que todas las categorías sean válidas (1-6)
    category_ids = [g.get('category_id') for g in goals]
    if set(category_ids) != {1, 2, 3, 4, 5, 6}:
        return jsonify({
            'success': False,
            'message': 'Deben incluirse las 6 categorías (IDs: 1, 2, 3, 4, 5, 6)'
        }), 400

    # Actualizar cada meta (solo el monto)
    update_query = """
        UPDATE goal 
        SET money = %s 
        WHERE user_id = %s AND category_id = %s
    """
    
    for goal in goals:
        category_id = goal.get('category_id')
        money = goal.get('money', 0.00)
        
        # Asegurar que money no sea negativo
        money = max(0, float(money))
        
        execute_query(update_query, (money, user_id, category_id))
    
    return jsonify({
        'success': True
    }), 200
