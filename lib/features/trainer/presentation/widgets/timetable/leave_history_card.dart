import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class LeaveHistoryCard extends StatelessWidget {
  final List<String> records;

  const LeaveHistoryCard({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leave history', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...records.map((record) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(record, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey)),
              )),
        ],
      ),
    );
  }
}
