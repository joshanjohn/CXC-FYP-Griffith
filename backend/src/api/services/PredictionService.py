import tensorflow as tf
import numpy as np
import io
from PIL import Image, UnidentifiedImageError
from fastapi import UploadFile, HTTPException
from src.constants.constants import CLASS_NAMES
from src.registry.model.model_info import MODEL_INFO
from src.registry.model.model_names import AVAILABLE_MODELS, DEFAULT, DEFAULT_MODEL_ALIAS
from src.registry.model.model_preprocessing import MODEL_PREPROCESSING_UNITS
from src.utils.image_utils import ImageUtils

class PredictionService:
    def __init__(self):
        self.model_cache = {}

    def resolve_model_alias(self, model_alias: str = None) -> str:
        """
        Resolve the request alias to a concrete configured model alias.
        """
        if model_alias is None or model_alias.lower() == "default":
            return DEFAULT_MODEL_ALIAS

        model_alias = model_alias.lower()
        if model_alias not in AVAILABLE_MODELS:
            raise HTTPException(status_code=400, detail=f"Model '{model_alias}' is not available. Available models: {list(AVAILABLE_MODELS.keys())}")
        return model_alias

    def get_model_preprocessing_unit(self, model_alias: str):
        """
        Return the preprocessing configuration for a model alias.
        """
        return MODEL_PREPROCESSING_UNITS.get(
            model_alias,
            {
                "custom_objects": None,
                "input_preprocess_fn": None,
            },
        )

    async def get_model(self, model_alias: str = None):
        """
        return a model using its alias or model name. If no alias is provided, it use the default model (DEFAULT).
        """
        model_key = self.resolve_model_alias(model_alias)
        model_path = DEFAULT if model_key == DEFAULT_MODEL_ALIAS else AVAILABLE_MODELS[model_key]
        preprocessing_unit = self.get_model_preprocessing_unit(model_key)

        if model_key not in self.model_cache:
            try:
                print(f"Loading model {model_key} from {model_path}...")
                self.model_cache[model_key] = tf.keras.models.load_model(
                    model_path,
                    custom_objects=preprocessing_unit["custom_objects"],
                )
            except Exception as e:
                print(f"Error loading model {model_key}: {e}")
                raise HTTPException(status_code=500, detail=f"Failed to load model {model_key}")

        return self.model_cache[model_key]


    def get_available_models(self):
        """
        function to return a list of available model aliases.
        """
        ordered_aliases = [DEFAULT_MODEL_ALIAS]
        ordered_aliases.extend(
            alias for alias in AVAILABLE_MODELS.keys() if alias != DEFAULT_MODEL_ALIAS
        )
        return ordered_aliases

    def get_models_info(self):
        """
        function to return detailed model metadata for frontend docs.
        """
        models_info = []
        for model_alias in self.get_available_models():
            model_info = MODEL_INFO.get(model_alias)
            if model_info is None:
                continue

            models_info.append(
                {
                    **model_info,
                    "alias": model_alias,
                    "is_default": model_alias == DEFAULT_MODEL_ALIAS,
                }
            )

        print(models_info)
        return models_info
    

    async def predict(self, file: UploadFile, model_name: str = None):
        """
        function to return prediction for an uploaded file using the specified model.
        """
        resolved_model_name = self.resolve_model_alias(model_name)
        preprocessing_unit = self.get_model_preprocessing_unit(resolved_model_name)
        model = await self.get_model(resolved_model_name)

        try:
            contents = await file.read()
            if not contents:
                raise HTTPException(status_code=400, detail="Uploaded file is empty")
            pil_image = Image.open(io.BytesIO(contents))
            pil_image.load()
            img_array = ImageUtils.preprocess_image_for_model(
                pil_image,
                model,
                preprocess_fn=preprocessing_unit["input_preprocess_fn"],
            )
            

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
                "model_used": resolved_model_name,
                "filename": file.filename,
            }
        except HTTPException:
            raise
        except UnidentifiedImageError:
            raise HTTPException(status_code=400, detail="Unsupported or invalid image file")
        except Exception as e:
            print(f"Prediction error: {e}")
            raise HTTPException(status_code=500, detail=str(e))
