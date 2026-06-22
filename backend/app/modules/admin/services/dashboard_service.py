def get_admin_dashboard_data():
    return {
        "role": "Admin",
        "title": "Admin Command Center",
        "summary": [
            {"label": "Branches", "value": "0", "icon": "🏢"},
            {"label": "Students", "value": "0", "icon": "🎓"},
            {"label": "Revenue", "value": "₹0", "icon": "💳"},
        ],
        "modules": [
            {"title": "Dashboard", "items": ["Global Analytics", "AI Insights"]},
            {"title": "User Management", "items": ["Users", "Roles", "Permissions"]},
            {"title": "Branch Management", "items": ["Branches", "Franchise Branches"]},
            {"title": "CRM", "items": ["Leads", "Admissions", "Counsellors"]},
            {"title": "Student Management", "items": ["Students", "Attendance", "Certificates"]},
            {"title": "LMS", "items": ["Courses", "Lessons", "Assignments"]},
            {"title": "Finance", "items": ["Fees", "GST Billing", "Expenses"]},
            {"title": "HR", "items": ["Employees", "Payroll"]},
            {"title": "AI Platform", "items": ["AI Chatbot", "AI Analytics"]},
            {"title": "Reports", "items": ["Student Reports", "Revenue Reports"]},
            {"title": "Security", "items": ["MFA", "API Security"]},
            {"title": "Settings", "items": ["Platform Settings"]},
        ],
    }
