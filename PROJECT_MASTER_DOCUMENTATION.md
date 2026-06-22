# Pinesphere ERP LMS: Master Project Understanding

Last analyzed: 2026-05-26

## 1. Executive Summary

Pinesphere ERP is a Flutter + FastAPI + PostgreSQL educational ERP/LMS scaffold for an AI training institute. The product direction is a modern SaaS-style, role-based platform for institute operations, learning management, finance, CRM, HR, branch administration, and AI-powered student support.

The repository currently contains:

- A Flutter app with a polished login screen, a generic role dashboard for most roles, and a custom student mobile experience.
- A FastAPI backend with PostgreSQL SQLAlchemy models for roles, users, modules, and generic ERP records.
- Seed data that defines the role/module roadmap for ten roles.
- A simple record persistence flow from Flutter to FastAPI to PostgreSQL.

The project is not yet a complete ERP implementation. Most role modules are represented as catalog entries and generic feature forms. Dedicated backend models and endpoints for attendance, assignments, courses, certificates, fees, CRM, HR, notifications, and AI chatbot workflows are still missing.

## 2. Repository Map

```text
pinesphere_erp/
  lib/
    main.dart
    core/app_theme.dart
    data/role_catalog.dart
    models/erp_models.dart
    services/api_service.dart
    services/auth_service.dart
    screens/login_screen.dart
    screens/roles/*.dart
    widgets/role_dashboard.dart
  backend/
    requirements.txt
    README.md
    app/
      main.py
      seed.py
      api/routes.py
      core/config.py
      core/database.py
      core/security.py
      models/models.py
      schemas/schemas.py
  test/widget_test.dart
  pubspec.yaml
  README.md
```

Generated platform folders exist for Android, iOS, web, Windows, macOS, and Linux. The application logic is concentrated in `lib/` and `backend/app/`.

## 3. Complete Project Architecture

### Frontend Architecture

The Flutter frontend starts at `lib/main.dart`. `PinesphereErpApp` configures a `MaterialApp`, applies `AppTheme.light(...)`, disables the debug banner, and uses `LoginScreen` as the home route.

Important frontend files:

- `lib/main.dart`: Application bootstrap.
- `lib/core/app_theme.dart`: Central Material 3 color, typography, app bar, input, button, card, snackbar, and transition theme.
- `lib/data/role_catalog.dart`: Static role/module/feature catalog used by frontend login and dashboards.
- `lib/models/erp_models.dart`: Frontend domain DTOs for roles, modules, metrics, and generic ERP records.
- `lib/services/auth_service.dart`: Mock authentication service. It validates only non-empty email/password and returns the selected role from the static catalog.
- `lib/services/api_service.dart`: HTTP service for generic record create/list operations.
- `lib/widgets/role_dashboard.dart`: Shared dashboard, module list, feature detail form, and saved records view for most roles.
- `lib/screens/roles/student_screen.dart`: Custom student app UI with dashboard, courses, tasks, AI tutor, and profile tabs.
- `lib/screens/roles/*.dart`: Thin role screen wrappers around `RoleDashboard`, except student.

The frontend has two main UI systems:

1. Generic role dashboard:
   - Used by Super Admin, Branch Admin, Counsellor, Trainer, Parent, HR, Finance Team, Franchise Owner, and Placement Partner.
   - Reads modules from `roleCatalog`.
   - Shows Home, Modules, Saved, and Logout destinations.
   - Opens module features through `FeatureDetailScreen`.
   - Saves generic records through `ApiService.saveRecord(...)`.

2. Student app:
   - Custom mobile-first dashboard in `student_screen.dart`.
   - Uses bottom navigation for Home, Courses, Tasks, AI Tutor, and Profile.
   - Uses static hardcoded demo data.
   - Does not currently call backend APIs.

### Backend Architecture

The backend is a FastAPI app under `backend/app`.

Important backend files:

- `backend/app/main.py`: Creates `FastAPI`, configures permissive CORS, creates tables at startup, seeds database, exposes `/health`, and mounts API router at `/api`.
- `backend/app/api/routes.py`: Defines all current API routes.
- `backend/app/models/models.py`: SQLAlchemy ORM models.
- `backend/app/schemas/schemas.py`: Pydantic request/response schemas.
- `backend/app/core/database.py`: Engine, session factory, declarative base, and DB dependency.
- `backend/app/core/config.py`: Settings loaded from `.env`, including database URL and JWT secret.
- `backend/app/core/security.py`: PBKDF2 password hashing/verification and JWT creation.
- `backend/app/seed.py`: Seeds role catalog, modules, and one admin user.

