// features/student/presentation/widgets/certificates/badge_card.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class BadgeCard extends StatelessWidget {

  final String title;

  const BadgeCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 150,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          Container(
            height: 70,
            width: 70,

            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.workspace_premium,
              color: AppColors.primary,
              size: 40,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}