import os
import json
import re
from google import genai
from google.genai import types
from datetime import date
from dotenv import load_dotenv

load_dotenv()

api_key = os.environ.get('GENAI_API_KEY')

client = genai.Client(api_key=api_key)

# ==== Configuración ====
image_path = './ticket-supreme-1.jpg'
if not os.path.exists(image_path):
    raise FileNotFoundError(f"Image not found at {image_path}. Place the image in the project folder or update the path.")

# Detecta MIME simple por extensión
ext = os.path.splitext(image_path)[1].lower()
mime = "image/jpeg"
if ext in {".png"}:
    mime = "image/png"
elif ext in {".jpg", ".jpeg"}:
    mime = "image/jpeg"

with open(image_path, 'rb') as f:
    image_bytes = f.read()

# ==== Prompt actualizado (NO LEER fecha impresa) ====
prompt = (
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

# ==== Llamada al modelo ====
try:
    response = client.models.generate_content(
        model='gemini-2.5-flash',
        contents=[
            types.Part.from_bytes(
                data=image_bytes,
                mime_type='image/jpeg',
            ),
            prompt
        ],
        # Si tu versión de SDK soporta config:
        # generation_config={"temperature": 0.2}
    )
except Exception as e:
    print("Error calling the API:\n", repr(e))
    print("Check your GENAI_API_KEY, network connectivity, and project quotas.")
    raise

# ==== Obtener texto y limpiar fences ====
text = getattr(response, 'text', str(response)).strip()

def strip_markdown_fences(s: str) -> str:
    if s.startswith("```"):
        lines = s.splitlines()
        # quita primera línea ```
        if lines and lines[0].lstrip().startswith("```"):
            lines = lines[1:]
        # corta al primer cierre ```
        for i, line in enumerate(lines):
            if line.strip().startswith("```"):
                lines = lines[:i]
                break
        s = "\n".join(lines).strip()
    return s

def try_parse_json(s: str):
    # 1) directo
    try:
        return json.loads(s)
    except Exception:
        pass
    # 2) sin fences
    s2 = strip_markdown_fences(s)
    try:
        return json.loads(s2)
    except Exception:
        pass
    # 3) bloque { ... }
    start = s2.find("{")
    end = s2.rfind("}")
    if start != -1 and end != -1 and end > start:
        candidate = s2[start:end+1]
        return json.loads(candidate)
    raise ValueError(f"No se pudo parsear JSON. Texto recibido:\n{s}")

parsed = try_parse_json(text)

# ==== Post-procesamiento y validaciones ====
cat_map = {
    1: "food",
    2: "drinks",
    3: "subscriptions",
    4: "small_payment",
    5: "transport",
    6: "others"
}
name_to_id = {v: k for k, v in cat_map.items()}

# Error explícito del modelo
if isinstance(parsed, dict) and parsed.get("error"):
    raise ValueError(f"Error en análisis del ticket: {parsed['error']}")

# Campos mínimos que nos importan del modelo
# (NO exigimos 'date' del modelo porque la fijaremos nosotros)
for k in ("store", "amount"):
    if k not in parsed:
        raise ValueError(f"Respuesta sin campo obligatorio: {k}")

# Normaliza store
if not parsed.get("store"):
    parsed["store"] = "unidentified"

# Fuerza la fecha a HOY (fecha de subida manejada por backend)
parsed["date"] = str(date.today())

# Normaliza amount a float positivo con 2 decimales
val = parsed.get("amount")
try:
    amt = round(float(val), 2)
    if amt <= 0:
        raise ValueError("amount_must_be_positive")
    parsed["amount"] = amt
except Exception:
    raise ValueError("❌ No se detectó el total del ticket (amount_parse_error).")

# Coherencia de categoría
cid = parsed.get("category_id")
cname = parsed.get("category_name")

if cid in cat_map and not cname:
    parsed["category_name"] = cat_map[cid]
elif cname in name_to_id and not cid:
    parsed["category_id"] = name_to_id[cname]
else:
    if cid not in cat_map or cname not in name_to_id:
        parsed["category_id"] = 6
        parsed["category_name"] = "others"

# Clamp explícito
if parsed["category_id"] not in cat_map:
    parsed["category_id"] = 6
    parsed["category_name"] = "others"

# ==== Guardar salida limpia (una sola vez) ====
pretty = json.dumps(parsed, ensure_ascii=False, indent=2)
print(pretty)
with open('output.json', 'w', encoding='utf-8') as out_f:
    out_f.write(pretty)
print('\n✅ Saved parsed JSON to output.json')