Current API endpoints:

```text
GET  /health
POST /api/auth/login
GET  /api/roles
POST /api/records
GET  /api/records
```

Only `/api/auth/login` uses real database users. The Flutter app currently does not call it.

### Database Architecture

The current database schema is intentionally small:

- `pinesphere_roles`
- `pinesphere_users`
- `pinesphere_modules`
- `pinesphere_erp_records`

The schema supports role/module discovery and generic record capture. It does not yet model actual ERP domain entities such as branches, batches, courses, lessons, attendance sessions, assignment submissions, fee invoices, certificates, notifications, chats, or AI usage logs.

### Routing and Navigation Flow

Frontend navigation uses direct `Navigator` and `MaterialPageRoute`, not named routes or a router package.

Flow:

1. `main.dart` launches `LoginScreen`.
2. Login form lets the user choose a role from `roleCatalog`.
3. `AuthService.login(...)` returns the selected role if email/password are non-empty.
4. `LoginScreen._screenFor(...)` switches by role id.
5. Most role screens instantiate `RoleDashboard(role: roleCatalog[index])`.
6. Student role opens the custom `StudentScreen`.
7. Generic dashboard feature chips open `FeatureDetailScreen`.
8. Logout pushes `LoginScreen` and clears the navigation stack.

There is no persisted session, refresh token handling, guarded route, or splash/auth restore flow.

### Authentication Flow

Backend authentication:

- `POST /api/auth/login` accepts `LoginRequest(email, password)`.
- It queries `User` by email.
- It verifies PBKDF2 password hash using `verify_password(...)`.
- It returns a JWT from `create_access_token(...)`, the user's role id, and full name.
- JWT payload contains `sub`, `role`, and `exp`.

Frontend authentication:

- `AuthService` is currently mocked.
- It does not call the backend login endpoint.
- It does not store JWTs.
- It trusts the role selected in the dropdown.
- It lets any non-empty email/password enter any selected role.

This is the largest authentication gap in the project.

### API Architecture

The current API architecture is simple and centralized:

- One router file: `backend/app/api/routes.py`.
- One generic persistence model: `ErpRecord`.
- Pydantic schemas mirror the small set of models.
- No service layer exists yet.
- No repository layer exists yet.
- No route modules by domain exist yet.
- No authorization dependency validates JWTs on protected endpoints.

Flutter `ApiService` assumes the backend base URL is provided as `API_BASE_URL` or falls back to localhost/emulator candidates. It always appends `/api` itself, so `API_BASE_URL` should normally be `http://127.0.0.1:8000`, not `http://127.0.0.1:8000/api`. The root `README.md` currently shows a Flutter command with `API_BASE_URL=http://127.0.0.1:8000/api`, which would produce `/api/api/records` for `ApiService` calls. This documentation/config mismatch should be fixed.

### State Management

Current state management is local widget state:

- `LoginScreen`: email/password controllers, selected role id, loading state.
- `RoleDashboard`: selected bottom nav index.
- `_RecordsPanel`: future for saved records.
- `FeatureDetailScreen`: form controllers, selected status, saving state, record future.
- `StudentScreen`: selected bottom nav index.

There is no Provider, Riverpod, Bloc, Redux, GetX, or app-level state container. This is acceptable for the current scaffold, but it will not scale once real authentication, user profile, notifications, assignment uploads, and offline loading are introduced.

### Reusable Components

Reusable frontend structure is partly centralized and partly file-local:

- Central reusable generic role UI: `RoleDashboard`, `_ModulePanel`, `_ModuleCard`, `_RecordsPanel`, `FeatureDetailScreen`.
- Central theme: `AppTheme`.
- Shared frontend models: `ErpRole`, `ErpModule`, `ErpRecord`.
- Student UI components are private classes inside `student_screen.dart`, such as `_SoftCard`, `_ColoredIcon`, `_SectionTitle`, `_StatCard`, `_AssignmentCard`, `_LiveClassCard`, `_NotificationTile`, `_CourseCard`, `_ChatBubble`, and `_ProfileRow`.

The student UI has good visual polish but is currently monolithic and should be split before it grows further.

## 4. Current Project Status

### Completed or Working

- Flutter app boots successfully.
- `flutter analyze` passes with no issues.
- Login screen renders and navigates to role screens.
- Theme system exists and is applied globally.
- Static role catalog exists for ten roles.
- Generic role dashboard supports Home, Modules, Saved, and Logout.
- Module feature chips navigate to a feature detail form.
- Generic records can be saved to backend through `POST /api/records`.
- Saved records can be listed through `GET /api/records`.
- Backend creates tables on startup.
- Backend seeds role/module data and one admin user.
- Backend has real PBKDF2 password hashing and JWT token generation.
- Basic widget test verifies login screen text.

