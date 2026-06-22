import uuid
from typing import Optional
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.shared.models.user import User
from app.modules.student.models.student import Student
from app.modules.student.models.attendance import Attendance
from app.modules.student.models.assignment import Assignment, AssignmentSubmission

router = APIRouter(prefix="/profile", tags=["profile"])


class ProfileOut(BaseModel):
    id: str
    name: str
    email: Optional[str]
    role: str
    username: Optional[str]
    courses: int
    certificates: int
    attendance: str
    streak: int
    total_xp: int
    assignments_done: int
    assignments_total: int
    avg_score: str


class ProfileUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    username: Optional[str] = None


@router.get("/{user_id}", response_model=ProfileOut)
def get_profile(user_id: str, db: Session = Depends(get_db)):
    try:
        uid = uuid.UUID(user_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid user_id")

    user = db.query(User).filter(User.id == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Get student profile
    student = db.query(Student).filter(Student.user_id == uid).first()

    # Attendance
    attendance_status = "Present"
    if student:
        from datetime import date
        today = db.query(Attendance).filter(
            Attendance.student_id == student.id,
        ).order_by(Attendance.attendance_date.desc()).first()
        if today:
            attendance_status = today.status or "Present"

    # Assignments stats
    all_assignments = db.query(Assignment).filter(Assignment.status == "Open").count()
    done_assignments = db.query(AssignmentSubmission).filter(
        AssignmentSubmission.student_id == uid
    ).count()

    return ProfileOut(
        id          = str(user.id),
        name        = user.name or "",
        email       = user.email or "",
        role        = user.role or "student",
        username    = getattr(user, 'username', None),
        courses     = 4,
        certificates= 0,
        attendance  = attendance_status,
        streak      = getattr(user, 'streak', 0) or 0,
        total_xp    = getattr(user, 'total_xp', 0) or 0,
        assignments_done  = done_assignments,
        assignments_total = all_assignments,
        avg_score   = "0.0",
    )


@router.put("/{user_id}", response_model=ProfileOut)
def update_profile(user_id: str, payload: ProfileUpdate, db: Session = Depends(get_db)):
    try:
        uid = uuid.UUID(user_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid user_id")

    user = db.query(User).filter(User.id == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if payload.name:
        user.name = payload.name
    if payload.email:
        # Check email not taken by another user
        existing = db.query(User).filter(
            User.email == payload.email,
            User.id != uid
        ).first()
        if existing:
            raise HTTPException(status_code=400, detail="Email already in use")
        user.email = payload.email
    if payload.username:
        existing = db.query(User).filter(
            User.username == payload.username,
            User.id != uid
        ).first()
        if existing:
            raise HTTPException(status_code=400, detail="Username already in use")
        user.username = payload.username

    db.commit()
    db.refresh(user)

    return get_profile(user_id, db)