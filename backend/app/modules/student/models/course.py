import uuid

from sqlalchemy import Column, String, Text, TIMESTAMP
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.core.database import Base


class Course(Base):

    __tablename__ = "courses"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    title = Column(String(255))

    description = Column(Text)

    duration = Column(String(50))

    created_at = Column(
        TIMESTAMP,
        server_default=func.now()
    )