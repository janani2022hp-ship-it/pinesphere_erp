from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.database import Base, SessionLocal, engine
from app.core.seed import seed_demo_data

# ── Shared models ──────────────────────────────────────────────────────────────
from app.shared.models.user import User

# ── Student models ─────────────────────────────────────────────────────────────
from app.modules.student.models.student import Student
from app.modules.student.models.course import Course
from app.modules.student.models.enrollment import Enrollment
from app.modules.student.models.attendance import Attendance
from app.modules.student.models.assignment import Assignment, AssignmentSubmission
from app.modules.student.models.live_class import LiveClass
from app.modules.student.models.student_course import StudentCourse
from app.modules.student.models.course_video import CourseVideo
from app.modules.student.models.notification import Notification, NotificationDevice, NotificationPreference

# ── Routers ────────────────────────────────────────────────────────────────────
from app.modules.auth.routers.auth_router import router as auth_router
from app.modules.student.routers.dashboard_router import router as dashboard_router
from app.modules.student.routers.course_router import router as course_router
from app.modules.student.routers.coding_router import router as coding_router
from app.modules.student.routers.live_class_router import router as live_class_router
from app.modules.student.routers.live_class_router import trainer_router as live_class_trainer_router
from app.modules.student.routers.profile_router import router as profile_router
from app.modules.student.routers.study_time_router import router as study_time_router
from app.modules.admin.routers.dashboard_router import router as admin_dashboard_router
from app.modules.trainer.routers.dashboard_router import router as trainer_dashboard_router
from app.modules.trainer.routers.assignment_router import router as assignment_router
from app.modules.trainer.routers.courses import router as trainer_courses_router  # ✅
from app.modules.trainer.routers.videos import router as trainer_videos_router    # ✅
from app.modules.parent.routers.dashboard_router import router as parent_dashboard_router
from app.modules.notifications.router import router as notifications_router

# ── DB setup ───────────────────────────────────────────────────────────────────
Base.metadata.create_all(bind=engine)

db = SessionLocal()
try:
    seed_demo_data(db)
finally:
    db.close()

# ── App ────────────────────────────────────────────────────────────────────────
app = FastAPI()

BACKEND_ROOT = Path(__file__).resolve().parents[1]
UPLOAD_DIR = BACKEND_ROOT / "uploads"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Register routers ───────────────────────────────────────────────────────────
app.include_router(auth_router)
app.include_router(dashboard_router)
app.include_router(course_router)
app.include_router(coding_router)
app.include_router(live_class_router)
app.include_router(live_class_trainer_router)
app.include_router(profile_router)
app.include_router(study_time_router)
app.include_router(admin_dashboard_router)
app.include_router(trainer_dashboard_router)
app.include_router(assignment_router)
app.include_router(parent_dashboard_router)
app.include_router(trainer_courses_router, prefix="/trainer", tags=["Trainer Courses"])
app.include_router(trainer_videos_router, prefix="/trainer", tags=["Trainer Videos"])
app.include_router(notifications_router)

# ── Static files ───────────────────────────────────────────────────────────────
app.mount(
    "/uploads",
    StaticFiles(directory=str(UPLOAD_DIR)),
    name="uploads",
)


@app.get("/")
def root():
    return {"message": "ERP Backend Running"}
