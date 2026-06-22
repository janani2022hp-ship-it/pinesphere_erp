// features/student/presentation/pages/courses_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../services/course_service.dart';
import 'package:better_player_plus/better_player_plus.dart';


class _A {
  static const green = Color(0xFF46A800);
  static const greenDark = Color(0xFF357800);
  static const orange = Color(0xFFF59000);
  static const blue = Color(0xFF14A0E0);
  static const blueDark = Color(0xFF0072B5);
  static const blueDeep = Color(0xFF2464B8);
  static const red = Color(0xFFEC3A3A);
  static const purple = Color(0xFFBB6EF0);
  static const purpleDark = Color(0xFFA500E8);
  static const bg = Color(0xFFFDF6EC);
  static const bgElevated = Color(0xFFFFFAF4);
  static const tintBlue = Color(0xFFEAF8FE);
  static const tintGreen = Color(0xFFF1FBE8);
  static const tintOrange = Color(0xFFFFF1E4);
  static const tintPurple = Color(0xFFF7EEFF);
  static const labelPrimary = Color(0xFF1C1C1E);
  static const labelSecondary = Color(0xFF3C3C43);
  static const labelTertiary = Color(0xFF8E8E93);
  static const labelQuaternary = Color(0xFFC7C7CC);
  static const separator = Color(0xFFE5E5EA);

  static TextStyle title2({Color? color}) => GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color ?? labelPrimary,
        height: 1.2,
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
        height: 1.4,
      );

  static TextStyle caption1({Color? color}) => GoogleFonts.fredoka(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color ?? labelTertiary,
      );

  static TextStyle caption2({Color? color}) => GoogleFonts.fredoka(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color ?? labelTertiary,
      );

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
}

