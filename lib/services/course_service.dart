import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CourseItem {
  final String id;
  final String title;
  final String description;
  final String duration;

  CourseItem({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
  });

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    return CourseItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
    );
  }
}

class CourseVideoItem {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final String videoUrl;
  final int durationMinutes;
  final int sequence;

  CourseVideoItem({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.durationMinutes,
    required this.sequence,
  });

  factory CourseVideoItem.fromJson(Map<String, dynamic> json) {
    return CourseVideoItem(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      sequence: json['sequence'] ?? 0,
    );
  }
}

class MyCourse {
  final String id;
  final String title;
  final String description;
  final String duration;
  final List<CourseVideoItem> videos;

  MyCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.videos,
  });

  factory MyCourse.fromJson(Map<String, dynamic> json) {
    final videosJson = (json['videos'] as List?) ?? [];
    return MyCourse(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      videos: videosJson
          .map((v) => CourseVideoItem.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CourseService {
  static const String _host = 'https://vaguely-dastardly-pennant.ngrok-free.dev';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  Future<String?> _getStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// Legacy method — kept for backward compatibility with old UI.
  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await http
          .get(Uri.parse('$_host/student/courses'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final courses = body['courses'] as List<dynamic>? ?? [];
        return courses.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Get ALL courses available for selection.
  Future<List<CourseItem>> getAllCourses() async {
    try {
      final response = await http
          .get(Uri.parse('$_host/student/courses/all'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => CourseItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('🔴 getAllCourses error: $e');
      return [];
    }
  }

  /// Get the course IDs the student already selected (empty if none yet).
  Future<List<String>> getSelectedCourseIds() async {
    final studentId = await _getStudentId();
    if (studentId == null) return [];

    try {
      final response = await http
          .get(
            Uri.parse('$_host/student/courses/selected/$studentId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      }
      return [];
    } catch (e) {
      print('🔴 getSelectedCourseIds error: $e');
      return [];
    }
  }

  /// Save the student's selected courses (must be 4 or more).
  Future<bool> selectCourses(List<String> courseIds) async {
    final studentId = await _getStudentId();
    if (studentId == null) return false;

    try {
      final response = await http
          .post(
            Uri.parse('$_host/student/courses/select'),
            headers: _headers,
            body: jsonEncode({
              'student_id': studentId,
              'course_ids': courseIds,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('📚 selectCourses status: ${response.statusCode}');
      print('📚 selectCourses body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('🔴 selectCourses error: $e');
      return false;
    }
  }

  /// Get the student's enrolled courses WITH their videos.
  Future<List<MyCourse>> getMyCourses() async {
    final studentId = await _getStudentId();
    if (studentId == null) return [];

    try {
      final response = await http
          .get(
            Uri.parse('$_host/student/courses/my/$studentId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => MyCourse.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('🔴 getMyCourses error: $e');
      return [];
    }
  }

  // ── Trainer methods ─────────────────────────────────────────────────────

  Future<CourseItem?> createCourse({
    required String title,
    required String description,
    required String duration,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final trainerId = prefs.getString('user_id') ?? '';

    try {
      final response = await http
          .post(
            Uri.parse('$_host/trainer/courses'),
            headers: _headers,
            body: jsonEncode({
              'trainer_id': trainerId,
              'title': title,
              'description': description,
              'duration': duration,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CourseItem.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('🔴 createCourse error: $e');
      return null;
    }
  }

  Future<List<CourseItem>> getTrainerCourses() async {
    try {
      final response = await http
          .get(Uri.parse('$_host/trainer/courses'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => CourseItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('🔴 getTrainerCourses error: $e');
      return [];
    }
  }

  Future<CourseVideoItem?> uploadVideo({
    required String courseId,
    required String title,
    required String description,
    required String videoUrl,
    int durationMinutes = 0,
    int sequence = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final trainerId = prefs.getString('user_id') ?? '';

    try {
      final response = await http
          .post(
            Uri.parse('$_host/trainer/courses/$courseId/videos'),
            headers: _headers,
            body: jsonEncode({
              'trainer_id': trainerId,
              'title': title,
              'description': description,
              'video_url': videoUrl,
              'duration_minutes': durationMinutes,
              'sequence': sequence,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('🎬 uploadVideo status: ${response.statusCode}');
      print('🎬 uploadVideo body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CourseVideoItem.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('🔴 uploadVideo error: $e');
      return null;
    }
  }

  Future<List<CourseVideoItem>> getCourseVideos(String courseId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_host/trainer/courses/$courseId/videos'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => CourseVideoItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('🔴 getCourseVideos error: $e');
      return [];
    }
  }
}