import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/push_notification_service.dart';
import '../models/user_model.dart';

class AuthService {
  static const List<String> _candidateHosts = [
    'https://vaguely-dastardly-pennant.ngrok-free.dev',
    'http://10.0.2.2:8000',
    'http://localhost:8000',
  ];

  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  Future<String?> login(String email, String password) async {
    final body = jsonEncode({'username_or_email': email, 'password': password});

    String? lastError;

    for (final host in _candidateHosts) {
      for (final role in ['student', 'trainer', 'parent', 'admin']) {
        try {
          final resp = await http
              .post(
                Uri.parse('$host/auth/$role/login'),
                headers: _headers,
                body: body,
              )
              .timeout(const Duration(seconds: 15));

          if (resp.statusCode == 200) {
            final data = jsonDecode(resp.body) as Map<String, dynamic>;
            await _saveSession(data);
            await _registerPushDevice();
            return null;
          }

          try {
            final data = jsonDecode(resp.body);
            final detail = data is Map<String, dynamic>
                ? (data['detail'] ?? data['message'] ?? data['error'])
                : null;
            if (detail != null) {
              lastError = detail.toString();
            }
          } catch (_) {}
          if (lastError == null) {
            lastError = 'Login failed (${resp.statusCode})';
          }
        } on TimeoutException {
          lastError = 'The server took too long to respond. Please try again.';
        } on SocketException {
          lastError =
              'Could not reach the server. Please check your internet and try again.';
        } catch (e) {
          lastError = e.toString().replaceFirst('Exception: ', '');
        }
      }
    }

    return lastError ?? 'Invalid username or password';
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, data['id']?.toString() ?? '');
    await prefs.setString(_keyUserName, data['name']?.toString() ?? '');
    await prefs.setString(_keyUserEmail, data['email']?.toString() ?? '');
    await prefs.setString(_keyUserRole, data['role']?.toString() ?? '');
    await prefs.setString('student_name', data['name']?.toString() ?? '');
    await prefs.setString('user_id', data['id']?.toString() ?? '');
  }

  Future<void> _registerPushDevice() async {
    try {
      await PushNotificationService().registerCurrentDevice();
    } catch (_) {
      // Login/signup should still succeed if push registration is unavailable.
    }
  }

  /// Returns null on success, or an error message string on failure.
  Future<String?> signup(UserModel user) async {
    try {
      final body = jsonEncode({
        'full_name': user.fullName ?? user.username,
        'username': user.username,
        'email': user.email ?? '',
        'password': user.password,
        'confirm_password': user.password,
      });

      final resp = await http
          .post(
            Uri.parse('${_candidateHosts.first}/auth/${user.role}/signup'),
            headers: _headers,
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        await _saveSession(data);
        await _registerPushDevice();
        return null; // success
      }

      // Try to read the actual error message from the backend response
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final msg = data['detail'] ?? data['message'] ?? data['error'];
        if (msg != null) return msg.toString();
      } catch (_) {}

      return 'Signup failed (${resp.statusCode}). Please try again.';
    } catch (e) {
      return 'Connection failed. Please check your internet and try again.';
    }
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyUserId);
    return (id == null || id.isEmpty) ? null : id;
  }

  Future<String?> getCurrentRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  Future<bool> isLoggedIn() async {
    final id = await getUserId();
    return id != null && id.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserRole);
    await prefs.remove('student_name');
    await prefs.remove('user_id');
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyUserId);
    if (id == null || id.isEmpty) return null;
    return UserModel(
      username: prefs.getString(_keyUserName) ?? '',
      password: '',
      role: prefs.getString(_keyUserRole) ?? 'student',
      fullName: prefs.getString(_keyUserName),
      email: prefs.getString(_keyUserEmail),
    );
  }
}
