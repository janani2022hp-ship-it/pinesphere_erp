import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_page.dart';
import 'students_page.dart';
import 'admin_stub_pages.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  String _adminName = 'Admin';
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      AdminDashboardPage(),
      AdminStudentsPage(),
      AdminFeesPage(),
      AdminAttendancePage(),
      AdminNotificationsPage(),
    ];
    _loadAdminName();
  }

  Future<void> _loadAdminName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _adminName = prefs.getString('user_name') ?? 'Admin';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF6EC),
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _AdminBottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────

class _AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AdminBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor   = Color(0xFF2B70C9);
    const inactiveColor = Color(0xFFAAAAAA);
    const bg            = Color(0xFFFFFFFF);

    final items = [
      (Icons.dashboard_rounded,      Icons.dashboard_outlined,      'Dashboard'),
      (Icons.people_rounded,         Icons.people_outline_rounded,  'Students'),
      (Icons.receipt_long_rounded,   Icons.receipt_long_outlined,   'Fees'),
      (Icons.how_to_reg_rounded,     Icons.how_to_reg_outlined,     'Attendance'),
      (Icons.notifications_rounded,  Icons.notifications_outlined,  'Alerts'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: const Border(top: BorderSide(color: Color(0xFFEDD9B8), width: 1)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2B70C9).withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final (activeIcon, inactiveIcon, label) = items[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(selected ? activeIcon : inactiveIcon, color: selected ? activeColor : inactiveColor, size: 24),
                      const SizedBox(height: 3),
                      Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? activeColor : inactiveColor)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}