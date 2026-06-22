// features/student/presentation/widgets/profile/profile_header.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {

  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        const CircleAvatar(
          radius: 55,
          backgroundImage: NetworkImage(
            "https://i.pravatar.cc/300",
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          "Arjun Kumar",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 8,
          ),

          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius:
                BorderRadius.circular(30),
          ),

          child: const Text(
            "AI Research Student",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}