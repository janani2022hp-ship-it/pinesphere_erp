from pydantic import BaseModel
from datetime import datetime
from uuid import UUID


class VideoOut(BaseModel):
    id: UUID
    course_id: UUID
    trainer_id: UUID
    title: str
    description: str
    video_url: str
    duration_minutes: int
    sequence: int
    created_at: datetime

    class Config:
        from_attributes = True


class VideoCreate(BaseModel):
    title: str
    description: str
    duration_minutes: int
    sequence: int