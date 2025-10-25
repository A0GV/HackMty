import os
import json
from google import genai
from google.genai import types



from dotenv import load_dotenv
load_dotenv()

api_key = os.environ.get('GENAI_API_KEY')

client = genai.Client(api_key=api_key)

image_path = './2971_6518_3.jpg'
if not os.path.exists(image_path):
    raise FileNotFoundError(f"Image not found at {image_path}. Place the image in the project folder or update the path.")

with open(image_path, 'rb') as f:
    image_bytes = f.read()

try:
    prompt = (
        "Extrae la información del recibo y DEVUELVE SOLO un JSON VÁLIDO (sin texto adicional).\n"
        "Estructura requerida (usar null cuando aplique):\n"
        "{\n"
        "  \"store\": string,\n"
        "  \"address\": string|null,\n"
        "  \"date\": string (YYYY-MM-DD)|null,\n"
        "  \"time\": string (HH:MM:SS)|null,\n"
        "  \"currency\": string|null,\n"
        "  \"items\": [\n"
        "    {\n"
        "      \"line\": number|null,\n"
        "      \"item_code\": string|null,\n"
        "      \"description\": string|null,\n"
        "      \"quantity\": number|null,\n"
        "      \"unit_price\": number|null,\n"
        "      \"total_price\": number|null,\n"
        "      \"category\": string|null,\n"
        "      \"is_hormiga\": boolean,\n"
        "      \"tipo_hormiga\": string|null\n"
        "    }\n"
        "  ],\n"
        "  \"summary\": {\n"
        "    \"units\": number|null,\n"
        "    \"subtotal\": number|null,\n"
        "    \"vat_percent\": number|null,\n"
        "    \"vat_amount\": number|null,\n"
        "    \"total\": number|null,\n"
        "    \"total_hormiga\": number|null,\n"
        "    \"total_no_hormiga\": number|null\n"
        "  }\n"
        "}\n\n"
        "Clasifica cada artículo en una categoría general y determina si es un gasto hormiga (is_hormiga: true) o no (false).\n"
        "Tipos de gastos hormiga posibles (usar exactamente estas etiquetas cuando correspondan):\n"
        "Comida, Bebidas, Suscripciones, Pequeños pagos, Propinas, Estacionamientos, Comisiones por pago de servicio, Retiro de cajero de otros bancos, Transporte, Gasolina, Uber. O cualquier otro que entre en este tipo de concepto y categoria\n\n"
        "Además: si is_hormiga=true, llenar \"tipo_hormiga\" con una de las etiquetas anteriores; si is_hormiga=false, \"tipo_hormiga\" debe ser null.\n"
        "Contexto: los \"gastos hormiga\" son pequeños gastos diarios que parecen insignificantes, pero al acumularse representan una pérdida importante de dinero y afectan el ahorro personal..\n"
        "Reglas: DEVUELVE SOLO EL JSON (sin texto adicional). Si algún dato no puede inferirse, ponga null. Asegúrate de que el JSON sea perfectamente parseable."
    )

    response = client.models.generate_content(
        model='gemini-2.5-flash',
        contents=[
            types.Part.from_bytes(
                data=image_bytes,
                mime_type='image/jpeg',
            ),
            prompt
        ]
    )
except Exception as e:
    print("Error calling the API:\n", repr(e))
    print("Check your GENAI_API_KEY, network connectivity, and project quotas.")
    raise

# Safely get the response text (some client versions provide .text, others may differ)
if hasattr(response, 'text'):
    text = response.text
else:
    text = str(response)

# Try to parse and pretty-print/save the JSON
try:
    parsed = json.loads(text)
    pretty = json.dumps(parsed, ensure_ascii=False, indent=2)
    print(pretty)
    # Save to output.json
    with open('output.json', 'w', encoding='utf-8') as out_f:
        out_f.write(pretty)
    print('\nSaved parsed JSON to output.json')
except Exception as ex:
    print('\nFailed to parse API response as JSON:')
    print(repr(ex))
    print('\nRaw response was:\n')
    print(text)