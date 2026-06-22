// features/student/presentation/widgets/dashboard/quick_actions_grid.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: actionCard(
            title: "Submit HW",
            icon: Icons.upload_file,
            filled: true,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: actionCard(
            title: "AI Tutor",
            icon: Icons.smart_toy,
            filled: false,
          ),
        ),
      ],
    );
  }

  Widget actionCard({
    required String title,
    required IconData icon,
    required bool filled,
  }) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: filled ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.nunito(
              color: filled ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}