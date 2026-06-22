import json
import urllib.request
import urllib.error

data = json.dumps({
    'username_or_email': 'fluttertest',
    'password': 'password123'
}).encode()

req = urllib.request.Request(
    'http://127.0.0.1:8000/auth/student/login',
    data=data,
    headers={'Content-Type': 'application/json'},
    method='POST'
)

try:
    resp = urllib.request.urlopen(req)
    print('Status:', resp.status)
    result = json.loads(resp.read().decode())
    print('access_token:', result['access_token'][:20] + '...')
    print('user_id:', result['user_id'])
    print('username:', result['username'])
    print('role:', result['role'])
except urllib.error.HTTPError as e:
    print('Error:', e.code)
    print('Body:', e.read().decode())
except Exception as e:
    print('Exception:', type(e).__name__, str(e))
