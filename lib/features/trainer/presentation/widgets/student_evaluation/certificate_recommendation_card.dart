import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/evaluation_service.dart';

class CertificateRecommendationCard extends StatelessWidget {
  final EvaluationRecord record;
  final VoidCallback onRecommend;

  const CertificateRecommendationCard({super.key, required this.record, required this.onRecommend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recommend certificate', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Text(record.recommendation, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          ElevatedButton(onPressed: onRecommend, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Recommend')),
        ],
      ),
    );
  }
}
