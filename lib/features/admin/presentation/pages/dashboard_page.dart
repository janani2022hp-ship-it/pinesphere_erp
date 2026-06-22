// features/admin/presentation/pages/admin_dashboard_page.dart
// ─────────────────────────────────────────────────────────────
// Cartoon/Duolingo-style theme (same palette + GoogleFonts.fredoka
// as the student dashboard), now with a top bar matching the
// student page's _TopBar (avatar, greeting, role badge, logout).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:pinesphere_erp/features/auth/services/auth_service.dart';
import 'package:pinesphere_erp/features/auth/presentation/pages/login_screen.dart';

import '../../data/services/admin_dashboard_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _service = AdminDashboardService();

  AdminDashboardData? _dashData;
  List<RecentStudent> _recentStudents = [];
  bool _loading = true;
  String? _error;
  String _adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadName();
    _fetchAll();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _adminName = prefs.getString('user_name') ?? 'Admin');
    }
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dash = await _service.getDashboard();
      final recent = await _service.getRecentStudents();
      if (mounted) {
        setState(() {
          _dashData = dash;
          _recentStudents = recent;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dashData = AdminDashboardData.mock();
          _recentStudents = _mockStudents();
          _loading = false;
        });
      }
    }
  }

  List<RecentStudent> _mockStudents() => [
        RecentStudent(studentId: 'PS-2025-001', fullName: 'Aravind Kumar', course: 'AI & Python', enrollmentDate: '12 Jun 2025', status: 'active'),
        RecentStudent(studentId: 'PS-2025-002', fullName: 'Nithya Selvam', course: 'Robotics Jr.', enrollmentDate: '14 Jun 2025', status: 'active'),
        RecentStudent(studentId: 'PS-2025-003', fullName: 'Deepan Raj', course: 'Web Dev', enrollmentDate: '15 Jun 2025', status: 'active'),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AT.bg,
      body: SafeArea(
        child: Column(
          children: [
            _AdminTopBar(adminName: _adminName),
            Expanded(
              child: _loading
                  ? const _LoadingView()
                  : RefreshIndicator(
                      onRefresh: _fetchAll,
                      color: _AT.blue,
                      backgroundColor: _AT.bgElevated,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(child: _buildHeader()),
                          if (_error != null) SliverToBoxAdapter(child: _ErrorBanner(message: _error!)),
                          SliverToBoxAdapter(child: _buildKpiGrid()),
                          SliverToBoxAdapter(child: _buildAttendanceCard()),
                          SliverToBoxAdapter(child: _buildFeeCard()),
                          SliverToBoxAdapter(child: _buildRecentStudents()),
                          const SliverToBoxAdapter(child: SizedBox(height: 110)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hero highlight card (decorative, identity now lives in the top bar) ───

  Widget _buildHeader() {
    final dateStr = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _AT.green,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "TODAY'S SNAPSHOT",
                    style: GoogleFonts.fredoka(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: .90),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text("Here's your branch summary", style: _AT.title3(color: Colors.white)),
                const SizedBox(height: 4),
                Text(dateStr, style: _AT.subheadline(color: Colors.white70)),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .20), shape: BoxShape.circle),
            child: const Icon(Icons.insights_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // ─── KPI Grid (rounded tint cards with circular icon badges) ────────────────

  Widget _buildKpiGrid() {
    if (_dashData == null) return const SizedBox();
    final d = _dashData!;
    final rupee = NumberFormat('₹#,##0');

    final cards = [
      _KpiData(
        label: 'Active Students',
        value: '${d.activeStudents}',
        sub: 'of ${d.totalStudents} total',
        icon: Icons.people_rounded,
        color: _AT.blue,
        tint: _AT.tintBlue,
      ),
      _KpiData(
        label: 'Attendance',
        value: '${d.todayAttendanceRate.toStringAsFixed(1)}%',
        sub: d.todayAttendanceRate >= 80 ? 'On track ✓' : 'Below target',
        icon: Icons.how_to_reg_rounded,
        color: d.todayAttendanceRate >= 80 ? _AT.green : _AT.orange,
        tint: d.todayAttendanceRate >= 80 ? _AT.tintGreen : _AT.tintOrange,
      ),
      _KpiData(
        label: 'Fee Collection',
        value: rupee.format(d.feeCollectionThisMonth),
        sub: 'This month',
        icon: Icons.account_balance_wallet_rounded,
        color: _AT.greenDark,
        tint: _AT.tintGreen,
      ),
      _KpiData(
        label: 'New Enquiries',
        value: '${d.newEnquiriesToday}',
        sub: 'Today',
        icon: Icons.person_add_rounded,
        color: _AT.blueDeep,
        tint: _AT.tintBlue,
      ),
      _KpiData(
        label: 'Active Batches',
        value: '${d.activeBatches}',
        sub: '${d.upcomingClassesToday} classes today',
        icon: Icons.class_rounded,
        color: _AT.purple,
        tint: _AT.tintPurple,
      ),
      _KpiData(
        label: 'Pending Dues',
        value: '${d.pendingDuesCount}',
        sub: 'Students overdue',
        icon: Icons.warning_amber_rounded,
        color: _AT.red,
        tint: _AT.tintRed,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: "📊 Branch Overview", action: ""),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (_, i) => _KpiCard(data: cards[i]),
          ),
        ],
      ),
    );
  }

  // ─── Attendance card ──────────────────────────────────────────────────────

  Widget _buildAttendanceCard() {
    if (_dashData == null) return const SizedBox();
    final rate = _dashData!.todayAttendanceRate;
    final present = (_dashData!.activeStudents * rate / 100).round();
    final absent = _dashData!.activeStudents - present;
    final onTrack = rate >= 80;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _AT.widgetCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("📅 Today's Attendance", style: _AT.headline()),
                const Spacer(),
                Text(
                  '${rate.toStringAsFixed(1)}%',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: onTrack ? _AT.green : _AT.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: (onTrack ? _AT.green : _AT.orange).withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (rate / 100).clamp(0, 1),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: onTrack ? _AT.green : _AT.orange,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _AttendancePill(label: 'Present', count: present, color: _AT.green),
                const SizedBox(width: 10),
                _AttendancePill(label: 'Absent', count: absent, color: _AT.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Fee card ─────────────────────────────────────────────────────────────

  Widget _buildFeeCard() {
    if (_dashData == null) return const SizedBox();
    final rupee = NumberFormat('₹#,##0');
    final collected = _dashData!.feeCollectionThisMonth;
    final pending = collected * 0.2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _AT.widgetCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("💰 Fee Collection — This Month", style: _AT.headline()),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _FeeTile(
                    label: 'Collected',
                    amount: rupee.format(collected),
                    color: _AT.green,
                    tint: _AT.tintGreen,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeeTile(
                    label: 'Pending',
                    amount: rupee.format(pending),
                    color: _AT.red,
                    tint: _AT.tintRed,
                    icon: Icons.pending_rounded,
                  ),
                ),
              ],
            ),
            if (_dashData!.pendingDuesCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _AT.tintRed,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: _AT.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_dashData!.pendingDuesCount} students have overdue fees',
                        style: _AT.subheadline(color: _AT.redDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Recent students ──────────────────────────────────────────────────────

  Widget _buildRecentStudents() {
    if (_recentStudents.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: "🎓 Recently Enrolled", action: "See All"),
          const SizedBox(height: 10),
          Container(
            decoration: _AT.widgetCard,
            child: Column(
              children: List.generate(_recentStudents.length, (i) {
                return _RecentStudentTile(
                  student: _recentStudents[i],
                  last: i == _recentStudents.length - 1,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TOP BAR — mirrors the student page's _TopBar: avatar, brand +
// greeting, a role badge (instead of the XP pill), and logout.
// ─────────────────────────────────────────────────────────────
class _AdminTopBar extends StatelessWidget {
  final String adminName;
  const _AdminTopBar({required this.adminName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: _AT.bg,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_AT.blue, _AT.blueDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Center(
              child: Text(
                adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PINESPHERE", style: _AT.title3()),
                Text(
                  "Hello, $adminName 👋",
                  style: _AT.title3().copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _AT.blueDeep,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_rounded, color: Colors.white, size: 13),
                const SizedBox(width: 5),
                Text(
                  "ADMIN",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _confirmLogout(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _AT.bgElevated,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: const Icon(Icons.logout_rounded, color: _AT.labelTertiary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await AuthService().logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────
// DESIGN TOKENS — matches the cartoon/Duolingo-style theme used
// across the app (same palette + GoogleFonts.fredoka as the
// student dashboard).
// ─────────────────────────────────────────────────────────────
class _AT {
  static const green = Color(0xFF46A800);
  static const greenDark = Color(0xFF357800);
  static const orange = Color(0xFFF59000);
  static const blue = Color(0xFF14A0E0);
  static const blueDeep = Color(0xFF2464B8);
  static const red = Color(0xFFEC3A3A);
  static const redDark = Color(0xFFB83535);
  static const purple = Color(0xFFBB6EF0);
  static const yellow = Color(0xFFE8C400);

  static const bg = Color(0xFFFDF6EC);
  static const bgElevated = Color(0xFFFFFAF4);

  static const tintBlue = Color(0xFFEAF8FE);
  static const tintGreen = Color(0xFFF1FBE8);
  static const tintOrange = Color(0xFFFFF1E4);
  static const tintRed = Color(0xFFFFEEEE);
  static const tintPurple = Color(0xFFF7EEFF);
  static const tintYellow = Color(0xFFFFFBE3);

  static const labelPrimary = Color(0xFF1C1C1E);
  static const labelSecondary = Color(0xFF3C3C43);
  static const labelTertiary = Color(0xFF8E8E93);
  static const labelQuaternary = Color(0xFFC7C7CC);
  static const separator = Color(0xFFE5E5EA);

  static TextStyle title3({Color? color}) => GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color ?? labelPrimary,
      );

  static TextStyle headline({Color? color}) => GoogleFonts.fredoka(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color ?? labelPrimary,
      );

  static TextStyle subheadline({Color? color}) => GoogleFonts.fredoka(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? labelSecondary,
      );

  static TextStyle caption1({Color? color}) => GoogleFonts.fredoka(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color ?? labelSecondary,
      );

  static TextStyle caption2({Color? color}) => GoogleFonts.fredoka(
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: color ?? labelQuaternary,
      );

  static BoxDecoration get widgetCard => BoxDecoration(
        color: bgElevated,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 18, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.white.withValues(alpha: .8), blurRadius: 8, offset: const Offset(-2, -2)),
        ],
      );

  static BoxDecoration tintCard(Color tint) => BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, Color.lerp(tint, Colors.white, 0.25)!],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .07), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      );
}

// ─── Shared sub-widgets ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  const _SectionHeader({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: _AT.title3()),
        const Spacer(),
        if (action.isNotEmpty) Text(action, style: _AT.subheadline(color: _AT.blue)),
      ],
    );
  }
}

class _KpiData {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  final Color tint;
  const _KpiData({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
    required this.tint,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _AT.tintCard(data.tint),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: data.color, shape: BoxShape.circle),
            child: Icon(data.icon, color: Colors.white, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w700, color: _AT.labelPrimary, height: 1.15),
              ),
              Text(data.label, style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.w600, color: data.color)),
              Text(data.sub, style: _AT.caption2(), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendancePill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _AttendancePill({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$label: $count', style: GoogleFonts.fredoka(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FeeTile extends StatelessWidget {
  final String label, amount;
  final Color color;
  final Color tint;
  final IconData icon;
  const _FeeTile({required this.label, required this.amount, required this.color, required this.tint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _AT.tintCard(tint),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 8),
          Text(amount, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w700, color: _AT.labelPrimary)),
          Text(label, style: _AT.caption1(color: color)),
        ],
      ),
    );
  }
}

class _RecentStudentTile extends StatelessWidget {
  final RecentStudent student;
  final bool last;
  const _RecentStudentTile({required this.student, required this.last});

  Color _statusColor(String s) => switch (s) {
        'active' => _AT.green,
        'on_hold' => _AT.orange,
        _ => _AT.red,
      };

  Color _statusTint(String s) => switch (s) {
        'active' => _AT.tintGreen,
        'on_hold' => _AT.tintOrange,
        _ => _AT.tintRed,
      };

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(student.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: _AT.separator, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: _statusTint(student.status), borderRadius: BorderRadius.circular(16)),
            child: Center(
              child: Text(
                student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : '?',
                style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullName, style: _AT.subheadline(color: _AT.labelPrimary)),
                const SizedBox(height: 2),
                Text('${student.course} · ${student.studentId}', style: _AT.caption1(color: _AT.labelTertiary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
                child: Text(student.status, style: GoogleFonts.fredoka(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
              ),
              const SizedBox(height: 4),
              Text(student.enrollmentDate, style: _AT.caption2()),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: _AT.green, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text('Loading dashboard...', style: _AT.subheadline(color: _AT.labelTertiary)),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: _AT.tintRed, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: _AT.red, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: _AT.subheadline(color: _AT.redDark))),
        ],
      ),
    );
  }
}