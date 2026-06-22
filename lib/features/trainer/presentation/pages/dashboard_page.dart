import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/dashboard/assignment_summary_card.dart';
import '../widgets/dashboard/attendance_summary_card.dart';
import '../widgets/dashboard/class_summary_card.dart';
import '../widgets/dashboard/schedule_overview_card.dart';
import '../widgets/dashboard/upcoming_class_card.dart';

class TrainerDashboardPage extends StatelessWidget {
  final VoidCallback? onOpenProfile;
  final VoidCallback? onLogout;

  const TrainerDashboardPage({super.key, this.onOpenProfile, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        color: AppColors.background,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TrainerTopBar(onOpenProfile: onOpenProfile, onLogout: onLogout),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  children: [
                    const _TrainerHeroCard(),
                    const SizedBox(height: 14),
                    const ClassSummaryCard(),
                    const SizedBox(height: 14),
                    const ScheduleOverviewCard(),
                    const SizedBox(height: 14),
                    const AttendanceSummaryCard(),
                    const SizedBox(height: 14),
                    const AssignmentSummaryCard(),
                    const SizedBox(height: 14),
                    const UpcomingClassCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final VoidCallback? onOpenProfile;
  final VoidCallback? onLogout;

  const DashboardPage({super.key, this.onOpenProfile, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return TrainerDashboardPage(onOpenProfile: onOpenProfile, onLogout: onLogout);
  }
}

// ─────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────
class _TrainerTopBar extends StatelessWidget {
  final VoidCallback? onOpenProfile;
  final VoidCallback? onLogout;

  const _TrainerTopBar({this.onOpenProfile, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: _T.bg,
      child: Row(
        children: [
          // Avatar — circle with border like student
          GestureDetector(
            onTap: onOpenProfile,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBBE5FF), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/trainer_profile.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: _T.blue,
                    child: const Center(
                      child: Text(
                        'T',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onOpenProfile,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KIDLEARN', style: _T.title3()),
                  Text(
                    'Hello, Meera 👋',
                    style: _T.title3().copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          // Trainer badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _T.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(
                  'Trainer',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: -.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Notifications
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const _TrainerNotificationSheet(),
              );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _T.bgElevated,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_rounded,
                color: _T.labelTertiary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Logout
          GestureDetector(
            onTap: onLogout,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _T.bgElevated,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEC3A3A),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HERO CARD
// ─────────────────────────────────────────────────────────────
class _TrainerHeroCard extends StatelessWidget {
  const _TrainerHeroCard();

  @override
  Widget build(BuildContext context) {
    const completion = .76;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _T.green,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Teaching Progress',
                      style: GoogleFonts.fredoka(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: .90),
                        letterSpacing: .2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Python Fundamentals',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _T.title3(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '76% of today\'s plan completed',
                    style: _T.subheadline(color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .25),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: completion,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'Open class',
                        style: _T.caption1(color: Colors.white70),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white54,
                        size: 11,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Illustration — trainer at board image
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 160,
              child: Align(
                alignment: Alignment.bottomRight,
                child: OverflowBox(
                  maxHeight: 230,
                  maxWidth: 220,
                  alignment: Alignment.bottomRight,
                  child: Transform.translate(
                    offset: const Offset(18, 20),
                    child: Image.asset(
                      'assets/images/student_reading.png',
                      height: 190,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const _TrainerBoardIllustration(size: 130),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FALLBACK BOARD ILLUSTRATION (kept from original)
// ─────────────────────────────────────────────────────────────
class _TrainerBoardIllustration extends StatelessWidget {
  final double size;

  const _TrainerBoardIllustration({this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _TrainerBoardPainter()),
    );
  }
}

class _TrainerBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * .50, h * .89),
        width: w * .72,
        height: h * .12,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: .14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * .12, h * .16, w * .76, h * .54),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      boardRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [_T.blue, _T.blueDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    canvas.drawRRect(
      boardRect,
      Paint()
        ..color = Colors.white.withValues(alpha: .24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final line = Paint()
      ..color = Colors.white.withValues(alpha: .62)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * .24, h * .31), Offset(w * .68, h * .31), line);
    canvas.drawLine(Offset(w * .24, h * .43), Offset(w * .76, h * .43), line);
    canvas.drawLine(Offset(w * .24, h * .55), Offset(w * .58, h * .55), line);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .43, h * .70, w * .14, h * .09),
        const Radius.circular(3),
      ),
      Paint()..color = _T.orange,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .27, h * .78, w * .46, h * .08),
        const Radius.circular(4),
      ),
      Paint()..color = _T.yellow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
// NOTIFICATION SHEET
// ─────────────────────────────────────────────────────────────
class _TrainerNotificationSheet extends StatelessWidget {
  const _TrainerNotificationSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        decoration: BoxDecoration(
          color: _T.bgElevated,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: _T.separator,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('Notifications', style: _T.title3()),
                ),
                Text(
                  'Mark all read',
                  style: _T.subheadline(color: _T.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: _T.widgetCard,
              child: Column(
                children: const [
                  _NotificationTile(
                    icon: Icons.assignment_turned_in_rounded,
                    title: '18 submissions ready for grading',
                    subtitle: 'Advanced ML batch',
                    time: '8 min ago',
                    bg: _T.tintOrange,
                    color: _T.orange,
                  ),
                  _NotificationTile(
                    icon: Icons.groups_rounded,
                    title: 'Python fundamentals starts soon',
                    subtitle: 'Lab 2 · 10:30 AM',
                    time: '24 min ago',
                    bg: _T.tintBlue,
                    color: _T.blue,
                  ),
                  _NotificationTile(
                    icon: Icons.fact_check_rounded,
                    title: 'Attendance report submitted',
                    subtitle: 'Grade 7 · Batch C',
                    time: '1 hr ago',
                    bg: _T.tintGreen,
                    color: _T.green,
                    showDivider: false,
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

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color bg;
  final Color color;
  final bool showDivider;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.bg,
    required this.color,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: _T.separator, width: .5),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _T.subheadline(color: _T.labelPrimary),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: _T.caption1()),
                const SizedBox(height: 2),
                Text(time, style: _T.caption2(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DESIGN TOKENS — matches student _T exactly
// ─────────────────────────────────────────────────────────────
class _T {
  // Use the student app color tokens for consistent theme
  static const green = AppColors.primary;
  static const greenDark = AppColors.primaryDark;
  static const orange = Color(0xFFF59000);
  static const blue = AppColors.primary;
  static const blueDeep = AppColors.primaryDark;
  static const yellow = Color(0xFFE8C400);
  static const red = AppColors.danger;
  static const purple = Color(0xFFBB6EF0);

  static const bg = AppColors.background;
  static const bgElevated = AppColors.cardLight;

  static const tintBlue = AppColors.primaryLight;
  static const tintGreen = AppColors.primaryLight;
  static const tintOrange = Color(0xFFFFF1E4);
  static const tintPurple = Color(0xFFF7EEFF);
  static const tintYellow = Color(0xFFFFFBE3);
  static const tintRed = AppColors.dangerLight;

  static const labelPrimary = AppColors.textDark;
  static const labelSecondary = AppColors.textGrey;
  static const labelTertiary = AppColors.textGrey;
  static const labelQuaternary = AppColors.textLight;
  static const separator = AppColors.border;

  // ── Typography — Fredoka + Nunito like student dashboard ──
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

  // ── Card decorations — identical to student ──
  static BoxDecoration get widgetCard => BoxDecoration(
    color: bgElevated,
    borderRadius: BorderRadius.circular(36),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .08),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: .8),
        blurRadius: 8,
        offset: const Offset(-2, -2),
      ),
    ],
  );

  static BoxDecoration tintCard(Color tint) => BoxDecoration(
    borderRadius: BorderRadius.circular(32),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        tint,
        Color.lerp(tint, Colors.white, 0.25)!,
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .08),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );
}