from fastapi import APIRouter, Depends, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import Optional
from app.core.database import get_db
from app.modules.trainer.schemas.video_schema import VideoOut
from app.modules.trainer.services.video_service import (
    create_video,
    get_videos_by_course,
    delete_video,
)

router = APIRouter()


@router.get("/courses/{course_id}/videos", response_model=list[VideoOut])
def list_videos(course_id: str, db: Session = Depends(get_db)):
    return get_videos_by_course(course_id, db)


@router.post("/courses/{course_id}/videos", response_model=VideoOut)
async def upload_video(
    course_id: str,
    trainer_id: str = Form(...),
    title: str = Form(...),
    description: str = Form(default=''),
    duration_minutes: int = Form(default=0),
    sequence: int = Form(default=0),       # ✅ optional now
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    return await create_video(
        course_id, trainer_id, title,
        description, duration_minutes, sequence, file, db
    )


@router.delete("/courses/{course_id}/videos/{video_id}")
def remove_video(
    course_id: str, video_id: str, db: Session = Depends(get_db)
):
    return delete_video(video_id, db)