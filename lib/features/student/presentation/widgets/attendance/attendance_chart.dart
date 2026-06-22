// features/student/presentation/widgets/attendance/attendance_chart.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class AttendanceChart extends StatelessWidget {

  const AttendanceChart({super.key});

  @override
  Widget build(BuildContext context) {

    final values = [90, 70, 85, 100, 60, 95];

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      crossAxisAlignment:
          CrossAxisAlignment.end,

      children: values.map((e) {

        return Container(
          width: 30,
          height: e.toDouble(),

          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius:
                BorderRadius.circular(10),
          ),
        );
      }).toList(),
    );
  }
}