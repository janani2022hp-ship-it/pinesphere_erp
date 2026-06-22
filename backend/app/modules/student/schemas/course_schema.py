from pydantic import BaseModel
from typing import List


class CourseItem(BaseModel):
    id: str
    title: str
    description: str
    duration: str
    progress: int
    watched_hours: str
    video_title: str
    video_url: str | None = None


class CoursesResponse(BaseModel):
    courses: List[CourseItem]
