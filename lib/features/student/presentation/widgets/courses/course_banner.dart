// features/student/presentation/widgets/courses/course_banner.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class CourseBanner extends StatelessWidget {

  final String title;

  const CourseBanner({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFF69B22A),
          ],
        ),

        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: const [

          Text(
            "Featured Course",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),

          SizedBox(height: 14),

          Text(
            "Advanced Artificial Intelligence",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),

          SizedBox(height: 14),

          Text(
            "Master future technologies with advanced AI systems and neural architectures.",
            style: TextStyle(
              color: Colors.white,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}