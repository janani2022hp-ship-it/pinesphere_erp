import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../parent_theme.dart';
import 'attendance_page.dart';
import 'communication_page.dart';
import 'dashboard_page.dart';
import 'fees_page.dart';
import 'parent_profile_page.dart';
import 'progress_page.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      ParentDashboardPage(onProfile: () => _openProfile(context)),
      const ParentAttendancePage(),
      const ParentFeesPage(),
      const ParentProgressPage(),
      const ParentCommunicationPage(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ParentTheme.bg,
        extendBody: true,
        body: pages[_current],
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .94),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: ParentTheme.separator, width: .5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .10),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_items.length, (i) {
                  final active = i == _current;
                  return GestureDetector(
                    onTap: () => setState(() => _current = i),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 62,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            active ? _items[i].$1 : _items[i].$2,
                            color: active
                                ? ParentTheme.blue
                                : ParentTheme.labelTertiary,
                            size: 21,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _items[i].$3,
                            style: ParentTheme.body(
                              color: active
                                  ? ParentTheme.blue
                                  : ParentTheme.labelTertiary,
                              size: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ParentProfilePage()),
    );
  }

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.event_available_rounded, Icons.event_available_outlined, 'Attend'),
    (Icons.payments_rounded, Icons.payments_outlined, 'Fees'),
    (Icons.insights_rounded, Icons.insights_outlined, 'Progress'),
    (Icons.chat_rounded, Icons.chat_outlined, 'Chat'),
  ];
}
