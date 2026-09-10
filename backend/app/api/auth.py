"""Authentication Endpoints."""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db.models import User, Workspace, WorkspaceMember
from app.schemas.auth import UserCreate, UserLogin, TokenResponse, UserResponse, RefreshTokenRequest
from app.core.security import get_password_hash, verify_password, create_access_token, get_current_user_token

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == user_in.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with this email already exists",
        )

    user = User(
        email=user_in.email,
        password_hash=get_password_hash(user_in.password),
        display_name=user_in.display_name,
        avatar_url=user_in.avatar_url,
    )
    db.add(user)
    db.flush()

    # Automatically provision default workspace
    ws = Workspace(
        owner_id=user.id,
        name=f"{user.display_name}'s Workspace",
        icon="🚀",
        color_hex="#4F46E5",
    )
    db.add(ws)
    db.flush()

    member = WorkspaceMember(
        workspace_id=ws.id,
        user_id=user.id,
        role="owner",
    )
    db.add(member)
    db.commit()
    db.refresh(user)

    token = create_access_token({"sub": user.id, "email": user.email})
    return TokenResponse(access_token=token, user=UserResponse.model_validate(user))


@router.post("/login", response_model=TokenResponse)
def login(login_in: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == login_in.email).first()
    if not user or not user.password_hash or not verify_password(login_in.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
        )

    token = create_access_token({"sub": user.id, "email": user.email})
    return TokenResponse(access_token=token, user=UserResponse.model_validate(user))


@router.post("/refresh", response_model=TokenResponse)
def refresh_token(refresh_in: RefreshTokenRequest, db: Session = Depends(get_db)):
    from app.core.security import decode_token
    payload = decode_token(refresh_in.refresh_token)
    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")

    new_token = create_access_token({"sub": user.id, "email": user.email})
    return TokenResponse(access_token=new_token, user=UserResponse.model_validate(user))


@router.post("/logout")
def logout(current_user: dict = Depends(get_current_user_token)):
    return {"status": "ok", "message": "Successfully logged out"}


@router.get("/me", response_model=UserResponse)
def get_me(current_user: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user_id = current_user.get("sub")
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return UserResponse.model_validate(user)
