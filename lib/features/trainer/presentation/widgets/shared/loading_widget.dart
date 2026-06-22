import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class TrainerLoadingWidget extends StatelessWidget {
  final String? message;

  const TrainerLoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class LoadingWidget extends TrainerLoadingWidget {
  const LoadingWidget({super.key, super.message});
}