### Half-Completed

- Authentication: backend is real, frontend is mock.
- Role permissions: roles are cataloged, but endpoints are not protected by role.
- PostgreSQL integration: works for generic records, not domain entities.
- API integration: Flutter uses backend for records only.
- Module system: modules and features are listed, but most are generic forms.
- Student app: polished UI exists, but data/actions are static.

### Placeholder Modules

Most modules in `role_catalog.dart` and `seed.py` are placeholders or roadmap markers:

- CRM leads/admissions/follow-ups
- Attendance marking/history
- Course lessons/videos/live classes
- Assignment upload/submission/feedback
- Certificates and badges
- Finance fees/invoices/GST/expenses
- HR employees/payroll/leaves
- Parent progress/fees/communication
- AI chatbot/analytics/quiz
- Franchise revenue sharing
- Placement hiring/resume/interview flows

### Broken or Risk Areas

- Frontend login bypasses backend authentication entirely.
- Root README demo credentials do not match `backend/app/seed.py`.
  - README lists `admin@pinesphere.ai` and password `admin123`.
  - Seed creates `admin@pinesphere.in` and password `postgres`.
- API base URL guidance is inconsistent.
  - `ApiService` appends `/api`.
  - Root README suggests passing a base URL already ending in `/api`.
- Student screen contains mojibake characters such as `â€¢`, likely intended to be bullet separators.
- Backend CORS allows every origin and credentials.
- JWT secret defaults to `change-this-before-production`.
- There is no migration system such as Alembic.
- There are no backend tests.
- No protected endpoint currently validates incoming JWTs.

## 5. Role-Based Module Analysis

### Super Admin

Implementation:

- `lib/screens/roles/super_admin_screen.dart`
- Uses `RoleDashboard(role: roleCatalog[0])`
- Seed role id: `super_admin`

Responsibilities:

- Platform-wide analytics
- Users, roles, permissions
- Branch and franchise management
- CRM oversight
- Student management
- LMS management
- Finance, HR, reports, security, settings
- AI platform governance

Current state:

- UI catalog and generic record forms exist.
- No dedicated user, branch, finance, LMS, HR, report, security, or settings APIs exist.
- No actual permission enforcement exists.

Backend dependencies needed:

- Users and role permission endpoints
- Branches/franchises schema
- CRM schema
- Student/course schema
- Finance and invoice schema
- Audit logs
- Settings table
- Auth/authorization dependencies

### Branch Admin

Implementation:

- `lib/screens/roles/branch_admin_screen.dart`
- Uses `RoleDashboard(role: roleCatalog[1])`
- Seed role id: `branch_admin`

Responsibilities:

- Manage one branch
- Student enrollment and transfer
- Attendance overview
- Trainer allocation and attendance
- Timetable and holidays
- Branch fees and expenses
- Branch reports/export

Current state:

- Role dashboard and generic record forms exist.
- No branch-scoped data model exists beyond nullable `User.branch_id`.
- No branch permissions or branch filtering are enforced.

Backend dependencies needed:

- `branches`
- `batches`
- `student_enrollments`
- `trainer_assignments`
- `attendance_sessions`
- `fee_payments`
- Branch-level report queries

### Trainer

Implementation:

- `lib/screens/roles/trainer_screen.dart`
- Uses `RoleDashboard(role: roleCatalog[3])`
- Seed role id: `trainer`

Responsibilities:

- View class summary
- Manage active classes and lesson plan
- Mark attendance
- Upload assignments
- Review submissions
- Provide marks and feedback
- Recommend certificates
- View timetable and live classes

Current state:

- Generic dashboard only.
- No trainer-specific UI beyond module catalog.
- No class, lesson, assignment, attendance, evaluation, or timetable APIs.

Backend dependencies needed:

- Trainer profile linked to user
- Course/batch assignment
- Lesson plan models
- Attendance mark endpoint
- Assignment create endpoint
- Submission review endpoint
- Evaluation/marks endpoint

### Student

Implementation:

- `lib/screens/roles/student_screen.dart`
- Custom UI instead of generic `RoleDashboard`
- Seed/frontend role id: `student`

Responsibilities:

- View learning summary
- Continue courses
- Submit assignments
- Track attendance
- Use AI tutor and quizzes
- View certificates/badges
- Read notifications
- Manage profile and ID card
- Use coding playground in a later phase

Current state:

- Rich static mobile UI exists.
- No backend calls exist in the student screen.
- No upload integration exists.
- No AI service integration exists.
- No profile is loaded from authenticated user.

