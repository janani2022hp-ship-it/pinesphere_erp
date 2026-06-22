from fastapi import APIRouter

from app.modules.admin.services.dashboard_service import get_admin_dashboard_data

router = APIRouter(prefix="/admin", tags=["Admin Dashboard"])


@router.get("/dashboard")
def admin_dashboard():
    return get_admin_dashboard_data()
