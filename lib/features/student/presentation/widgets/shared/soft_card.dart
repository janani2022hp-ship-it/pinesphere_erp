// features/student/presentation/widgets/shared/soft_card.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SoftCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16), // was 18
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}