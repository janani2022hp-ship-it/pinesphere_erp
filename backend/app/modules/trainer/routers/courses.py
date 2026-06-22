from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.modules.trainer.schemas.course_schema import CourseOut
from app.modules.trainer.services.course_service import (
    get_all_courses,
    get_student_courses,
    enroll_student,
)

router = APIRouter()


@router.get("/courses", response_model=list[CourseOut])
def all_courses(db: Session = Depends(get_db)):
    return get_all_courses(db)


@router.get("/students/{student_id}/courses", response_model=list[CourseOut])
def student_courses(student_id: str, db: Session = Depends(get_db)):
    return get_student_courses(student_id, db)


@router.post("/students/{student_id}/courses/{course_id}")
def enroll(student_id: str, course_id: str, db: Session = Depends(get_db)):
    return enroll_student(student_id, course_id, db)