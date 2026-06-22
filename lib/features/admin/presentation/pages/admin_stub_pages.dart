import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Fees Page ────────────────────────────────────────────────────────────────

class AdminFeesPage extends StatelessWidget {
  const AdminFeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Fees', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
            Text('Fee collection & dues', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF888888))),
            const SizedBox(height: 32),
            const Expanded(child: Center(child: _ComingSoon(icon: Icons.receipt_long_rounded, label: 'Fee management coming soon'))),
          ]),
        ),
      ),
    );
  }
}

// ─── Attendance Page ──────────────────────────────────────────────────────────

class AdminAttendancePage extends StatelessWidget {
  const AdminAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Attendance', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
            Text('Daily attendance records', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF888888))),
            const SizedBox(height: 32),
            const Expanded(child: Center(child: _ComingSoon(icon: Icons.how_to_reg_rounded, label: 'Attendance management coming soon'))),
          ]),
        ),
      ),
    );
  }
}

// ─── Notifications Page ───────────────────────────────────────────────────────

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Notifications', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
            Text('Alerts & announcements', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF888888))),
            const SizedBox(height: 32),
            const Expanded(child: Center(child: _ComingSoon(icon: Icons.notifications_rounded, label: 'Notifications coming soon'))),
          ]),
        ),
      ),
    );
  }
}

// ─── Shared coming-soon widget ────────────────────────────────────────────────

class _ComingSoon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ComingSoon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 56, color: const Color(0xFFDDDDDD)),
      const SizedBox(height: 16),
      Text(label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFAAAAAA), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
    ]);
  }
}