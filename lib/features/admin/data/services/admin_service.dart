import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardService {
  // ── Change to your WiFi IP for physical device, or ngrok host for external ──
  static const String baseUrl = 'http://192.168.1.3:8000';

  // Ngrok header — add when using ngrok, remove for local WiFi
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      ..._headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /admin/dashboard
  /// Returns: total_students, active_students, today_attendance_rate,
  ///          fee_collection_this_month, new_enquiries_today,
  ///          pending_dues_count, active_batches, upcoming_classes
  Future<AdminDashboardData> getDashboard() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return AdminDashboardData.fromJson(data);
    } else {
      throw Exception('Failed to load admin dashboard: ${response.statusCode}');
    }
  }

  /// GET /admin/dashboard/recent-students?limit=5
  Future<List<RecentStudent>> getRecentStudents() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard/recent-students?limit=5'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final list = (json['data'] ?? json) as List;
      return list.map((e) => RecentStudent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load recent students');
    }
  }

  /// GET /admin/dashboard/fee-summary
  Future<FeeSummary> getFeeSummary() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard/fee-summary'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return FeeSummary.fromJson(data);
    } else {
      throw Exception('Failed to load fee summary');
    }
  }
}

// ─── Data models ────────────────────────────────────────────────────────────

class AdminDashboardData {
  final int totalStudents;
  final int activeStudents;
  final double todayAttendanceRate;   // 0.0 – 100.0
  final double feeCollectionThisMonth; // in rupees
  final int newEnquiriesToday;
  final int pendingDuesCount;
  final int activeBatches;
  final int upcomingClassesToday;

  AdminDashboardData({
    required this.totalStudents,
    required this.activeStudents,
    required this.todayAttendanceRate,
    required this.feeCollectionThisMonth,
    required this.newEnquiriesToday,
    required this.pendingDuesCount,
    required this.activeBatches,
    required this.upcomingClassesToday,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      totalStudents: (json['total_students'] ?? 0) as int,
      activeStudents: (json['active_students'] ?? 0) as int,
      todayAttendanceRate:
          ((json['today_attendance_rate'] ?? 0) as num).toDouble(),
      feeCollectionThisMonth:
          ((json['fee_collection_this_month'] ?? 0) as num).toDouble(),
      newEnquiriesToday: (json['new_enquiries_today'] ?? 0) as int,
      pendingDuesCount: (json['pending_dues_count'] ?? 0) as int,
      activeBatches: (json['active_batches'] ?? 0) as int,
      upcomingClassesToday: (json['upcoming_classes_today'] ?? 0) as int,
    );
  }

  // Fallback mock for UI testing before backend is wired
  factory AdminDashboardData.mock() => AdminDashboardData(
        totalStudents: 148,
        activeStudents: 132,
        todayAttendanceRate: 87.5,
        feeCollectionThisMonth: 184500,
        newEnquiriesToday: 6,
        pendingDuesCount: 14,
        activeBatches: 9,
        upcomingClassesToday: 4,
      );
}

class RecentStudent {
  final String studentId;
  final String fullName;
  final String course;
  final String enrollmentDate;
  final String status; // active | on_hold | dropped

  RecentStudent({
    required this.studentId,
    required this.fullName,
    required this.course,
    required this.enrollmentDate,
    required this.status,
  });

  factory RecentStudent.fromJson(Map<String, dynamic> json) => RecentStudent(
        studentId: json['student_id'] ?? '',
        fullName: json['full_name'] ?? '',
        course: json['course'] ?? '',
        enrollmentDate: json['enrollment_date'] ?? '',
        status: json['status'] ?? 'active',
      );
}

class FeeSummary {
  final double totalCollected;
  final double totalPending;
  final int overdueCount;

  FeeSummary({
    required this.totalCollected,
    required this.totalPending,
    required this.overdueCount,
  });

  factory FeeSummary.fromJson(Map<String, dynamic> json) => FeeSummary(
        totalCollected: ((json['total_collected'] ?? 0) as num).toDouble(),
        totalPending: ((json['total_pending'] ?? 0) as num).toDouble(),
        overdueCount: (json['overdue_count'] ?? 0) as int,
      );
}