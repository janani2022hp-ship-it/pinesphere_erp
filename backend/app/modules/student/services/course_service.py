from sqlalchemy.orm import Session

from app.modules.student.models.course import Course


def get_student_courses(db: Session):
    courses = db.query(Course).order_by(Course.created_at.desc()).all()

    return {
        "courses": [
            {
                "id": str(course.id),
                "title": course.title or "Untitled Course",
                "description": course.description or "No description added yet",
                "duration": course.duration or "0 hrs",
                "progress": 0,
                "watched_hours": "0",
                "video_title": f"{course.title or 'Course'} sample lesson",
                "video_url": "https://samplelib.com/lib/preview/mp4/sample-5s.mp4",
            }
            for course in courses
        ]
    }
