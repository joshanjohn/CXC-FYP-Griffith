import tensorflow as tf
import numpy as np
import io
from PIL import Image, UnidentifiedImageError
from fastapi import UploadFile, HTTPException
from src.constants.constants import CLASS_NAMES
from src.registry.model.model_names import AVAILABLE_MODELS, DEFAULT, DEFAULT_MODEL_ALIAS
from src.registry.model.model_preprocessing import MODEL_PREPROCESSING_UNITS
from src.logging import get_logger
from src.utils.image_utils import ImageUtils

logger = get_logger(__name__)

class PredictionService:
    def __init__(self):
        # cached model variable     
        self.model_cache = {}

    def resolve_model_alias(self, model_alias: str = None) -> str:
        """
        Resolve the request alias to a concrete configured model alias.
        """
        if model_alias is None or model_alias.lower() == "default":
            return DEFAULT_MODEL_ALIAS

        model_alias = model_alias.lower()
         # Validate requested model
        if model_alias not in AVAILABLE_MODELS:
            raise HTTPException(status_code=400, detail=f"Model '{model_alias}' is not available. Available models: {list(AVAILABLE_MODELS.keys())}")
        return model_alias

    def get_model_preprocessing_unit(self, model_alias: str):
        """
        Return the preprocessing configuration for a model alias.
        """
        # Retrieve preprocessing configuration
        return MODEL_PREPROCESSING_UNITS.get(
            model_alias,
            {
                "custom_objects": None,
                "input_preprocess_fn": None,
            },
        )

    def predict_batch_from_bytes(
        self,
        files: list[tuple[str | None, bytes]],
        model_name: str = None,
    ):
        """
        for multiple uploaded images in a single batched predict call.
        """

         # Resolve and validate model name
        resolved_model_name = self.resolve_model_alias(model_name)
        logger.info(
           f"Running batch prediction with model {resolved_model_name} for {len(files)} files.",
        )
        preprocessing_unit = self.get_model_preprocessing_unit(resolved_model_name)
        model = self.model_cache.get(resolved_model_name)

        if model is None:
            raise HTTPException(
                status_code=500,
                detail=f"Model '{resolved_model_name}' is not loaded",
            )

        try:
            processed_images = []
            filenames = []

             # Preprocess all uploaded images
            for filename, contents in files:
                # Validate file content
                if not contents:
                    raise HTTPException(status_code=400, detail="Uploaded file is empty")

                pil_image = Image.open(io.BytesIO(contents))
                pil_image.load()
                img_array = ImageUtils.preprocess_image_for_model(
                    pil_image,
                    model,
                    preprocess_fn=preprocessing_unit["input_preprocess_fn"],
                )
                processed_images.append(img_array[0])
                filenames.append(filename)

            # Create a single batch for inference
            batch_array = np.stack(processed_images, axis=0)
            # Run prediction on the entire batch
            prediction_probs_batch = model.predict(batch_array, verbose=0)

            results = []
            for index, prediction_probs in enumerate(prediction_probs_batch):
                predicted_class_idx = int(np.argmax(prediction_probs))
                predicted_class = CLASS_NAMES[predicted_class_idx]
                confidence = float(prediction_probs[predicted_class_idx])
                all_confidences = {
                    CLASS_NAMES[i]: float(prediction_probs[i])
                    for i in range(len(CLASS_NAMES))
                }

                results.append(
                    {
                        "prediction": predicted_class,
                        "confidence": confidence,
                        "all_confidences": all_confidences,
                        "model_used": resolved_model_name,
                        "filename": filenames[index],
                    }
                )

                logger.info(f"Prediction completed with model {resolved_model_name}: \nclass={predicted_class} confidence={confidence} filename={filenames[index]}",)


            return results
        except HTTPException:
            raise

        # Handle invalid image files
        except UnidentifiedImageError:
            raise HTTPException(status_code=400, detail="Unsupported or invalid image file")
        
        # Handle unexpected errors
        except Exception as e:
            logger.exception("Batch prediction error: %s", e)
            raise HTTPException(status_code=500, detail=str(e))

    async def get_model(self, model_alias: str = None):
        """
        return a model using its alias or model name. If no alias is provided, it use the default model (DEFAULT).
        """
        model_key = self.resolve_model_alias(model_alias)

        # Determine model file path
        model_path = DEFAULT if model_key == DEFAULT_MODEL_ALIAS else AVAILABLE_MODELS[model_key]
        preprocessing_unit = self.get_model_preprocessing_unit(model_key)

        # Load model only once and cache it
        if model_key not in self.model_cache:
            try:
                logger.info(f"Loading model {model_key} from {model_path}")
                self.model_cache[model_key] = tf.keras.models.load_model(
                    model_path,
                    custom_objects=preprocessing_unit["custom_objects"],
                )
            except Exception as e:
                logger.exception(f"Error loading model {model_key}: {e}")
                raise HTTPException(status_code=500, detail=f"Failed to load model {model_key}")

        return self.model_cache[model_key]

    async def predict(self, file: UploadFile, model_name: str = None):
        """
        function to return prediction for an uploaded file using the specified model.
        """
        resolved_model_name = self.resolve_model_alias(model_name)
        preprocessing_unit = self.get_model_preprocessing_unit(resolved_model_name)
        model = await self.get_model(resolved_model_name)

        try:
             # Read uploaded file
            contents = await file.read()

            if not contents:
                raise HTTPException(status_code=400, detail="Uploaded file is empty")
            pil_image = Image.open(io.BytesIO(contents))
            pil_image.load()

            # Preprocess image for inference
            img_array = ImageUtils.preprocess_image_for_model(
                pil_image,
                model,
                preprocess_fn=preprocessing_unit["input_preprocess_fn"],
            )
            

            prediction_probs = model.predict(img_array)[0]
            
            predicted_class_idx = int(np.argmax(prediction_probs))
            predicted_class = CLASS_NAMES[predicted_class_idx]
            confidence = float(prediction_probs[predicted_class_idx])

             # Store confidence for all classes
            all_confidences = {CLASS_NAMES[i]: float(prediction_probs[i]) for i in range(len(CLASS_NAMES))}

            logger.info(f"Prediction completed with model {resolved_model_name}: \nclass={predicted_class} confidence={confidence} filename={file.filename}",)

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
            logger.exception(f"Prediction error: {e}")
            raise HTTPException(status_code=500, detail=str(e))
