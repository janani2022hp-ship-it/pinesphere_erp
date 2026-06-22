from sqlalchemy.orm import Session
from app.modules.student.models.course import Course
from app.modules.student.models.student_course import StudentCourse
import uuid


def get_all_courses(db: Session):
    return db.query(Course).all()


def get_student_courses(student_id: str, db: Session):
    # Convert string to UUID to match DB type
    student_uuid = uuid.UUID(student_id)
    
    registrations = db.query(StudentCourse).filter(
        StudentCourse.student_id == student_uuid
    ).all()
    
    course_ids = [r.course_id for r in registrations]
    
    if not course_ids:
        return []
    
    return db.query(Course).filter(Course.id.in_(course_ids)).all()


def enroll_student(student_id: str, course_id: str, db: Session):
    student_uuid = uuid.UUID(student_id)
    course_uuid = uuid.UUID(course_id)
    
    existing = db.query(StudentCourse).filter(
        StudentCourse.student_id == student_uuid,
        StudentCourse.course_id == course_uuid,
    ).first()
    if existing:
        return existing
    registration = StudentCourse(
        student_id=student_uuid,
        course_id=course_uuid,
    )
    db.add(registration)
    db.commit()
    db.refresh(registration)
    return registration