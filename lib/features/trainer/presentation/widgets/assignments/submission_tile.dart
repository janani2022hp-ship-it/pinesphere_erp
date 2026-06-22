import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class SubmissionTile extends StatelessWidget {
  final String studentName;
  final String assignmentTitle;
  final String submittedAt;
  final bool graded;

  const SubmissionTile({
    super.key,
    required this.studentName,
    required this.assignmentTitle,
    required this.submittedAt,
    required this.graded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withAlpha((.18 * 255).round()),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(studentName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(assignmentTitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          Text(graded ? 'Graded' : 'Pending', style: GoogleFonts.inter(color: graded ? Colors.green : AppColors.primary)),
        ],
      ),
    );
  }
}
