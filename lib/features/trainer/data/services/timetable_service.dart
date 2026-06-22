import 'dart:async';

class TimetableEvent {
  final String day;
  final String subject;
  final String time;
  final String location;

  TimetableEvent({
    required this.day,
    required this.subject,
    required this.time,
    required this.location,
  });
}

class TimetableService {
  Future<List<TimetableEvent>> fetchWeeklySchedule() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      TimetableEvent(day: 'Mon', subject: 'Mathematics', time: '09:30 AM', location: 'Room 204'),
      TimetableEvent(day: 'Tue', subject: 'Physics', time: '11:00 AM', location: 'Lab 1'),
      TimetableEvent(day: 'Wed', subject: 'English', time: '01:30 PM', location: 'Room 108'),
    ];
  }

  Future<void> requestLeave(String reason, String from, String to) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
