from flask import Blueprint, request, jsonify
from config.db import execute_query
from datetime import date, datetime, timedelta
import os
import json
import re
from pathlib import Path
from google import genai
from google.genai import types
from dotenv import load_dotenv

# Cargar variables del archivo .env
load_dotenv()

# Leer la API key del entorno
api_key = os.environ.get('GENAI_API_KEY')

# Crear el cliente de Gemini
client = genai.Client(api_key=api_key)

# =========================
#  Blueprint
# =========================
expenses_bp = Blueprint('expenses', __name__)

# =========================
#  Helpers
# =========================
def week_bounds(target_date=None):
    """Devuelve (lunes, domingo) de la semana del target_date (o de hoy)"""
    d = target_date or date.today()
    monday = d - timedelta(days=d.weekday())
    sunday = monday + timedelta(days=6)
    return monday, sunday

def _strip_markdown_fences(s: str) -> str:
    s = (s or "").strip()
    if s.startswith("```"):
        lines = s.splitlines()
        if lines and lines[0].lstrip().startswith("```"):
            lines = lines[1:]
        for i, line in enumerate(lines):
            if line.strip().startswith("```"):
                lines = lines[:i]
                break
        s = "\n".join(lines).strip()
    return s

def _try_parse_json(s: str):
    # 1) Directo
    try:
        return json.loads(s)
    except Exception:
        pass
    # 2) Quitando fences
    s2 = _strip_markdown_fences(s)
    try:
        return json.loads(s2)
    except Exception:
        pass
    # 3) Extraer bloque { ... }
    start = s2.find("{")
    end = s2.rfind("}")
    if start != -1 and end != -1 and end > start:
        candidate = s2[start:end+1]
        return json.loads(candidate)
    raise ValueError("No se pudo parsear JSON de Gemini.")

CAT_MAP = {
    1: "food",
    2: "drinks",
    3: "subscriptions",
    4: "small_payment",
    5: "transport",
    6: "others",
}
NAME_TO_ID = {v: k for k, v in CAT_MAP.items()}

# Prompt: fecha NO se toma del ticket; el backend fija date = fecha de subida (hoy)
GEMINI_PROMPT = (
    "LEE LA IMAGEN DEL RECIBO Y DEVUELVE EXCLUSIVAMENTE UN JSON VÁLIDO (sin texto adicional, sin markdown, sin comentarios).\n\n"
    "El recibo completo representa UN solo gasto. Si la imagen está dañada o ilegible, debes devolver un objeto de error.\n\n"
    "Formato requerido:\n"
    "{\n"
    "  \"store\": string,              // nombre del comercio o 'unidentified' si no se puede leer\n"
    "  \"date\": string,               // SIEMPRE en formato YYYY-MM-DD, representando la FECHA DE SUBIDA (NO LEAS la fecha impresa en el ticket)\n"
    "  \"amount\": number,             // monto total del ticket (si no aparece o es ambiguo, marcar error)\n"
    "  \"category_id\": number,        // 1..6\n"
    "  \"category_name\": string,      // 'food','drinks','subscriptions','small_payment','transport','others'\n"
    "  \"error\": string|null          // describe error si no se pudo analizar correctamente\n"
    "}\n\n"
    "Reglas:\n"
    "- Si no hay tienda visible, usa \"store\": \"unidentified\".\n"
    "- NO LEAS la fecha impresa del ticket; la fecha corresponde al momento de SUBIDA (el sistema del cliente la fijará).\n"
    "- Si no hay total claro o el recibo es ilegible, devuelve un JSON con:\n"
    "  {\"error\": \"total_not_found\"} o {\"error\": \"unreadable_image\"} según el caso.\n"
    "- Si no hay categoría clara, usa id=6 y name='others'.\n"
    "- Clasificación de categoría:\n"
    "   1. food            → comida, restaurantes, supermercado, comida rápida\n"
    "   2. drinks          → café, bebidas, jugos, bares\n"
    "   3. subscriptions   → Netflix, Spotify, servicios digitales\n"
    "   4. small_payment   → propinas, comisiones pequeñas, micro pagos\n"
    "   5. transport       → Uber, gasolina, transporte público, estacionamientos\n"
    "   6. others          → todo lo demás o ambiguo\n\n"
    "Si el ticket parece mezcla (ej. OXXO con comida y bebidas), aplica predominio:\n"
    "- Si no hay predominio claro, usa food (1) por defecto, salvo que sea casi puro bebidas → drinks (2).\n\n"
    "IMPORTANTE:\n"
    "- DEVUELVE SOLO EL JSON SIN ``` NI TEXTO EXTRA.\n"
    "- Usa punto decimal en los montos.\n"
)

# =========================
#  Endpoints
# =========================

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
    category_id = data.get('category_id')
    amount = data.get('amount')
    description = data.get('description', '')
    date_str = data.get('date')

    if not all([user_id, category_id, amount]):
        return jsonify({'success': False, 'message': 'Faltan datos requeridos'}), 400

    # Parsear fecha
    try:
        expense_date = datetime.strptime(date_str, '%Y-%m-%d').date() if date_str else date.today()
    except Exception:
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


