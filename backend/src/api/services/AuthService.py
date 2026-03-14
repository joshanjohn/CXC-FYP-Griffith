from src.constants.variables import MONGODB_URL, MONGODB_DB_NAME
from src.models.user import UserCreate, UserResponse, Token, UserLogin
from fastapi import HTTPException, status
from src.utils.auth_utils import get_password_hash, verify_password, create_access_token, create_refresh_token
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi


class AuthService:

    def __init__(self):
        self.client = MongoClient(
            MONGODB_URL,
            server_api=ServerApi('1')
        )
        self.db = self.client.get_database(MONGODB_DB_NAME)
        self.users_collection = self.db.users

    def create_user(self, user_data: UserCreate) -> UserResponse:
        # Check if username or email already exists
        if self.users_collection.find_one({"username": user_data.username}):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already taken"
            )
        if self.users_collection.find_one({"email": user_data.email}):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )

        # Hash password and save user
        hashed_password = get_password_hash(user_data.password)
        user_dict = user_data.model_dump()
        user_dict.pop("password")
        user_dict["hashed_password"] = hashed_password
        result = self.users_collection.insert_one(user_dict)

        return UserResponse(
            id=str(result.inserted_id),
            username=user_data.username,
            email=user_data.email,
        )

    def login_user(self, credentials: UserLogin) -> Token:
        user = self.users_collection.find_one({"username": credentials.username})
        if not user or not verify_password(credentials.password, user["hashed_password"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect username or password",
                headers={"WWW-Authenticate": "Bearer"},
            )

        user_id = str(user["_id"])
        token_data = {"sub": user_id, "username": user["username"]}

        access_token = create_access_token(data=token_data)
        refresh_token = create_refresh_token(data=token_data)

        return Token(
            access_token=access_token,
            refresh_token=refresh_token,
            user=UserResponse(
                id=user_id,
                username=user["username"],
                email=user["email"],
            ),
        )
