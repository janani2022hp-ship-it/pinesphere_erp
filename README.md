# Pinesphere ERP

Restored Flutter + FastAPI ERP app for Pinesphere AI Training Institute.

## Backend

Database defaults:

- PostgreSQL DB: `ai_erp`
- User: `postgres`
- Password: `postgres`

Run:

```powershell
cd G:\PinesphereERP\pinesphere_erp\backend
.\.venv\Scripts\Activate.ps1
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Health check:

```text
http://127.0.0.1:8000/api/health
```

For phone browser:

```text
http://192.168.1.3:8000/api/health
```

## Flutter

Run on Chrome:

```powershell
cd G:\PinesphereERP\pinesphere_erp
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

Run on physical phone:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.3:8000/api
```

## Demo Logins

All passwords are:

```text
admin123
```

Accounts:

```text
admin@pinesphere.ai
branch@pinesphere.ai
counsellor@pinesphere.ai
trainer@pinesphere.ai
student@pinesphere.ai
parent@pinesphere.ai
hr@pinesphere.ai
finance@pinesphere.ai
franchise@pinesphere.ai
```
