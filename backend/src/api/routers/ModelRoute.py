from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from src.api.services.PredictionService import PredictionService
from src.utils.api_deps import get_current_user

router = APIRouter(
    tags=["models"],
    dependencies=[Depends(get_current_user)]
)

prediction_service = PredictionService()


@router.get("/models")
async def get_models():
    """
    GET endpoint for returning list of available models.
    """
    models = prediction_service.get_available_models()
    return JSONResponse({"models": models})


@router.get("/models-info")
async def get_models_info():
    """
    GET endpoint for returning detailed information for all available models.
    """
    models = prediction_service.get_models_info()
    return JSONResponse({"models": models})
