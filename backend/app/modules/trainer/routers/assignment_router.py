# app/modules/trainer/routers/assignment_router.py

import uuid
from typing import List, Optional, Any
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File
from pydantic import BaseModel
from sqlalchemy.orm import Session
import httpx
import os

from app.core.database import get_db
from app.modules.student.models.assignment import Assignment, AssignmentSubmission

router = APIRouter(tags=["assignments"])


# ── Schemas ────────────────────────────────────────────────────────────────────

class QuestionSchema(BaseModel):
    question: str
    model_answer: str = ""   # trainer's expected answer for AI grading
    marks: int = 10          # marks for this question


class AssignmentCreate(BaseModel):
    trainer_id: str
    course_id: Optional[str] = None
    title: str
    description: str = ""
    subject: str = "General"
    due_date: str = ""
    assignment_type: str = "written"   # written | quiz | file
    questions: List[QuestionSchema] = []
    quiz_link: Optional[str] = None
    total_marks: int = 100


class AssignmentOut(BaseModel):
    id: str
    trainer_id: str
    course_id: Optional[str]
    title: str
    description: str
    subject: str
    due_date: str
    status: str
    assignment_type: str
    questions: List[Any]
    quiz_link: Optional[str]
    total_marks: int

    class Config:
        from_attributes = True


class SubmissionCreate(BaseModel):
    answers: List[str] = []     # for written — one answer per question
    notes: str = ""             # for quiz/file — optional note
    file_url: Optional[str] = None  # for file upload


class SubmissionOut(BaseModel):
    id: str
    assignment_id: str
    student_id: str
    answers: List[Any]
    notes: str
    file_url: Optional[str]
    grade: Optional[str]
    marks: Optional[int]
    feedback: Optional[str]
    status: str

    class Config:
        from_attributes = True


class GradeRequest(BaseModel):
    grade: str
    marks: Optional[int] = None
    feedback: str = ""


class StudentAssignmentOut(BaseModel):
    id: str
    title: str
    description: str
    subject: str
    due_date: str
    status: str
    assignment_type: str
    questions: List[Any]
    quiz_link: Optional[str]
    total_marks: int
    grade: Optional[str]
    marks: Optional[int]
    feedback: Optional[str]
    submission_id: Optional[str]
    answers: Optional[List[Any]]


# ── Trainer: Create assignment ─────────────────────────────────────────────────

@router.post("/trainer/assignments", response_model=AssignmentOut)
def create_assignment(payload: AssignmentCreate, db: Session = Depends(get_db)):
    """Trainer creates assignment — visible to ALL students immediately."""
    assignment = Assignment(
        trainer_id      = uuid.UUID(payload.trainer_id),
        course_id       = uuid.UUID(payload.course_id) if payload.course_id else None,
        title           = payload.title,
        description     = payload.description,
        subject         = payload.subject,
        due_date        = payload.due_date,
        status          = "Open",
        assignment_type = payload.assignment_type,
        questions       = [q.dict() for q in payload.questions],
        quiz_link       = payload.quiz_link,
        total_marks     = payload.total_marks,
    )
    db.add(assignment)
    db.commit()
    db.refresh(assignment)
    return _assignment_out(assignment)


# ── Trainer: Get their assignments ────────────────────────────────────────────

@router.get("/trainer/assignments/{trainer_id}", response_model=List[AssignmentOut])
def get_trainer_assignments(trainer_id: str, db: Session = Depends(get_db)):
    assignments = db.query(Assignment).filter(
        Assignment.trainer_id == uuid.UUID(trainer_id)
    ).order_by(Assignment.created_at.desc()).all()
    return [_assignment_out(a) for a in assignments]


# ── Trainer: View submissions for an assignment ───────────────────────────────

@router.get("/trainer/assignments/{assignment_id}/submissions", response_model=List[SubmissionOut])
def get_submissions(assignment_id: str, db: Session = Depends(get_db)):
    submissions = db.query(AssignmentSubmission).filter(
        AssignmentSubmission.assignment_id == uuid.UUID(assignment_id)
    ).all()
    return [_submission_out(s) for s in submissions]


# ── Trainer: Manual grade ─────────────────────────────────────────────────────

@router.post("/trainer/grade/{submission_id}", response_model=SubmissionOut)
def grade_submission(submission_id: str, payload: GradeRequest, db: Session = Depends(get_db)):
    sub = db.query(AssignmentSubmission).filter(
        AssignmentSubmission.id == uuid.UUID(submission_id)
    ).first()
    if not sub:
        raise HTTPException(status_code=404, detail="Submission not found")
    sub.grade    = payload.grade
    sub.marks    = payload.marks
    sub.feedback = payload.feedback
    sub.status   = "Graded"
    db.commit()
    db.refresh(sub)
    return _submission_out(sub)


# ── Student: Get all assignments with submission status ───────────────────────

