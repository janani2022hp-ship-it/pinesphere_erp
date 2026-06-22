import 'package:flutter/material.dart';

import '../parent_theme.dart';

class ParentProfilePage extends StatelessWidget {
  const ParentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ParentTopBar(
              title: 'Parent Profile',
              subtitle: 'Personal details',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: ParentTheme.cardDecoration(),
                    child: Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: ParentTheme.tintBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: ParentTheme.blue,
                            size: 38,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Parent User', style: ParentTheme.title()),
                              Text(
                                'parent@test.com',
                                style: ParentTheme.body(),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Child: Arjun Kumar',
                                style: ParentTheme.body(
                                  color: ParentTheme.greenDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ParentInfoCard(
                    icon: Icons.badge_rounded,
                    title: 'Personal Details',
                    subtitle: 'Update phone, email, relation',
                    color: ParentTheme.blue,
                    tint: ParentTheme.tintBlue,
                  ),
                  SizedBox(height: 12),
                  const ParentInfoCard(
                    icon: Icons.lock_rounded,
                    title: 'Security',
                    subtitle: 'Password and account access',
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
