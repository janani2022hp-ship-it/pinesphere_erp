import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class ActiveClassCard extends StatelessWidget {
  final int classCount;
  final String nextSession;

  const ActiveClassCard({super.key, required this.classCount, required this.nextSession});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withAlpha((.15 * 255).round()), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active classes', style: GoogleFonts.inter(fontSize: 13, color: AppColors.white)),
          const SizedBox(height: 8),
          Text('$classCount classes', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.white)),
          const SizedBox(height: 12),
          Text('Next session', style: GoogleFonts.inter(fontSize: 12, color: AppColors.white.withAlpha((.85 * 255).round()))),
          const SizedBox(height: 4),
          Text(nextSession, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white)),
        ],
      ),
    );
  }
}
