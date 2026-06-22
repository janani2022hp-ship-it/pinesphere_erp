from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import BaseModel, Field


class DeviceRegistrationRequest(BaseModel):
    user_id: UUID
    role: str = "student"
    token: str = Field(..., min_length=8)
    platform: str = "unknown"
    enabled: bool = True


class NotificationSendRequest(BaseModel):
    title: str = Field(..., min_length=1, max_length=160)
    body: str = Field(..., min_length=1)
    target_role: str | None = None
    user_ids: list[UUID] = Field(default_factory=list)
    category: str = "general"
    data: dict[str, Any] = Field(default_factory=dict)


class NotificationPreferenceRequest(BaseModel):
    user_id: UUID
    role: str = "student"
    push_enabled: bool = True
    assignment_alerts: bool = True
    fee_alerts: bool = True
    class_alerts: bool = True
    placement_alerts: bool = True


class NotificationResponse(BaseModel):
    id: UUID
    user_id: UUID
    target_role: str | None
    title: str
    body: str
    category: str
    data: dict[str, Any]
    is_read: bool
    push_status: str
    created_at: datetime
    read_at: datetime | None

    model_config = {"from_attributes": True}
