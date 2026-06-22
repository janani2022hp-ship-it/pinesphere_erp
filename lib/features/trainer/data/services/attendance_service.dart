import 'dart:async';

class AttendanceRecord {
  final String date;
  final int present;
  final int absent;
  final String status;

  AttendanceRecord({
    required this.date,
    required this.present,
    required this.absent,
    required this.status,
  });
}

class AttendanceService {
  Future<List<AttendanceRecord>> fetchAttendanceHistory() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      AttendanceRecord(date: 'Mon 3 Jun', present: 21, absent: 3, status: 'Completed'),
      AttendanceRecord(date: 'Tue 4 Jun', present: 23, absent: 1, status: 'Completed'),
      AttendanceRecord(date: 'Wed 5 Jun', present: 20, absent: 4, status: 'Completed'),
    ];
  }

  Future<void> submitDailyAttendance(String classId, List<String> presentStudents) async {
    await Future.delayed(const Duration(milliseconds: 250));
  }
}
