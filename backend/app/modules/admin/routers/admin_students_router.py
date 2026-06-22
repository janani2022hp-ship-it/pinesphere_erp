# routers/admin_students_router.py
# ─────────────────────────────────────────────────────────────────────────────
# Admin-facing student management endpoints.
# POST /admin/students/create  → creates auth user + student profile,
#                                returns generated credentials to admin.
# GET  /admin/students         → paginated student list with search & filter
# GET  /admin/students/{id}    → full student detail
# PATCH /admin/students/{id}   → update status
# ─────────────────────────────────────────────────────────────────────────────

import random
import string
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session

from database import get_db
from models import User, Student  # your existing SQLAlchemy models
from auth_utils import hash_password  # your existing bcrypt helper

router = APIRouter(prefix="/admin", tags=["admin-students"])


# ─── Pydantic schemas ─────────────────────────────────────────────────────────

class CreateStudentRequest(BaseModel):
    # Student details (from admin form)
    full_name: str
    phone: str
    email: Optional[str] = None
    course: str
    batch: str
    parent_name: Optional[str] = None
    parent_phone: Optional[str] = None
    address: Optional[str] = None

    # Login account fields (admin-chosen username, password auto-generated)
    username: str  # admin enters this; used as the login email prefix


class CreateStudentResponse(BaseModel):
    success: bool
    message: str
    student_id: str
    student_code: str
    # Credentials to hand to the student
    login_email: str
    temp_password: str


class UpdateStatusRequest(BaseModel):
    status: str  # active | on_hold | dropped


# ─── Helpers ─────────────────────────────────────────────────────────────────

def _generate_password(length: int = 8) -> str:
    """
    Generates a human-readable temp password.
    Avoids visually ambiguous chars (0/O, 1/l/I).
    """
    chars = (
        "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789"
    )
    return "".join(random.choices(chars, k=length))


def _generate_student_code(db: Session) -> str:
    """
    Auto-increments student code: PS-2025-001, PS-2025-002, …
    Reads the highest existing code and bumps it.
    """
    from datetime import datetime
    year = datetime.now().year
    last = (
        db.query(Student)
        .filter(Student.student_code.like(f"PS-{year}-%"))
        .order_by(Student.student_code.desc())
        .first()
    )
    if last and last.student_code:
        try:
            seq = int(last.student_code.split("-")[-1]) + 1
        except ValueError:
            seq = 1
    else:
        seq = 1
    return f"PS-{year}-{seq:03d}"


# ─── Routes ───────────────────────────────────────────────────────────────────

@router.post("/students/create", response_model=CreateStudentResponse)
def create_student(
    body: CreateStudentRequest,
    db: Session = Depends(get_db),
    # Uncomment when you add JWT guard:
    # current_admin = Depends(require_admin),
):
    """
    Admin creates a student account.
    - Derives login email from username: username@pinesphere.in
    - Auto-generates a temp password
    - Creates User row (role = student) + Student profile row
    - Returns credentials so admin can hand them to the student
    """

    # 1. Build login email from username
    login_email = f"{body.username.strip().lower()}@pinesphere.in"

    # 2. Check username / email uniqueness
    existing = db.query(User).filter(User.email == login_email).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail=f"Username '{body.username}' is already taken. Try a different one.",
        )

    # 3. Generate password
    temp_password = _generate_password()
    password_hash = hash_password(temp_password)

    # 4. Create User row (re-uses your existing User model)
    new_user = User(
        email=login_email,
        name=body.full_name,
        password_hash=password_hash,
        role="student",
        phone=body.phone,
        is_active=True,
    )
    db.add(new_user)
    db.flush()  # get new_user.id before committing

    # 5. Generate student code
    student_code = _generate_student_code(db)

    # 6. Create Student profile row
    new_student = Student(
        user_id=str(new_user.id),
        student_code=student_code,
        full_name=body.full_name,
        phone=body.phone,
        email=body.email or login_email,
        course=body.course,
        batch=body.batch,
        parent_name=body.parent_name,
        parent_phone=body.parent_phone,
        address=body.address,
        status="active",
    )
    db.add(new_student)
    db.commit()
    db.refresh(new_student)

    return CreateStudentResponse(
        success=True,
        message="Student created successfully",
        student_id=str(new_student.id),
        student_code=student_code,
        login_email=login_email,
        temp_password=temp_password,
    )


