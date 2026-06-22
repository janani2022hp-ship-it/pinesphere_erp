// lib/features/student/data/services/assignment_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class AssignmentQuestion {
  final String question;
  final String modelAnswer;
  final int marks;

  const AssignmentQuestion({
    required this.question,
    this.modelAnswer = '',
    this.marks = 10,
  });

  factory AssignmentQuestion.fromJson(Map<String, dynamic> json) =>
      AssignmentQuestion(
        question:    json['question']?.toString() ?? '',
        modelAnswer: json['model_answer']?.toString() ?? '',
        marks:       (json['marks'] as num?)?.toInt() ?? 10,
      );

  Map<String, dynamic> toJson() => {
        'question':     question,
        'model_answer': modelAnswer,
        'marks':        marks,
      };
}

class StudentAssignment {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String dueDate;
  final String status;          // Open | Submitted | Graded | Late
  final String assignmentType;  // written | quiz | file
  final List<AssignmentQuestion> questions;
  final String? quizLink;
  final int totalMarks;
  final String? grade;
  final int? marks;
  final String? feedback;
  final String? submissionId;
  final List<String>? myAnswers;

  const StudentAssignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    this.status = 'Open',
    this.assignmentType = 'written',
    this.questions = const [],
    this.quizLink,
    this.totalMarks = 100,
    this.grade,
    this.marks,
    this.feedback,
    this.submissionId,
    this.myAnswers,
  });

  factory StudentAssignment.fromJson(Map<String, dynamic> json) {
    final rawQ = json['questions'];
    final questions = (rawQ is List)
        ? rawQ.map((q) => AssignmentQuestion.fromJson(q as Map<String, dynamic>)).toList()
        : <AssignmentQuestion>[];

    final rawA = json['answers'];
    final answers = (rawA is List)
        ? rawA.map((a) => a?.toString() ?? '').toList()
        : <String>[];

    return StudentAssignment(
      id:             json['id']?.toString() ?? '',
      title:          json['title']?.toString() ?? '',
      description:    json['description']?.toString() ?? '',
      subject:        json['subject']?.toString() ?? '',
      dueDate:        json['due_date']?.toString() ?? '',
      status:         json['status']?.toString() ?? 'Open',
      assignmentType: json['assignment_type']?.toString() ?? 'written',
      questions:      questions,
      quizLink:       json['quiz_link']?.toString(),
      totalMarks:     (json['total_marks'] as num?)?.toInt() ?? 100,
      grade:          json['grade']?.toString(),
      marks:          (json['marks'] as num?)?.toInt(),
      feedback:       json['feedback']?.toString(),
      submissionId:   json['submission_id']?.toString(),
      myAnswers:      answers.isEmpty ? null : answers,
    );
  }
}

class TrainerAssignmentModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String dueDate;
  final String status;
  final String assignmentType;
  final List<AssignmentQuestion> questions;
  final String? quizLink;
  final int totalMarks;
  final int submissions;

  const TrainerAssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    this.status = 'Open',
    this.assignmentType = 'written',
    this.questions = const [],
    this.quizLink,
    this.totalMarks = 100,
    this.submissions = 0,
  });

  factory TrainerAssignmentModel.fromJson(Map<String, dynamic> json) {
    final rawQ = json['questions'];
    final questions = (rawQ is List)
        ? rawQ.map((q) => AssignmentQuestion.fromJson(q as Map<String, dynamic>)).toList()
        : <AssignmentQuestion>[];

    return TrainerAssignmentModel(
      id:             json['id']?.toString() ?? '',
      title:          json['title']?.toString() ?? '',
      description:    json['description']?.toString() ?? '',
      subject:        json['subject']?.toString() ?? '',
      dueDate:        json['due_date']?.toString() ?? '',
      status:         json['status']?.toString() ?? 'Open',
      assignmentType: json['assignment_type']?.toString() ?? 'written',
      questions:      questions,
      quizLink:       json['quiz_link']?.toString(),
      totalMarks:     (json['total_marks'] as num?)?.toInt() ?? 100,
      submissions:    (json['submissions'] as num?)?.toInt() ?? 0,
    );
  }
}

class SubmissionModel {
  final String id;
  final String studentId;
  final String assignmentId;
  final List<String> answers;
  final String? fileUrl;
  final String notes;
  final String status;
  final String? grade;
  final int? marks;
  final String? feedback;

