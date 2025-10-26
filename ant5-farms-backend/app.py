from flask import Flask
from flask_cors import CORS
from flasgger import Swagger
from routes.auth import auth_bp
from routes.expenses import expenses_bp
from routes.farm import farm_bp
from routes.goals import goals_bp

# Crear app
app = Flask(__name__)
CORS(app)

# Configurar Swagger
swagger_config = {
    "headers": [],
    "specs": [
        {
            "endpoint": 'apispec',
            "route": '/apispec.json',
            "rule_filter": lambda rule: True,
            "model_filter": lambda tag: True,
        }
    ],
    "static_url_path": "/flasgger_static",
    "swagger_ui": True,
    "specs_route": "/docs"  # Ruta de la documentación
}

swagger_template = {
    "info": {
        "title": "ANT5 FARMS API",
        "description": "API para control de gastos hormiga con gamificación",
        "version": "1.0.0",
        "contact": {
            "name": "Tu equipo",
            "url": "https://github.com/tu-repo"
        }
    },
    "host": "localhost:5001",
    "basePath": "/",
    "schemes": ["http"],
}

swagger = Swagger(app, config=swagger_config, template=swagger_template)

# Registrar blueprints
app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(expenses_bp, url_prefix='/api/expenses')
app.register_blueprint(farm_bp, url_prefix='/api/farm')
app.register_blueprint(goals_bp, url_prefix='/api/goals')

@app.route('/')
def home():
    """
    Endpoint principal
    ---
    responses:
      200:
        description: Información de la API
        schema:
          properties:
            message:
              type: string
            version:
              type: string
    """
    return {
        'message': '🐜 ANT5 FARMS API',
        'version': '1.0.0',
        'docs': '/docs',
        'endpoints': {
            'auth': '/api/auth',
            'expenses': '/api/expenses',
            'farm': '/api/farm'
        }
    }

@app.route('/health')
def health():
    """
    Health check
    ---
    responses:
      200:
        description: Estado del servidor
        schema:
          properties:
            status:
              type: string
    """
    return {'status': 'healthy'}, 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)