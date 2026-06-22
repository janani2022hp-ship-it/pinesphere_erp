import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))))

from app.core.database import SessionLocal, engine
from app.modules.student.models.course import Course
from app.core.database import Base

Base.metadata.create_all(bind=engine)

courses = [
    {"title": "Business Communication", "description": "Emails, reports & presentations", "duration": "4 weeks"},
    {"title": "Data Analytics", "description": "Dashboards, insights & trends", "duration": "6 weeks"},
    {"title": "Project Management", "description": "Agile, sprints & delivery", "duration": "5 weeks"},
    {"title": "Financial Literacy", "description": "Budgets, P&L & forecasting", "duration": "4 weeks"},
    {"title": "Leadership & Management", "description": "Teams, growth & culture", "duration": "5 weeks"},
    {"title": "Digital Marketing", "description": "SEO, ads & social strategy", "duration": "4 weeks"},
]


def seed():
    db = SessionLocal()
    try:
        existing = db.query(Course).count()
        if existing >= 6:
            print("Courses already seeded.")
            return
        for c in courses:
            db.add(Course(**c))
        db.commit()
        print(f"✅ Seeded {len(courses)} courses.")
    finally:
        db.close()


if __name__ == "__main__":
    seed()