Backend dependencies needed:

- Student profile endpoint
- Course enrollment/progress endpoints
- Assignment list/submission endpoints
- Attendance history and leave request endpoints
- Notification endpoints
- Certificate endpoints
- AI chat endpoint and conversation storage
- Coding playground/project endpoints

## 6. Student App Analysis

### Dashboard Architecture

`StudentScreen` is a `StatefulWidget` with `_selectedIndex`. It uses:

- `Scaffold`
- `SafeArea`
- `AnimatedSwitcher`
- Floating styled `NavigationBar`
- Private page widgets selected by `_pageForIndex()`

Home dashboard uses `CustomScrollView` and slivers:

- `_StudentHeader`
- `_StreakCard`
- Learning overview grid of `_StatCard`
- Pending assignments list
- Live classes list
- Quick actions grid
- Notifications list

All values are hardcoded demo values such as `Arjun Kumar`, `4` enrolled courses, `92%` attendance, and fixed class/assignment names.

### Navigation Flow

Bottom navigation destinations:

- Home: `_DashboardPage`
- Courses: `_CoursesPage`
- Tasks: `_TasksPage`
- AI Tutor: `_AiTutorPage`
- Profile: `_ProfilePage`

There are no nested detail routes for student course detail, assignment detail, notification detail, certificate download, or chatbot conversation.

### Attendance System

Implemented:

- Attendance appears as a dashboard stat card with `92%`.
- Student catalog includes Attendance with `Attendance History` and `Leave Request`.

Missing:

- Attendance page in custom student bottom nav.
- Attendance API.
- Attendance session model.
- Student attendance history.
- Leave request form/workflow.
- QR or digital ID attendance integration.

### Assignments Flow

Implemented:

- Dashboard pending assignment cards.
- Tasks page with `_UploadPanel` and assignment cards.
- Upload button placeholder.

Missing:

- File picker/upload.
- Assignment list API.
- Submission model.
- Due dates, statuses, marks, feedback from backend.
- Trainer review integration.
- Notifications for deadlines.

### Course Flow

Implemented:

- Courses page with `_CourseCard` widgets.
- Progress bars and static metadata.
- Dashboard live class cards.

Missing:

- Course detail screen.
- Lesson/video model.
- Course progress persistence.
- Live class joining integration.
- Enrollment data from backend.
- Trainer/course/batch relationships.

### AI Chatbot Integration

Implemented:

- AI Tutor tab with static `_ChatBubble` widgets and quiz suggestions.
- Role catalog includes AI Tutor and Practice Quiz.

Missing:

- Text input composer.
- Chat API.
- OpenAI or other LLM provider integration.
- Conversation persistence.
- Quiz generation endpoint.
- Safety/guardrail policy.
- Token usage and cost tracking.

### Notifications System

Implemented:

- Header notification icon with unread dot.
- Static dashboard notification tiles.
- Generic dashboard app bar notification button placeholder.

Missing:

- Notification table.
- Read/unread state.
- Push notification integration.
- Notification preferences.
- Role-targeted notification delivery.

### Certificates System

Implemented:

- Student catalog includes Certificates and Skill Badges.
- Quick action tile says `My Certificates`.

Missing:

- Certificate page.
- Certificate generation/download.
- Badge models.
- Trainer recommendation approval flow.
- Public verification URL/QR.

### Coding Playground Architecture

Implemented:

- Catalog placeholder: `Coding Playground`, phase 3, features `Python IDE` and `My Projects`.

Missing:

- UI screen.
- Code editor.
- Execution sandbox.
- Project persistence.
- Security isolation.
- Assignment integration.

Recommended future architecture:

- Flutter code editor package for frontend.
- Backend execution service isolated from the main API.
- Queue/time limit/resource limit for code runs.
- Persist projects separately from submissions.
- Never execute arbitrary code inside the FastAPI process.

## 7. Frontend Analysis

### Folder Structure

Current structure is simple:

- `core/`: theme only.
- `data/`: static catalog.
- `models/`: simple immutable data models.
- `services/`: HTTP/mock services.
- `screens/`: login and role entry screens.
- `widgets/`: shared generic role dashboard.

This is reasonable for the current scaffold but should evolve toward feature-based folders once real modules are implemented.

Recommended future frontend structure:

```text
lib/
  app/
    app.dart
    router.dart
  core/
    theme/
    config/
    network/
    auth/
    widgets/
  features/
    auth/
    student/
    trainer/
    branch_admin/
    super_admin/
    attendance/
    assignments/
    courses/
    notifications/
    ai_tutor/
```

