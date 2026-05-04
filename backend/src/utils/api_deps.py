from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin import auth
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from src.constants.variables import FIREBASE_PROJECT_ID

security = HTTPBearer(auto_error=True)

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Dependency to verify the Firebase ID token and return the decoded user info.
    """
    token = credentials.credentials
    try:
        # Try standard firebase_admin verification first
        # This works best in GCP/Production environments
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        print(f"DEBUG: firebase_admin verification failed: {e}")
        
        # Fallback to google.oauth2.id_token if ADC is missing (common in local dev)
        # This verifies the token using Google's public keys without needing a service account.
        if "default credentials" in str(e).lower() or "credentials" in str(e).lower():
            try:
                print("DEBUG: Attempting google-auth verification fallback...")
                decoded_token = id_token.verify_firebase_token(
                    token,
                    google_requests.Request(),
                    audience=FIREBASE_PROJECT_ID
                )
                print("DEBUG: Fallback verification successful!")
                return decoded_token
            except Exception as fallback_e:
                print(f"DEBUG: Fallback verification also failed: {fallback_e}")
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail=f"Firebase token verification failed. Error: {fallback_e}",
                    headers={"WWW-Authenticate": "Bearer"},
                )
        
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid or expired Firebase token: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )
