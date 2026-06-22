import uuid

from sqlalchemy import Column, DATE, String, TIMESTAMP, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.core.database import Base


class Attendance(Base):

    __tablename__ = "attendance"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    student_id = Column(
        UUID(as_uuid=True),
        ForeignKey("students.id")
    )

    attendance_date = Column(DATE)

    status = Column(String(20))

    created_at = Column(
        TIMESTAMP,
        server_default=func.now()
    )