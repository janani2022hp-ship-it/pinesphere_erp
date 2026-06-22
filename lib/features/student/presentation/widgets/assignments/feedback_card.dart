// features/student/presentation/widgets/assignments/feedback_card.dart

import 'package:flutter/material.dart';

class FeedbackCard extends StatelessWidget {

  final String title;
  final String feedback;

  const FeedbackCard({
    super.key,
    required this.title,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            feedback,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.6,
            ),
          )
        ],
      ),
    );
  }
}