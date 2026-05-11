import tensorflow as tf
import numpy as np
import io
from PIL import Image, UnidentifiedImageError
from fastapi import UploadFile, HTTPException
from src.constants.model_names import AVAILABLE_MODELS, DEFAULT
from src.constants.model_info import MODEL_INFO
from src.constants.constants import CLASS_NAMES
from src.utils.image_utils import ImageUtils

class PredictionService:
    def __init__(self):
        self.model_cache = {}

    async def get_model(self, model_alias: str = None):
        """
        return a model using its alias or model name. If no alias is provided, it use the default model (DEFAULT).
        """
        if model_alias is None or model_alias.lower() == "default":
            model_path = DEFAULT
            model_key = "default"
        else:
            model_alias = model_alias.lower()
            if model_alias not in AVAILABLE_MODELS:
                raise HTTPException(status_code=400, detail=f"Model '{model_alias}' is not available. Available models: {list(AVAILABLE_MODELS.keys())}")
            model_path = AVAILABLE_MODELS[model_alias]
            model_key = model_alias

        if model_key not in self.model_cache:
            try:
                print(f"Loading model {model_key} from {model_path}...")
                self.model_cache[model_key] = tf.keras.models.load_model(model_path)
            except Exception as e:
                print(f"Error loading model {model_key}: {e}")
                raise HTTPException(status_code=500, detail=f"Failed to load model {model_key}")

        return self.model_cache[model_key]


    def get_available_models(self):
        """
        function to return a list of available model aliases.
        """
        return list(AVAILABLE_MODELS.keys())

    def get_models_info(self):
        """
        function to return detailed model metadata for frontend docs.
        """
        return [MODEL_INFO[model_name] for model_name in AVAILABLE_MODELS.keys()]
    

    async def predict(self, file: UploadFile, model_name: str = None):
        """
        function to return prediction for an uploaded file using the specified model.
        """
        model = await self.get_model(model_name)

        try:
            contents = await file.read()
            if not contents:
                raise HTTPException(status_code=400, detail="Uploaded file is empty")
            pil_image = Image.open(io.BytesIO(contents))
            pil_image.load()
            img_array = ImageUtils.preprocess_image_for_model(pil_image, model)
            
            prediction_probs = model.predict(img_array)[0]
            
            predicted_class_idx = int(np.argmax(prediction_probs))
            predicted_class = CLASS_NAMES[predicted_class_idx]
            confidence = float(prediction_probs[predicted_class_idx])

            # Create a dictionary of all class confidences
            all_confidences = {CLASS_NAMES[i]: float(prediction_probs[i]) for i in range(len(CLASS_NAMES))}
            
            print(f"Model: {model_name or 'default'}, Prediction: {predicted_class}, Confidence: {confidence}")
            
            return {
                "prediction": predicted_class,
                "confidence": confidence,
                "all_confidences": all_confidences,
                "model_used": model_name if model_name and model_name.lower() != "default" else "default",
                "filename": file.filename,
            }
        except HTTPException:
            raise
        except UnidentifiedImageError:
            raise HTTPException(status_code=400, detail="Unsupported or invalid image file")
        except Exception as e:
            print(f"Prediction error: {e}")
            raise HTTPException(status_code=500, detail=str(e))
