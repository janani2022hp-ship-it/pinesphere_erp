import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAttendancePage extends StatefulWidget {
  const AdminAttendancePage({super.key});

  @override
  State<AdminAttendancePage> createState() => _AdminAttendancePageState();
}

class _AdminAttendancePageState extends State<AdminAttendancePage> {
  final List<AttendanceRecord> _records = [
    AttendanceRecord(
      studentName: 'Aravind Kumar',
      course: 'Flutter Development',
      batch: 'Batch A',
      attendancePercent: 92,
      totalClasses: 50,
      attended: 46,
    ),
    AttendanceRecord(
      studentName: 'Nithya Selvam',
      course: 'Web Development',
      batch: 'Batch B',
      attendancePercent: 88,
      totalClasses: 50,
      attended: 44,
    ),
    AttendanceRecord(
      studentName: 'Deepan Raj',
      course: 'Python Programming',
      batch: 'Batch C',
      attendancePercent: 65,
      totalClasses: 50,
      attended: 32,
    ),
    AttendanceRecord(
      studentName: 'Priya Sharma',
      course: 'Data Science',
      batch: 'Batch A',
      attendancePercent: 95,
      totalClasses: 50,
      attended: 47,
    ),
    AttendanceRecord(
      studentName: 'Rajesh Kumar',
      course: 'Flutter Development',
      batch: 'Batch B',
      attendancePercent: 58,
      totalClasses: 50,
      attended: 29,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final avgAttendance = (_records.fold(0, (sum, r) => sum + r.attendancePercent) / _records.length).toStringAsFixed(1);
    final lowAttendance = _records.where((r) => r.attendancePercent < 75).length;

    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: _T.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Attendance Tracking', style: _T.headline().copyWith(color: _T.labelPrimary)),
      ),
      body: Column(
        children: [
          // Summary Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Average',
                    value: '$avgAttendance%',
                    color: _T.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Low Attendance',
                    value: '$lowAttendance',
                    color: _T.red,
                  ),
                ),
              ],
            ),
          ),

          // Attendance List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return _AttendanceCard(record: record);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  const _AttendanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    Color progressColor = record.attendancePercent >= 80
        ? _T.green
        : record.attendancePercent >= 75
            ? _T.orange
            : _T.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _T.widgetCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.studentName,
                        style: _T.headline().copyWith(color: _T.labelPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${record.course} · ${record.batch}',
                        style: _T.caption1().copyWith(color: _T.labelSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${record.attendancePercent}%',
                    style: _T.subheadline().copyWith(color: progressColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: record.attendancePercent / 100,
                minHeight: 6,
                backgroundColor: _T.bgElevated,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${record.attended}/${record.totalClasses} classes attended',
              style: _T.caption1().copyWith(color: _T.labelTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _T.caption1().copyWith(color: color)),
          const SizedBox(height: 8),
          Text(
            value,
            style: _T.headline().copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class AttendanceRecord {
  final String studentName;
  final String course;
  final String batch;
  final int attendancePercent;
  final int totalClasses;
  final int attended;

  AttendanceRecord({
    required this.studentName,
    required this.course,
    required this.batch,
    required this.attendancePercent,
    required this.totalClasses,
    required this.attended,
  });
}

// Design Tokens
class _T {
  static const green = Color(0xFF46A800);
  static const orange = Color(0xFFF59000);
  static const blue = Color(0xFF14A0E0);
  static const red = Color(0xFFEC3A3A);

  static const bg = Color(0xFFFdf6EC);
  static const bgElevated = Color(0xFFFFFAF4);

  static const labelPrimary = Color(0xFF1C1C1E);
  static const labelSecondary = Color(0xFF3C3C43);
  static const labelTertiary = Color(0xFF8E8E93);

  static TextStyle headline() => GoogleFonts.fredoka(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
      );

  static TextStyle subheadline() => GoogleFonts.fredoka(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: labelPrimary,
      );

  static TextStyle caption1() => GoogleFonts.fredoka(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: labelPrimary,
      );

  static BoxDecoration get widgetCard => BoxDecoration(
        color: bgElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
}
