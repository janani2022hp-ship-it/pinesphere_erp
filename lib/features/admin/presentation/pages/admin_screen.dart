import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/services/auth_service.dart';
import '../../../auth/presentation/pages/login_screen.dart';

class AdminScreen extends StatelessWidget {
  AdminScreen({super.key});

  final _authService = AuthService();

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin Panel', style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C1E))),
                      Text('PineSphere Management', style: GoogleFonts.fredoka(fontSize: 14, color: const Color(0xFF8E8E93))),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _logout(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Logout', style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFCB3E3E))),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Menu cards
              _AdminCard(icon: Icons.people_outline_rounded,   label: 'Manage Users',    color: const Color(0xFF1CB0F6), onTap: () {}),
              const SizedBox(height: 14),
              _AdminCard(icon: Icons.school_outlined,          label: 'Manage Courses',  color: const Color(0xFF58CC02), onTap: () {}),
              const SizedBox(height: 14),
              _AdminCard(icon: Icons.assignment_outlined,      label: 'Assignments',     color: const Color(0xFFFF9600), onTap: () {}),
              const SizedBox(height: 14),
              _AdminCard(icon: Icons.bar_chart_rounded,        label: 'Reports',         color: const Color(0xFFCE82FF), onTap: () {}),
              const SizedBox(height: 14),
              _AdminCard(icon: Icons.settings_outlined,        label: 'Settings',        color: const Color(0xFF8E8E93), onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF1C1C1E))),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }
}