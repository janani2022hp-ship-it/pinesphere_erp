// features/student/presentation/widgets/ai/typing_indicator.dart

import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {

  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: const Row(
        mainAxisSize: MainAxisSize.min,

        children: [

          SizedBox(
            height: 10,
            width: 10,

            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),

          SizedBox(width: 12),

          Text("AI is typing...")
        ],
      ),
    );
  }
}