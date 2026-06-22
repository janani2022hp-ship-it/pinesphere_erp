import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class ScheduleOverviewCard extends StatelessWidget {
  final List<int> classMinutes;

  const ScheduleOverviewCard({
    super.key,
    this.classMinutes = const [80, 120, 60, 150, 90, 45, 30],
  });

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final maxMinutes = classMinutes.reduce((a, b) => a > b ? a : b);
    final todayIndex = DateTime.now().weekday - DateTime.monday;

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
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'Schedule Overview',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .25),
                  ),
                ),
                child: const Text('This week'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 155,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(classMinutes.length, (index) {
                final value = classMinutes[index];
                final isMax = value == maxMinutes;
                final barH = (value / maxMinutes) * 85;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isMax)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: const Text('🏆', style: TextStyle(fontSize: 12)),
                          )
                        else
                          const SizedBox(height: 16),

                        AnimatedContainer(
                          duration: Duration(milliseconds: 350 + index * 60),
                          curve: Curves.easeOutCubic,
                          height: barH,
                          decoration: BoxDecoration(
                            color: isMax ? AppColors.primary : AppColors.primaryLight,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                            boxShadow: isMax
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: .3),
                                      blurRadius: 10,
                                      offset: const Offset(0, -3),
                                    )
                                  ]
                                : [],
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          _days[index],
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isMax ? AppColors.primary : AppColors.textLight,
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

// No local tokens — using `AppColors` to match student styling
