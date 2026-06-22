import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentApiService {
  static const String _host =
      'https://vaguely-dastardly-pennant.ngrok-free.dev';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    return (id == null || id.isEmpty) ? null : id;
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final userId = await _getUserId();
    if (userId == null) {
      return <String, dynamic>{};
    }

    final response = await http
        .get(Uri.parse('$_host/student/profile/$userId'), headers: _headers)
        .timeout(
          const Duration(seconds: 8),
          onTimeout: () => http.Response(
            jsonEncode({'error': 'Timeout reaching student profile'}),
            504,
          ),
        );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchDashboard() async {
    final userId = await _getUserId();
    if (userId == null) {
      return <String, dynamic>{};
    }

    final response = await http
        .get(Uri.parse('$_host/student/dashboard/$userId'), headers: _headers)
        .timeout(
          const Duration(seconds: 8),
          onTimeout: () => http.Response(
            jsonEncode({'error': 'Timeout reaching dashboard'}),
            504,
          ),
        );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  Future<List<dynamic>> fetchCourses() async {
    final userId = await _getUserId();
    if (userId == null) {
      return const [];
    }

    final response = await http
        .get(Uri.parse('$_host/student/courses/$userId'), headers: _headers)
        .timeout(
          const Duration(seconds: 8),
          onTimeout: () => http.Response(
            jsonEncode({'error': 'Timeout reaching courses'}),
            504,
          ),
        );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded;
      }
    }

    return const [];
  }

  Future<bool> updateProfile(Map<String, dynamic> payload) async {
    final userId = await _getUserId();
    if (userId == null) {
      return false;
    }

    final response = await http
        .put(
          Uri.parse('$_host/student/profile/$userId'),
          headers: _headers,
          body: jsonEncode(payload),
        )
        .timeout(
          const Duration(seconds: 8),
          onTimeout: () => http.Response(
            jsonEncode({'error': 'Timeout updating profile'}),
            504,
          ),
        );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