### Responsive Layout Strategy

Current strategy:

- Login uses `ConstrainedBox(maxWidth: 520)` and scrollable content.
- Generic dashboards use `ListView`, `Row`, `Expanded`, `Wrap`, cards, and `NavigationBar`.
- Student dashboard is mobile-first with `CustomScrollView`, `SliverGrid.count(crossAxisCount: 2)`, and fixed bottom nav.

Limitations:

- No tablet/desktop adaptive navigation rail.
- Student dashboard uses a fixed 2-column grid, which may not be ideal on wide screens.
- Generic dashboard is usable on mobile but not optimized for desktop ERP workflows.

### Theme Management

`AppTheme` centralizes:

- Brand colors: green, blue, purple, teal, orange, yellow.
- Material 3 `ColorScheme`.
- Poppins text theme.
- Platform page transitions.
- AppBar, input, button, card, and snackbar styling.

Design direction:

- Friendly SaaS learning product.
- Green/blue primary identity.
- Rounded, soft, mobile-first surfaces.

### Navigation Pattern

The project uses imperative Navigator calls:

- `pushReplacement` after login.
- `pushAndRemoveUntil` on logout.
- `push` for generic feature details.

No route guards or deep links exist.

### State Management

Only local `setState` is used. There is no global auth/session/data cache.

For the next phase, use a predictable app state solution before adding many modules. Riverpod or Provider would both fit; Riverpod is stronger for async API state and dependency injection.

### Design System

Existing components establish a visual design but are not yet packaged as a formal design system:

- Soft cards
- Colored icon containers
- Status pills/badges
- Section titles
- Metric/stat cards
- Module cards
- Empty states
- Hero panels

Refactor opportunity:

- Move student private components that are generally useful into `lib/core/widgets/` or `lib/shared/widgets/`.
- Keep feature-specific widgets inside feature folders.

## 8. Backend Analysis

### FastAPI Structure

The backend is a small scaffold:

```text
app/main.py
app/api/routes.py
app/core/
app/models/
app/schemas/
app/seed.py
```

The startup hook calls:

- `Base.metadata.create_all(bind=engine)`
- `seed_database(db)`

This is convenient during prototyping, but production should use Alembic migrations and controlled seed scripts.

### Routers

All routes are in one file:

- `POST /auth/login`
- `GET /roles`
- `POST /records`
- `GET /records`

Future backend should split routers by domain:

```text
api/routes/auth.py
api/routes/roles.py
api/routes/students.py
api/routes/courses.py
api/routes/attendance.py
api/routes/assignments.py
api/routes/finance.py
api/routes/notifications.py
api/routes/ai.py
```

### Services

No service layer exists yet. Current route functions directly query SQLAlchemy and transform models.

Add services when implementing domain logic:

- `AuthService`
- `StudentService`
- `AttendanceService`
- `AssignmentService`
- `FinanceService`
- `NotificationService`
- `AiTutorService`

### Middleware

Only CORS middleware is configured:

```python
allow_origins=["*"]
allow_credentials=True
allow_methods=["*"]
allow_headers=["*"]
```

This is acceptable for local development only. Production should configure explicit origins.

### Models

Current SQLAlchemy models:

- `Role`
  - id, name, description
  - relationships: users, modules
- `User`
  - id, email, full_name, hashed_password, role_id, branch_id, created_at
  - relationship: role
- `Module`
  - id, role_id, title, phase, features
  - features are stored as a pipe-separated text string
- `ErpRecord`
  - id, module, feature, title, status, notes, owner_role, created_at

Model limitations:

- `Module.features` should eventually become normalized rows or JSONB.
- `branch_id` has no foreign key because branches table does not exist.
- `owner_role` in `ErpRecord` is a string, not a foreign key.
- `ErpRecord` is too generic for real workflows.

### JWT Authentication Flow

`backend/app/core/security.py`:

- Hashes passwords with PBKDF2 SHA-256 and random 16-byte salt.
- Verifies using `hmac.compare_digest`.
- Creates HS256 JWTs with expiration.

Missing:

- Decode/verify JWT dependency.
- Current user dependency.
- Role requirement dependency.
- Token refresh/revocation.
- Password reset.
- Frontend storage and authorization header.

### Existing Endpoints

`POST /api/auth/login`

- Input: email, password
- Output: access token, token type, role, full name
- Real database backed

`GET /api/roles`

- Returns roles and modules.
- Converts pipe-separated module features to arrays.

`POST /api/records`

- Creates generic ERP record.
- No auth required.
- No validation that module/feature belongs to owner role.

`GET /api/records`

