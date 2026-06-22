import json
import urllib.request
import urllib.error

data = json.dumps({
    'full_name': 'Test Flutter User',
    'username': 'fluttertest',
    'email': 'flutter@test.com',
    'password': 'password123',
    'confirm_password': 'password123'
}).encode()

req = urllib.request.Request(
    'http://127.0.0.1:8000/auth/student/signup',
    data=data,
    headers={'Content-Type': 'application/json'},
    method='POST'
)

try:
    resp = urllib.request.urlopen(req)
    print('Status:', resp.status)
    print('Response:', resp.read().decode())
except urllib.error.HTTPError as e:
    print('Error:', e.code)
    print('Body:', e.read().decode())
except Exception as e:
    print('Exception:', type(e).__name__, str(e))
