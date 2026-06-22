import uuid

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, JSON, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.core.database import Base


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    target_role = Column(String(30), index=True)
    title = Column(String(160), nullable=False)
    body = Column(Text, nullable=False)
    category = Column(String(60), default="general", index=True)
    data = Column(JSON, default=dict)
    is_read = Column(Boolean, nullable=False, default=False, index=True)
    push_status = Column(String(30), nullable=False, default="queued")
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    read_at = Column(DateTime(timezone=True))


class NotificationDevice(Base):
    __tablename__ = "notification_devices"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    role = Column(String(30), nullable=False, index=True)
    token = Column(Text, nullable=False, unique=True)
    platform = Column(String(30), nullable=False, default="unknown")
    enabled = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())


class NotificationPreference(Base):
    __tablename__ = "notification_preferences"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, unique=True)
    role = Column(String(30), nullable=False, default="student")
    push_enabled = Column(Boolean, nullable=False, default=True)
    assignment_alerts = Column(Boolean, nullable=False, default=True)
    fee_alerts = Column(Boolean, nullable=False, default=True)
    class_alerts = Column(Boolean, nullable=False, default=True)
    placement_alerts = Column(Boolean, nullable=False, default=True)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