- Lists latest 200 records.
- Optional filters: owner_role, module, feature.
- No auth required.

### Missing Endpoints

High-priority missing APIs:

- `GET /api/me`
- `POST /api/auth/logout`
- `POST /api/auth/refresh`
- `GET/POST/PATCH /api/users`
- `GET/POST/PATCH /api/branches`
- `GET/POST/PATCH /api/students`
- `GET/POST/PATCH /api/courses`
- `GET/POST/PATCH /api/batches`
- `GET/POST /api/attendance`
- `GET/POST /api/assignments`
- `POST /api/submissions`
- `GET/POST /api/notifications`
- `GET/POST /api/certificates`
- `GET/POST /api/fees`
- `GET/POST /api/invoices`
- `POST /api/ai/chat`
- `POST /api/ai/quiz`

### API Conventions

Current conventions:

- REST-like paths.
- Pydantic schemas for request/response.
- Snake_case JSON keys from backend.
- Frontend maps `owner_role` to `ownerRole`.

Recommended conventions:

- Keep snake_case in API.
- Use domain-specific resource routes.
- Require JWT for all non-public routes.
- Use pagination for list endpoints.
- Use branch/role scoping in dependencies, not ad hoc route logic.
- Return consistent error objects.

## 9. Database Analysis

### Current ER Understanding

```text
Role 1--* User
Role 1--* Module
ErpRecord currently references owner role by string only
```

Table purposes:

- `pinesphere_roles`: Master role definitions.
- `pinesphere_users`: Login identities linked to roles.
- `pinesphere_modules`: Role-specific module catalog and phase roadmap.
- `pinesphere_erp_records`: Generic saved items created from feature forms.

### Important Relationships

- `User.role_id` -> `Role.id`
- `Module.role_id` -> `Role.id`
- `Role.modules` uses cascade delete orphan.
- `Role.users` connects users to permissions conceptually.

### Missing Schema Areas

Core organization:

- branches
- departments
- settings
- audit_logs

People:

- students
- trainers/employees
- parents/guardians
- counsellors
- franchise owners

Learning:

- courses
- lessons
- batches
- enrollments
- live_classes
- recordings
- course_progress

Attendance:

- attendance_sessions
- attendance_marks
- leave_requests

Assignments:

- assignments
- assignment_files
- submissions
- grades
- feedback

Finance:

- fee_plans
- invoices
- payments
- expenses
- payroll
- salary_slips

Communication:

- notifications
- notification_preferences
- messages/chats
- CRM follow-ups

AI:

- ai_conversations
- ai_messages
- generated_quizzes
- quiz_attempts
- ai_usage_logs

Certification:

- certificates
- certificate_templates
- badges
- certificate_verifications

### Scalability Suggestions

- Add Alembic migrations before expanding schema.
- Use UUID primary keys consistently.
- Add `created_at`, `updated_at`, and soft-delete or status fields to core domain tables.
- Add branch scoping to operational entities.
- Normalize role permissions instead of relying on static module strings.
- Use JSONB selectively for flexible metadata, not as a replacement for domain tables.
- Add indexes on foreign keys, branch ids, role ids, and frequently filtered date/status fields.

## 10. Development Roadmap

### Immediate Next Steps

1. Fix README/API URL and demo credential mismatch.
2. Connect Flutter login to `POST /api/auth/login`.
3. Store token securely and attach `Authorization: Bearer ...` to API calls.
4. Add backend `get_current_user` and role protection dependencies.
5. Decide state management approach before adding more real screens.
6. Add Alembic migrations.
7. Split backend routes into domain modules.
8. Split `student_screen.dart` into smaller files.

### High-Priority Tasks

- Real authentication and session handling.
- Role-protected APIs.
- Branch model and branch scoping.
- Student profile and course enrollment models.
- Attendance backend and UI integration.
- Assignment backend and upload workflow.
- Notification model and read/unread APIs.
- Backend and frontend tests for auth and generic record flow.

### UI Refinement Roadmap

- Convert generic role dashboard from catalog explorer into real module entry points.
- Add desktop/tablet layouts for admin roles.
- Build dedicated screens for Super Admin, Branch Admin, Trainer, and Student priority modules.
- Extract shared UI components.
- Replace hardcoded student data with API-backed view models.
- Fix encoding issues in student text separators.
- Implement loading, error, empty, and permission states consistently.

### Backend Completion Roadmap

Phase 1:

- Auth, users, roles, branches.
- Students, trainers, batches, courses.
- Attendance and assignments.
- Notifications.

Phase 2:

