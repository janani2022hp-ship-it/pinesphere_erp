import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/trainer_api_service.dart';

class TrainerInfoCard extends StatelessWidget {
  final TrainerProfile profile;

  const TrainerInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withAlpha((.15 * 255).round()), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(profile.name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 6),
          Text(profile.subject, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 14),
          Text(profile.experience, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 12),
          Text(profile.email, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }
}
