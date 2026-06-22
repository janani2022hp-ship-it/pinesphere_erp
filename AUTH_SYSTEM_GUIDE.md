# ScholarHub ERP Authentication System - Setup Guide

## ✅ Implementation Complete

You now have a **complete authentication system** with the following features:

### 📁 File Structure Created

```
lib/features/auth/
├── models/
│   └── user_model.dart
├── services/
│   └── auth_service.dart
└── presentation/pages/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── signup_screen.dart
    └── dashboard_router.dart
```

### 🎯 Key Features

#### 1. **UserModel** (`user_model.dart`)
- Stores user information: username, password, role, fullName, email
- JSON serialization for SharedPreferences storage
- Supports 4 roles: student, trainer, parent, admin

#### 2. **AuthService** (`auth_service.dart`)
- `signup()` - Create new user accounts
- `login()` - Authenticate users
- `logout()` - Clear session
- `isLoggedIn()` - Check if user is logged in
- `getCurrentUser()` - Get logged-in user details
- `getCurrentRole()` - Get user's role
- Uses SharedPreferences for persistent storage

#### 3. **SplashScreen** (`splash_screen.dart`)
- Shows 2-second splash animation
- Checks if user is already logged in
- Auto-redirects to dashboard if session exists

#### 4. **LoginScreen** (`login_screen.dart`)
- Clean UI for username/password entry
- Password visibility toggle
- Error message display
- Link to signup page
- Auto-navigates to role-based dashboard after login

#### 5. **SignupScreen** (`signup_screen.dart`)
- Full name (optional), username, email (optional), password fields
- Password confirmation validation
- Role selection (Student/Trainer/Parent/Admin)
- Auto-login after signup
- Link to login page

#### 6. **DashboardRouter** (`dashboard_router.dart`)
- Smart routing based on user role:
  - Student → StudentScreen
  - Trainer → TrainerScreen
  - Parent → ParentScreen
  - Admin → AdminScreen
- Used as home page in main.dart

### 🔄 App Flow

```
App Starts
    ↓
DashboardRouter (checks login status)
    ├─ If NOT logged in → LoginScreen
    │   └─ After login → Role-based Dashboard
    │
    └─ If logged in → Role-based Dashboard
        ├─ Student → StudentScreen
        ├─ Trainer → TrainerScreen
        ├─ Parent → ParentScreen
        └─ Admin → AdminScreen
```

### 💾 Data Storage

Users are stored in SharedPreferences as JSON:
```json
{
  "pinesphere_users": {
    "oviya": {
      "username": "oviya",
      "password": "1234",
      "role": "student",
      "fullName": "Oviya Kumar",
      "email": "oviya@example.com"
    },
    "john_trainer": {
      "username": "john_trainer",
      "password": "5678",
      "role": "trainer",
      "fullName": "John Smith",
      "email": null
    }
  },
  "pinesphere_current_user": "oviya",
  "pinesphere_current_role": "student"
}
```

### 🚀 How to Test

1. **Start the app** - It will show SplashScreen
2. **Go to LoginScreen** - Click "Sign Up" link
3. **Create account** - Enter username, password, select role
4. **Auto-login** - After signup, automatically logs in
5. **See dashboard** - Shows dashboard based on role selected

### 📱 Test Accounts to Create

You can create test accounts via the signup screen:

**Student:**
- Username: `student1`
- Password: `pass1234`
- Role: Student

**Trainer:**
- Username: `trainer1`
- Password: `pass1234`
- Role: Trainer

**Parent:**
- Username: `parent1`
- Password: `pass1234`
- Role: Parent

**Admin:**
- Username: `admin1`
- Password: `pass1234`
- Role: Admin

### ⚙️ Configuration

**In main.dart:**
- Home is set to `DashboardRouter()`
- DashboardRouter automatically handles routing

**No additional configuration needed!**

### 🔐 Security Notes (⚠️ For Production)

Current implementation stores passwords in **plain text** in SharedPreferences. For production:

1. **Encrypt passwords** - Use bcrypt or argon2
2. **Use backend authentication** - Implement proper server-side auth
3. **Add JWT tokens** - Use token-based auth
4. **Email verification** - Verify user emails
5. **Password reset** - Add forgot password flow
6. **Rate limiting** - Prevent brute force attacks
7. **Session timeout** - Auto-logout after inactivity

### 🛠️ Logout Implementation

To add logout functionality to your dashboard screens:

```dart
import 'package:pinesphere_erp/features/auth/services/auth_service.dart';

final authService = AuthService();

// In your logout button:
ElevatedButton(
  onPressed: () async {
    await authService.logout();
    Navigator.pushReplacementNamed(context, '/');
    // or
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardRouter()),
    );
  },
  child: const Text('Logout'),
)
```

### 📊 Backend Integration Ready

The auth system works **independently** from your backend. You can later:

1. Replace `AuthService` login/signup with API calls
2. Send credentials to your backend (currently at `http://10.0.2.2:8000` for Android)
3. Get JWT tokens and store them
4. Use tokens for subsequent API requests

Example integration point in `auth_service.dart`:
```dart
Future<bool> login(String username, String password) async {
  // Instead of checking local users, call:
  // final response = await http.post('/api/login', ...)
  // final token = response['token']
  // await prefs.setString('auth_token', token)
}
```

### ✨ What's Ready to Use

✅ Full signup/login flow  
✅ Role-based routing  
✅ Session persistence  
✅ Beautiful UI matching your theme  
✅ Error handling  
✅ Password visibility toggle  
✅ Email optional field  
✅ Full name optional field  
✅ Works across all 4 roles  

### 🎨 UI Features

- Green/white theme matching ScholarHub branding
- Rounded corners and smooth shadows
- Input validation with error messages
- Loading indicators during auth
- Visibility toggle for password
- Role selection grid in signup
- Professional icons and spacing

Enjoy your new authentication system! 🎉