- CRM leads/admissions.
- Fees, invoices, payments.
- Certificates and reports.
- Parent portal data APIs.
- AI tutor basic chat and quiz generation.

Phase 3:

- Franchise revenue sharing.
- Placement partner portal.
- Coding playground.
- Advanced analytics and AI insights.
- Audit logs and compliance hardening.

### AI Feature Roadmap

- AI tutor chat endpoint.
- Student-specific learning context retrieval.
- Practice quiz generation.
- Assignment feedback assistant for trainers.
- Attendance/performance risk prediction.
- Revenue and admission forecasting.
- Admin analytics summaries.
- AI usage logging and cost controls.

### Deployment Roadmap

- Environment-specific `.env` files.
- Alembic migrations.
- Production PostgreSQL.
- Dockerfile and docker-compose.
- CORS origin restrictions.
- Strong JWT secret via environment.
- HTTPS termination.
- CI for Flutter analyze/test and backend tests.
- Structured logging.
- Monitoring and database backup plan.

## 11. Technical Debt Analysis

### Duplicate or Divergent Data

- Role/module catalog is duplicated in `lib/data/role_catalog.dart` and `backend/app/seed.py`.
- Demo credentials differ between README and seed.
- Frontend uses static catalog instead of `/api/roles`.

Recommendation:

- Treat backend as source of truth for roles/modules.
- Load roles at app startup or after login.
- Keep frontend fallback catalog only for offline/dev preview if needed.

### Poor Structure Areas

- `student_screen.dart` is over 1400 lines and contains many private widgets.
- Backend route file will become too large if more endpoints are added there.
- Generic `ErpRecord` risks becoming a dumping ground.

### Refactor Opportunities

- Split student app into:
  - `student_screen.dart`
  - `student_dashboard_page.dart`
  - `student_courses_page.dart`
  - `student_tasks_page.dart`
  - `student_ai_tutor_page.dart`
  - `student_profile_page.dart`
  - `student_widgets.dart`
- Move common cards/badges/icons to shared widgets.
- Add frontend repositories around `ApiService`.
- Add backend service modules.
- Normalize `Module.features`.

### Performance Risks

- `GET /api/records` returns latest 200 without pagination metadata.
- No indexes beyond some simple role/module/status fields.
- Generic dashboards may refetch records every panel open without caching.
- Student page has many static widgets in one file but acceptable runtime cost for now.

### Security Improvements

- Replace mock frontend auth.
- Require JWT on `/records`.
- Enforce role and branch authorization.
- Replace default secret key.
- Restrict CORS.
- Add password reset flow.
- Add audit logging for admin actions.
- Validate that a user can only create records for their authorized role/branch.
- Avoid exposing all roles/modules to unauthorized users if permission model becomes sensitive.

### Scalability Issues

- Generic record design cannot support reporting, workflows, permissions, or relational integrity.
- Static frontend catalog creates drift from backend seed.
- No migration layer makes schema evolution risky.
- No file storage abstraction for assignments/certificates.
- No background jobs for notifications, reports, AI processing, or emails.

## 12. Testing and Quality

Current tests:

- `test/widget_test.dart` verifies the login screen loads and displays key text.

Verified during this analysis:

- `flutter analyze` completed with no issues.

Missing tests:

- Backend unit tests.
- Backend API tests.
- Auth login tests.
- Role permission tests.
- Flutter service tests.
- Widget tests for role dashboard, student navigation, and feature record form.
- Integration test for saving records to backend.

Recommended tooling:

- `pytest` + FastAPI `TestClient` for backend.
- Test database or SQLite-compatible test setup if schema allows.
- Flutter widget tests for major flows.
- CI step for `flutter analyze`, `flutter test`, and backend tests.

## 13. PROJECT_CONTEXT_FOR_FUTURE_AI_AGENTS

### Architecture Overview

This is a Flutter frontend plus FastAPI backend educational ERP/LMS. The system is role-based and intended to support Super Admin, Branch Admin, Trainers, Students, and additional roles such as Parent, Counsellor, HR, Finance Team, Franchise Owner, and Placement Partner.

The current codebase is a scaffold with a polished frontend shell and a small backend. Do not assume all catalog modules are implemented. Most modules are roadmap entries. The only real frontend-to-backend business flow today is generic ERP record create/list.

### Important Files

