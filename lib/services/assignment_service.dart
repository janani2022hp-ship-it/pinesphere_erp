import 'dart:convert';
import 'package:http/http.dart' as http;

class RoleDashboardService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  Future<Map<String, dynamic>?> getDashboard(String path) async {
    try {
      final response = await http
          .get(
            Uri.parse("https://vaguely-dastardly-pennant.ngrok-free.dev$path"),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
