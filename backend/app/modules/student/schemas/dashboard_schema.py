from pydantic import BaseModel
from typing import List


class AssignmentItem(BaseModel):
    title: str
    due: str


class NotificationItem(BaseModel):
    title: str


class DashboardResponse(BaseModel):

    student_name: str

    weekly_streak: int

    xp: int

    courses: int

    continue_course: str

    course_progress: int

    course_progress_text: str

    study_hours: str

    assignments_done: str

    attendance: str

    assignments: List[AssignmentItem]

    notifications: List[NotificationItem]
