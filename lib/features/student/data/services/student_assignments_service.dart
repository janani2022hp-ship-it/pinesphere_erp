import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class StudentAssignment {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String dueDate;
  final String? attachment;
  final String? submissionStatus;
  final int? marks;
  final String? feedback;

  StudentAssignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    this.attachment,
    this.submissionStatus,
    this.marks,
    this.feedback,
  });

  factory StudentAssignment.fromJson(Map<String, dynamic> json) {
    return StudentAssignment(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      dueDate: json['due_date'] ?? '',
      attachment: json['attachment'],
      submissionStatus: json['submission_status'],
      marks: json['marks'],
      feedback: json['feedback'],
    );
  }
}

class StudentAssignmentSubmission {
  final String id;
  final String assignmentId;
  final String submissionText;
  final String? fileUrl;
  final String submittedAt;
  final int? marks;
  final String? feedback;
  final String status;

  StudentAssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.submissionText,
    this.fileUrl,
    required this.submittedAt,
    this.marks,
    this.feedback,
    required this.status,
  });

  factory StudentAssignmentSubmission.fromJson(Map<String, dynamic> json) {
    return StudentAssignmentSubmission(
      id: json['id'] ?? '',
      assignmentId: json['assignment_id'] ?? '',
      submissionText: json['submission_text'] ?? '',
      fileUrl: json['file_url'],
      submittedAt: json['submitted_at'] ?? '',
      marks: json['marks'],
      feedback: json['feedback'],
      status: json['status'] ?? 'submitted',
    );
  }
}

class StudentAssignmentsService {
  static String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  Future<List<StudentAssignment>> fetchMyAssignments({
    required String studentId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student/my-assignments/$studentId'),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => StudentAssignment.fromJson(item)).toList();
    }
    throw Exception('Failed to load assignments (${response.statusCode})');
  }

  Future<List<StudentAssignment>> fetchAssignments({
    required String courseId,
    String? studentId,
  }) async {
    final uri = studentId != null
        ? Uri.parse(
            '$baseUrl/student/assignments/$courseId?student_id=$studentId',
          )
        : Uri.parse('$baseUrl/student/assignments/$courseId');

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => StudentAssignment.fromJson(item)).toList();
    }
    throw Exception('Failed to load assignments (${response.statusCode})');
  }

  Future<Map<String, dynamic>> submitAssignment({
    required String assignmentId,
    required String studentId,
    required String submissionText,
    String? fileUrl,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/student/submit-assignment/$assignmentId?student_id=$studentId',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'submission_text': submissionText,
        'file_url': fileUrl,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': data['success'] ?? true,
        'message': data['message'] ?? 'Assignment submitted successfully',
        'submission_id': data['submission_id'],
      };
    }
    return {
      'success': false,
      'message': 'Failed to submit assignment',
    };
  }

  Future<List<StudentAssignmentSubmission>> fetchSubmissions({
    required String studentId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student/assignment-submissions/$studentId'),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => StudentAssignmentSubmission.fromJson(item))
          .toList();
    }
    return [];
  }
}
