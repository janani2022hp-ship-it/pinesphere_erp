// lib/features/trainer/data/repositories/assignment_store.dart

import '../../../student/presentation/models/student_assignment.dart';

class AssignmentStore {
  AssignmentStore._();
  static final AssignmentStore instance = AssignmentStore._();

  final List<StudentAssignment> _assignments = [];

  /// All assignments — every student sees these
  List<StudentAssignment> getAll() => List.unmodifiable(_assignments);

  /// Only assignments created by this trainer
  /// Convention: assignment id starts with trainerId
  List<StudentAssignment> getByTrainer(String trainerId) =>
      _assignments.where((a) => a.id.startsWith(trainerId)).toList();

  void add(StudentAssignment assignment) => _assignments.insert(0, assignment);

  void update(StudentAssignment updated) {
    final idx = _assignments.indexWhere((a) => a.id == updated.id);
    if (idx != -1) _assignments[idx] = updated;
  }

  void remove(String id) => _assignments.removeWhere((a) => a.id == id);

  /// Call once at app start to pre-populate demo data
  void seedDemo() {
    if (_assignments.isNotEmpty) return;
    _assignments.addAll([
      const StudentAssignment(
        id: 'trainer-math-1',
        title: 'Algebra Worksheet',
        description: 'Complete exercises 1–10 on quadratic equations.',
        subject: 'Mathematics',
        dueDate: 'Today, 5:00 PM',
        status: 'Open',
      ),
      const StudentAssignment(
        id: 'trainer-physics-1',
        title: 'Physics Lab Report',
        description: 'Upload your lab report for last week\'s experiment.',
        subject: 'Physics',
        dueDate: 'Tomorrow, 11:59 PM',
        status: 'Open',
      ),
      const StudentAssignment(
        id: 'trainer-english-1',
        title: 'Essay: Climate Change',
        description: 'Write a 500-word essay on the effects of climate change.',
        subject: 'English',
        dueDate: 'Friday, 6:00 PM',
        status: 'Open',
      ),
    ]);
  }
}