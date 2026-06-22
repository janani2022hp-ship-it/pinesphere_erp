import 'dart:async';

class EvaluationRecord {
  final String studentName;
  final String subject;
  final String progress;
  final String recommendation;

  EvaluationRecord({
    required this.studentName,
    required this.subject,
    required this.progress,
    required this.recommendation,
  });
}

class EvaluationService {
  Future<List<EvaluationRecord>> fetchEvaluations() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      EvaluationRecord(
        studentName: 'Anaya Sharma',
        subject: 'Mathematics',
        progress: 'Strong progress',
        recommendation: 'Award certificate',
      ),
      EvaluationRecord(
        studentName: 'Rohan Verma',
        subject: 'Physics',
        progress: 'Needs improvement',
        recommendation: 'Extra coaching',
      ),
      EvaluationRecord(
        studentName: 'Nisha Patel',
        subject: 'English',
        progress: 'Good performance',
        recommendation: 'Continue practice',
      ),
    ];
  }

  Future<void> submitFeedback(String studentId, String feedback) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> recommendCertificate(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
