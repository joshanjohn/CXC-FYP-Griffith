from fastapi import APIRouter, File, UploadFile, Query, HTTPException, Depends, BackgroundTasks, Form
from fastapi.responses import JSONResponse, FileResponse
from src.api.services.PredictionService import PredictionService
from src.utils.api_deps import get_current_user
import os
import uuid
import shutil
import tempfile
from pathlib import Path
from src.constants.constants import CLASS_NAMES

TEMP_BASE_DIR = os.path.join(tempfile.gettempdir(), "cxc_batch")
os.makedirs(TEMP_BASE_DIR, exist_ok=True)

router = APIRouter(
    tags=["prediction"],
    dependencies=[Depends(get_current_user)]
)

prediction_service = PredictionService()


def validate_filename(filename: str | None) -> str:
    """
    function to valdate and return unique filename
    """
    # if original file na,me is none set default to upload.jpg
    original_name = Path(filename or "upload.jpg").name
    # extract file name 
    stem = Path(original_name).stem or "upload"
    # extratc file extension name 
    suffix = Path(original_name).suffix or ".jpg"
    
    # checking if alphs and nums are there
    sanitized_stem = "".join(
        char if char.isalnum() or char in {"-", "_"} else "_" 
        for char in stem
    )
    # return with attched uuid for unique
    return f"{sanitized_stem[:80]}_{uuid.uuid4().hex[:8]}{suffix.lower()}"

@router.post("/predict")
async def predict_xray(file: UploadFile = File(...)):
    """
    POST endpoint for prediting with default model. 
    only file need to be passed. 
    """
    result = await prediction_service.predict(file)
    return JSONResponse(result)

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

@router.post("/batch/start")
async def start_batch():
    """
    POST endpoint for  starting a batch classification session.
    return session id 
    """
    session_id = str(uuid.uuid4())  # session id for batch process 
    print("SESSION ID = ", session_id)
    session_dir = os.path.join(TEMP_BASE_DIR, session_id) # temp dir to store 
    os.makedirs(session_dir, exist_ok=True)

    for class_name in CLASS_NAMES:
        os.makedirs(os.path.join(session_dir, class_name), exist_ok=True)
    return JSONResponse({"session_id": session_id})

@router.post("/batch/classify")
async def classify_batch(
    session_id: str = Form(...),
    file: UploadFile = File(...),
    model_name: str = Query(None)
):
    """
    Classify a single image within a batch session and save it to the session directory.
    """
    session_dir = os.path.join(TEMP_BASE_DIR, session_id)
    print("SESSION DIR = ", session_dir)
    if not os.path.exists(session_dir):
        raise HTTPException(status_code=404, detail="Session not found")
    
    # Save the file content for later reuse since predict() consumes the stream
    contents = await file.read()
    await file.seek(0)
    
    # Get prediction
    result = await prediction_service.predict(file, model_name=model_name)
    predicted_class = result["prediction"]
    if predicted_class not in CLASS_NAMES:
        predicted_class = "UNKNOWN"
    
    # Save the file to the corresponding class directory
    file_path = os.path.join(session_dir, predicted_class, validate_filename(file.filename))
    with open(file_path, "wb") as f:
        f.write(contents)
    
    return JSONResponse(result)

@router.get("/batch/download/{session_id}")
async def download_batch(session_id: str, background_tasks: BackgroundTasks):
    """
    Zip the batch session results and return for download.
    Clean up temporary files after download.
    """
    session_dir = os.path.join(TEMP_BASE_DIR, session_id)
    if not os.path.exists(session_dir):
        raise HTTPException(status_code=404, detail="Session not found")
    
    zip_base = os.path.join(TEMP_BASE_DIR, session_id)
    zip_path = f"{zip_base}.zip"
    
    # Create zip archive
    shutil.make_archive(zip_base, 'zip', session_dir)
    
    def cleanup():
        if os.path.exists(session_dir):
            shutil.rmtree(session_dir)
        if os.path.exists(zip_path):
            os.remove(zip_path)
    
    background_tasks.add_task(cleanup)
    
    return FileResponse(
        zip_path, 
        media_type="application/zip", 
        filename=f"classified_images_{session_id[:8]}.zip"
    )
