import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class OnlineSessionCard extends StatelessWidget {
  final bool isHosting;
  final String meetingLink;
  final String subject;
  final String time;
  final int studentsJoined;
  final VoidCallback onCopyLink;
  final VoidCallback onStopHosting;

  const OnlineSessionCard({
    super.key,
    required this.isHosting,
    required this.meetingLink,
    required this.subject,
    required this.time,
    required this.studentsJoined,
    required this.onCopyLink,
    required this.onStopHosting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: .8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha((.08 * 255).round()),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Host Live Class',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isHosting
                ? 'Your students can join this session now using the meeting link below.'
                : 'Choose a class and tap Host to let students attend live immediately.',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha((.18 * 255).round()),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    meetingLink,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onCopyLink,
                  child: Text(
                    'Copy',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (studentsJoined > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.group, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  '$studentsJoined students joined',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          if (isHosting)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$subject • $time',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onStopHosting,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCEBEB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Stop',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE24B4A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
