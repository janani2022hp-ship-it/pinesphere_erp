import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentTheme {
  static const green = Color(0xFF46A800);
  static const greenDark = Color(0xFF357800);
  static const orange = Color(0xFFF59000);
  static const blue = Color(0xFF14A0E0);
  static const blueDark = Color(0xFF0072B5);
  static const purple = Color(0xFFBB6EF0);
  static const red = Color(0xFFEC3A3A);
  static const bg = Color(0xFFFDF6EC);
  static const card = Color(0xFFFFFAF4);
  static const tintBlue = Color(0xFFEAF8FE);
  static const tintGreen = Color(0xFFF1FBE8);
  static const tintOrange = Color(0xFFFFF1E4);
  static const tintPurple = Color(0xFFF7EEFF);
  static const tintRed = Color(0xFFFFEEEE);
  static const labelPrimary = Color(0xFF1C1C1E);
  static const labelTertiary = Color(0xFF8E8E93);
  static const separator = Color(0xFFE5E5EA);

  static TextStyle title({Color? color, double size = 20}) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: color ?? labelPrimary,
    height: 1.2,
  );

  static TextStyle body({Color? color, double size = 13}) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: FontWeight.w500,
    color: color ?? labelTertiary,
    height: 1.35,
  );

  static BoxDecoration cardDecoration({Color color = card}) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .06),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class ParentTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onProfile;

  const ParentTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      color: ParentTheme.bg,
      child: Row(
        children: [
          GestureDetector(
            onTap: onProfile,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ParentTheme.blue, ParentTheme.blueDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.family_restroom_rounded,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onProfile,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ParentTheme.title(size: 18)),
                  Text(subtitle, style: ParentTheme.body(size: 12)),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ParentTheme.tintGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Parent',
              style: ParentTheme.body(color: ParentTheme.greenDark),
            ),
          ),
        ],
      ),
    );
  }
}

class ParentSectionTitle extends StatelessWidget {
  final String title;
  final String? action;

  const ParentSectionTitle({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: ParentTheme.title(size: 17)),
        const Spacer(),
        if (action != null)
          Text(action!, style: ParentTheme.body(color: ParentTheme.blue)),
      ],
    );
  }
}

class ParentInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color tint;
  final VoidCallback? onTap;

  const ParentInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.tint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ParentTheme.cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ParentTheme.title(size: 15)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: ParentTheme.body(size: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
