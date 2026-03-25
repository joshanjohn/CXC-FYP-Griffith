from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import tensorflow as tf
from fastapi import Request
import numpy as np
from PIL import Image
import io
import uvicorn

from src.constants.model_names import  CXC104
from src.constants.constants import CLASS_NAMES, IMG_SIZE
from src.api.routers.UserAuthRoute import router as auth_router


app = FastAPI()
app.include_router(auth_router)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

async def load_model(): 
    # Load the model
    try:
        model = tf.keras.models.load_model(CXC104)
        print(f"Model loaded successfully from {CXC104}")
    except Exception as e:
        print(f"Error loading model: {e}")
        model = None
    return model

def preprocess_image(pil_image: Image.Image, target_size=IMG_SIZE):
    if pil_image.mode != "RGB":
        pil_image = pil_image.convert("RGB")
    
    img = pil_image.resize(target_size)
    img_array = tf.keras.preprocessing.image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    
    return img_array


@app.get("/")
async def root(request: Request) -> dict[str, str]: 
    return {"message": "CXC backend is running ... PERFECT healthy"}


@app.get("/health")
async def health(request: Request) -> dict[str, str]: 
    return {"status": "healthy"}



@app.post("/predict")
async def predict_xray(file: UploadFile = File(...)) -> JSONResponse:
    model = await load_model()
    if model is None:
        raise HTTPException(status_code=500, detail="Model not loaded")

    try:
        contents = await file.read()
        pil_image = Image.open(io.BytesIO(contents))
        img_array = preprocess_image(pil_image)
        
        prediction_probs = model.predict(img_array)[0]
        
        predicted_class_idx = int(np.argmax(prediction_probs))
        predicted_class = CLASS_NAMES[predicted_class_idx]
        confidence = float(prediction_probs[predicted_class_idx])

        for i in range(prediction_probs):
            print(f"{CLASS_NAMES[i]} : {i}") 

        print(f"prediction: {predicted_class},confidence: {confidence}")
        
        return JSONResponse({
            "prediction": predicted_class,
            "confidence": confidence,
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run("src.api.api:app", host="0.0.0.0", port=8080, reload=True)
