import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class UploadAssignmentCard extends StatelessWidget {
  final VoidCallback onUpload;

  const UploadAssignmentCard({super.key, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withAlpha((.2 * 255).round()), width: 2, style: BorderStyle.solid),
        boxShadow: [BoxShadow(color: AppColors.primary.withAlpha((.1 * 255).round()), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('📤', style: GoogleFonts.inter(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create new assignment', style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text('Add questions, files and due date', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('New', style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}
