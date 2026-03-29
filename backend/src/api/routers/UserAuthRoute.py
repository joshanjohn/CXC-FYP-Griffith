from fastapi import APIRouter
from src.models.user import UserCreate, UserResponse, Token, UserLogin
from src.api.services.AuthService import AuthService

router = APIRouter(prefix="/auth", tags=["auth"])

auth_service = AuthService()


@router.post("/signup", response_model=UserResponse)
def signup(user_data: UserCreate):
    return auth_service.create_user(user_data)


@router.post("/login", response_model=Token)
def login(credentials: UserLogin):
    return auth_service.login_user(credentials)
