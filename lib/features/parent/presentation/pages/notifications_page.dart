import 'package:flutter/material.dart';

import '../parent_theme.dart';

class ParentNotificationsPage extends StatelessWidget {
  const ParentNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ParentTopBar(
              title: 'Notifications',
              subtitle: 'Alerts and updates',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  ParentInfoCard(
                    icon: Icons.notifications_rounded,
                    title: 'Class Alerts',
                    subtitle: 'No new class alerts',
                    color: ParentTheme.blue,
                    tint: ParentTheme.tintBlue,
                  ),
                  SizedBox(height: 12),
                  ParentInfoCard(
                    icon: Icons.payments_rounded,
                    title: 'Fee Reminders',
                    subtitle: 'No payment reminders',
                    color: ParentTheme.orange,
                    tint: ParentTheme.tintOrange,
                  ),
                  SizedBox(height: 12),
                  ParentInfoCard(
                    icon: Icons.assignment_late_rounded,
                    title: 'Homework Alerts',
                    subtitle: 'No pending homework alerts',
                    color: ParentTheme.red,
                    tint: ParentTheme.tintRed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
