import uuid

from sqlalchemy import Column, String, Text, Integer, ForeignKey, TIMESTAMP
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.core.database import Base


class CourseVideo(Base):
    """A video/lesson uploaded by a trainer for a specific course."""

    __tablename__ = "course_videos"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    course_id = Column(
        UUID(as_uuid=True),
        ForeignKey("courses.id"),
        nullable=False,
        index=True,
    )

    trainer_id = Column(UUID(as_uuid=True), nullable=False, index=True)

    title = Column(String(255), nullable=False)

    description = Column(Text)

    video_url = Column(String(500), nullable=False)

    duration_minutes = Column(Integer, default=0)

    # Order in which videos appear within a course
    sequence = Column(Integer, default=0)

    created_at = Column(
        TIMESTAMP,
        server_default=func.now()
    )