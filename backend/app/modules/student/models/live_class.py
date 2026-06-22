import uuid
from sqlalchemy import Column, String, TIMESTAMP, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.core.database import Base


class LiveClass(Base):
    __tablename__ = "live_classes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    course_id = Column(UUID(as_uuid=True), ForeignKey("courses.id"), nullable=False)
    title = Column(String(255), nullable=False)
    teacher_name = Column(String(255), nullable=False)
    start_time = Column(TIMESTAMP, nullable=True)
    end_time = Column(TIMESTAMP, nullable=True)
    is_live = Column(Boolean, default=False)
    meeting_link = Column(String(500), nullable=True)
    created_at = Column(TIMESTAMP, server_default=func.now())