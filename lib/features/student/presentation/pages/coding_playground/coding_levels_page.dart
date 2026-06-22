import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coding_challenge_page.dart' as challenge;

class CodingLevel {
  final int level;
  final String title;
  final String topic;
  final String prompt;
  final String starter;
  final String expectedOutput;
  final int xp;
  final bool unlocked;
  final bool completed;

  CodingLevel({
    required this.level, required this.title, required this.topic,
    required this.prompt, required this.starter, required this.expectedOutput,
    required this.xp, required this.unlocked, required this.completed,
  });
}

class CodingLevelsPage extends StatefulWidget {
  const CodingLevelsPage({super.key});
  @override
  State<CodingLevelsPage> createState() => _CodingLevelsPageState();
}

class _CodingLevelsPageState extends State<CodingLevelsPage>
    with SingleTickerProviderStateMixin {
  static const _storageCurrentLevel = 'coding_current_level';
  static const _storageCompleted    = 'coding_level_completed';
  static const _storageStars        = 'coding_stars_earned';
  static const _storageXp           = 'coding_xp';

  int  _currentLevel    = 1;
  int  _completedLevels = 0;
  int  _starsEarned     = 0;
  int  _xp              = 0;
  bool _loading         = true;
  late final AnimationController _pageAnimation;

  final List<_LevelDefinition> _baseLevels = const [
    _LevelDefinition(
      level: 1, title: 'Variables', topic: 'Store and print values',
      prompt: 'Create a variable called name and set it to "Python". Print: Hello, Python!',
      starter: 'name = "Python"\nprint("Hello, " + name + "!")',
      expectedOutput: 'Hello, Python!', xp: 10,
    ),
    _LevelDefinition(
      level: 2, title: 'Data Types', topic: 'Numbers, strings & booleans',
      prompt: 'Set age = 16 and gpa = 3.8. Print them on one line separated by a space.',
      starter: 'age = 16\ngpa = 3.8\nprint(age, gpa)',
      expectedOutput: '16 3.8', xp: 12,
    ),
    _LevelDefinition(
      level: 3, title: 'Conditions', topic: 'Make decisions with if/else',
      prompt: 'Set score = 75. If score >= 60 print "Pass", else print "Fail".',
      starter: 'score = 75\nif score >= 60:\n    print("Pass")\nelse:\n    print("Fail")',
      expectedOutput: 'Pass', xp: 14,
    ),
    _LevelDefinition(
      level: 4, title: 'Operators', topic: 'Math and comparison',
      prompt: 'Set a = 12 and b = 5. Print a % b and a // b on separate lines.',
      starter: 'a = 12\nb = 5\nprint(a % b)\nprint(a // b)',
      expectedOutput: '2\n2', xp: 16,
    ),
    _LevelDefinition(
      level: 5, title: 'Loops', topic: 'Repeat with for loops',
      prompt: 'Print squares of numbers 1 to 5 using a for loop, one per line.',
      starter: 'for i in range(1, 6):\n    print(i ** 2)',
      expectedOutput: '1\n4\n9\n16\n25', xp: 18,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageAnimation = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLevel    = prefs.getInt(_storageCurrentLevel) ?? 1;
      _completedLevels = prefs.getInt(_storageCompleted)    ?? 0;
      _starsEarned     = prefs.getInt(_storageStars)        ?? _completedLevels;
      _xp              = prefs.getInt(_storageXp)           ?? 0;
      _loading         = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (mounted) _pageAnimation.forward();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageCurrentLevel, _currentLevel);
    await prefs.setInt(_storageCompleted,    _completedLevels);
    await prefs.setInt(_storageStars,        _starsEarned);
    await prefs.setInt(_storageXp,           _xp);
  }

  List<CodingLevel> get _levels => _baseLevels.map((base) => CodingLevel(
    level: base.level, title: base.title, topic: base.topic,
    prompt: base.prompt, starter: base.starter,
    expectedOutput: base.expectedOutput, xp: base.xp,
    unlocked: base.level <= _currentLevel,
    completed: base.level <= _completedLevels,
  )).toList();

  void _openLevel(CodingLevel level) {
    if (!level.unlocked) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => challenge.CodingChallengePage(
        level: level, onCompleted: _onLevelCompleted),
    ));
  }

  Future<void> _onLevelCompleted(CodingLevel level) async {
    final nextLevel       = (level.level + 1).clamp(1, _baseLevels.length + 1);
    final completedLevels = level.level > _completedLevels ? level.level : _completedLevels;
    setState(() {
      _completedLevels = completedLevels;
      _currentLevel    = nextLevel;
      _starsEarned     = completedLevels;
      _xp = _baseLevels.take(completedLevels).fold<int>(0, (s, e) => s + e.xp);
    });
    await _saveProgress();
  }

  @override
  void dispose() { _pageAnimation.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DL.bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _DL.green))
            : CustomScrollView(slivers: [
                SliverToBoxAdapter(child: _TopHeader(
                  stars: _starsEarned, xp: _xp,
                  completedLevels: _completedLevels,
                  totalLevels: _baseLevels.length,
                )),
                SliverToBoxAdapter(child: _UnitBanner(
                  completedLevels: _completedLevels,
                  totalLevels: _baseLevels.length,
                )),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(child: _LevelPath(
                    levels: _levels, onTap: _openLevel,
                    animation: _pageAnimation,
                  )),
                ),
                SliverToBoxAdapter(child: _BottomTrophyCard(animation: _pageAnimation)),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ]),
      ),
    );
  }
}

