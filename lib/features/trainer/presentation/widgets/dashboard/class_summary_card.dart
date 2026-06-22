import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../student/presentation/widgets/dashboard/stat_item_card.dart';

class ClassSummaryCard extends StatelessWidget {
  final int activeClasses;
  final int students;
  final int hoursToday;

  const ClassSummaryCard({
    super.key,
    this.activeClasses = 6,
    this.students = 148,
    this.hoursToday = 5,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 20) / 3;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: itemWidth,
              child: StatItemCard(
                emoji: '',
                imagePath: 'assets/images/trophy_icon.png',
                imageSize: 40,
                compact: true,
                title: 'Classes',
                value: '$activeClasses',
                sub: '',
                progress: 0.8,
                accentColor: AppColors.primary,
                accentBg: AppColors.primaryLight,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: StatItemCard(
                emoji: '',
                imagePath: 'assets/images/tick_icon.png',
                imageSize: 40,
                compact: true,
                title: 'Students',
                value: '$students',
                sub: '',
                progress: 0.65,
                accentColor: AppColors.primary,
                accentBg: AppColors.primaryLight,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: StatItemCard(
                emoji: '',
                imagePath: 'assets/images/clock_icon.png',
                imageSize: 40,
                compact: true,
                title: 'Today',
                value: '${hoursToday}h',
                sub: '',
                progress: 0.5,
                accentColor: AppColors.primary,
                accentBg: AppColors.primaryLight,
              ),
            ),
          ],
        );
      },
    );
  }
}

