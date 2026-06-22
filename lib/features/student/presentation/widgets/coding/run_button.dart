// features/student/presentation/widgets/coding/run_button.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class RunButton extends StatelessWidget {

  final VoidCallback onTap;

  const RunButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 55,
      width: double.infinity,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),

        onPressed: onTap,

        child: const Text(
          "RUN CODE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}