// ─── TOP HEADER ──────────────────────────────────────────────────────────────

class _TopHeader extends StatelessWidget {
  final int stars, xp, completedLevels, totalLevels;
  const _TopHeader({required this.stars, required this.xp,
      required this.completedLevels, required this.totalLevels});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _DL.bg,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Row(children: [
        Image.asset('assets/images/star_filled.png', width: 26, height: 26,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.star_rounded, color: Color(0xFFFF9600), size: 26)),
        const SizedBox(width: 5),
        Text('$stars', style: GoogleFonts.nunito(
            fontSize: 16, fontWeight: FontWeight.w800,
            color: _DL.textPrimary)),
        const SizedBox(width: 18),
        const Icon(Icons.bolt_rounded, color: _DL.yellow, size: 26),
        const SizedBox(width: 5),
        Text('$xp XP', style: GoogleFonts.nunito(
            fontSize: 16, fontWeight: FontWeight.w800,
            color: _DL.textPrimary)),
        const Spacer(),
        const Icon(Icons.favorite_rounded, color: _DL.red, size: 26),
        const SizedBox(width: 5),
        Text('${5 - (completedLevels ~/ 2).clamp(0, 4)}',
            style: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: _DL.textPrimary)),
      ]),
    );
  }
}

// ─── UNIT BANNER ─────────────────────────────────────────────────────────────

class _UnitBanner extends StatelessWidget {
  final int completedLevels, totalLevels;
  const _UnitBanner({required this.completedLevels, required this.totalLevels});

  @override
  Widget build(BuildContext context) {
    final progress = completedLevels / totalLevels;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DL.green,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: _DL.green.withValues(alpha: 0.3),
            blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('SECTION 1', style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: 1.2)),
          ),
          const Spacer(),
          const Icon(Icons.menu_book_rounded, color: Colors.white70, size: 22),
        ]),
        const SizedBox(height: 10),
        Text('Python Basics', style: GoogleFonts.nunito(
            fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 4),
        Text('Variables, types, loops and more', style: GoogleFonts.nunito(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8))),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress, minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text('$completedLevels / $totalLevels levels complete',
            style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: Colors.white70)),
      ]),
    );
  }
}

// ─── LEVEL PATH ──────────────────────────────────────────────────────────────

class _LevelPath extends StatelessWidget {
  final List<CodingLevel> levels;
  final ValueChanged<CodingLevel> onTap;
  final Animation<double> animation;
  const _LevelPath({required this.levels, required this.onTap,
      required this.animation});

  static const List<_NodePos> _positions = [
    _NodePos(alignment: _Align.center, isFirst: true),
    _NodePos(alignment: _Align.right),
    _NodePos(alignment: _Align.center, isMidBonusAbove: true),
    _NodePos(alignment: _Align.left),
    _NodePos(alignment: _Align.center),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (int i = 0; i < levels.length; i++) ...[
        if (i == 2) ...[
          _AnimatedEntry(animation: animation, index: i * 2,
              child: const _MascotRow()),
          const SizedBox(height: 4),
        ],
        _AnimatedEntry(
          animation: animation, index: i * 2 + 1,
          child: _NodeRow(level: levels[i], position: _positions[i], onTap: onTap),
        ),
        if (i < levels.length - 1)
          _ConnectorLine(
            fromAlign: _positions[i].alignment,
            toAlign: _positions[i + 1].alignment,
            bothCompleted: levels[i].completed && levels[i + 1].completed,
          ),
      ],
    ]);
  }
}