@router.get("/students")
def list_students(
    search: str = Query(default=""),
    status: str = Query(default=""),
    page: int = Query(default=1, ge=1),
    per_page: int = Query(default=20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    query = db.query(Student)

    if search:
        like = f"%{search}%"
        query = query.filter(
            Student.full_name.ilike(like)
            | Student.student_code.ilike(like)
            | Student.phone.ilike(like)
            | Student.course.ilike(like)
        )

    if status:
        query = query.filter(Student.status == status)

    total = query.count()
    students = query.offset((page - 1) * per_page).limit(per_page).all()

    return {
        "success": True,
        "data": {
            "students": [_student_summary(s) for s in students],
            "total": total,
            "page": page,
            "per_page": per_page,
        },
    }


@router.get("/students/{student_id}")
def get_student(student_id: str, db: Session = Depends(get_db)):
    student = db.query(Student).filter(Student.id == student_id).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    return {"success": True, "data": _student_detail(student, db)}


@router.patch("/students/{student_id}")
def update_student_status(
    student_id: str,
    body: UpdateStatusRequest,
    db: Session = Depends(get_db),
):
    student = db.query(Student).filter(Student.id == student_id).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    allowed = {"active", "on_hold", "dropped"}
    if body.status not in allowed:
        raise HTTPException(status_code=400, detail=f"Status must be one of {allowed}")

    student.status = body.status
    db.commit()
    return {"success": True, "message": f"Status updated to {body.status}"}


# ─── GET /admin/dashboard (already wired? add here if missing) ────────────────

@router.get("/dashboard")
def admin_dashboard(db: Session = Depends(get_db)):
    from datetime import date
    from models import Attendance  # import your Attendance model

    total_students = db.query(Student).count()
    active_students = db.query(Student).filter(Student.status == "active").count()

    # Today's attendance rate
    today = date.today()
    today_records = db.query(Attendance).filter(Attendance.session_date == today).all()
    if today_records:
        present = sum(1 for a in today_records if a.status == "present")
        attendance_rate = round((present / len(today_records)) * 100, 1)
    else:
        attendance_rate = 0.0

    return {
        "success": True,
        "data": {
            "total_students": total_students,
            "active_students": active_students,
            "today_attendance_rate": attendance_rate,
            "fee_collection_this_month": 0,   # wire Finance module later
            "new_enquiries_today": 0,          # wire CRM module later
            "pending_dues_count": 0,           # wire Finance module later
            "active_batches": 0,               # wire Batch module later
            "upcoming_classes_today": 0,       # wire LMS module later
        },
    }


@router.get("/dashboard/recent-students")
def recent_students(
    limit: int = Query(default=5, le=20),
    db: Session = Depends(get_db),
):
    students = (
        db.query(Student)
        .order_by(Student.created_at.desc())
        .limit(limit)
        .all()
    )
    return {
        "success": True,
        "data": [_student_summary(s) for s in students],
    }


# ─── Private serialisers ──────────────────────────────────────────────────────

def _student_summary(s: Student) -> dict:
    return {
        "student_id": str(s.id),
        "student_code": s.student_code or "",
        "full_name": s.full_name or "",
        "course": s.course or "",
        "batch": s.batch or "",
        "status": s.status or "active",
        "enrollment_date": str(s.created_at.date()) if s.created_at else "",
        "phone": s.phone or "",
        "attendance_percent": 0.0,  # join with Attendance table to compute
    }


def _student_detail(s: Student, db: Session) -> dict:
    base = _student_summary(s)
    base.update(
        {
            "email": s.email or "",
            "parent_name": s.parent_name or "",
            "parent_phone": s.parent_phone or "",
            "address": s.address or "",
            "dob": str(s.dob) if s.dob else "",
            "gender": s.gender or "",
            "fees_paid": float(s.fees_paid or 0),
            "fees_total": float(s.fees_total or 0),
        }
    )
    return base