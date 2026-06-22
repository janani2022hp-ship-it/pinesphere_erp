import uuid

from sqlalchemy import Column, ForeignKey, TIMESTAMP
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.core.database import Base


class StudentCourse(Base):
    """Links a student to the courses they selected/enrolled in."""

    __tablename__ = "student_courses"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    student_id = Column(UUID(as_uuid=True), nullable=False, index=True)

    course_id = Column(
        UUID(as_uuid=True),
        ForeignKey("courses.id"),
        nullable=False,
        index=True,
    )

    enrolled_at = Column(
        TIMESTAMP,
        server_default=func.now()
    )