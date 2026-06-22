import 'package:flutter/material.dart';

import '../parent_theme.dart';
import 'attendance_page.dart';
import 'fees_page.dart';
import 'homework_page.dart';
import 'notifications_page.dart';
import 'progress_page.dart';

class ParentDashboardPage extends StatelessWidget {
  final VoidCallback onProfile;
  const ParentDashboardPage({super.key, required this.onProfile});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          ParentTopBar(
            title: 'KIDLEARN',
            subtitle: 'Child summary for Arjun',
            onProfile: onProfile,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                _ChildHeroCard(
                  onTap: () => _open(context, const ParentProgressPage()),
                ),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.event_available_rounded,
                        value: 'Present',
                        label: 'Today',
                        color: ParentTheme.green,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.payments_rounded,
                        value: '₹0',
                        label: 'Fees Due',
                        color: ParentTheme.orange,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.assignment_turned_in_rounded,
                        value: '0/0',
                        label: 'Homework',
                        color: ParentTheme.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const ParentSectionTitle(
                  title: 'Parent Actions',
                  action: 'View all',
                ),
                const SizedBox(height: 10),
                ParentInfoCard(
                  icon: Icons.calendar_month_rounded,
                  title: 'Attendance Reports',
                  subtitle: 'Track daily class presence',
                  color: ParentTheme.green,
                  tint: ParentTheme.tintGreen,
                  onTap: () => _open(context, const ParentAttendancePage()),
                ),
                const SizedBox(height: 10),
                ParentInfoCard(
                  icon: Icons.receipt_long_rounded,
                  title: 'Payments & Invoices',
                  subtitle: 'View fee status and receipts',
                  color: ParentTheme.orange,
                  tint: ParentTheme.tintOrange,
                  onTap: () => _open(context, const ParentFeesPage()),
                ),
                const SizedBox(height: 10),
                ParentInfoCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Homework Tracking',
                  subtitle: 'See pending assignments',
                  color: ParentTheme.blue,
                  tint: ParentTheme.tintBlue,
                  onTap: () => _open(context, const ParentHomeworkPage()),
                ),
                const SizedBox(height: 10),
                ParentInfoCard(
                  icon: Icons.notifications_rounded,
                  title: 'Alerts & Updates',
                  subtitle: 'Class updates and reminders',
                  color: ParentTheme.red,
                  tint: ParentTheme.tintRed,
                  onTap: () => _open(context, const ParentNotificationsPage()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _ChildHeroCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ChildHeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ParentTheme.green,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: ParentTheme.greenDark.withValues(alpha: .35),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Child Summary',
                      style: ParentTheme.body(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Arjun Kumar',
                    style: ParentTheme.title(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Learning progress starts from 0%',
                    style: ParentTheme.body(color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: const LinearProgressIndicator(
                      value: 0,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.child_care_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .34),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 10),
          Text(value, style: ParentTheme.title(color: Colors.white, size: 16)),
          Text(label, style: ParentTheme.body(color: Colors.white70, size: 11)),
        ],
      ),
    );
  }
}
