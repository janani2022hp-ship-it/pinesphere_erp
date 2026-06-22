def get_trainer_dashboard_data():
    return {
        "role": "Trainer",
        "title": "Trainer Workspace",
        "summary": [
            {"label": "Classes", "value": "0", "icon": "🎥"},
            {"label": "Attendance", "value": "0", "icon": "✅"},
            {"label": "Assignments", "value": "0", "icon": "📝"},
        ],
        "modules": [
            {"title": "Dashboard", "items": ["Class Summary"]},
            {"title": "My Classes", "items": ["Active Classes"]},
            {"title": "Attendance", "items": ["Mark Attendance"]},
            {"title": "Assignments", "items": ["Upload Assignments"]},
            {"title": "Student Evaluation", "items": ["Marks & Feedback"]},
            {"title": "Timetable", "items": ["Daily Schedule"]},
            {"title": "Live Classes", "items": ["Online Sessions"]},
        ],
    }
