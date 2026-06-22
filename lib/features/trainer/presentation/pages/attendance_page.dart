import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/attendance_service.dart';
import '../widgets/attendance/attendance_history_table.dart';
import '../widgets/attendance/attendance_marking_card.dart';
import '../widgets/attendance/attendance_stats_card.dart';

class AttendancePage extends StatelessWidget {
  final AttendanceService service = AttendanceService();

  AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight.withAlpha((.10 * 255).round()),
      appBar: AppBar(
        title: Text('Attendance Control', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: FutureBuilder<List<AttendanceRecord>>(
        future: service.fetchAttendanceHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            children: [
              AttendanceStatsCard(totalStudents: 24, presentToday: 22, absentToday: 2),
              const SizedBox(height: 16),
              AttendanceMarkingCard(onSubmit: () {}, subject: 'Mathematics • 9:30 AM'),
              const SizedBox(height: 20),
              AttendanceHistoryTable(records: history),
            ],
          );
        },
      ),
    );
  }
}
