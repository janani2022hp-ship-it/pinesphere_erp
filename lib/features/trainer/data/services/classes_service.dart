import 'dart:async';

class TrainerClass {
  final String id;
  final String title;
  final String subject;
  final int studentCount;
  final String nextSession;

  TrainerClass({
    required this.id,
    required this.title,
    required this.subject,
    required this.studentCount,
    required this.nextSession,
  });
}

class ClassesService {
  Future<List<TrainerClass>> fetchMyClasses() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      TrainerClass(
        id: 'c1',
        title: 'Grade 8 Mathematics',
        subject: 'Mathematics',
        studentCount: 22,
        nextSession: 'Today • 09:30 AM',
      ),
      TrainerClass(
        id: 'c2',
        title: 'Physics Lab Group',
        subject: 'Physics',
        studentCount: 18,
        nextSession: 'Today • 12:00 PM',
      ),
      TrainerClass(
        id: 'c3',
        title: 'English Literature',
        subject: 'English',
        studentCount: 20,
        nextSession: 'Thu • 02:00 PM',
      ),
    ];
  }
}
