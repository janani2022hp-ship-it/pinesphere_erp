// features/student/presentation/widgets/assignments/marks_card.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class MarksCard extends StatelessWidget {

  final String subject;
  final String marks;

  const MarksCard({
    super.key,
    required this.subject,
    required this.marks,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFF67B22B),
          ],
        ),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                subject,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Assignment Score",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          Text(
            marks,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}