// features/student/presentation/widgets/coding/code_editor.dart

import 'package:flutter/material.dart';

class CodeEditor extends StatelessWidget {

  const CodeEditor({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 320,
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),

      child: const Text(
        "print('Hello ScholarHub')",
        style: TextStyle(
          color: Colors.greenAccent,
          fontSize: 16,
        ),
      ),
    );
  }
}