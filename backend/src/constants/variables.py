import os 
from dotenv import load_dotenv

load_dotenv()

MODEL_DIR = os.getenv("MODEL_DIR", "")
DATASET_DIR = os.getenv("DATASET_DIR", "")
PORT = os.getenv("PORT", "")
MONGODB_URL = os.getenv("MONGODB_URL", "")
MONGODB_DB_NAME = os.getenv("MONGODB_DB_NAME", "chest_xray_db")

DEFAULT_CXC_MODEL=os.getenv("DEFAULT_CXC_MODEL", "CXC105.keras")
FIREBASE_PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID", "ticker-24113")