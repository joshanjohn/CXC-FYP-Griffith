import os 
from src.constants.variables import MODEL_DIR, DEFAULT_CXC_MODEL

CXC1 = os.path.join(MODEL_DIR, "CXC1.keras")
CXC102 = os.path.join(MODEL_DIR, "CXC102.keras")
CXC103 = os.path.join(MODEL_DIR, "CXC103.keras")
CXC104 = os.path.join(MODEL_DIR, "CXC104.keras")
CXC105 = os.path.join(MODEL_DIR, "CXC105.keras")
DEFAULT = os.path.join(MODEL_DIR, DEFAULT_CXC_MODEL)

AVAILABLE_MODELS = {
    "cxc1": CXC1,
    "cxc102": CXC102,
    "cxc103": CXC103,
    "cxc104": CXC104,
    "cxc105": CXC105,
    "default": DEFAULT
}
