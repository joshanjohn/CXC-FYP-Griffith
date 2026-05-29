import os 
from dotenv import load_dotenv

load_dotenv()

MODEL_DIR = os.getenv("MODEL_DIR", "")
DATASET_DIR = os.getenv("DATASET_DIR", "")
PORT = os.getenv("PORT", "")
DEFAULT_CXC_MODEL=os.getenv("DEFAULT_CXC_MODEL", "CXC201.keras")
FIREBASE_PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID", "ticker-24113")
