// features/student/presentation/widgets/assignments/upload_panel.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class UploadPanel extends StatelessWidget {

  const UploadPanel({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),

      child: const Column(
        children: [

          Icon(
            Icons.cloud_upload,
            size: 60,
            color: AppColors.primary,
          ),

          SizedBox(height: 16),

          Text(
            "Upload Assignment",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "Drag and drop your files here",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}