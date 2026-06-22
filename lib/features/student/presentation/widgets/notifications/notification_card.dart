// features/student/presentation/widgets/notifications/notification_card.dart

import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {

  final String title;

  const NotificationCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}