from uuid import UUID

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.modules.student.models.course import Course
from app.shared.models.user import User
from app.modules.trainer.schemas.assignment_schema import (
    AssignmentSubmissionResponse,
    CreateAssignmentRequest,
    GradeAssignmentRequest,
    TrainerAssignmentResponse,
)


def create_assignment(
    db: Session,
    trainer_id: UUID,
    request: CreateAssignmentRequest
):
    """Create a new assignment for a course."""
    trainer = db.query(User).filter(User.id == trainer_id).first()
    if not trainer:
        raise ValueError("Trainer not found")

    course = db.query(Course).filter(Course.id == request.course_id).first()
    if not course:
        raise ValueError("Course not found")

    db_assignment = Assignment(
        title=request.title,
        description=request.description,
        subject=request.subject,
        due_date=request.due_date,
        course_id=request.course_id,
        trainer_id=trainer_id,
        attachment=request.attachment
    )
    db.add(db_assignment)
    db.commit()
    db.refresh(db_assignment)
    return db_assignment


def get_trainer_assignments(
    db: Session,
    trainer_id: UUID
) -> list[TrainerAssignmentResponse]:
    """Get all assignments created by a trainer"""
    assignments = db.query(Assignment).filter(
        Assignment.trainer_id == trainer_id
    ).all()

    result = []
    for assignment in assignments:
        submission_count = db.query(func.count(AssignmentSubmission.id)).filter(
            AssignmentSubmission.assignment_id == assignment.id
        ).scalar() or 0

        result.append(TrainerAssignmentResponse(
            id=assignment.id,
            title=assignment.title,
            description=assignment.description,
            subject=assignment.subject,
            due_date=assignment.due_date,
            course_id=assignment.course_id,
            trainer_id=assignment.trainer_id,
            attachment=assignment.attachment,
            created_at=assignment.created_at,
            submissions=submission_count
        ))

    return result


def get_assignment_submissions(
    db: Session,
    assignment_id: UUID
) -> list[AssignmentSubmissionResponse]:
    """Get all submissions for an assignment"""
    submissions = db.query(AssignmentSubmission).filter(
        AssignmentSubmission.assignment_id == assignment_id
    ).all()

    return [
        AssignmentSubmissionResponse.model_validate(submission)
        for submission in submissions
    ]


def grade_assignment(
    db: Session,
    request: GradeAssignmentRequest
) -> AssignmentSubmission:
    """Grade a student submission"""
    submission = db.query(AssignmentSubmission).filter(
        AssignmentSubmission.id == request.submission_id
    ).first()

    if not submission:
        raise ValueError("Submission not found")

    submission.marks = request.marks
    submission.feedback = request.feedback
    submission.status = request.status

    db.commit()
    db.refresh(submission)
    return submission
