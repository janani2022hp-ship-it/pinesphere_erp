import logging
from typing import Optional

import bcrypt
from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.shared.models.user import User

router = APIRouter(prefix="/auth", tags=["auth"])
logger = logging.getLogger("auth")


class SignupRequest(BaseModel):
    full_name: str = Field(..., alias="full_name")
    username: str
    email: Optional[EmailStr] = None
    password: str
    confirm_password: str


class LoginRequest(BaseModel):
    username_or_email: str
    password: str


class AuthResponse(BaseModel):
    id: str
    username: str
    name: str
    email: Optional[EmailStr] = None
    role: str


def _get_role_segment(role: str) -> str:
    role = (role or "").lower()
    if role.startswith("stu"):   return "student"
    if role.startswith("train"): return "trainer"
    if role.startswith("par"):   return "parent"
    if role.startswith("adm"):   return "admin"
    return "student"


def _hash_password(plain: str) -> str:
    return bcrypt.hashpw(plain.encode(), bcrypt.gensalt()).decode()


def _verify_password(plain: str, stored: str) -> bool:
    try:
        return bcrypt.checkpw(plain.encode(), stored.encode())
    except Exception:
        # Legacy plain text fallback
        return plain == stored


@router.post("/{role}/signup", response_model=AuthResponse)
def signup(role: str, payload: SignupRequest, db: Session = Depends(get_db)):
    role = _get_role_segment(role)
    logger.info("Signup: role=%s username=%s", role, payload.username)

    if payload.password != payload.confirm_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")

    if db.query(User).filter(User.username == payload.username).first():
        raise HTTPException(status_code=400, detail="Username already exists")

    if payload.email:
        if db.query(User).filter(User.email == payload.email).first():
            raise HTTPException(status_code=400, detail="Email already exists")

    user = User(
        username=payload.username,
        name=payload.full_name,
        email=payload.email,
        password_hash=_hash_password(payload.password),
        role=role,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # If student role, also insert into students table
    if role == 'student':
        from sqlalchemy import text
        db.execute(text("""
            INSERT INTO students (id, user_id, created_at)
            VALUES (:id, :user_id, NOW())
            ON CONFLICT (id) DO NOTHING
        """), {'id': user.id, 'user_id': user.id})
        db.commit()

    logger.info("Signup success: user=%s id=%s", user.username, user.id)
    return AuthResponse(
        id=str(user.id),
        username=user.username,
        name=user.name,
        email=user.email,
        role=user.role,
    )


@router.post("/{role}/login", response_model=AuthResponse)
def login(role: str, payload: LoginRequest, db: Session = Depends(get_db)):
    role = _get_role_segment(role)
    identifier = payload.username_or_email

    user = db.query(User).filter(
        (User.username == identifier) | (User.email == identifier)
    ).first()

    if not user or not _verify_password(payload.password, user.password_hash):
        logger.warning("Login failed: %s", identifier)
        raise HTTPException(status_code=401, detail="Invalid credentials")

    logger.info("Login success: user=%s role=%s id=%s", user.username, user.role, user.id)
    return AuthResponse(
        id=str(user.id),
        username=user.username,
        name=user.name,
        email=user.email,
        role=user.role,
    )