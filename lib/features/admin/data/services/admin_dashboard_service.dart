import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminDashboardData {
  final int totalStudents;
  final int activeStudents;
  final double todayAttendanceRate;
  final double feeCollectionThisMonth;
  final int newEnquiriesToday;
  final int activeBatches;
  final int upcomingClassesToday;
  final int pendingDuesCount;

  const AdminDashboardData({
    required this.totalStudents,
    required this.activeStudents,
    required this.todayAttendanceRate,
    required this.feeCollectionThisMonth,
    required this.newEnquiriesToday,
    required this.activeBatches,
    required this.upcomingClassesToday,
    required this.pendingDuesCount,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> j) {
    return AdminDashboardData(
      totalStudents:           (j['total_students']             ?? 0) as int,
      activeStudents:          (j['active_students']            ?? 0) as int,
      todayAttendanceRate:     (j['today_attendance_rate']      ?? 0).toDouble(),
      feeCollectionThisMonth:  (j['fee_collection_this_month']  ?? 0).toDouble(),
      newEnquiriesToday:       (j['new_enquiries_today']        ?? 0) as int,
      activeBatches:           (j['active_batches']             ?? 0) as int,
      upcomingClassesToday:    (j['upcoming_classes_today']     ?? 0) as int,
      pendingDuesCount:        (j['pending_dues_count']         ?? 0) as int,
    );
  }

  factory AdminDashboardData.mock() => const AdminDashboardData(
        totalStudents:          120,
        activeStudents:         108,
        todayAttendanceRate:    87.5,
        feeCollectionThisMonth: 124000,
        newEnquiriesToday:      3,
        activeBatches:          6,
        upcomingClassesToday:   4,
        pendingDuesCount:       12,
      );
}

class RecentStudent {
  final String studentId;
  final String fullName;
  final String course;
  final String enrollmentDate;
  final String status;

  const RecentStudent({
    required this.studentId,
    required this.fullName,
    required this.course,
    required this.enrollmentDate,
    required this.status,
  });

  factory RecentStudent.fromJson(Map<String, dynamic> j) => RecentStudent(
        studentId:      j['student_id']      ?? '',
        fullName:       j['full_name']        ?? '',
        course:         j['course']           ?? '',
        enrollmentDate: j['enrollment_date']  ?? '',
        status:         j['status']           ?? 'active',
      );
}

class AdminDashboardService {
  static const String _host = 'https://vaguely-dastardly-pennant.ngrok-free.dev';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  Future<AdminDashboardData> getDashboard() async {
    final resp = await http
        .get(Uri.parse('$_host/admin/dashboard'), headers: _headers)
        .timeout(const Duration(seconds: 8));
    if (resp.statusCode == 200) {
      return AdminDashboardData.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Dashboard fetch failed: ${resp.statusCode}');
  }

  Future<List<RecentStudent>> getRecentStudents() async {
    final resp = await http
        .get(Uri.parse('$_host/admin/students/recent'), headers: _headers)
        .timeout(const Duration(seconds: 8));
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List<dynamic>;
      return list.map((e) => RecentStudent.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Recent students fetch failed: ${resp.statusCode}');
  }
}