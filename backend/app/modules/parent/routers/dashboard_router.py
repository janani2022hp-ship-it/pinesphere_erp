from fastapi import APIRouter

from app.modules.parent.services.dashboard_service import get_parent_dashboard_data

router = APIRouter(prefix="/parent", tags=["Parent Dashboard"])


@router.get("/dashboard")
def parent_dashboard():
    return get_parent_dashboard_data()
