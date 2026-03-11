import os 
from dotenv import load_dotenv

load_dotenv()

MODEL_DIR = os.getenv("MODEL_DIR", "")
DATASET_DIR = os.getenv("DATASET_DIR", "")
PORT = os.getenv("PORT", "")
