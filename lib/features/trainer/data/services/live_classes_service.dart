import 'dart:async';

class TrainerLiveClass {
  final String id;
  final String title;
  final String subject;
  final String schedule;
  final bool isLive;
  final int attendees;

  TrainerLiveClass({
    required this.id,
    required this.title,
    required this.subject,
    required this.schedule,
    required this.isLive,
    required this.attendees,
  });
}

class LiveClassesService {
  Future<List<TrainerLiveClass>> fetchLiveSessions() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      TrainerLiveClass(
        id: 'l1',
        title: 'Math revision session',
        subject: 'Mathematics',
        schedule: 'Live now',
        isLive: true,
        attendees: 19,
      ),
      TrainerLiveClass(
        id: 'l2',
        title: 'Physics lab Q&A',
        subject: 'Physics',
        schedule: 'Today • 02:30 PM',
        isLive: false,
        attendees: 0,
      ),
    ];
  }

  Future<void> startSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
