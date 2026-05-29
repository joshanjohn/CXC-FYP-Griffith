from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from src.constants.variables import FIREBASE_PROJECT_ID

security = HTTPBearer(auto_error=True)


def verifyWithGooglePublicKeys(token: str):
    return id_token.verify_firebase_token(
        token,
        google_requests.Request(),
        audience=FIREBASE_PROJECT_ID,
    )

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Middleware Dependency to verify the Firebase ID token and return the decoded user info.
    """
    token = credentials.credentials
    try:
        decodedToken = verifyWithGooglePublicKeys(token)
        return decodedToken
    except Exception as e:
        errorMessage = str(e)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Firebase token verification failed: {errorMessage}",
            headers={"WWW-Authenticate": "Bearer"},
        )
