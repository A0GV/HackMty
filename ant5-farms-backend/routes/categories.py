from flask import Blueprint, jsonify
from config.db import execute_query

categories_bp = Blueprint('categories', __name__)

@categories_bp.route('/', methods=['GET'])
def list_categories():
    """
    Lista de categorías globales (para todos los usuarios)
    ---
    tags:
      - Categories
    responses:
      200:
        description: Lista de categorías
        schema:
          type: object
          properties:
            success:
              type: boolean
            categories:
              type: array
              items:
                type: object
                properties:
                  id:
                    type: integer
                  name:
                    type: string
    """
    query = "SELECT id, name FROM category ORDER BY name"
    rows = execute_query(query, fetch=True) or []
    return jsonify({'success': True, 'categories': rows}), 200