import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/timetable_service.dart';
import '../widgets/timetable/daily_schedule_card.dart';
import '../widgets/timetable/leave_application_form.dart';
import '../widgets/timetable/leave_history_card.dart';
import '../widgets/timetable/weekly_schedule_card.dart';

class TimetablePage extends StatelessWidget {
  final TimetableService service = TimetableService();

  TimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight.withAlpha((.08 * 255).round()),
      appBar: AppBar(
        title: Text('Trainer Timetable', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: FutureBuilder<List<TimetableEvent>>(
        future: service.fetchWeeklySchedule(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            children: [
              WeeklyScheduleCard(events: events),
              const SizedBox(height: 18),
              DailyScheduleCard(event: events.first),
              const SizedBox(height: 18),
              LeaveApplicationForm(onSubmit: () {}),
              const SizedBox(height: 18),
              LeaveHistoryCard(records: const ['Leave approved • 2 Jun', 'Leave pending • 25 May']),
            ],
          );
        },
      ),
    );
  }
}
