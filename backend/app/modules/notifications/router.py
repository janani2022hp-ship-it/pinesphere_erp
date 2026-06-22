from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.modules.notifications.schemas import (
    DeviceRegistrationRequest,
    NotificationPreferenceRequest,
    NotificationResponse,
    NotificationSendRequest,
)
from app.modules.notifications.service import (
    get_preferences,
    list_notifications,
    mark_read,
    register_device,
    send_notification,
    unread_count,
    upsert_preferences,
)

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.post("/devices")
def register_push_device(payload: DeviceRegistrationRequest, db: Session = Depends(get_db)):
    device = register_device(db, payload)
    return {
        "message": "Device registered",
        "device_id": str(device.id),
        "push_enabled": device.enabled,
    }


@router.post("/send", response_model=list[NotificationResponse])
def create_role_notification(payload: NotificationSendRequest, db: Session = Depends(get_db)):
    if not payload.user_ids and not payload.target_role:
        raise HTTPException(status_code=400, detail="Provide target_role or user_ids")
    return send_notification(db, payload)


@router.get("/preferences/{user_id}")
def read_preferences(user_id: UUID, db: Session = Depends(get_db)):
    preference = get_preferences(db, user_id)
    if preference is None:
        return {
            "user_id": str(user_id),
            "push_enabled": True,
            "assignment_alerts": True,
            "fee_alerts": True,
            "class_alerts": True,
            "placement_alerts": True,
        }
    return {
        "user_id": str(preference.user_id),
        "role": preference.role,
        "push_enabled": preference.push_enabled,
        "assignment_alerts": preference.assignment_alerts,
        "fee_alerts": preference.fee_alerts,
        "class_alerts": preference.class_alerts,
        "placement_alerts": preference.placement_alerts,
    }


@router.put("/preferences")
def save_preferences(payload: NotificationPreferenceRequest, db: Session = Depends(get_db)):
    preference = upsert_preferences(db, payload)
    return {
        "message": "Notification preferences saved",
        "user_id": str(preference.user_id),
        "push_enabled": preference.push_enabled,
    }


@router.get("/{user_id}", response_model=list[NotificationResponse])
def get_user_notifications(
    user_id: UUID,
    unread_only: bool = False,
    db: Session = Depends(get_db),
):
    return list_notifications(db, user_id, unread_only=unread_only)


@router.get("/{user_id}/unread-count")
def get_unread_count(user_id: UUID, db: Session = Depends(get_db)):
    return {"unread_count": unread_count(db, user_id)}


@router.patch("/{notification_id}/read", response_model=NotificationResponse)
def read_notification(notification_id: UUID, db: Session = Depends(get_db)):
    notification = mark_read(db, notification_id)
    if notification is None:
        raise HTTPException(status_code=404, detail="Notification not found")
    return notification
