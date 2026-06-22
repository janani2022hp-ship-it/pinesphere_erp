// features/student/presentation/widgets/dashboard/pending_assignment_tile.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class PendingAssignmentTile extends StatelessWidget {
  final String title;
  final String subject;
  final String badge;
  final String emoji;
  final Color badgeBg;
  final Color badgeColor;
  final Color accentBg;
  final bool isLast;

  const PendingAssignmentTile({
    super.key,
    required this.title,
    required this.subject,
    required this.badge,
    this.emoji = '📝',
    this.badgeBg = const Color(0xFFFCEBEB),
    this.badgeColor = const Color(0xFF791F1F),
    this.accentBg = const Color(0xFFFCEBEB),
    this.isLast = false,
  });

  factory PendingAssignmentTile.danger({
    required String title,
    required String subject,
    String emoji = '⚠️',
    bool isLast = false,
  }) {
    return PendingAssignmentTile(
      title: title,
      subject: subject,
      badge: 'Due today',
      emoji: emoji,
      badgeBg: const Color(0xFFFCEBEB),
      badgeColor: const Color(0xFF791F1F),
      accentBg: const Color(0xFFFCEBEB),
      isLast: isLast,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: .8)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subject,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge,
              style: GoogleFonts.nunito(
                color: badgeColor,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: .2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}