@router.get("/student/my-assignments/{student_id}", response_model=List[StudentAssignmentOut])
def get_student_assignments(student_id: str, db: Session = Depends(get_db)):
    try:
        sid = uuid.UUID(student_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid student_id")

    # Get the course IDs this student is enrolled in
    from app.modules.student.models.student_course import StudentCourse
    enrolled = db.query(StudentCourse).filter(
        StudentCourse.student_id == sid
    ).all()
    enrolled_course_ids = [e.course_id for e in enrolled]

    # Only fetch assignments belonging to enrolled courses
    # Also include assignments with no course_id (general assignments)
    from sqlalchemy import or_
    assignments = db.query(Assignment).filter(
        Assignment.status == "Open",
        or_(
            Assignment.course_id.in_(enrolled_course_ids),
            Assignment.course_id == None,
        )
    ).order_by(Assignment.created_at.desc()).all()

    result = []
    for a in assignments:
        sub = db.query(AssignmentSubmission).filter(
            AssignmentSubmission.assignment_id == a.id,
            AssignmentSubmission.student_id    == sid,
        ).first()

        result.append(StudentAssignmentOut(
            id              = str(a.id),
            title           = a.title or "",
            description     = a.description or "",
            subject         = a.subject or "General",
            due_date        = str(a.due_date) if a.due_date else "",
            status          = sub.status if sub else "Open",
            assignment_type = a.assignment_type or "written",
            questions       = a.questions or [],
            quiz_link       = a.quiz_link,
            total_marks     = a.total_marks or 100,
            grade           = sub.grade if sub else None,
            marks           = sub.marks if sub else None,
            feedback        = sub.feedback if sub else None,
            submission_id   = str(sub.id) if sub else None,
            answers         = sub.answers if sub else None,
        ))

    return result


# ── Student: Submit assignment ────────────────────────────────────────────────

@router.post("/student/submit-assignment/{assignment_id}", response_model=SubmissionOut)
async def submit_assignment(
    assignment_id: str,
    student_id: str,
    payload: SubmissionCreate,
    db: Session = Depends(get_db),
):
    try:
        aid = uuid.UUID(assignment_id)
        sid = uuid.UUID(student_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid ID")

    assignment = db.query(Assignment).filter(Assignment.id == aid).first()
    if not assignment:
        raise HTTPException(status_code=404, detail="Assignment not found")

    existing = db.query(AssignmentSubmission).filter(
        AssignmentSubmission.assignment_id == aid,
        AssignmentSubmission.student_id    == sid,
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Already submitted")

    # Auto-grade written assignments using AI
    auto_grade = None
    auto_marks = None
    auto_feedback = None

    if assignment.assignment_type == "written" and payload.answers and assignment.questions:
        try:
            result = await _ai_grade(
                questions=assignment.questions,
                answers=payload.answers,
                total_marks=assignment.total_marks or 100,
            )
            auto_marks    = result.get("marks")
            auto_grade    = result.get("grade")
            auto_feedback = result.get("feedback")
        except Exception:
            pass  # If AI fails, submission still saves without grade

    sub = AssignmentSubmission(
        assignment_id = aid,
        student_id    = sid,
        answers       = payload.answers,
        notes         = payload.notes,
        file_url      = payload.file_url,
        status        = "Graded" if auto_grade else "Submitted",
        grade         = auto_grade,
        marks         = auto_marks,
        feedback      = auto_feedback,
    )
    db.add(sub)
    db.commit()
    db.refresh(sub)
    return _submission_out(sub)


# ── AI Grading ────────────────────────────────────────────────────────────────

async def _ai_grade(questions: list, answers: list, total_marks: int) -> dict:
    """
    Uses Claude API to auto-grade written answers.
    Set ANTHROPIC_API_KEY in your environment.
    """
    api_key = os.getenv("ANTHROPIC_API_KEY", "")
    if not api_key:
        return {}

    # Build prompt
    qa_pairs = []
    marks_per_q = []
    for i, q in enumerate(questions):
        student_answer = answers[i] if i < len(answers) else "(no answer)"
        marks = q.get("marks", 10)
        marks_per_q.append(marks)
        qa_pairs.append(
            f"Q{i+1} [{marks} marks]: {q.get('question', '')}\n"
            f"Model Answer: {q.get('model_answer', '')}\n"
            f"Student Answer: {student_answer}"
        )

    prompt = f"""You are grading a student assignment. Total marks: {total_marks}.

{chr(10).join(qa_pairs)}

For each question, award marks out of the question's total based on correctness and completeness.
Then provide:
1. Total marks awarded out of {total_marks}
2. A letter grade (A, B, C, D, F)
3. Brief constructive feedback (2-3 sentences)

Respond in this exact JSON format:
{{"marks": <number>, "grade": "<letter>", "feedback": "<feedback text>"}}
Only respond with the JSON, nothing else."""

    async with httpx.AsyncClient() as client:
        resp = await client.post(
            "https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": api_key,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
            json={
                "model": "claude-haiku-4-5-20251001",
                "max_tokens": 256,
                "messages": [{"role": "user", "content": prompt}],
            },
            timeout=15.0,
        )

    if resp.status_code != 200:
        return {}

    import json
    text = resp.json()["content"][0]["text"].strip()
    return json.loads(text)


# ── Helpers ────────────────────────────────────────────────────────────────────

def _assignment_out(a: Assignment) -> AssignmentOut:
    return AssignmentOut(
        id              = str(a.id),
        trainer_id      = str(a.trainer_id),
        course_id       = str(a.course_id) if a.course_id else None,
        title           = a.title,
        description     = a.description or "",
        subject         = a.subject or "General",
        due_date        = str(a.due_date) if a.due_date else "",
        status          = a.status or "Open",
        assignment_type = a.assignment_type or "written",
        questions       = a.questions or [],
        quiz_link       = a.quiz_link,
        total_marks     = a.total_marks or 100,
    )


def _submission_out(s: AssignmentSubmission) -> SubmissionOut:
    return SubmissionOut(
        id            = str(s.id),
        assignment_id = str(s.assignment_id),
        student_id    = str(s.student_id),
        answers       = s.answers or [],
        notes         = s.notes or "",
        file_url      = s.file_url,
        grade         = s.grade,
        marks         = s.marks,
        feedback      = s.feedback,
        status        = s.status or "Submitted",
    )