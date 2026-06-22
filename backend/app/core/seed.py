"""Seed demo data for trainer/student assignment flow."""

from datetime import date, datetime
from uuid import UUID

from sqlalchemy.orm import Session

from app.modules.student.models.course import Course
from app.modules.student.models.enrollment import Enrollment
from app.modules.student.models.student import Student
from app.shared.models.user import User
from sqlalchemy import text

DEMO_TRAINER_ID = UUID("11111111-1111-1111-1111-111111111111")
DEMO_COURSE_ID = UUID("22222222-2222-2222-2222-222222222222")
DEMO_STUDENT_ID = UUID("33333333-3333-3333-3333-333333333333")
DEMO_STUDENT_USER_ID = UUID("44444444-4444-4444-4444-444444444444")

DEFAULT_DEMO_USERS = [
    ("student", "testing", "student@example.com", "student"),
    ("trainer", "testing", "trainer@example.com", "trainer"),
    ("parent", "testing", "parent@example.com", "parent"),
    ("admin", "testing", "admin@example.com", "admin"),
]


def seed_demo_data(db: Session) -> None:
    """Insert demo trainer, course, and student if they do not exist."""
    # Ensure username and role columns exist BEFORE querying User (which maps these columns)
    try:
        db.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS username VARCHAR(80) UNIQUE"))
        db.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'student'"))
        db.execute(text("UPDATE users SET username = 'user_' || substring(cast(id as varchar), 1, 8) WHERE username IS NULL OR username = ''"))
        db.execute(text("UPDATE users SET role = 'student' WHERE role IS NULL OR role = ''"))
        db.commit()
    except Exception:
        db.rollback()

    # Ensure the exact demo credentials requested by the app are available.
    for username, password, email, role in DEFAULT_DEMO_USERS:
        user = db.query(User).filter(User.username == username).first()
        if user is None:
            db.add(
                User(
                    username=username,
                    name=username.title(),
                    email=email,
                    password_hash=password,
                    role=role,
                )
            )
        else:
            user.password_hash = password
            user.role = role
            user.email = user.email or email
            user.name = user.name or username.title()

    db.commit()

    trainer = db.query(User).filter(User.id == DEMO_TRAINER_ID).first()
    if not trainer:
        db.add(
            User(
                id=DEMO_TRAINER_ID,
                username="demo_trainer",
                name="Demo Trainer",
                email="trainer@demo.com",
                password_hash="demo",
                role="trainer",
            )
        )
        db.commit()

    student_user = db.query(User).filter(User.id == DEMO_STUDENT_USER_ID).first()
    if not student_user:
        db.add(
            User(
                id=DEMO_STUDENT_USER_ID,
                username="demo_student",
                name="Demo Student",
                email="student@demo.com",
                password_hash="demo",
                role="student",
            )
        )
        db.commit()

    course = db.query(Course).filter(Course.id == DEMO_COURSE_ID).first()
    if not course:
        db.add(
            Course(
                id=DEMO_COURSE_ID,
                title="Full Stack Development",
                description="Demo course for assignments",
                duration="12 weeks",
            )
        )
        db.commit()

    student = db.query(Student).filter(Student.id == DEMO_STUDENT_ID).first()
    if not student:
        db.add(
            Student(
                id=DEMO_STUDENT_ID,
                user_id=DEMO_STUDENT_USER_ID,
                student_code="STU-001",
                course_id=DEMO_COURSE_ID,
                admission_date=date.today(),
            )
        )

    # Ensure the student and course rows are flushed before inserting the enrollment
    db.flush()

    enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == DEMO_STUDENT_ID,
        Enrollment.course_id == DEMO_COURSE_ID,
    ).first()
    if not enrollment:
        db.add(
            Enrollment(
                student_id=DEMO_STUDENT_ID,
                course_id=DEMO_COURSE_ID,
                progress=0,
                status="active",
            )
        )

    db.commit()
