import os
from google import genai
from google.genai import types



from dotenv import load_dotenv
load_dotenv()

api_key = os.environ.get('GENAI_API_KEY')

client = genai.Client(api_key=api_key)

image_path = './ticket-supreme-1.jpg'
if not os.path.exists(image_path):
    raise FileNotFoundError(f"Image not found at {image_path}. Place the image in the project folder or update the path.")

with open(image_path, 'rb') as f:
    image_bytes = f.read()

try:
    prompt = (
        "Extrae la información del recibo y devuelve SOLO un objeto JSON válido (sin texto adicional). "
        "El JSON debe tener la estructura: {\n  \"store\": string, \n  \"address\": string|null, \n  \"date\": string (YYYY-MM-DD)|null,\n  \"time\": string (HH:MM:SS)|null,\n  \"currency\": string|null,\n  \"items\": [ {\"line\": number|null, \"item_code\": string|null, \"description\": string|null, \"quantity\": number|null, \"unit_price\": number|null, \"total_price\": number|null, \"category\": string|null } ],\n  \"summary\": { \"units\": number|null, \"subtotal\": number|null, \"vat_percent\": number|null, \"vat_amount\": number|null, \"total\": number|null }\n}. "
        "Clasifica cada artículo en una categoría general (ej.: clothing, accessories, footwear, other). "
        "Si algún campo no puede inferirse, usa null. No incluyas explicaciones, solo el JSON.")

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

# Safely print the response (some client versions provide .text, others may differ)
if hasattr(response, 'text'):
    print(response.text)
else:
    print(response)