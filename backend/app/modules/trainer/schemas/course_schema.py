from pydantic import BaseModel
from typing import List
from uuid import UUID
from .video_schema import VideoOut


class CourseOut(BaseModel):
    id: UUID          # ✅ changed from str to UUID
    title: str
    description: str
    duration: str
    videos: List[VideoOut] = []

    class Config:
        from_attributes = True


class CourseCreate(BaseModel):
    title: str
    description: str
    duration: str