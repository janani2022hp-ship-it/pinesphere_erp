// features/student/presentation/widgets/attendance/attendance_history_tile.dart

import 'package:flutter/material.dart';

class AttendanceHistoryTile extends StatelessWidget {

  final String date;
  final bool present;

  const AttendanceHistoryTile({
    super.key,
    required this.date,
    required this.present,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [

          CircleAvatar(
            backgroundColor: present
                ? Colors.green.shade100
                : Colors.red.shade100,

            child: Icon(
              present
                  ? Icons.check
                  : Icons.close,

              color: present
                  ? Colors.green
                  : Colors.red,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              date,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            present
                ? "Present"
                : "Absent",

            style: TextStyle(
              color: present
                  ? Colors.green
                  : Colors.red,
            ),
          )
        ],
      ),
    );
  }
}