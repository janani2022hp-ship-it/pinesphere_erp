import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/timetable_service.dart';

class DailyScheduleCard extends StatelessWidget {
  final TimetableEvent event;

  const DailyScheduleCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey)),
          const SizedBox(height: 8),
          Text(event.subject, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('${event.time} • ${event.location}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
        ],
      ),
    );
  }
}
