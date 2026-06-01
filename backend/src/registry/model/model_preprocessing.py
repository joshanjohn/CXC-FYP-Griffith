from tensorflow.keras.applications.resnet50 import (
    preprocess_input as resnet50_preprocess_input,
)
from tensorflow.keras.applications.vgg16 import (
    preprocess_input as vgg16_preprocess_input
)
from tensorflow.keras.applications.inception_v3 import (
    preprocess_input as inception_v3_preprocess_input
)

MODEL_PREPROCESSING_UNITS = {
    "cxc101": {
        "custom_objects": None,
        "input_preprocess_fn": None,
    },
    "cxc102": {
        "custom_objects": None,
        "input_preprocess_fn": None,
    },
    "cxc103": {
        "custom_objects": None,
        "input_preprocess_fn": None,
    },
     "cxc201": {
        "custom_objects": {
            "preprocess_input": inception_v3_preprocess_input,
        },
        "input_preprocess_fn": inception_v3_preprocess_input,
    },
    "cxc202": {
        "custom_objects": {
            "preprocess_input": vgg16_preprocess_input,
        },
        "input_preprocess_fn": vgg16_preprocess_input,
    },
    "cxc203": {
        "custom_objects": {
            "preprocess_input": resnet50_preprocess_input,
        },
        "input_preprocess_fn": resnet50_preprocess_input,
    },
}

