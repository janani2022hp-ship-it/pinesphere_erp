# app/modules/student/models/assignment.py

import uuid
from sqlalchemy import Column, String, Text, TIMESTAMP, ForeignKey, Integer, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.core.database import Base


class Assignment(Base):
    __tablename__ = "assignments"

    id            = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    trainer_id    = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    course_id     = Column(UUID(as_uuid=True), ForeignKey("courses.id"), nullable=True)
    title         = Column(String(255), nullable=False)
    description   = Column(Text, default="")
    subject       = Column(String(100), default="General")
    due_date      = Column(String(100), default="")
    status        = Column(String(20), default="Open")

    # NEW: assignment type — "written" | "quiz" | "file"
    assignment_type = Column(String(20), default="written")

    # NEW: for written — list of question dicts [{question, model_answer, marks}]
    questions     = Column(JSON, default=list)

    # NEW: for quiz — external URL (Google Forms etc.)
    quiz_link     = Column(String(500), nullable=True)

    # NEW: total marks possible
    total_marks   = Column(Integer, default=100)

    created_at    = Column(TIMESTAMP, server_default=func.now())


class AssignmentSubmission(Base):
    __tablename__ = "assignment_submissions"

    id            = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    assignment_id = Column(UUID(as_uuid=True), ForeignKey("assignments.id"), nullable=False)
    student_id    = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)

    # Student's written answers — list of strings matching questions order
    answers       = Column(JSON, default=list)

    # For file upload — stored file path or URL
    file_url      = Column(String(500), nullable=True)

    # For quiz — student just marks as done, no answer stored
    notes         = Column(Text, default="")

    # Grading
    grade         = Column(String(20), nullable=True)   # e.g. "85/100" or "A"
    marks         = Column(Integer, nullable=True)       # numeric score
    feedback      = Column(Text, nullable=True)
    status        = Column(String(20), default="Submitted")  # Submitted | Graded
    submitted_at  = Column(TIMESTAMP, server_default=func.now())