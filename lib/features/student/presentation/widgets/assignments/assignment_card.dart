// features/student/presentation/widgets/assignments/assignment_card.dart

import 'package:flutter/material.dart';

class AssignmentCard extends StatelessWidget {

  final String title;
  final String dueDate;

  const AssignmentCard({
    super.key,
    required this.title,
    required this.dueDate,
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

          Container(
            height: 55,
            width: 55,

            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.assignment,
              color: Colors.orange,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  dueDate,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios,
              size: 18),
        ],
      ),
    );
  }
}