- `lib/main.dart`: Flutter app entry.
- `lib/core/app_theme.dart`: Global theme and brand colors.
- `lib/screens/login_screen.dart`: Role-select login UI using mock auth.
- `lib/services/auth_service.dart`: Mock login service. Replace with backend login.
- `lib/services/api_service.dart`: HTTP calls for generic records.
- `lib/data/role_catalog.dart`: Static frontend role/module catalog.
- `lib/widgets/role_dashboard.dart`: Shared role dashboard and record form flow.
- `lib/screens/roles/student_screen.dart`: Rich static student app UI.
- `backend/app/main.py`: FastAPI entry, CORS, startup table creation and seed.
- `backend/app/api/routes.py`: Current API endpoints.
- `backend/app/models/models.py`: Current database models.
- `backend/app/schemas/schemas.py`: Pydantic schemas.
- `backend/app/core/security.py`: Password hashing and JWT creation.
- `backend/app/seed.py`: Backend role/module seed data.

### Module Map

Generic dashboard roles:

- Super Admin: `super_admin_screen.dart` -> `RoleDashboard(roleCatalog[0])`
- Branch Admin: `branch_admin_screen.dart` -> `RoleDashboard(roleCatalog[1])`
- Counsellor: `counsellor_screen.dart` -> `RoleDashboard(roleCatalog[2])`
- Trainer: `trainer_screen.dart` -> `RoleDashboard(roleCatalog[3])`
- Parent: `parent_screen.dart` -> `RoleDashboard(roleCatalog[5])`
- HR: `hr_screen.dart` -> `RoleDashboard(roleCatalog[6])`
- Finance Team: `finance_team_screen.dart` -> `RoleDashboard(roleCatalog[7])`
- Franchise Owner: `franchise_owner_screen.dart` -> `RoleDashboard(roleCatalog[8])`
- Placement Partner: `placement_partner_screen.dart` -> `RoleDashboard(roleCatalog[9])`

Custom student role:

- Student: `student_screen.dart`
- Bottom tabs: Home, Courses, Tasks, AI Tutor, Profile
- Static UI only; no backend integration yet.

Backend modules:

- Auth login: implemented backend, not connected to frontend.
- Roles/modules: implemented backend seed and list endpoint, not used by frontend.
- Records: implemented and used by generic dashboard.
- All domain modules: planned, not implemented as domain models.

### Coding Conventions

Flutter:

- Material 3.
- Poppins font via `google_fonts`.
- Local `setState`.
- Immutable simple model classes.
- Private widgets inside screen files for local UI composition.
- Imperative `Navigator` routing.
- Backend JSON uses snake_case; Dart models expose camelCase.

Backend:

- FastAPI route functions.
- SQLAlchemy 2.0 typed ORM.
- Pydantic v2 schemas.
- Dependency-injected database session via `get_db`.
- PBKDF2 password hashes.
- HS256 JWT creation.

### Current Progress

Implemented:

- Flutter app shell.
- Polished login screen.
- Static role catalog.
- Generic role dashboard.
- Generic feature record form.
- Generic record persistence to PostgreSQL.
- Custom student UI shell.
- Backend auth endpoint.
- Backend role/module/record endpoints.
- Database seed.

Partially implemented:

- Auth, because backend exists but frontend bypasses it.
- Role/module catalog, because frontend duplicates backend data.
- Student app, because UI exists but data/actions are static.
- ERP modules, because they exist as feature labels and generic forms only.

Not implemented:

- Real domain workflows.
- Role permissions.
- Branch scoping.
- Production security.
- Migrations.
- AI provider integration.
- File uploads.
- Push notifications.
- Reports/analytics.

### Critical Dependencies

Frontend:

- Flutter SDK `^3.9.0`
- `google_fonts`
- `http`

Backend:

- FastAPI
- Uvicorn
- SQLAlchemy
- PostgreSQL via `psycopg`
- `python-jose`
- `pydantic-settings`
- `python-multipart`

Database:

- PostgreSQL database defaults to `ai_erp`, user `postgres`, password `postgres`.

### Recommended Development Order

1. Fix documentation/config mismatches for credentials and API base URL.
2. Connect frontend login to backend `/api/auth/login`.
3. Add token storage and authorization headers.
4. Add backend current-user and role-required dependencies.
5. Add Alembic migrations.
6. Make backend roles/modules source of truth.
7. Implement branches, users, students, trainers, batches, and courses.
8. Implement attendance end to end.
9. Implement assignments end to end.
10. Replace static student dashboard data with API-backed data.
11. Implement notifications and certificates.
12. Add AI tutor/chat and quiz generation.
13. Expand finance, CRM, HR, franchise, and placement modules.
14. Add tests and CI around each completed workflow.

### Development Warning

Future agents should not build more real ERP logic into `ErpRecord`. Use it only as a prototype/demo generic persistence mechanism. Real features need proper relational models, domain endpoints, role/branch authorization, and frontend feature screens.

