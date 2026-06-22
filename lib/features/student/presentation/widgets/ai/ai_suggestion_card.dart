// features/student/presentation/widgets/ai/ai_suggestion_card.dart

import 'package:flutter/material.dart';

class AISuggestionCard extends StatelessWidget {

  final String title;

  const AISuggestionCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}