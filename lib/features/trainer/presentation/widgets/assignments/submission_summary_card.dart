import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class SubmissionSummaryCard extends StatelessWidget {
  final int submitted;
  final int reviewPending;
  final int pendingSubmission;

  const SubmissionSummaryCard({
    super.key,
    required this.submitted,
    required this.reviewPending,
    required this.pendingSubmission,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [BoxShadow(color: AppColors.primary.withAlpha((.08 * 255).round()), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📊 Quick Stats', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _SummaryItem(emoji: '✅', label: 'Submitted', value: submitted.toString(), color: Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _SummaryItem(emoji: '👀', label: 'Need review', value: reviewPending.toString(), color: Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _SummaryItem(emoji: '⏳', label: 'Pending', value: pendingSubmission.toString(), color: Colors.red)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha((.12 * 255).round()),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha((.3 * 255).round()), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
