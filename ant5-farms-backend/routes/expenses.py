from flask import Blueprint, request, jsonify
from config.db import execute_query
from datetime import date, datetime, timedelta

expenses_bp = Blueprint('expenses', __name__)

def week_bounds(target_date=None):
    """Devuelve (lunes, domingo) de la semana del target_date (o de hoy)"""
    d = target_date or date.today()
    monday = d - timedelta(days=d.weekday())
    sunday = monday + timedelta(days=6)
    return monday, sunday

@expenses_bp.route('/', methods=['POST'])
def create_expense():
    """
    Crear un nuevo gasto
    ---
    tags:
      - Expenses
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - user_id
            - category_id
            - amount
          properties:
            user_id:
              type: integer
              example: 1
            category_id:
              type: integer
              example: 1
            amount:
              type: number
              example: 45.50
            description:
              type: string
              example: Tacos al pastor
            date:
              type: string
              format: date
              example: 2025-10-25
    responses:
      201:
        description: Gasto creado exitosamente
      400:
        description: Datos inválidos
    """
    data = request.get_json() or {}
    user_id = data.get('user_id')
    category_id = data.get('category_id')  # AHORA ES category_id
    amount = data.get('amount')
    description = data.get('description', '')
    date_str = data.get('date')

    if not all([user_id, category_id, amount]):
        return jsonify({'success': False, 'message': 'Faltan datos requeridos'}), 400

    # Parsear fecha
    try:
        expense_date = datetime.strptime(date_str, '%Y-%m-%d').date() if date_str else date.today()
    except:
        return jsonify({'success': False, 'message': 'Formato de fecha inválido (YYYY-MM-DD)'}), 400

    # Validar usuario
    if not execute_query("SELECT id FROM users WHERE id=%s", (user_id,), fetch=True):
        return jsonify({'success': False, 'message': 'Usuario no existe'}), 404

    # Validar categoría
    if not execute_query("SELECT id FROM category WHERE id=%s", (category_id,), fetch=True):
        return jsonify({'success': False, 'message': 'Categoría no existe'}), 404

    # Insertar gasto
    query = """
        INSERT INTO expenses (user_id, category_id, amount, description, date)
        VALUES (%s, %s, %s, %s, %s)
    """
    expense_id = execute_query(query, (user_id, category_id, amount, description, expense_date))

    return jsonify({'success': True, 'expense_id': expense_id}), 201

@expenses_bp.route('/weekly/<int:user_id>', methods=['GET'])
def get_weekly_expenses(user_id):
    """
    Obtener gastos de la semana actual (con nombre de categoría)
    ---
    tags:
      - Expenses
    parameters:
      - in: path
        name: user_id
        type: integer
        required: true
        description: ID del usuario
        example: 1
    responses:
      200:
        description: Lista de gastos de la semana
    """
    monday, sunday = week_bounds()
    
    query = """
        SELECT e.id, e.user_id, e.category_id, c.name AS category_name,
               e.amount, e.description, e.date
        FROM expenses e
        LEFT JOIN category c ON c.id = e.category_id
        WHERE e.user_id = %s
          AND e.date BETWEEN %s AND %s
        ORDER BY e.date DESC
    """
    expenses = execute_query(query, (user_id, monday, sunday), fetch=True) or []

    return jsonify({
        'success': True,
        'period': {'from': str(monday), 'to': str(sunday)},
        'expenses': expenses
    }), 200

@expenses_bp.route('/summary/<int:user_id>', methods=['GET'])
def get_weekly_summary(user_id):
    """
    Resumen de gastos vs metas de la semana actual
    ---
    tags:
      - Expenses
    parameters:
      - in: path
        name: user_id
        type: integer
        required: true
        description: ID del usuario
        example: 1
    responses:
      200:
        description: Resumen semanal con porcentajes
    """
    monday, sunday = week_bounds()

    # Gastos por categoría esta semana
    spent_query = """
        SELECT c.id AS category_id, c.name AS category_name, 
               COALESCE(SUM(e.amount), 0) AS spent
        FROM category c
        LEFT JOIN expenses e ON e.category_id = c.id 
                             AND e.user_id = %s
                             AND e.date BETWEEN %s AND %s
        GROUP BY c.id, c.name
        ORDER BY c.name
    """
    spent_rows = execute_query(spent_query, (user_id, monday, sunday), fetch=True) or []

    # Metas del usuario por categoría
    goals_query = """
        SELECT g.category_id, g.money
        FROM goal g
        WHERE g.user_id = %s
    """
    goal_rows = execute_query(goals_query, (user_id,), fetch=True) or []
    goal_map = {r['category_id']: float(r['money']) for r in goal_rows}

    # Combinar datos
    per_category = []
    total_spent = 0.0
    total_budget = 0.0

    for row in spent_rows:
        cat_id = row['category_id']
        spent = float(row['spent'] or 0)
        goal = float(goal_map.get(cat_id, 0))
        
        total_spent += spent
        total_budget += goal
        
        per_category.append({
            'category_id': cat_id,
            'category_name': row['category_name'],
            'spent': round(spent, 2),
            'goal': round(goal, 2),
        })

    # Calcular porcentajes
    expended_pct = round((total_spent / total_budget) * 100, 2) if total_budget > 0 else 0.0
    saved_pct = round(max(0.0, 100.0 - expended_pct), 2)

    return jsonify({
        'success': True,
        'period': {'from': str(monday), 'to': str(sunday)},
        'total_spent': round(total_spent, 2),
        'total_budget': round(total_budget, 2),
        'expended_pct': expended_pct,
        'saved_pct': saved_pct,
        'per_category': per_category
    }), 200

@expenses_bp.route('/<int:expense_id>', methods=['DELETE'])
def delete_expense(expense_id):
    """
    Eliminar un gasto por ID
    ---
    tags:
      - Expenses
    parameters:
      - in: path
        name: expense_id
        type: integer
        required: true
        description: ID del gasto a eliminar
    responses:
      200:
        description: Gasto eliminado exitosamente
    """
    query = "DELETE FROM expenses WHERE id = %s"
    execute_query(query, (expense_id,))

    return jsonify({'success': True, 'message': 'Gasto eliminado'}), 200