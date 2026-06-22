// features/student/presentation/widgets/ai/chat_input_box.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class ChatInputBox extends StatelessWidget {

  const ChatInputBox({super.key});

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [

        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Ask anything...",
              filled: true,
              fillColor: Colors.white,

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(18),

                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Container(
          height: 56,
          width: 56,

          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius:
                BorderRadius.circular(18),
          ),

          child: const Icon(
            Icons.send,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}