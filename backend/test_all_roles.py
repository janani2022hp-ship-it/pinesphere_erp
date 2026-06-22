import json
import urllib.request
import urllib.error

roles = ['trainer', 'parent', 'admin']

for role in roles:
    data = json.dumps({
        'full_name': f'Test {role.title()}',
        'username': f'{role}test',
        'email': f'{role}@test.com',
        'password': 'password123',
        'confirm_password': 'password123'
    }).encode()

    req = urllib.request.Request(
        f'http://127.0.0.1:8000/auth/{role}/signup',
        data=data,
        headers={'Content-Type': 'application/json'},
        method='POST'
    )

    try:
        resp = urllib.request.urlopen(req)
        result = json.loads(resp.read().decode())
        print(f'✓ {role}: {result["role"]} ({result["username"]})')
    except Exception as e:
        print(f'✗ {role}: {str(e)}')
