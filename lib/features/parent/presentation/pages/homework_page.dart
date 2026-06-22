import 'package:flutter/material.dart';

import '../parent_theme.dart';

class ParentHomeworkPage extends StatelessWidget {
  const ParentHomeworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ParentTopBar(
              title: 'Homework',
              subtitle: 'Assignment tracking',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  ParentInfoCard(
                    icon: Icons.assignment_rounded,
                    title: 'Pending Homework',
                    subtitle: '0 tasks pending',
                    color: ParentTheme.orange,
                    tint: ParentTheme.tintOrange,
                  ),
                  SizedBox(height: 12),
                  ParentInfoCard(
                    icon: Icons.cloud_upload_rounded,
                    title: 'Submitted Work',
                    subtitle: 'No submissions yet',
                    color: ParentTheme.green,
                    tint: ParentTheme.tintGreen,
                  ),
                  SizedBox(height: 12),
                  ParentInfoCard(
                    icon: Icons.rate_review_rounded,
                    title: 'Trainer Feedback',
                    subtitle: 'Feedback appears after evaluation',
                    color: ParentTheme.blue,
                    tint: ParentTheme.tintBlue,
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
