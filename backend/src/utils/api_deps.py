from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import os
from firebase_admin import auth
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from src.constants.variables import FIREBASE_CREDENTIALS_PATH, FIREBASE_PROJECT_ID

security = HTTPBearer(auto_error=True)


def firebaseAdminVerificationEnabled() -> bool:
    """
    Return True when a Firebase Admin credentials file is configured locally.
    """
    return bool(
        FIREBASE_CREDENTIALS_PATH and os.path.exists(FIREBASE_CREDENTIALS_PATH)
    )


def verifyWithFirebaseAdmin(token: str):
    return auth.verify_id_token(token)


def verifyWithGooglePublicKeys(token: str):
    return id_token.verify_firebase_token(
        token,
        google_requests.Request(),
        audience=FIREBASE_PROJECT_ID,
    )

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Dependency to verify the Firebase ID token and return the decoded user info.
    """
    token = credentials.credentials
    try:
        if firebaseAdminVerificationEnabled():
            decodedToken = verifyWithFirebaseAdmin(token)
        else:
            decodedToken = verifyWithGooglePublicKeys(token)

        return decodedToken
    except Exception as e:
        errorMessage = str(e)

        if firebaseAdminVerificationEnabled():
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Invalid or expired Firebase token: {errorMessage}",
                headers={"WWW-Authenticate": "Bearer"},
            )

        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Firebase token verification failed: {errorMessage}",
            headers={"WWW-Authenticate": "Bearer"},
        )
