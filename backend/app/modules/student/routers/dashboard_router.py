from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.modules.student.services.dashboard_service import (
    get_dashboard_data
)

router = APIRouter(
    prefix="/student",
    tags=["Student Dashboard"]
)


@router.get("/dashboard/{student_id}")
def student_dashboard(
    student_id: str,
    db: Session = Depends(get_db)
):
    return get_dashboard_data(db, student_id)