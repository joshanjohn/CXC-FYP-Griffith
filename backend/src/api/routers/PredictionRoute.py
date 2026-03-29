from fastapi import APIRouter, File, UploadFile, Query, HTTPException
from fastapi.responses import JSONResponse
from src.api.services.PredictionService import PredictionService

router = APIRouter(tags=["prediction"])

prediction_service = PredictionService()

@router.post("/predict")
async def predict_xray(file: UploadFile = File(...)):
    """
    POST endpoint for prediting with default model. 
    only file need to be passed. 
    """
    result = await prediction_service.predict(file)
    return JSONResponse(result)

@router.get("/models")
async def get_models():
    """
    GET endpoint for returning list of available models.
    """
    models = prediction_service.get_available_models()
    return JSONResponse({"models": models})

@router.post("/predictv2")
async def predict_xray_v2(
    file: UploadFile = File(...),
    model_name: str = Query(..., description="The name of the model to use for prediction")
):
    """
    POST endpoint for prediction need to provide: 
    a file and a valid model name as argument.
    """
    if not model_name:
        raise HTTPException(status_code=400, detail="model_name parameter is required")
        
    result = await prediction_service.predict(file, model_name=model_name)
    return JSONResponse(result)
