import uuid
from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.modules.student.models.live_class import LiveClass
from app.modules.student.models.student_course import StudentCourse
from app.modules.student.models.student import Student

router = APIRouter(prefix="/student", tags=["Student Live Classes"])

# Separate router with NO /student prefix, for trainer-facing endpoints.
trainer_router = APIRouter(prefix="/trainer", tags=["Trainer Live Classes"])


class LiveClassOut(BaseModel):
    id: str
    title: str
    teacher_name: str
    course_id: str
    meeting_link: Optional[str]
    start_time: Optional[str]
    end_time: Optional[str]
    is_live: bool


class LiveClassSchedule(BaseModel):
    start_time: datetime
    end_time: datetime


class LiveClassCreate(BaseModel):
    title: str
    course_id: str
    teacher_name: Optional[str] = "Trainer"


def _to_out(lc: LiveClass) -> LiveClassOut:
    return LiveClassOut(
        id=str(lc.id),
        title=lc.title,
        teacher_name=lc.teacher_name,
        course_id=str(lc.course_id),
        meeting_link=lc.meeting_link,
        start_time=lc.start_time.isoformat() if lc.start_time else None,
        end_time=lc.end_time.isoformat() if lc.end_time else None,
        is_live=lc.is_live,
    )


@router.post("/live-classes/create", response_model=LiveClassOut)
def create_live_class(payload: LiveClassCreate, db: Session = Depends(get_db)):
    try:
        course_uuid = uuid.UUID(payload.course_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid course_id")

    live_class = LiveClass(
        id=uuid.uuid4(),
        course_id=course_uuid,
        title=payload.title,
        teacher_name=payload.teacher_name or "Trainer",
        is_live=False,
        meeting_link=None,
        created_at=datetime.utcnow(),
    )
    db.add(live_class)
    db.commit()
    db.refresh(live_class)
    return _to_out(live_class)


@router.get("/live-classes", response_model=List[LiveClassOut])
def get_live_classes(
    student_id: Optional[str] = None,
    db: Session = Depends(get_db),
):
    """
    Returns only classes that are currently live.
    If student_id is provided, further restricts to classes whose
    course_id is one of the student's selected courses.
    """
    query = db.query(LiveClass).filter(LiveClass.is_live == True)  # noqa: E712

    if student_id:
        try:
            user_uuid = uuid.UUID(student_id)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid student_id")

        # student_id in the URL is the User.id (from SharedPreferences
        # 'user_id'), but student_courses.student_id references the
        # Student PROFILE id, not the User id. Resolve User -> Student first.
        student_profile = (
            db.query(Student).filter(Student.user_id == user_uuid).first()
        )

        if student_profile is None:
            # No student profile at all — can't have course selections
            return []

        selected_course_ids = [
            row.course_id
            for row in db.query(StudentCourse)
            .filter(StudentCourse.student_id == student_profile.id)
            .all()
        ]

        if not selected_course_ids:
            # Student hasn't selected any courses yet — nothing to show
            return []

        query = query.filter(LiveClass.course_id.in_(selected_course_ids))

    classes = query.order_by(LiveClass.start_time.asc()).all()
    return [_to_out(lc) for lc in classes]


@trainer_router.get("/live-classes", response_model=List[LiveClassOut])
def get_trainer_live_classes(db: Session = Depends(get_db)):
    """
    Returns ALL live classes (live, scheduled, or ended) so trainers can
    manage their full list, not just the currently-live ones.
    """
    classes = (
        db.query(LiveClass)
        .order_by(LiveClass.created_at.desc())
        .all()
    )
    return [_to_out(lc) for lc in classes]


@router.post("/live-classes/{class_id}/host", response_model=LiveClassOut)
def host_live_class(class_id: str, db: Session = Depends(get_db)):
    try:
        class_uuid = uuid.UUID(class_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid class_id")

    live_class = db.query(LiveClass).filter(LiveClass.id == class_uuid).first()
    if not live_class:
        raise HTTPException(status_code=404, detail="Live class not found")

    live_class.is_live = True
    live_class.meeting_link = live_class.meeting_link or \
        f"https://studio.pinesphere.live/{class_uuid.hex[:8]}"
    db.commit()
    db.refresh(live_class)
    return _to_out(live_class)


@router.post("/live-classes/{class_id}/stop", response_model=LiveClassOut)
def stop_live_class(class_id: str, db: Session = Depends(get_db)):
    try:
        class_uuid = uuid.UUID(class_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid class_id")

    live_class = db.query(LiveClass).filter(LiveClass.id == class_uuid).first()
    if not live_class:
        raise HTTPException(status_code=404, detail="Live class not found")

    live_class.is_live = False
    db.commit()
    db.refresh(live_class)
    return _to_out(live_class)


@router.post("/live-classes/{class_id}/schedule", response_model=LiveClassOut)
def schedule_live_class(class_id: str, payload: LiveClassSchedule, db: Session = Depends(get_db)):
    try:
        class_uuid = uuid.UUID(class_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid class_id")

    live_class = db.query(LiveClass).filter(LiveClass.id == class_uuid).first()
    if not live_class:
        raise HTTPException(status_code=404, detail="Live class not found")

    live_class.start_time = payload.start_time
    live_class.end_time = payload.end_time
    db.commit()
    db.refresh(live_class)
    return _to_out(live_class)