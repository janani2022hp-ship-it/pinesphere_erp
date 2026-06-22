import uuid
import cloudinary
import cloudinary.uploader
from fastapi import UploadFile, HTTPException
from sqlalchemy.orm import Session
from app.modules.student.models.course_video import CourseVideo

cloudinary.config(
    cloud_name="ds0flfph3",
    api_key="764998111853942",
    api_secret="OZk8HU8fOICc1nkoAI5GgSVh4MQ",
    secure=True,
)


def _get_hls_url(public_id: str) -> str:
    return (
        f"https://res.cloudinary.com/ds0flfph3/video/upload"
        f"/sp_full_hd/{public_id}.m3u8"
    )


async def create_video(
    course_id: str,
    trainer_id: str,
    title: str,
    description: str,
    duration_minutes: int,
    sequence: int,
    file: UploadFile,
    db: Session,
):
    contents = await file.read()

    result = cloudinary.uploader.upload(
        contents,
        resource_type="video",
        folder=f"course_videos/{course_id}",
        public_id=f"{course_id}_{sequence}_{title.replace(' ', '_')}",
        overwrite=True,
        eager=[
            {"streaming_profile": "full_hd", "format": "m3u8"},
        ],
        eager_async=True,
    )

    public_id = result["public_id"]
    hls_url = _get_hls_url(public_id)

    # ✅ Convert string UUIDs to UUID objects
    video = CourseVideo(
        course_id=uuid.UUID(course_id),
        trainer_id=uuid.UUID(trainer_id),
        title=title,
        description=description,
        video_url=hls_url,
        duration_minutes=duration_minutes,
        sequence=sequence,
    )
    db.add(video)
    db.commit()
    db.refresh(video)
    return video


def get_videos_by_course(course_id: str, db: Session):
    return (
        db.query(CourseVideo)
        .filter(CourseVideo.course_id == uuid.UUID(course_id))  # ✅
        .order_by(CourseVideo.sequence)
        .all()
    )


def delete_video(video_id: str, db: Session):
    video = db.query(CourseVideo).filter(
        CourseVideo.id == uuid.UUID(video_id)  # ✅
    ).first()
    if not video:
        raise HTTPException(status_code=404, detail="Video not found")

    try:
        public_id = video.video_url.split("/sp_full_hd/")[-1].replace(".m3u8", "")
        cloudinary.uploader.destroy(public_id, resource_type="video")
    except Exception:
        pass

    db.delete(video)
    db.commit()
    return {"message": "Video deleted successfully"}