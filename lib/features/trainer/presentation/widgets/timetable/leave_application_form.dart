import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class LeaveApplicationForm extends StatelessWidget {
  final VoidCallback onSubmit;

  const LeaveApplicationForm({super.key, required this.onSubmit});

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
          Text('Leave application', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 10),
          Text('Request leave for upcoming sessions with a quick form.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onSubmit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Request leave'))),
        ],
      ),
    );
  }
}
