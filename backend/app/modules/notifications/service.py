from uuid import UUID

from sqlalchemy.orm import Session
from sqlalchemy.sql import func

from app.modules.student.models.notification import (
    Notification,
    NotificationDevice,
    NotificationPreference,
)
from app.shared.models.user import User


def register_device(db: Session, payload):
    existing = db.query(NotificationDevice).filter(NotificationDevice.token == payload.token).first()
    if existing:
        existing.user_id = payload.user_id
        existing.role = payload.role
        existing.platform = payload.platform
        existing.enabled = payload.enabled
        db.commit()
        db.refresh(existing)
        return existing

    device = NotificationDevice(
        user_id=payload.user_id,
        role=payload.role,
        token=payload.token,
        platform=payload.platform,
        enabled=payload.enabled,
    )
    db.add(device)
    db.commit()
    db.refresh(device)
    return device


def list_notifications(db: Session, user_id: UUID, unread_only: bool = False):
    query = (
        db.query(Notification)
        .filter(Notification.user_id == user_id)
        .order_by(Notification.created_at.desc())
    )
    if unread_only:
        query = query.filter(Notification.is_read.is_(False))
    return query.limit(100).all()


def unread_count(db: Session, user_id: UUID) -> int:
    return (
        db.query(Notification)
        .filter(Notification.user_id == user_id, Notification.is_read.is_(False))
        .count()
    )


def mark_read(db: Session, notification_id: UUID):
    notification = db.query(Notification).filter(Notification.id == notification_id).first()
    if notification is None:
        return None
    notification.is_read = True
    notification.read_at = func.now()
    db.commit()
    db.refresh(notification)
    return notification


def upsert_preferences(db: Session, payload):
    preference = (
        db.query(NotificationPreference)
        .filter(NotificationPreference.user_id == payload.user_id)
        .first()
    )
    if preference is None:
        preference = NotificationPreference(user_id=payload.user_id)
        db.add(preference)

    preference.role = payload.role
    preference.push_enabled = payload.push_enabled
    preference.assignment_alerts = payload.assignment_alerts
    preference.fee_alerts = payload.fee_alerts
    preference.class_alerts = payload.class_alerts
    preference.placement_alerts = payload.placement_alerts
    db.commit()
    db.refresh(preference)
    return preference


def get_preferences(db: Session, user_id: UUID):
    return (
        db.query(NotificationPreference)
        .filter(NotificationPreference.user_id == user_id)
        .first()
    )


def send_notification(db: Session, payload):
    target_ids = list(payload.user_ids)
    if payload.target_role:
        target_ids.extend(
            user.id for user in db.query(User.id).filter(User.role == payload.target_role).all()
        )

    unique_target_ids = list(dict.fromkeys(target_ids))
    notifications = []
    for user_id in unique_target_ids:
        has_enabled_device = (
            db.query(NotificationDevice)
            .filter(
                NotificationDevice.user_id == user_id,
                NotificationDevice.enabled.is_(True),
            )
            .first()
            is not None
        )
        notifications.append(
            Notification(
                user_id=user_id,
                target_role=payload.target_role,
                title=payload.title,
                body=payload.body,
                category=payload.category,
                data=payload.data,
                push_status="queued" if has_enabled_device else "stored",
            )
        )

    db.add_all(notifications)
    db.commit()
    for notification in notifications:
        db.refresh(notification)
    return notifications
