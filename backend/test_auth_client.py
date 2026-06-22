from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

# Signup trainer
r = client.post('/auth/trainer/signup', json={
    'full_name':'Test Trainer','username':'test_trainer','email':'test_trainer@example.com','password':'secret123','confirm_password':'secret123'
})
print('signup', r.status_code, r.json())
# Login trainer
r2 = client.post('/auth/trainer/login', json={'username_or_email':'test_trainer','password':'secret123'})
print('login', r2.status_code, r2.json())
# Signup student
r3 = client.post('/auth/student/signup', json={'full_name':'Test Student','username':'test_student','email':'test_student@example.com','password':'secret123','confirm_password':'secret123'})
print('stu signup', r3.status_code, r3.json())
# Login student
r4 = client.post('/auth/student/login', json={'username_or_email':'test_student','password':'secret123'})
print('stu login', r4.status_code, r4.json())
