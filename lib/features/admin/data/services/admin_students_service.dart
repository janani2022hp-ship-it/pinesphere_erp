// lib/features/admin/data/services/admin_students_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Handles all admin-facing student API calls.
// addStudent()  → POST /admin/students/create
//                 Returns login credentials to show to admin.
// getStudents() → GET  /admin/students
// getStudentDetail() → GET /admin/students/{id}
// updateStudentStatus() → PATCH /admin/students/{id}
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminStudentsService {
  static const String baseUrl = 'http://192.168.1.3:8000';

  static Map<String, String> get _baseHeaders => {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      ..._baseHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // POST /admin/students/create
  // Returns StudentCredentials (login_email + temp_password) on success.
  // Throws a String error message on failure.
  Future<StudentCredentials> addStudent(Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/admin/students/create'),
      headers: headers,
      body: jsonEncode(data),
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return StudentCredentials.fromJson(json);
    }

    final detail = json['detail'] ?? json['message'] ?? 'Failed to add student';
    throw detail.toString();
  }

  // GET /admin/students
  Future<StudentListResult> getStudents({
    String search = '',
    String status = '',
    int page = 1,
    int perPage = 20,
  }) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$baseUrl/admin/students').replace(
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        if (status.isNotEmpty) 'status': status,
        'page': '$page',
        'per_page': '$perPage',
      },
    );
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      final list = (data['students'] ?? data) as List;
      return StudentListResult(
        students: list.map((e) => StudentSummary.fromJson(e)).toList(),
        total: (data['total'] ?? list.length) as int,
      );
    }
    throw 'Failed to load students (${response.statusCode})';
  }

  // GET /admin/students/{id}
  Future<StudentDetail> getStudentDetail(String studentId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/students/$studentId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return StudentDetail.fromJson(json['data'] ?? json);
    }
    throw 'Student not found';
  }

  // PATCH /admin/students/{id}
  Future<void> updateStudentStatus(String studentId, String status) async {
    final headers = await _authHeaders();
    await http.patch(
      Uri.parse('$baseUrl/admin/students/$studentId'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class StudentCredentials {
  final bool success;
  final String studentId;
  final String studentCode;
  final String loginEmail;
  final String tempPassword;

  StudentCredentials({
    required this.success,
    required this.studentId,
    required this.studentCode,
    required this.loginEmail,
    required this.tempPassword,
  });

  factory StudentCredentials.fromJson(Map<String, dynamic> j) =>
      StudentCredentials(
        success: j['success'] ?? true,
        studentId: j['student_id'] ?? '',
        studentCode: j['student_code'] ?? '',
        loginEmail: j['login_email'] ?? '',
        tempPassword: j['temp_password'] ?? '',
      );
}

class StudentListResult {
  final List<StudentSummary> students;
  final int total;
  StudentListResult({required this.students, required this.total});
}

class StudentSummary {
  final String studentId;
  final String studentCode;
  final String fullName;
  final String course;
  final String batch;
  final String status;
  final String enrollmentDate;
  final String phone;
  final double attendancePercent;

  StudentSummary({
    required this.studentId,
    required this.studentCode,
    required this.fullName,
    required this.course,
    required this.batch,
    required this.status,
    required this.enrollmentDate,
    required this.phone,
    required this.attendancePercent,
  });

  factory StudentSummary.fromJson(Map<String, dynamic> j) => StudentSummary(
        studentId: j['student_id'] ?? '',
        studentCode: j['student_code'] ?? '',
        fullName: j['full_name'] ?? '',
        course: j['course'] ?? '',
        batch: j['batch'] ?? '',
        status: j['status'] ?? 'active',
        enrollmentDate: j['enrollment_date'] ?? '',
        phone: j['phone'] ?? '',
        attendancePercent:
            ((j['attendance_percent'] ?? 0) as num).toDouble(),
      );

  static List<StudentSummary> mockList() => [
        StudentSummary(
          studentId: 'uuid-001', studentCode: 'PS-2025-001',
          fullName: 'Aravind Kumar', course: 'AI & Python',
          batch: 'Batch A', status: 'active',
          enrollmentDate: '12 Jun 2025', phone: '9876543210',
          attendancePercent: 92.0,
        ),
        StudentSummary(
          studentId: 'uuid-002', studentCode: 'PS-2025-002',
          fullName: 'Nithya Selvam', course: 'Robotics Jr.',
          batch: 'Batch B', status: 'active',
          enrollmentDate: '14 Jun 2025', phone: '9123456780',
          attendancePercent: 78.5,
        ),
        StudentSummary(
          studentId: 'uuid-003', studentCode: 'PS-2025-003',
          fullName: 'Deepan Raj', course: 'Web Dev',
          batch: 'Batch A', status: 'on_hold',
          enrollmentDate: '15 Jun 2025', phone: '9988776655',
          attendancePercent: 61.0,
        ),
      ];
}

class StudentDetail {
  final String studentId;
  final String studentCode;
  final String fullName;
  final String email;
  final String phone;
  final String parentPhone;
  final String course;
  final String batch;
  final String status;
  final String enrollmentDate;
  final String dob;
  final String gender;
  final double attendancePercent;
  final double feesPaid;
  final double feesTotal;

  StudentDetail({
    required this.studentId,
    required this.studentCode,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.parentPhone,
    required this.course,
    required this.batch,
    required this.status,
    required this.enrollmentDate,
    required this.dob,
    required this.gender,
    required this.attendancePercent,
    required this.feesPaid,
    required this.feesTotal,
  });

  factory StudentDetail.fromJson(Map<String, dynamic> j) => StudentDetail(
        studentId: j['student_id'] ?? '',
        studentCode: j['student_code'] ?? '',
        fullName: j['full_name'] ?? '',
        email: j['email'] ?? '',
        phone: j['phone'] ?? '',
        parentPhone: j['parent_phone'] ?? '',
        course: j['course'] ?? '',
        batch: j['batch'] ?? '',
        status: j['status'] ?? 'active',
        enrollmentDate: j['enrollment_date'] ?? '',
        dob: j['dob'] ?? '',
        gender: j['gender'] ?? '',
        attendancePercent:
            ((j['attendance_percent'] ?? 0) as num).toDouble(),
        feesPaid: ((j['fees_paid'] ?? 0) as num).toDouble(),
        feesTotal: ((j['fees_total'] ?? 0) as num).toDouble(),
      );

  factory StudentDetail.mock(StudentSummary s) => StudentDetail(
        studentId: s.studentId,
        studentCode: s.studentCode,
        fullName: s.fullName,
        email: '${s.fullName.toLowerCase().replaceAll(' ', '.')}@pinesphere.in',
        phone: s.phone,
        parentPhone: '9111122223',
        course: s.course,
        batch: s.batch,
        status: s.status,
        enrollmentDate: s.enrollmentDate,
        dob: '2005-03-15',
        gender: 'male',
        attendancePercent: s.attendancePercent,
        feesPaid: 12000,
        feesTotal: 18000,
      );
}

