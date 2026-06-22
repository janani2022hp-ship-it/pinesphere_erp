// features/student/presentation/pages/attendance_page.dart

import 'package:flutter/material.dart';


class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: 10,

        itemBuilder: (_, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                Text(
                  "Day ${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text(
                  "Present",
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}