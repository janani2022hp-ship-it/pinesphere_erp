// features/student/presentation/widgets/ai/quiz_card.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class QuizCard extends StatelessWidget {

  final String title;

  const QuizCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFF5FA81F),
          ],
        ),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Icon(
            Icons.quiz,
            color: Colors.white,
            size: 40,
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Practice with AI generated quizzes",
            style: TextStyle(
              color: Colors.white70,
            ),
          )
        ],
      ),
    );
  }
}