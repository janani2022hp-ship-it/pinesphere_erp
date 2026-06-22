import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;

class AssignmentStatus {
  AssignmentStatus._();
  static const open = 'Open';
  static const submitted = 'Submitted';
  static const graded = 'Graded';
  static const late = 'Late';
}

class TrainerAssignment {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String dueDate;
  final String status;
  final int submissions;
  final String? grade;
  final String? feedback;
  final String? attachment;

  TrainerAssignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    required this.status,
    required this.submissions,
    this.grade,
    this.feedback,
    this.attachment,
  });

  TrainerAssignment copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    String? dueDate,
    String? status,
    int? submissions,
    String? grade,
    String? feedback,
    String? attachment,
  }) {
    return TrainerAssignment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      submissions: submissions ?? this.submissions,
      grade: grade ?? this.grade,
      feedback: feedback ?? this.feedback,
      attachment: attachment ?? this.attachment,
    );
  }

  factory TrainerAssignment.fromJson(Map<String, dynamic> json) {
    return TrainerAssignment(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      dueDate: json['due_date'] ?? '',
      status: AssignmentStatus.open,
      submissions: json['submissions'] ?? 0,
      attachment: json['attachment'],
    );
  }
}

class AssignmentsService {
  static String get baseUrl {
    // Android emulators can't reach host localhost; use 10.0.2.2
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  Future<List<TrainerAssignment>> fetchAssignments({String? trainerId}) async {
    try {
      // For now, return mock data until we get trainer ID from auth
      if (trainerId == null) {
        return _getMockAssignments();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/trainer/assignments?trainer_id=$trainerId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => TrainerAssignment.fromJson(item)).toList();
      } else {
        return _getMockAssignments();
      }
    } catch (e) {
      // Fall back to mock data if API fails
      return _getMockAssignments();
    }
  }

  Future<TrainerAssignment> createAssignment({
    required String trainerId,
    required String title,
    required String description,
    required String subject,
    required String dueDate,
    required String courseId,
    String? attachment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/trainer/assignments?trainer_id=$trainerId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'subject': subject,
          'due_date': dueDate,
          'course_id': courseId,
          'attachment': attachment,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TrainerAssignment(
          id: data['assignment_id'] ?? '',
          title: title,
          description: description,
          subject: subject,
          dueDate: dueDate,
          status: AssignmentStatus.open,
          submissions: 0,
          attachment: attachment,
        );
      } else {
        throw Exception('Failed to create assignment');
      }
    } catch (e) {
      // Return mock for demo if API fails
      return TrainerAssignment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        subject: subject,
        dueDate: dueDate,
        status: AssignmentStatus.open,
        submissions: 0,
        attachment: attachment,
      );
    }
  }

  Future<void> gradeAssignment(String assignmentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> publishAssignment(String assignmentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  List<TrainerAssignment> _getMockAssignments() {
    return [
      TrainerAssignment(
        id: 'a1',
        title: 'Algebra worksheet review',
        description: 'Solve and submit the algebra worksheet covering quadratic equations.',
        subject: 'Mathematics',
        dueDate: 'Today, 5:00 PM',
        status: AssignmentStatus.open,
        submissions: 18,
      ),
      TrainerAssignment(
        id: 'a2',
        title: 'Physics lab review',
        description: 'Review the lab report and submit any corrections by tomorrow.',
        subject: 'Physics',
        dueDate: 'Tomorrow, 11:59 PM',
        status: AssignmentStatus.submitted,
        submissions: 12,
      ),
      TrainerAssignment(
        id: 'a3',
        title: 'English essay feedback',
        description: 'Provide feedback on the submitted English essay draft.',
        subject: 'English',
        dueDate: 'In 2 days',
        status: AssignmentStatus.graded,
        submissions: 24,
        grade: 'A-',
        feedback: 'Good structure, refine your conclusion.',
      ),
      TrainerAssignment(
        id: 'a4',
        title: 'Chemistry assignment follow-up',
        description: 'Finalize the lab write-up and submit responses for review.',
        subject: 'Chemistry',
        dueDate: 'Yesterday',
        status: AssignmentStatus.late,
        submissions: 3,
      ),
    ];
  }
}
