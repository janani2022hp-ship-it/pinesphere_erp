def get_parent_dashboard_data():
    return {
        "role": "Parent",
        "title": "Parent Portal",
        "summary": [
            {"label": "Attendance", "value": "0", "icon": "📅"},
            {"label": "Fees Due", "value": "₹0", "icon": "💳"},
            {"label": "Homework", "value": "0", "icon": "📘"},
        ],
        "modules": [
            {"title": "Dashboard", "items": ["Child Summary"]},
            {"title": "Attendance", "items": ["Attendance Reports"]},
            {"title": "Fees", "items": ["Payments", "Invoices"]},
            {"title": "Progress Reports", "items": ["Academic Reports"]},
            {"title": "Homework", "items": ["Assignment Tracking"]},
            {"title": "Notifications", "items": ["Alerts"]},
            {"title": "Communication", "items": ["Trainer Chat"]},
        ],
    }
