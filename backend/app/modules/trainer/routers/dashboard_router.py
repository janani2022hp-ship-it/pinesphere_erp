from fastapi import APIRouter

from app.modules.trainer.services.dashboard_service import get_trainer_dashboard_data

router = APIRouter(prefix="/trainer", tags=["Trainer Dashboard"])


@router.get("/dashboard")
def trainer_dashboard():
    return get_trainer_dashboard_data()
