// features/student/presentation/widgets/attendance/attendance_card.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class AttendanceCard extends StatelessWidget {

  final String percentage;

  const AttendanceCard({
    super.key,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFF5BA51D),
          ],
        ),

        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            "Attendance Rate",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            percentage,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 48,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Excellent consistency this semester",
            style: TextStyle(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}