class _NodeRow extends StatelessWidget {
  final CodingLevel level;
  final _NodePos position;
  final ValueChanged<CodingLevel> onTap;
  const _NodeRow({required this.level, required this.position,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final node = _LevelNode(level: level, onTap: onTap);
    switch (position.alignment) {
      case _Align.left:
        return Row(children: [node, const Spacer(), const Spacer()]);
      case _Align.right:
        return Row(children: [const Spacer(), const Spacer(), node]);
      case _Align.center:
        return Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [node]);
    }
  }
}

// ─── CONNECTOR LINE ──────────────────────────────────────────────────────────

class _ConnectorLine extends StatelessWidget {
  final _Align fromAlign, toAlign;
  final bool bothCompleted;
  const _ConnectorLine({required this.fromAlign, required this.toAlign,
      required this.bothCompleted});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: CustomPaint(
      painter: _ConnectorPainter(
          from: fromAlign, to: toAlign, filled: bothCompleted),
      child: const SizedBox.expand(),
    ),
  );
}

class _ConnectorPainter extends CustomPainter {
  final _Align from, to;
  final bool filled;
  _ConnectorPainter({required this.from, required this.to,
      required this.filled});

  double _x(_Align a, double w) {
    switch (a) {
      case _Align.left:   return w * 0.18;
      case _Align.center: return w * 0.5;
      case _Align.right:  return w * 0.82;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = filled ? _DL.green : const Color(0xFFDDDDDD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(_x(from, size.width), 0)
      ..cubicTo(_x(from, size.width), size.height * 0.4,
                _x(to,   size.width), size.height * 0.6,
                _x(to,   size.width), size.height);

    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(
            metric.extractPath(d, (d + 8).clamp(0, metric.length)), paint);
        d += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter old) =>
      old.filled != filled || old.from != from || old.to != to;
}

// ─── LEVEL NODE ──────────────────────────────────────────────────────────────

class _LevelNode extends StatelessWidget {
  final CodingLevel level;
  final ValueChanged<CodingLevel> onTap;
  const _LevelNode({required this.level, required this.onTap});

  Color get _nodeColor {
    if (level.completed) return _DL.green;
    if (level.unlocked)  return _DL.blue;
    return _DL.locked;
  }

  Color get _shadowColor {
    if (level.completed) return const Color(0xFF3DAF00);
    if (level.unlocked)  return const Color(0xFF0090D4);
    return const Color(0xFFB0B8C1);
  }

  bool get _isActive => level.unlocked && !level.completed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: level.unlocked ? () => onTap(level) : null,
      child: Column(children: [
        if (_isActive) _ActiveChip(title: level.title)
        else const SizedBox(height: 28),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: _isActive ? 1.0 : 0.95),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          builder: (_, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Stack(clipBehavior: Clip.none,
              alignment: Alignment.center, children: [
            if (_isActive)
              Container(width: 90, height: 90,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _DL.blue.withValues(alpha: 0.15))),
            Container(
              width: 76, height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _nodeColor,
                boxShadow: [BoxShadow(
                    color: _shadowColor,
                    blurRadius: 0, offset: const Offset(0, 5))],
              ),
              child: Center(child: _nodeIcon()),
            ),
            Positioned(
              bottom: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _DL.yellow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Image.asset('assets/images/star_filled.png',
                      width: 12, height: 12,
                      errorBuilder: (_, _, _) => const Icon(
                          Icons.star_rounded,
                          color: Colors.white, size: 12)),
                  const SizedBox(width: 3),
                  Text('${level.xp} XP', style: GoogleFonts.nunito(
                      fontSize: 10, fontWeight: FontWeight.w800,
                      color: Colors.white)),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        Text(level.title, style: GoogleFonts.nunito(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: level.unlocked
                ? _DL.textPrimary
                : _DL.textSecondary)),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _nodeIcon() {
    if (level.completed) {
      return Image.asset('assets/images/star_filled.png',
          width: 38, height: 38,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.check_rounded, color: Colors.white, size: 36));
    }
    if (level.unlocked) {
      return Image.asset('assets/images/star_empty.png',
          width: 34, height: 34,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.star_rounded, color: Colors.white, size: 32));
    }
    return const Icon(Icons.lock_rounded, color: Colors.white54, size: 28);
  }
}

// ─── ACTIVE CHIP ─────────────────────────────────────────────────────────────

class _ActiveChip extends StatefulWidget {
  final String title;
  const _ActiveChip({required this.title});
  @override
  State<_ActiveChip> createState() => _ActiveChipState();
}

class _ActiveChipState extends State<_ActiveChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _bounce = Tween(begin: 0.0, end: -6.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _bounce.value), child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: _DL.blue,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
              color: _DL.blue.withValues(alpha: 0.4),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Text(widget.title.toUpperCase(), style: GoogleFonts.nunito(
            fontSize: 13, fontWeight: FontWeight.w900,
            color: Colors.white, letterSpacing: 0.5)),
      ),
    );
  }
}

