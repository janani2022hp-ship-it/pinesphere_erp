import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class UpcomingClass {
  final String title;
  final String batch;
  final String time;
  final String room;
  final int joined;
  final int total;
  final bool isLive;
  final Color color;
  final Color tint;
  final IconData icon;

  const UpcomingClass({
    required this.title,
    required this.batch,
    required this.time,
    required this.room,
    required this.joined,
    required this.total,
    required this.isLive,
    required this.color,
    required this.tint,
    required this.icon,
  });
}

class UpcomingClassCard extends StatelessWidget {
  final List<UpcomingClass> classes;

  const UpcomingClassCard({
    super.key,
    this.classes = const [
      UpcomingClass(
        title: 'Python fundamentals',
        batch: 'Grade 8 - Batch A',
        time: '10:30 AM',
        room: 'Lab 2',
        joined: 26,
        total: 30,
        isLive: true,
        color: _D.blue,
        tint: _D.tintBlue,
        icon: Icons.code_rounded,
      ),
      UpcomingClass(
        title: 'AI project review',
        batch: 'Advanced ML',
        time: '12:00 PM',
        room: 'Studio 1',
        joined: 18,
        total: 22,
        isLive: false,
        color: _D.purple,
        tint: _D.tintPurple,
        icon: Icons.smart_toy_rounded,
      ),
      UpcomingClass(
        title: 'Math problem solving',
        batch: 'Grade 7 - Batch C',
        time: '03:15 PM',
        room: 'Room 104',
        joined: 31,
        total: 34,
        isLive: false,
        color: _D.green,
        tint: _D.tintGreen,
        icon: Icons.calculate_rounded,
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Upcoming Classes', action: 'See all'),
          const SizedBox(height: 12),
          ...List.generate(classes.length, (index) {
            final item = classes[index];
            return _UpcomingClassTile(
              item: item,
              showDivider: index != classes.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _UpcomingClassTile extends StatelessWidget {
  final UpcomingClass item;
  final bool showDivider;

  const _UpcomingClassTile({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final progress = item.total == 0 ? 0.0 : item.joined / item.total;

    return Container(
      padding: EdgeInsets.only(bottom: showDivider ? 12 : 0),
      margin: EdgeInsets.only(bottom: showDivider ? 12 : 0),
      decoration: BoxDecoration(
        border: showDivider ? Border(bottom: BorderSide(color: AppColors.border, width: .5)) : null,
      ),
      child: Row(
        children: [
          // Cartoon icon square
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset('assets/images/star_filled.png', width: 24, height: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ),
                    if (item.isLive) const SizedBox(width: 8),
                    if (item.isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Live', style: GoogleFonts.nunito(fontSize: 10, color: AppColors.dangerText, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${item.batch} - ${item.time} - ${item.room}', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textGrey)),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0, 1),
                          minHeight: 5,
                          color: item.color,
                          backgroundColor: item.color.withValues(alpha: .12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${item.joined}/${item.total}', style: GoogleFonts.nunito(fontSize: 11, color: item.color)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;

  const _SectionHeader({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: _D.title3())),
        Text(action, style: _D.subheadline(color: _D.blue)),
      ],
    );
  }
}

class _D {
  static const green = Color(0xFF46A800);
  static const blue = Color(0xFF14A0E0);
  static const purple = Color(0xFFBB6EF0);
  static const red = Color(0xFFEC3A3A);
  static const bgElevated = Color(0xFFFFFAF4);
  static const tintBlue = Color(0xFFEAF8FE);
  static const tintGreen = Color(0xFFF1FBE8);
  static const tintPurple = Color(0xFFF7EEFF);
  static const tintRed = Color(0xFFFFEEEE);
  static const labelPrimary = Color(0xFF1C1C1E);
  static const labelTertiary = Color(0xFF8E8E93);
  static const separator = Color(0xFFE5E5EA);

  static TextStyle title3({Color? color}) => GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: color ?? labelPrimary,
    letterSpacing: -.41,
    height: 1.3,
  );

  static TextStyle subheadline({Color? color}) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: color ?? labelTertiary,
    letterSpacing: -.08,
    height: 1.4,
  );

  static TextStyle caption1({Color? color}) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: color ?? labelTertiary,
    letterSpacing: .07,
  );

  static BoxDecoration get widgetCard => BoxDecoration(
    color: bgElevated,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .06),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: .03),
        blurRadius: 6,
        offset: const Offset(0, 1),
      ),
    ],
  );
}
