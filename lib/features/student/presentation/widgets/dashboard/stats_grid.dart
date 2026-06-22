// features/student/presentation/widgets/dashboard/stats_grid.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'stat_item_card.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.75,
      children: const [
        StatItemCard(
          emoji: '📚',
          title: 'Courses\nEnrolled',
          value: '4',
          sub: '3 in progress',
          progress: .60,
          accentColor: Color(0xFF378ADD),
          accentBg: Color(0xFFE6F1FB),
        ),
        StatItemCard(
          emoji: '⏱️',
          title: 'Studied\nThis Week',
          value: '12.5h',
          sub: 'Goal: 16h',
          progress: .75,
          accentColor: AppColors.primary,
          accentBg: AppColors.primaryLight,
        ),
        StatItemCard(
          emoji: '📝',
          title: 'Assignments\nDone',
          value: '8/11',
          sub: '3 pending',
          progress: .73,
          accentColor: Color(0xFF7F77DD),
          accentBg: Color(0xFFEEEDFE),
        ),
        StatItemCard(
          emoji: '🎯',
          title: 'Attendance\nThis Month',
          value: '92%',
          sub: 'Excellent!',
          progress: .92,
          accentColor: Color(0xFF1D9E75),
          accentBg: Color(0xFFE1F5EE),
        ),
      ],
    );
  }
}
