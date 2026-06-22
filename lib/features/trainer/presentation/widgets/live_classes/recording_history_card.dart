import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import 'recording_tile.dart';

class RecordingHistoryCard extends StatelessWidget {
  final List<RecordingHistory> recordings;

  const RecordingHistoryCard({
    super.key,
    required this.recordings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recording History',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          ...recordings.map(
            (recording) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RecordingTile(recording: recording),
            ),
          ),
        ],
      ),
    );
  }
}
