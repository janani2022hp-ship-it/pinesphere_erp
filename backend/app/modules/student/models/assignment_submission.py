# AssignmentSubmission model removed — submissions are UI-only in the app.
# File retained as an empty stub to avoid import failures during partial cleanups.import uuid
from sqlalchemy import Column, String, Text, Integer, DateTime, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.core.database import Base

class AssignmentSubmission(Base):
    __tablename__ = "assignment_submissions"

    id            = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    assignment_id = Column(UUID(as_uuid=True), nullable=False)
    student_id    = Column(UUID(as_uuid=True), nullable=False)
    answers       = Column(JSON, default=list)
    file_url      = Column(Text, nullable=True)
    notes         = Column(Text, default='')
    grade         = Column(String(10), nullable=True)
    marks         = Column(Integer, nullable=True)
    feedback      = Column(Text, nullable=True)
    status        = Column(String(20), default='Submitted')
    submitted_at  = Column(DateTime(timezone=True), server_default=func.now())