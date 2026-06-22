import uuid
from datetime import date
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy import Column, Date, Float, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Session
from app.core.database import Base, get_db

router = APIRouter(prefix="/student", tags=["student"])

class StudyTimeLog(Base):
    __tablename__ = "study_time_logs"
    id         = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id = Column(UUID(as_uuid=True), nullable=False)
    log_date   = Column(Date, nullable=False)
    hours      = Column(Float, default=0.0)

class LogRequest(BaseModel):
    student_id: str
    hours: float

class WeeklyResponse(BaseModel):
    days: list[float]  # 7 values Mon–Sun

@router.post("/study-time/log")
def log_study_time(payload: LogRequest, db: Session = Depends(get_db)):
    today = date.today()
    existing = db.query(StudyTimeLog).filter(
        StudyTimeLog.student_id == payload.student_id,
        StudyTimeLog.log_date == today,
    ).first()
    if existing:
        existing.hours = min(existing.hours + payload.hours, 24.0)
    else:
        db.add(StudyTimeLog(
            student_id=payload.student_id,
            log_date=today,
            hours=min(payload.hours, 24.0),
        ))
    db.commit()
    return {"status": "ok"}

@router.get("/study-time/weekly/{student_id}", response_model=WeeklyResponse)
def get_weekly(student_id: str, db: Session = Depends(get_db)):
    from datetime import timedelta
    today = date.today()
    monday = today - timedelta(days=today.weekday())
    days = [0.0] * 7
    logs = db.query(StudyTimeLog).filter(
        StudyTimeLog.student_id == student_id,
        StudyTimeLog.log_date >= monday,
        StudyTimeLog.log_date <= today,
    ).all()
    for log in logs:
        idx = (log.log_date - monday).days
        if 0 <= idx < 7:
            days[idx] = log.hours
    return WeeklyResponse(days=days)