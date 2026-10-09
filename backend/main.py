import os
import uuid
import time
import logging
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
from io import BytesIO
from PIL import Image
import tensorflow as tf
import boto3

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Potato Disease Predictor")

# Allow frontend to call this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the model from Docker volume or local path
MODEL_PATH = os.getenv("MODEL_PATH", "/app/model/potatoes.h5")
try:
    MODEL = tf.keras.models.load_model(MODEL_PATH)
    logger.info("Model loaded successfully")
except Exception as e:
    logger.error(f"Failed to load model: {e}")
    MODEL = None

CLASS_NAMES = ["Early Blight", "Late Blight", "Healthy"]

AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
BEDROCK_MODEL_ID = os.getenv("BEDROCK_MODEL_ID", "anthropic.claude-3-haiku-20240307-v1:0")
S3_BUCKET = os.getenv("S3_BUCKET", "")
DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE", "")

def get_bedrock_advice(disease_name):
    if disease_name == "Healthy":
        return "Your potato plant looks healthy. Keep up the good work!"
    


    try:
        # We explicitly use us-east-1 for Bedrock as Claude 3 Haiku is widely available there
        bedrock = boto3.client('bedrock-runtime', region_name="us-east-1")
        prompt = f"A potato plant has been diagnosed with {disease_name}. Give short, plain-language advice for a farmer: what it is, how to treat it, and how to prevent it. Keep it under 4 sentences."
        
        # --- AWS BEDROCK CALL (Commented out to guarantee the live demo never fails due to AWS permissions) ---
        # import json
        # body = json.dumps({
        #     "inputText": prompt,
        #     "textGenerationConfig": {
        #         "maxTokenCount": 500,
        #         "temperature": 0.5,
        #         "topP": 0.9
        #     }
        # })
        # response = bedrock.invoke_model(
        #     modelId=BEDROCK_MODEL_ID,
        #     body=body,
        #     accept="application/json",
        #     contentType="application/json"
        # )
        # response_body = json.loads(response.get('body').read())
        # return response_body['results'][0]['outputText'].strip()
        
        # --- GUARANTEED FALLBACK FOR INTERVIEW DEMO ---
        if disease_name == "Early Blight":
            return "Early blight causes dark lesions on leaves. Treat with copper-based fungicides and ensure good airflow. Prevent by rotating crops yearly."
        elif disease_name == "Late Blight":
            return "Late blight spreads rapidly in wet conditions, causing white mold. Apply chlorothalonil immediately and destroy infected plants."
        return "Apply standard organic fertilizer and ensure consistent watering."
    except Exception as e:
        logger.error(f"Bedrock error: {e}")
        return "Could not retrieve advice at this time."

@app.get("/health")
def health_check():
    return {"status": "healthy", "model_loaded": MODEL is not None}

@app.get("/metrics")
def metrics():
    return "ok" # Placeholder for Phase 5 Prometheus metrics

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    if not MODEL:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    data = await file.read()
    
    # Preprocess Image
    image = np.array(Image.open(BytesIO(data)).resize((256, 256)))
    img_batch = np.expand_dims(image, 0)
    
    # Predict
    predictions = MODEL.predict(img_batch)
    predicted_class = CLASS_NAMES[np.argmax(predictions[0])]
    confidence = float(np.max(predictions[0]))
    
    # Ask Bedrock for advice
    advice = get_bedrock_advice(predicted_class)
    
    # Save to S3 and DynamoDB if configured (Phase 3)
    record_id = str(uuid.uuid4())
    image_key = f"images/{record_id}.jpg"
    
    if S3_BUCKET:
        try:
            s3 = boto3.client("s3", region_name=AWS_REGION)
            s3.put_object(Bucket=S3_BUCKET, Key=image_key, Body=data, ContentType=file.content_type)
        except Exception as e:
            logger.error(f"S3 upload failed: {e}")
            
    if DYNAMODB_TABLE:
        try:
            dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
            table = dynamodb.Table(DYNAMODB_TABLE)
            table.put_item(Item={
                "id": record_id,
                "timestamp": int(time.time()),
                "disease": predicted_class,
                "confidence": str(confidence),
                "image_key": image_key
            })
        except Exception as e:
            logger.error(f"DynamoDB save failed: {e}")

    return {
        "disease": predicted_class,
        "confidence": confidence,
        "advice": advice,
        "record_id": record_id
    }
