// features/student/presentation/widgets/shared/student_app_bar.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class StudentAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  final String title;
  final List<Widget>? actions;
  final bool showNotification;

  const StudentAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showNotification = true,
  });

  @override
  Widget build(BuildContext context) {

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,

      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0.5),
        child: Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
      ),

      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
      ),

      actions: [
        if (showNotification)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(61);
}