const int kMinCoursesRequired = 4;

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final CourseService _courseService = CourseService();

  bool _loading = true;
  bool _hasSelectedCourses = false;
  List<MyCourse> _myCourses = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    final selectedIds = await _courseService.getSelectedCourseIds();

    debugPrint('🟢 CoursesPage._init -> selectedIds=$selectedIds (len=${selectedIds.length}) kMin=$kMinCoursesRequired');

    if (selectedIds.length >= kMinCoursesRequired) {
      final myCourses = await _courseService.getMyCourses();
      debugPrint('🟢 CoursesPage._init -> myCourses.length=${myCourses.length}');
      if (!mounted) return;
      setState(() {
        _hasSelectedCourses = true;
        _myCourses = myCourses;
        _loading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _hasSelectedCourses = false;
        _loading = false;
      });
    }
  }

  void _openVideo(CourseVideoItem video, String courseTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VideoLessonSheet(video: video, courseTitle: courseTitle),
    );
  }

  Future<void> _openCourseSelection() async {
    debugPrint('🟢 CoursesPage -> navigating to CourseSelectionPage');
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CourseSelectionPage()),
    );
    debugPrint('🟢 CoursesPage <- back from CourseSelectionPage, changed=$changed');
    if (changed == true) {
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🟢 CoursesPage.build -> loading=$_loading hasSelected=$_hasSelectedCourses myCourses=${_myCourses.length}');
    return Container(
      color: _A.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              hasSelectedCourses: _hasSelectedCourses,
              onChangeCourses: _openCourseSelection,
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _A.blue),
                    )
                  : !_hasSelectedCourses
                      ? _NoCoursesSelectedState(onSelect: _openCourseSelection)
                      : RefreshIndicator(
                          color: _A.blue,
                          onRefresh: _init,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                            children: [
                              const _SectionHeader(
                                title: '📚 My Courses',
                              ),
                              const SizedBox(height: 12),
                              if (_myCourses.isEmpty)
                                const _EmptyCoursesCard()
                              else
                                ...List.generate(_myCourses.length, (index) {
                                  final course = _myCourses[index];
                                  final color =
                                      [_A.blue, _A.green, _A.purple][index % 3];
                                  final dark = [
                                    _A.blueDark,
                                    _A.greenDark,
                                    _A.purpleDark,
                                  ][index % 3];
                                  final icon = [
                                    Icons.calculate_rounded,
                                    Icons.science_rounded,
                                    Icons.smart_toy_rounded,
                                  ][index % 3];

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _CourseCard(
                                      iconColor: color,
                                      progressTextColor: dark,
                                      icon: icon,
                                      course: course,
                                      onVideoTap: (video) =>
                                          _openVideo(video, course.title),
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool hasSelectedCourses;
  final VoidCallback onChangeCourses;

  const _TopBar({
    required this.hasSelectedCourses,
    required this.onChangeCourses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: _A.bg,
        border: Border(bottom: BorderSide(color: _A.separator, width: .5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _A.tintPurple,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.menu_book_rounded, color: _A.purple, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My learning', style: _A.caption1()),
                const SizedBox(height: 4),
                Text('Courses', style: _A.title2()),
              ],
            ),
          ),
          if (hasSelectedCourses)
            GestureDetector(
              onTap: onChangeCourses,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _A.tintBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tune_rounded, color: _A.blue, size: 18),
                    const SizedBox(width: 6),
                    Text('Change', style: _A.caption1(color: _A.blueDark)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoCoursesSelectedState extends StatelessWidget {
  final VoidCallback onSelect;
  const _NoCoursesSelectedState({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _A.tintPurple,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.checklist_rounded,
                  color: _A.purple, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'Pick your courses',
              style: _A.title2(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select at least $kMinCoursesRequired courses to get started. '
              'You\'ll only see videos for the courses you choose.',
              style: _A.subheadline(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onSelect,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: _A.green,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _A.green.withValues(alpha: .35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  'Select Courses',
                  style: GoogleFonts.fredoka(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  const _SectionHeader({required this.title}) : action = null;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: _A.title2()),
        const Spacer(),
        if (action != null)
          Text(action!, style: _A.subheadline(color: _A.blue)),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Color iconColor;
  final Color progressTextColor;
  final IconData icon;
  final MyCourse course;
  final void Function(CourseVideoItem video) onVideoTap;

  const _CourseCard({
    required this.iconColor,
    required this.progressTextColor,
    required this.icon,
    required this.course,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    final videoCount = course.videos.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _A.widgetCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(course.title, style: _A.headline()),
                    const SizedBox(height: 5),
                    Text(
                      course.description.isEmpty
                          ? 'No description'
                          : course.description,
                      style: _A.caption1(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      videoCount == 0
                          ? 'No videos uploaded yet'
                          : '$videoCount video${videoCount > 1 ? 's' : ''} available',
                      style: _A.caption2(color: progressTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (videoCount > 0) ...[
            const SizedBox(height: 14),
            ...course.videos.map((video) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GestureDetector(
                    onTap: () => onVideoTap(video),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.play_circle_fill_rounded,
                              color: iconColor, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              video.title,
                              style: _A.subheadline(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (video.durationMinutes > 0)
                            Text(
                              '${video.durationMinutes}m',
                              style: _A.caption2(),
                            ),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _VideoLessonSheet extends StatefulWidget {
  final CourseVideoItem video;
  final String courseTitle;
  const _VideoLessonSheet({required this.video, required this.courseTitle});

  @override
  State<_VideoLessonSheet> createState() => _VideoLessonSheetState();
}

class _VideoLessonSheetState extends State<_VideoLessonSheet> {
  BetterPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.video.videoUrl,
      videoFormat: BetterPlayerVideoFormat.hls,
    );

    _controller = BetterPlayerController(
      const BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          enablePlayPause: true,
          enableProgressBar: true,
          enableSkips: true,
          controlBarColor: Colors.black54,
          iconsColor: Colors.white,
          progressBarPlayedColor: Color(0xFF14A0E0),
          progressBarBufferedColor: Colors.white38,
          progressBarBackgroundColor: Colors.white12,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _A.bgElevated,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('🎬 Lesson Video', style: _A.title2()),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _controller != null
                    ? BetterPlayer(controller: _controller!)
                    : Container(
                        color: _A.labelPrimary,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF14A0E0)),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Text(widget.video.title, style: _A.title2()),
            const SizedBox(height: 4),
            Text(
              '${widget.courseTitle} · ${widget.video.durationMinutes} min',
              style: _A.subheadline(),
            ),
            if (widget.video.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(widget.video.description, style: _A.caption1()),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyCoursesCard extends StatelessWidget {
  const _EmptyCoursesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _A.widgetCard,
      child: Text(
        'No courses found. Try changing your course selection.',
        style: _A.subheadline(color: _A.labelTertiary),
      ),
    );
  }
}

// ── COURSE SELECTION PAGE ───────────────────────────────────────────────────

class CourseSelectionPage extends StatefulWidget {
  const CourseSelectionPage({super.key});

  @override
  State<CourseSelectionPage> createState() => _CourseSelectionPageState();
}

class _CourseSelectionPageState extends State<CourseSelectionPage> {
  final CourseService _courseService = CourseService();

  bool _loading = true;
  bool _submitting = false;
  String? _loadError;
  List<CourseItem> _allCourses = [];
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final all = await _courseService.getAllCourses();
      final selected = await _courseService.getSelectedCourseIds();

      debugPrint('🟣 CourseSelectionPage._load -> all=${all.length} selected=${selected.length}');
      for (final c in all) {
        debugPrint('🟣   course: id=${c.id} title=${c.title}');
      }

      if (!mounted) return;
      setState(() {
        _allCourses = all;
        _selectedIds
          ..clear()
          ..addAll(selected);
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('🔴 CourseSelectionPage._load EXCEPTION: $e\n$st');
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  void _toggle(String courseId) {
    setState(() {
      if (_selectedIds.contains(courseId)) {
        _selectedIds.remove(courseId);
      } else {
        _selectedIds.add(courseId);
      }
    });
  }

  Future<void> _confirm() async {
    if (_selectedIds.length < kMinCoursesRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please select at least $kMinCoursesRequired courses '
              '(${_selectedIds.length}/$kMinCoursesRequired selected)'),
          backgroundColor: _A.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final success =
        await _courseService.selectCourses(_selectedIds.toList());
    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save selection. Try again.'),
          backgroundColor: _A.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = kMinCoursesRequired - _selectedIds.length;

    return Scaffold(
      backgroundColor: _A.bg,
      appBar: AppBar(
        backgroundColor: _A.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _A.labelPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Select Courses',
            style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _A.labelPrimary)),
      ),
      body: _buildBody(remaining),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody(int remaining) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _A.blue));
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: _A.red, size: 40),
              const SizedBox(height: 12),
              Text(
                'Could not load courses.\n$_loadError',
                style: _A.subheadline(color: _A.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _load,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: _A.blue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('Retry',
                      style: GoogleFonts.fredoka(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_allCourses.isEmpty) {
      return Center(
        child: Text(
          'No courses available yet.\nAsk your trainer to add courses.',
          style: _A.subheadline(),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: remaining > 0 ? _A.tintOrange : _A.tintGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                remaining > 0
                    ? Icons.info_outline_rounded
                    : Icons.check_circle_rounded,
                color: remaining > 0 ? _A.orange : _A.green,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  remaining > 0
                      ? 'Select $remaining more course${remaining > 1 ? 's' : ''} '
                          '(min. $kMinCoursesRequired)'
                      : '${_selectedIds.length} courses selected ✓',
                  style: _A.subheadline(
                    color:
                        remaining > 0 ? const Color(0xFF8A5A00) : _A.greenDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: _allCourses.length,
            itemBuilder: (context, index) => _buildCourseTile(index),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseTile(int index) {
    final course = _allCourses[index];
    final isSelected = _selectedIds.contains(course.id);
    final color = [_A.blue, _A.green, _A.purple][index % 3];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _toggle(course.id),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _A.bgElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : _A.separator,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.menu_book_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: _A.headline()),
                    if (course.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        course.description,
                        style: _A.caption1(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : _A.labelQuaternary,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildBottomBar() {
    if (_loading || _loadError != null || _allCourses.isEmpty) return null;

    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: GestureDetector(
          onTap: _submitting ? null : _confirm,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: _A.green,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _A.green.withValues(alpha: .35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      'Confirm Selection (${_selectedIds.length})',
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}