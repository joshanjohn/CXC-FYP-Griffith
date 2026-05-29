from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi import Request
import uvicorn
import os
from src.logging import configure_logging, get_logger
from src.constants.constants import APP_LOG_LEVEL
from src.constants.variables import PORT
from src.api.routers.ModelRoute import router as model_router
from src.api.routers.PredictionRoute import router as prediction_router

configure_logging(APP_LOG_LEVEL)
logger = get_logger(__name__)


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
