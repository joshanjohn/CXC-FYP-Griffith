import tensorflow as tf
import numpy as np
from PIL import Image
from src.constants.constants import IMG_SIZE

class ImageUtils:
    @staticmethod
    def get_target_size_for_model(model) -> tuple[int, int]:
        """
        Resolve the expected spatial input size from a loaded Keras model.
        Falls back to IMG_SIZE when the model shape is unavailable.
        """
        input_shape = getattr(model, "input_shape", None)
        if not input_shape or len(input_shape) < 4:
            return IMG_SIZE

        height = input_shape[1] or IMG_SIZE[0]
        width = input_shape[2] or IMG_SIZE[1]
        return int(height), int(width)

    @staticmethod
    def preprocess_image(
        pil_image: Image.Image,
        target_size=IMG_SIZE,
        preprocess_fn=None,
    ):
        """
        Preprocess the image for model prediction.
        """
        if pil_image.mode != "RGB":
            pil_image = pil_image.convert("RGB")
        
        img = pil_image.resize(target_size)
        img_array = tf.keras.preprocessing.image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)

        if preprocess_fn is not None:
            img_array = preprocess_fn(img_array)
        
        return img_array

    @staticmethod
    def preprocess_image_for_model(pil_image: Image.Image, model, preprocess_fn=None):
        """
        Preprocess the image using the input size expected by the provided model.
        """
        target_size = ImageUtils.get_target_size_for_model(model)
        return ImageUtils.preprocess_image(
            pil_image,
            target_size=target_size,
            preprocess_fn=preprocess_fn,
        )
