import uuid

from sqlalchemy import Column, Integer, String, TIMESTAMP, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.core.database import Base


class Enrollment(Base):

    __tablename__ = "enrollments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    student_id = Column(
        UUID(as_uuid=True),
        ForeignKey("students.id")
    )

    course_id = Column(
        UUID(as_uuid=True),
        ForeignKey("courses.id")
    )

    progress = Column(Integer, default=0)

    status = Column(String(50))

    created_at = Column(
        TIMESTAMP,
        server_default=func.now()
    )