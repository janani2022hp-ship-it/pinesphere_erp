// features/student/presentation/widgets/shared/section_title.dart

import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {

  final String title;
  final String? action;

  const SectionTitle({
    super.key,
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {

    final textTheme =
        Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [

        Text(
          title,
          style: textTheme.titleLarge,
        ),

        if (action != null)
          Text(
            action!,
            style: textTheme.bodyMedium,
          ),
      ],
    );
  }
}