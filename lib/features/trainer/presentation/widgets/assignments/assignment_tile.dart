import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/assignments_service.dart';

class AssignmentTile extends StatelessWidget {
  final TrainerAssignment assignment;
  final VoidCallback? onGrade;
  final VoidCallback? onPublish;

  const AssignmentTile({
    super.key,
    required this.assignment,
    required this.onGrade,
    required this.onPublish,
  });

  Color get _statusColor {
    switch (assignment.status) {
      case AssignmentStatus.graded:
        return Colors.green;
      case AssignmentStatus.submitted:
        return Colors.orange;
      case AssignmentStatus.late:
        return Colors.redAccent;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(assignment.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor.withAlpha((.14 * 255).round()),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(assignment.status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${assignment.subject} • ${assignment.dueDate}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
          if (assignment.status == AssignmentStatus.graded && assignment.grade != null) ...[
            const SizedBox(height: 8),
            Text('Grade: ${assignment.grade}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            if (assignment.feedback != null) ...[
              const SizedBox(height: 4),
              Text(assignment.feedback!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
            ],
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('${assignment.submissions} submissions', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onGrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onGrade != null ? AppColors.primary : AppColors.border,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(assignment.status == AssignmentStatus.submitted ? 'Grade' : 'View'),
                ),
              ),
              if (onPublish != null) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onPublish,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: const Text('Publish'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
