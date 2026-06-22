import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class PerformanceSummaryCard extends StatelessWidget {
  final String bestStudent;
  final String strongSubject;

  const PerformanceSummaryCard({super.key, required this.bestStudent, required this.strongSubject});

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
          Text('Performance summary', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          Text('$bestStudent is the top performer.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey)),
          const SizedBox(height: 8),
          Text('Strong subject: $strongSubject', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
