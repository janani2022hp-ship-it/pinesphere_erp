import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/evaluation_service.dart';

class FeedbackCard extends StatelessWidget {
  final EvaluationRecord record;
  final VoidCallback onSendFeedback;
  final VoidCallback onRecommendCertificate;

  const FeedbackCard({
    super.key,
    required this.record,
    required this.onSendFeedback,
    required this.onRecommendCertificate,
  });

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
          Text(record.studentName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text(record.subject, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 10),
          Text(record.progress, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: onSendFeedback, style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary), child: const Text('Send feedback'))),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: onRecommendCertificate, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Recommend')),
            ],
          ),
        ],
      ),
    );
  }
}
