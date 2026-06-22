import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudyTimeService {
  static const String _host = 'https://vaguely-dastardly-pennant.ngrok-free.dev';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> logStudyTime(double hours) async {
    final id = await _getUserId();
    if (id == null) return;
    try {
      await http.post(
        Uri.parse('$_host/student/study-time/log'),
        headers: _headers,
        body: jsonEncode({'student_id': id, 'hours': hours}),
      ).timeout(const Duration(seconds: 8));
    } catch (_) {}
  }

  Future<List<double>> getWeeklyHours() async {
    final id = await _getUserId();
    print('🔍 user_id = $id');
    if (id == null) return List.filled(7, 0.0);
    try {
      final resp = await http.get(
        Uri.parse('$_host/student/study-time/weekly/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 8));
      print('📡 status = ${resp.statusCode}');
      print('📦 body = ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final days = (data['days'] as List).map((e) => (e as num).toDouble()).toList();
        return days;
      }
    } catch (e) {
      print('🔴 error = $e');
    }
    return List.filled(7, 0.0);
  }
}