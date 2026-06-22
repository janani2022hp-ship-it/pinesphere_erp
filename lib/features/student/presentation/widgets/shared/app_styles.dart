// features/student/presentation/widgets/shared/app_styles.dart

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class AppStyles {

  static BoxDecoration cardDecoration =
      BoxDecoration(

    color: Colors.white,

    borderRadius:
        BorderRadius.circular(22),

    border: Border.all(
      color: AppColors.border,
      width: 0.5,
    ),
  );

  static BoxDecoration primaryCard =
      BoxDecoration(

    color: AppColors.primary,

    borderRadius:
        BorderRadius.circular(22),
  );

  static BoxDecoration subtleCard =
      BoxDecoration(

    color: AppColors.primarySubtle,

    borderRadius:
        BorderRadius.circular(22),
  );
}