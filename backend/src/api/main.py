from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi import Request
import uvicorn
import os

import firebase_admin
from firebase_admin import credentials

from src.constants.variables import FIREBASE_CREDENTIALS_PATH, FIREBASE_PROJECT_ID
from src.constants.variables import PORT
from src.api.routers.ModelRoute import router as model_router
from src.api.routers.PredictionRoute import router as prediction_router


# Initialize Firebase Admin
if not firebase_admin._apps:
    try:
        if FIREBASE_CREDENTIALS_PATH and os.path.exists(FIREBASE_CREDENTIALS_PATH):
            firebaseCredentials = credentials.Certificate(FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(
                firebaseCredentials,
                options={'projectId': FIREBASE_PROJECT_ID},
            )
            print(
                f"Firebase Admin initialized with credentials for project: {FIREBASE_PROJECT_ID}"
            )
        else:
            print(
                "Firebase Admin credentials not configured. "
                "Using public-key Firebase token verification."
            )
    except Exception as e:
        print(f"Error initializing Firebase Admin: {e}")


app = FastAPI()
app.include_router(model_router)
app.include_router(prediction_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root(request: Request) -> dict[str, str]: 
    return {"message": "CXC backend is running ... PERFECT healthy"}

@app.get("/health")
async def health(request: Request) -> dict[str, str]: 
    return {"status": "healthy"}


if __name__ == "__main__":
    uvicorn.run("src.api.main:app", host="0.0.0.0", port=int(PORT) if PORT else 8080, reload=True)
