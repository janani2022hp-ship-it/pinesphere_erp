// features/student/presentation/widgets/ai/ai_chat_bubble.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class AIChatBubble extends StatelessWidget {

  final String text;
  final bool isUser;

  const AIChatBubble({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(
        margin: const EdgeInsets.only(
          bottom: 14,
        ),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : Colors.white,

          borderRadius: BorderRadius.circular(18),
        ),

        child: Text(
          text,

          style: TextStyle(
            color: isUser
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }
}