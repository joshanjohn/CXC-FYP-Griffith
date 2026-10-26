import os

from src.constants.variables import MODEL_DIR, DEFAULT_CXC_MODEL

CXC101 = os.path.join(MODEL_DIR, "CXC101.keras")
CXC102 = os.path.join(MODEL_DIR, "CXC102.keras")
CXC103 = os.path.join(MODEL_DIR, "CXC103.keras")
CXC201 = os.path.join(MODEL_DIR, "CXC201.keras")
CXC202 = os.path.join(MODEL_DIR, "CXC202.keras")
CXC203 = os.path.join(MODEL_DIR, "CXC203.keras")

AVAILABLE_MODELS = {
    "cxc101": CXC101,
    "cxc102": CXC102,
    "cxc103": CXC103,
    "cxc201": CXC201,
    "cxc202": CXC202,
    "cxc203": CXC203,
}

DEFAULT = os.path.join(MODEL_DIR, DEFAULT_CXC_MODEL)

# Find the alias that matches the configured default model
DEFAULT_MODEL_ALIAS = next(
    (
        alias
        for alias, model_path in AVAILABLE_MODELS.items()
        if os.path.basename(model_path).lower() == DEFAULT_CXC_MODEL.lower()
    ),
    "cxc203",
)

