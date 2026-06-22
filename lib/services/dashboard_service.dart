import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardService {
  static const String _host = 'https://vaguely-dastardly-pennant.ngrok-free.dev';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  Future<Map<String, dynamic>?> getDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';

      if (userId.isEmpty) {
        print('❌ No user_id found in SharedPreferences');
        return null;
      }

      final response = await http.get(
        Uri.parse('$_host/student/dashboard/$userId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      print('✅ Status: ${response.statusCode}');
      print('✅ Body: ${response.body}');

      if (response.statusCode == 200) {
        var dashboardData = jsonDecode(response.body) as Map<String, dynamic>;

        final studentName = prefs.getString('student_name');
        if (studentName != null) {
          dashboardData['student_name'] = studentName;
        }

        return dashboardData;
      } else {
        print('❌ Bad status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exception: $e');

      final prefs = await SharedPreferences.getInstance();
      final studentName = prefs.getString('student_name');
      if (studentName != null) {
        return {
          'student_name': studentName,
          'xp': 0,
          'streak_days': 0,
        };
      }
      return null;
    }
  }
}