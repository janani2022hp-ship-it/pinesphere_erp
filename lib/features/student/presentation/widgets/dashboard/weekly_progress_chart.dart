// features/student/presentation/widgets/dashboard/weekly_progress_chart.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyProgressChart extends StatelessWidget {
  const WeeklyProgressChart({super.key});

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _values = [40, 80, 55, 90, 60, 35, 20];

  @override
  Widget build(BuildContext context) {
    final maxVal = _values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'Weekly Progress',
                  style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .25),
                  ),
                ),
                child: const Text(
                  'This week',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Bar chart ───────────────────────────────────────
          SizedBox(
            height: 155,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_values.length, (i) {
                final isMax = _values[i] == maxVal;
                final barH = (_values[i] / maxVal) * 85;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Trophy for max
                        if (isMax)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: const Text('🏆',
                                style: TextStyle(fontSize: 12)),
                          )
                        else
                          const SizedBox(height: 16),

                        // Bar
                        AnimatedContainer(
                          duration:
                              Duration(milliseconds: 350 + i * 60),
                          curve: Curves.easeOutCubic,
                          height: barH,
                          decoration: BoxDecoration(
                            color: isMax
                                ? AppColors.primary
                                : AppColors.primaryLight,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(9),
                            ),
                            boxShadow: isMax
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: .3),
                                      blurRadius: 10,
                                      offset: const Offset(0, -3),
                                    )
                                  ]
                                : [],
                          ),
                        ),

                        const SizedBox(height: 3),

                        // Day label
                        Text(
                          _days[i],
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isMax
                                ? AppColors.primary
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}