  const SubmissionModel({
    required this.id,
    required this.studentId,
    required this.assignmentId,
    this.answers = const [],
    this.fileUrl,
    this.notes = '',
    this.status = 'Submitted',
    this.grade,
    this.marks,
    this.feedback,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    final rawA = json['answers'];
    final answers = (rawA is List)
        ? rawA.map((a) => a?.toString() ?? '').toList()
        : <String>[];
    return SubmissionModel(
      id:           json['id']?.toString() ?? '',
      studentId:    json['student_id']?.toString() ?? '',
      assignmentId: json['assignment_id']?.toString() ?? '',
      answers:      answers,
      fileUrl:      json['file_url']?.toString(),
      notes:        json['notes']?.toString() ?? '',
      status:       json['status']?.toString() ?? 'Submitted',
      grade:        json['grade']?.toString(),
      marks:        (json['marks'] as num?)?.toInt(),
      feedback:     json['feedback']?.toString(),
    );
  }
}

// ── Service ───────────────────────────────────────────────────────────────────

class AssignmentService {
  static String get _host => 'https://vaguely-dastardly-pennant.ngrok-free.dev';

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    return (id == null || id.isEmpty) ? null : id;
  }

  // ── Student ────────────────────────────────────────────────────────────────

  /// Fetch all assignments for the logged-in student
  Future<List<StudentAssignment>> fetchMyAssignments() async {
    final studentId = await _getUserId();
    if (studentId == null) return [];
    try {
      final resp = await http.get(
        Uri.parse('$_host/student/my-assignments/$studentId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body);
        return data.map((e) => StudentAssignment.fromJson(e)).toList();
      }
    } catch (e) {
      print('fetchMyAssignments error: $e');
    }
    return [];
  }

  /// Student submits an assignment
  /// [answers] — list of answers for written type
  /// [fileUrl] — uploaded file URL for file type
  /// [notes]   — optional note for quiz type
  Future<SubmissionModel?> submitAssignment(
    String assignmentId, {
    List<String> answers = const [],
    String? fileUrl,
    String notes = '',
  }) async {
    final studentId = await _getUserId();
    if (studentId == null) return null;
    try {
      final resp = await http.post(
        Uri.parse('$_host/student/submit-assignment/$assignmentId?student_id=$studentId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'answers':  answers,
          'file_url': fileUrl,
          'notes':    notes,
        }),
      ).timeout(const Duration(seconds: 15)); // longer for AI grading

      if (resp.statusCode == 200) {
        return SubmissionModel.fromJson(jsonDecode(resp.body));
      }
    } catch (e) {
      print('submitAssignment error: $e');
    }
    return null;
  }

  // ── Trainer ────────────────────────────────────────────────────────────────

  /// Fetch all assignments created by the logged-in trainer
  Future<List<TrainerAssignmentModel>> fetchTrainerAssignments() async {
    final trainerId = await _getUserId();
    if (trainerId == null) return [];
    try {
      final resp = await http.get(
        Uri.parse('$_host/trainer/assignments/$trainerId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body);
        return data.map((e) => TrainerAssignmentModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('fetchTrainerAssignments error: $e');
    }
    return [];
  }

  /// Trainer creates a new assignment
  Future<TrainerAssignmentModel?> createAssignment({
    required String title,
    required String description,
    required String subject,
    required String dueDate,
    required String assignmentType,
    List<AssignmentQuestion> questions = const [],
    String? quizLink,
    int totalMarks = 100,
    String? courseId,
  }) async {
    final trainerId = await _getUserId();
    if (trainerId == null) return null;
    try {
      final resp = await http.post(
        Uri.parse('$_host/trainer/assignments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'trainer_id':      trainerId,
          'course_id':       courseId,
          'title':           title,
          'description':     description,
          'subject':         subject,
          'due_date':        dueDate,
          'assignment_type': assignmentType,
          'questions':       questions.map((q) => q.toJson()).toList(),
          'quiz_link':       quizLink,
          'total_marks':     totalMarks,
        }),
      ).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        return TrainerAssignmentModel.fromJson(jsonDecode(resp.body));
      }
    } catch (e) {
      print('createAssignment error: $e');
    }
    return null;
  }

  /// Fetch all submissions for a specific assignment
  Future<List<SubmissionModel>> fetchSubmissions(String assignmentId) async {
    try {
      final resp = await http.get(
        Uri.parse('$_host/trainer/assignments/$assignmentId/submissions'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body);
        return data.map((e) => SubmissionModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('fetchSubmissions error: $e');
    }
    return [];
  }

  /// Trainer manually grades a submission
  Future<bool> gradeSubmission(
    String submissionId, {
    required String grade,
    required String feedback,
    int? marks,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse('$_host/trainer/grade/$submissionId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'grade':    grade,
          'feedback': feedback,
          'marks':    marks,
        }),
      ).timeout(const Duration(seconds: 8));
      return resp.statusCode == 200;
    } catch (e) {
      print('gradeSubmission error: $e');
      return false;
    }
  }
}