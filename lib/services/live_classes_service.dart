import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LiveClass {
  final String id;
  final String title;
  final String teacherName;
  final String courseId;
  final String? meetingLink;
  final String? startTime;
  final String? endTime;
  final bool isLive;

  LiveClass({
    required this.id,
    required this.title,
    required this.teacherName,
    required this.courseId,
    this.meetingLink,
    this.startTime,
    this.endTime,
    required this.isLive,
  });

  factory LiveClass.fromJson(Map<String, dynamic> json) {
    return LiveClass(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      courseId: json['course_id'] ?? '',
      meetingLink: json['meeting_link'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isLive: json['is_live'] ?? false,
    );
  }
}

class LiveClassesService {
  static const String _host = 'https://vaguely-dastardly-pennant.ngrok-free.dev';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  /// Fetches only classes that are currently live, restricted to the
  /// logged-in student's selected courses.
  Future<List<LiveClass>> fetchLiveClasses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('user_id') ?? '';

      final uri = studentId.isEmpty
          ? Uri.parse('$_host/student/live-classes')
          : Uri.parse('$_host/student/live-classes?student_id=$studentId');

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => LiveClass.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching live classes: $e');
      return [];
    }
  }

  /// Fetches ALL live classes (live, scheduled, ended) for the trainer's
  /// management view.
  Future<List<LiveClass>> fetchTrainerLiveClasses() async {
    try {
      final response = await http
          .get(Uri.parse('$_host/trainer/live-classes'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => LiveClass.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching trainer live classes: $e');
      return [];
    }
  }

  Future<LiveClass?> hostLiveClass(String classId) async {
    try {
      final response = await http
          .post(Uri.parse('$_host/student/live-classes/$classId/host'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return LiveClass.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error hosting live class: $e');
      return null;
    }
  }

  /// Marks a live class as stopped (is_live = false). Call this when the
  /// trainer taps "Stop Broadcast" so the student dashboard reflects it
  /// on the next refresh.
  Future<LiveClass?> stopLiveClass(String classId) async {
    try {
      final response = await http
          .post(Uri.parse('$_host/student/live-classes/$classId/stop'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return LiveClass.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error stopping live class: $e');
      return null;
    }
  }

  Future<LiveClass?> scheduleLiveClass(
    String classId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_host/student/live-classes/$classId/schedule'),
            headers: _headers,
            body: jsonEncode({
              'start_time': startTime.toIso8601String(),
              'end_time': endTime.toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return LiveClass.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error scheduling live class: $e');
      return null;
    }
  }

  Future<LiveClass?> createLiveClass(
    String title,
    String courseId, {
    String teacherName = 'Trainer',
  }) async {
    print('🔵 HOST: $_host');
    try {
      final uri = Uri.parse('$_host/student/live-classes/create');
      print('🔵 CREATE URL: $uri');

      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'title': title,
              'course_id': courseId,
              'teacher_name': teacherName,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('🔵 CREATE STATUS: ${response.statusCode}');
      print('🔵 CREATE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LiveClass.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('🔴 CREATE ERROR: $e');
      return null;
    }
  }
}