@expenses_bp.route('/analyze', methods=['POST'])
def analyze_and_create_expense():
    """
    Analiza un recibo con Gemini y crea un gasto
    ---
    tags:
      - Expenses
    consumes:
      - multipart/form-data
    parameters:
      - in: formData
        name: user_id
        type: integer
        required: true
        description: ID del usuario dueño del gasto
        example: 1
      - in: formData
        name: image
        type: file
        required: true
        description: Imagen del recibo (JPG o PNG)
    responses:
      201:
        description: Recibo analizado y gasto creado
        schema:
          type: object
          properties:
            success:
              type: boolean
            message:
              type: string
            expense_id:
              type: integer
            expense:
              type: object
              properties:
                id: {type: integer}
                user_id: {type: integer}
                category_id: {type: integer}
                category_name: {type: string}
                amount: {type: number}
                description: {type: string}
                date: {type: string, format: date}
      400:
        description: Petición inválida (falta user_id, imagen o amount no detectado)
      404:
        description: Usuario no existe
      502:
        description: Error llamando a Gemini
    """
    # Validaciones de entrada
    user_id = request.form.get('user_id', type=int)
    if not user_id:
        return jsonify({'success': False, 'message': 'user_id requerido'}), 400
    if 'image' not in request.files:
        return jsonify({'success': False, 'message': 'Imagen requerida'}), 400

    image_file = request.files['image']
    if not image_file or image_file.filename == '':
        return jsonify({'success': False, 'message': 'Imagen vacía'}), 400

    # Validar usuario existe
    if not execute_query("SELECT id FROM users WHERE id=%s", (user_id,), fetch=True):
        return jsonify({'success': False, 'message': 'Usuario no existe'}), 404

    # Bytes e inferencia de mime
    image_bytes = image_file.read()
    mime_type = image_file.content_type or 'image/jpeg'

    # Llamada a Gemini
    try:
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=[
                types.Part.from_bytes(data=image_bytes, mime_type=mime_type),
                GEMINI_PROMPT
            ],
            # generation_config={"temperature": 0.2}  # si tu SDK lo permite
        )
    except Exception as e:
        return jsonify({'success': False, 'message': 'Error llamando a Gemini', 'error': str(e)}), 502

    # Parseo de salida (limpieza de fences)
    text = getattr(response, 'text', str(response)).strip()
    try:
        data = _try_parse_json(text)
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Respuesta de Gemini no es JSON parseable',
            'error': str(e),
            'raw': text[:500]
        }), 400

    # Checa error explícito del modelo
    if isinstance(data, dict) and data.get('error'):
        return jsonify({'success': False, 'message': f"Gemini error: {data['error']}"}), 400

    # Campos mínimos (store puede ser vacío → se normaliza; date la fija backend)
    if 'amount' not in data:
        return jsonify({'success': False, 'message': 'No se detectó amount'}), 400

    # Normalizaciones
    store = data.get('store') or 'unidentified'

    # Fecha SIEMPRE = fecha de subida (hoy)
    receipt_date = date.today()

    # amount: float positivo
    try:
        amount = round(float(data.get('amount')), 2)
        if amount <= 0:
            return jsonify({'success': False, 'message': 'amount debe ser > 0'}), 400
    except Exception:
        return jsonify({'success': False, 'message': 'amount no numérico'}), 400

    # Categoría coherente, con fallback a others(6)
    cid = data.get('category_id')
    cname = data.get('category_name')
    if cid in CAT_MAP and not cname:
        cname = CAT_MAP[cid]
    elif cname in NAME_TO_ID and not cid:
        cid = NAME_TO_ID[cname]
    if cid not in CAT_MAP:
        cid, cname = 6, 'others'

    # Validar categoría exista en DB
    if not execute_query("SELECT id FROM category WHERE id=%s", (cid,), fetch=True):
        cid, cname = 6, 'others'

    # Insertar en BD
    insert_q = """
        INSERT INTO expenses (user_id, category_id, amount, description, date)
        VALUES (%s, %s, %s, %s, %s)
    """
    expense_id = execute_query(insert_q, (user_id, cid, amount, store, receipt_date))

    # Recuperar expense con nombre de categoría
    sel_q = """
        SELECT e.id, e.user_id, e.category_id, c.name AS category_name,
               e.amount, e.description, e.date
        FROM expenses e
        LEFT JOIN category c ON c.id = e.category_id
        WHERE e.id = %s
    """
    rows = execute_query(sel_q, (expense_id,), fetch=True) or []
    expense = rows[0] if rows else {
        'id': expense_id, 'user_id': user_id, 'category_id': cid,
        'category_name': cname, 'amount': float(amount),
        'description': store, 'date': str(receipt_date)
    }

    return jsonify({
        'success': True,
        'message': 'Recibo analizado y gasto creado',
        'expense_id': expense_id,
        'expense': expense
    }), 201


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