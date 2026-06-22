import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/timetable_service.dart';

class WeeklyScheduleCard extends StatelessWidget {
  final List<TimetableEvent> events;

  const WeeklyScheduleCard({super.key, required this.events});

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
          Text('Weekly schedule', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...events.map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(event.day, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Expanded(child: Text('${event.subject} • ${event.time}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey), overflow: TextOverflow.ellipsis)),
                    Text(event.location, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
