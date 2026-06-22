import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class TrainerDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onSelect;
  final VoidCallback? onLogout;

  const TrainerDrawer({
    super.key,
    this.selectedIndex = 0,
    this.onSelect,
    this.onLogout,
  });

  static const _items = [
    _DrawerItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
    _DrawerItem(Icons.groups_outlined, Icons.groups_rounded, 'My Classes'),
    _DrawerItem(
      Icons.fact_check_outlined,
      Icons.fact_check_rounded,
      'Attendance',
    ),
    _DrawerItem(
      Icons.assignment_outlined,
      Icons.assignment_rounded,
      'Assignments',
    ),
    _DrawerItem(
      Icons.analytics_outlined,
      Icons.analytics_rounded,
      'Evaluation',
    ),
    _DrawerItem(
      Icons.calendar_month_outlined,
      Icons.calendar_month_rounded,
      'Timetable',
    ),
    _DrawerItem(Icons.video_call_outlined, Icons.video_call_rounded, 'Live'),
    _DrawerItem(Icons.person_outline, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KIDLEARN',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Trainer workspace',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final active = selectedIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: GestureDetector(
                      onTap: () => onSelect?.call(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primarySubtle
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              active ? item.activeIcon : item.icon,
                              color: active
                                  ? AppColors.primary
                                  : AppColors.textGrey,
                              size: 21,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.textDark,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: GestureDetector(
                onTap: onLogout,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _DrawerItem(this.icon, this.activeIcon, this.label);
}
