from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi import Request
import uvicorn

import firebase_admin

from src.constants.variables import FIREBASE_PROJECT_ID
from src.constants.variables import PORT
from src.api.routers.ModelRoute import router as model_router
from src.api.routers.PredictionRoute import router as prediction_router


# Initialize Firebase Admin
if not firebase_admin._apps:
    try:
        firebase_admin.initialize_app(options={'projectId': FIREBASE_PROJECT_ID})
        print(f"Firebase initialized with project: {FIREBASE_PROJECT_ID}")
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        firebase_admin.initialize_app() # Fallback


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
