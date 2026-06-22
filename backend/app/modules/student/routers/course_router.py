# app/modules/student/routers/course_router.py

import uuid
from typing import List, Optional
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.modules.student.models.course import Course
from app.modules.student.models.student_course import StudentCourse
from app.modules.student.models.course_video import CourseVideo

router = APIRouter(tags=["courses"])

MIN_COURSES_REQUIRED = 4


# ── Schemas ──────────────────────────────────────────────────────────────────

class CourseOut(BaseModel):
    id: str
    title: str
    description: str
    duration: str

    class Config:
        from_attributes = True


class CourseCreate(BaseModel):
    trainer_id: str
    title: str
    description: str = ""
    duration: str = ""


class SelectCoursesRequest(BaseModel):
    student_id: str
    course_ids: List[str]


class VideoOut(BaseModel):
    id: str
    course_id: str
    title: str
    description: str
    video_url: str
    duration_minutes: int
    sequence: int

    class Config:
        from_attributes = True


class VideoCreate(BaseModel):
    trainer_id: str
    title: str
    description: str = ""
    video_url: str
    duration_minutes: int = 0
    sequence: int = 0


class MyCourseOut(BaseModel):
    id: str
    title: str
    description: str
    duration: str
    videos: List[VideoOut]


# ── Student: List ALL available courses (for selection) ──────────────────────

@router.get("/student/courses/all", response_model=List[CourseOut])
def list_all_courses(db: Session = Depends(get_db)):
    courses = db.query(Course).order_by(Course.created_at.desc()).all()
    return [_course_out(c) for c in courses]


# ── Student: Check if courses already selected ────────────────────────────────

@router.get("/student/courses/selected/{student_id}", response_model=List[str])
def get_selected_course_ids(student_id: str, db: Session = Depends(get_db)):
    try:
        sid = uuid.UUID(student_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid student_id")

    rows = db.query(StudentCourse).filter(StudentCourse.student_id == sid).all()
    return [str(r.course_id) for r in rows]


# ── Student: Select courses (minimum 4) ───────────────────────────────────────

@router.post("/student/courses/select")
def select_courses(payload: SelectCoursesRequest, db: Session = Depends(get_db)):
    if len(payload.course_ids) < MIN_COURSES_REQUIRED:
        raise HTTPException(
            status_code=400,
            detail=f"Please select at least {MIN_COURSES_REQUIRED} courses",
        )

    try:
        sid = uuid.UUID(payload.student_id)
        course_uuids = [uuid.UUID(c) for c in payload.course_ids]
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid student_id or course_id")

    # Remove previous selections (allows re-selecting anytime)
    db.query(StudentCourse).filter(StudentCourse.student_id == sid).delete()

    for cid in course_uuids:
        db.add(StudentCourse(student_id=sid, course_id=cid))

    db.commit()
    return {"message": "Courses selected successfully", "count": len(course_uuids)}


# ── Student: Get MY enrolled courses with videos ──────────────────────────────

@router.get("/student/courses/my/{student_id}", response_model=List[MyCourseOut])
def get_my_courses(student_id: str, db: Session = Depends(get_db)):
    try:
        sid = uuid.UUID(student_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid student_id")

    enrolled = db.query(StudentCourse).filter(StudentCourse.student_id == sid).all()
    course_ids = [e.course_id for e in enrolled]

    if not course_ids:
        return []

    courses = db.query(Course).filter(Course.id.in_(course_ids)).all()

    result = []
    for c in courses:
        videos = (
            db.query(CourseVideo)
            .filter(CourseVideo.course_id == c.id)
            .order_by(CourseVideo.sequence.asc())
            .all()
        )
        result.append(MyCourseOut(
            id=str(c.id),
            title=c.title or "",
            description=c.description or "",
            duration=c.duration or "",
            videos=[_video_out(v) for v in videos],
        ))

    return result


# ── Trainer: Create a course ──────────────────────────────────────────────────

@router.post("/trainer/courses", response_model=CourseOut)
def create_course(payload: CourseCreate, db: Session = Depends(get_db)):
    course = Course(
        title=payload.title,
        description=payload.description,
        duration=payload.duration,
    )
    db.add(course)
    db.commit()
    db.refresh(course)
    return _course_out(course)


# ── Trainer: List their courses ───────────────────────────────────────────────

@router.get("/trainer/courses", response_model=List[CourseOut])
def list_trainer_courses(db: Session = Depends(get_db)):
    courses = db.query(Course).order_by(Course.created_at.desc()).all()
    return [_course_out(c) for c in courses]


# ── Trainer: Upload a video to a course ───────────────────────────────────────


# ── Trainer: List videos for a course ─────────────────────────────────────────


# ── Helpers ────────────────────────────────────────────────────────────────────

def _course_out(c: Course) -> CourseOut:
    return CourseOut(
        id=str(c.id),
        title=c.title or "",
        description=c.description or "",
        duration=c.duration or "",
    )


def _video_out(v: CourseVideo) -> VideoOut:
    return VideoOut(
        id=str(v.id),
        course_id=str(v.course_id),
        title=v.title or "",
        description=v.description or "",
        video_url=v.video_url or "",
        duration_minutes=v.duration_minutes or 0,
        sequence=v.sequence or 0,
    )