// features/student/presentation/widgets/assignments/submission_status_chip.dart

import 'package:flutter/material.dart';

class SubmissionStatusChip extends StatelessWidget {

  final String title;
  final Color color;

  const SubmissionStatusChip({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}