import uuid

from sqlalchemy import Column, String, DATE, TIMESTAMP, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.core.database import Base


class Student(Base):

    __tablename__ = "students"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id")
    )

    student_code = Column(String(50), unique=True)

    branch_id = Column(UUID(as_uuid=True))

    course_id = Column(UUID(as_uuid=True))

    admission_date = Column(DATE)

    created_at = Column(
        TIMESTAMP,
        server_default=func.now()
    )