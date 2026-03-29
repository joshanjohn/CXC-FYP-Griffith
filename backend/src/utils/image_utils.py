import tensorflow as tf
import numpy as np
from PIL import Image
from src.constants.constants import IMG_SIZE

class ImageUtils:
    @staticmethod
    def preprocess_image(pil_image: Image.Image, target_size=IMG_SIZE):
        """
        Preprocess the image for model prediction.
        """
        if pil_image.mode != "RGB":
            pil_image = pil_image.convert("RGB")
        
        img = pil_image.resize(target_size)
        img_array = tf.keras.preprocessing.image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)
        
        return img_array
