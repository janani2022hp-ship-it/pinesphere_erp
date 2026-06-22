import 'package:flutter/material.dart';

import '../parent_theme.dart';

class ParentAttendancePage extends StatelessWidget {
  const ParentAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ParentTopBar(
              title: 'Attendance',
              subtitle: 'Daily presence reports',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  ParentInfoCard(
                    icon: Icons.check_circle_rounded,
                    title: 'Today',
                    subtitle: 'Marked present after login',
                    color: ParentTheme.green,
                    tint: ParentTheme.tintGreen,
                  ),
                  SizedBox(height: 12),
                  ParentInfoCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'This Month',
                    subtitle: '0 attended days recorded',
                    color: ParentTheme.blue,
                    tint: ParentTheme.tintBlue,
                  ),
                  SizedBox(height: 12),
                  ParentInfoCard(
                    icon: Icons.warning_rounded,
                    title: 'Absence Alerts',
                    subtitle: 'No absence alerts',
                    color: ParentTheme.orange,
                    tint: ParentTheme.tintOrange,
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
