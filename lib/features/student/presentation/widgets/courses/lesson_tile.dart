// features/student/presentation/widgets/courses/lesson_tile.dart

import 'package:flutter/material.dart';

class LessonTile extends StatelessWidget {

  final String title;

  const LessonTile({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(
      leading: const Icon(Icons.play_circle),
      title: Text(title),
      trailing:
          const Icon(Icons.arrow_forward_ios,
              size: 18),
    );
  }
}