// ─── MASCOT ROW ──────────────────────────────────────────────────────────────

class _MascotRow extends StatefulWidget {
  const _MascotRow();
  @override
  State<_MascotRow> createState() => _MascotRowState();
}

class _MascotRowState extends State<_MascotRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, Tween(begin: 0.0, end: -10.0)
              .animate(CurvedAnimation(
                  parent: _ctrl, curve: Curves.easeInOut))
              .value),
          child: child,
        ),
        child: Image.asset('assets/images/coding_mascot.png',
            height: 110, fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
                Icons.android_rounded, size: 80,
                color: Color(0xFF8E8E93))),
      ),
    );
  }
}

// ─── BOTTOM TROPHY CARD ──────────────────────────────────────────────────────

class _BottomTrophyCard extends StatelessWidget {
  final Animation<double> animation;
  const _BottomTrophyCard({required this.animation});

  @override
  Widget build(BuildContext context) {
    return _AnimatedEntry(
      animation: animation, index: 12,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Image.asset('assets/images/reward_chest.png',
              width: 52, height: 52,
              errorBuilder: (_, _, _) => const Icon(
                  Icons.emoji_events_rounded,
                  color: _DL.yellow, size: 40)),
          const SizedBox(width: 16),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bonus Challenge', style: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w900,
                color: _DL.textPrimary)),
            const SizedBox(height: 4),
            Text('Earn all stars to unlock the final boss level!',
                style: GoogleFonts.nunito(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: _DL.textSecondary)),
          ])),
        ]),
      ),
    );
  }
}

// ─── ANIMATED ENTRY ──────────────────────────────────────────────────────────

class _AnimatedEntry extends StatelessWidget {
  final Animation<double> animation;
  final int index;
  final Widget child;
  const _AnimatedEntry({required this.animation, required this.index,
      required this.child});

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(
        (index * 0.07).clamp(0.0, 0.85),
        ((index * 0.07) + 0.45).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}

// ─── ENUMS / HELPERS ─────────────────────────────────────────────────────────

enum _Align { left, center, right }

class _NodePos {
  final _Align alignment;
  final bool isFirst;
  final bool isMidBonusAbove;
  const _NodePos({required this.alignment,
      this.isFirst = false, this.isMidBonusAbove = false});
}

// ─── DESIGN TOKENS ───────────────────────────────────────────────────────────

class _DL {
  static const Color green         = Color(0xFF58CC02);
  static const Color blue          = Color(0xFF1CB0F6);
  static const Color yellow        = Color(0xFFFFD900);
  static const Color orange        = Color(0xFFFF9600);
  static const Color red           = Color(0xFFFF4B4B);
  static const Color bg            = Color(0xFFFDF6EC);
  static const Color trackGrey     = Color(0xFFDDDDDD);
  static const Color locked        = Color(0xFFB0B8C1);
  static const Color textPrimary   = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
}

// ─── MODEL ───────────────────────────────────────────────────────────────────

class _LevelDefinition {
  final int level, xp;
  final String title, topic, prompt, starter, expectedOutput;
  const _LevelDefinition({
    required this.level, required this.title, required this.topic,
    required this.prompt, required this.starter,
    required this.expectedOutput, required this.xp,
  });
}