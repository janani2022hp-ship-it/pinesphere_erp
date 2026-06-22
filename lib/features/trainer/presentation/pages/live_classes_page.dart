import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../services/live_classes_service.dart';
import '../../../../services/course_service.dart';

class TrainerLiveClassesPage extends StatefulWidget {
  const TrainerLiveClassesPage({super.key});

  @override
  State<TrainerLiveClassesPage> createState() => _TrainerLiveClassesPageState();
}

class _TrainerLiveClassesPageState extends State<TrainerLiveClassesPage> {
  final LiveClassesService _liveClassesService = LiveClassesService();
  final CourseService _courseService = CourseService();

  List<LiveClass> _classes = [];
  List<CourseItem> _courses = [];
  bool _loadingClasses = true;
  bool _loadingCourses = true;

  String? _activeClassId;
  String _meetingLink = '';

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadCourses();
  }

  Future<void> _loadClasses() async {
    setState(() => _loadingClasses = true);
    final classes = await _liveClassesService.fetchTrainerLiveClasses();
    if (!mounted) return;
    setState(() {
      _classes = classes;
      _loadingClasses = false;
      final active = classes.where((c) => c.isLive).toList();
      if (active.isNotEmpty) {
        _activeClassId = active.first.id;
        _meetingLink = active.first.meetingLink ?? '';
      } else {
        _activeClassId = null;
        _meetingLink = '';
      }
    });
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await _courseService.getTrainerCourses();
      if (!mounted) return;
      setState(() {
        _courses = courses;
        _loadingCourses = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  Future<void> _startHosting(String classId) async {
    final updated = await _liveClassesService.hostLiveClass(classId);
    if (updated != null) {
      await _loadClasses();
    } else {
      _showSnack('Failed to start broadcast', isError: true);
    }
  }

  Future<void> _stopHosting() async {
    if (_activeClassId == null) return;
    final updated = await _liveClassesService.stopLiveClass(_activeClassId!);
    if (updated != null) {
      await _loadClasses();
    } else {
      _showSnack('Failed to stop broadcast', isError: true);
    }
  }

  void _copyMeetingLink() {
    if (_meetingLink.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _meetingLink));
    _showSnack('Link copied!');
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        backgroundColor: isError ? const Color(0xFFE24B4A) : const Color(0xFF58CC02),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openCreateDialog() async {
    final titleCtrl = TextEditingController();
    String? selectedCourseId = _courses.isNotEmpty ? _courses.first.id : null;

    if (_courses.isEmpty) {
      _showSnack('No courses available — create a course first', isError: true);
      return;
    }

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Create Live Class',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Class title',
                      hintText: 'e.g. Algebra Live Q&A',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Course',
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8E8E93))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCourseId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    items: _courses
                        .map((c) => DropdownMenuItem<String>(
                              value: c.id,
                              child: Text(c.title, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setDialogState(() => selectedCourseId = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                  ),
                  child: const Text('Create',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (created != true) return;

    final title = titleCtrl.text.trim();
    if (title.isEmpty || selectedCourseId == null) {
      _showSnack('Title and course are required', isError: true);
      return;
    }

    final result = await _liveClassesService.createLiveClass(
      title,
      selectedCourseId!,
    );

    if (result != null) {
      _showSnack('Live class created');
      await _loadClasses();
    } else {
      _showSnack('Failed to create live class', isError: true);
    }
  }

  String _courseTitle(String courseId) {
    final match = _courses.where((c) => c.id == courseId).toList();
    return match.isNotEmpty ? match.first.title : 'Unknown course';
  }

  @override
  Widget build(BuildContext context) {
    final isHosting = _activeClassId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1C1C1E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Live Classes',
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1C1C1E))),
      ),
      body: RefreshIndicator(
        onRefresh: _loadClasses,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _BroadcastCard(
              isHosting: isHosting,
              meetingLink: _meetingLink,
              onCopy: _copyMeetingLink,
              onStop: _stopHosting,
            ),
            const SizedBox(height: 20),

            _LightButton(
              icon: Icons.add_circle_outline_rounded,
              label: 'Create Live Class',
              color: const Color(0xFF1CB0F6),
              onTap: _loadingCourses ? () {} : _openCreateDialog,
            ),
            const SizedBox(height: 24),

            Row(children: [
              Text('Your Classes',
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1C1C1E))),
              const Spacer(),
              GestureDetector(
                onTap: _loadClasses,
                child: const Icon(Icons.refresh_rounded,
                    color: Color(0xFF8E8E93), size: 20),
              ),
            ]),
            const SizedBox(height: 14),

            if (_loadingClasses)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_classes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text('No classes yet — create one above',
                      style: GoogleFonts.nunito(color: const Color(0xFF8E8E93))),
                ),
              )
            else
              ..._classes.map((cls) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ClassCard(
                      cls: cls,
                      courseTitle: _courseTitle(cls.courseId),
                      isActive: cls.id == _activeClassId,
                      onHost: () => _startHosting(cls.id),
                      onCopyLink: () {
                        Clipboard.setData(
                            ClipboardData(text: cls.meetingLink ?? ''));
                        _showSnack('Link copied!');
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

// ── BROADCAST CARD ────────────────────────────────────────────

class _BroadcastCard extends StatelessWidget {
  final bool isHosting;
  final String meetingLink;
  final VoidCallback onCopy;
  final VoidCallback onStop;

  const _BroadcastCard({
    required this.isHosting,
    required this.meetingLink,
    required this.onCopy,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHosting
              ? const Color(0xFFFF4B4B).withValues(alpha: 0.4)
              : const Color(0xFFE5E5EA),
          width: isHosting ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (isHosting)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4B4B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFFF4B4B).withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                      color: Color(0xFFFF4B4B),
                      shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('LIVE SESSION ACTIVE',
                  style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF4B4B),
                      letterSpacing: 0.8)),
            ]),
          ),
        if (isHosting) const SizedBox(height: 12),

        if (isHosting && meetingLink.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.link_rounded,
                  color: Color(0xFF8E8E93), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(meetingLink,
                    style: GoogleFonts.robotoMono(
                        fontSize: 11,
                        color: const Color(0xFF1C1C1E))),
              ),
              GestureDetector(
                onTap: onCopy,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1CB0F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Copy',
                      style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1CB0F6))),
                ),
              ),
            ]),
          )
        else
          Text(
            'No active broadcast. Tap "Host Now" on a class below to go live.',
            style: GoogleFonts.nunito(
                fontSize: 12, color: const Color(0xFF8E8E93)),
          ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: isHosting ? onStop : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: isHosting
                  ? const Color(0xFFFF4B4B).withValues(alpha: 0.08)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isHosting
                    ? const Color(0xFFFF4B4B).withValues(alpha: 0.4)
                    : const Color(0xFFE5E5EA),
              ),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                isHosting
                    ? Icons.stop_circle_outlined
                    : Icons.radio_button_checked_rounded,
                color: isHosting
                    ? const Color(0xFFFF4B4B)
                    : const Color(0xFF8E8E93),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isHosting ? 'STOP BROADCAST' : 'NOT BROADCASTING',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isHosting
                      ? const Color(0xFFFF4B4B)
                      : const Color(0xFF8E8E93),
                  letterSpacing: 0.5,
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── LIGHT BUTTON ─────────────────────────────────────────────

class _LightButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool outlined;
  final VoidCallback onTap;

  const _LightButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : outlined = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: outlined ? Colors.white : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: outlined
                  ? const Color(0xFFE5E5EA)
                  : color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon,
              color: outlined ? const Color(0xFF8E8E93) : color, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: outlined ? const Color(0xFF8E8E93) : color)),
        ]),
      ),
    );
  }
}

// ── CLASS CARD ────────────────────────────────────────────────

class _ClassCard extends StatelessWidget {
  final LiveClass cls;
  final String courseTitle;
  final bool isActive;
  final VoidCallback onHost;
  final VoidCallback onCopyLink;

  const _ClassCard({
    required this.cls,
    required this.courseTitle,
    required this.isActive,
    required this.onHost,
    required this.onCopyLink,
  });

  @override
  Widget build(BuildContext context) {
    final isLive = cls.isLive;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLive
              ? const Color(0xFF58CC02).withValues(alpha: 0.4)
              : const Color(0xFFE5E5EA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('📚', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (isLive)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 5, height: 5,
                        decoration: const BoxDecoration(
                            color: Color(0xFF58CC02),
                            shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('LIVE NOW',
                        style: GoogleFonts.nunito(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF58CC02),
                            letterSpacing: 0.5)),
                  ]),
                ),
              Text(cls.title,
                  style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1C1C1E))),
              const SizedBox(height: 2),
              Text(
                'Course: $courseTitle',
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: const Color(0xFF8E8E93)),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 14),

        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: isLive ? null : onHost,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isLive
                      ? const Color(0xFFE5E5EA)
                      : const Color(0xFF58CC02),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isLive
                      ? []
                      : [BoxShadow(
                          color: const Color(0xFF58CC02).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3))],
                ),
                child: Center(
                  child: Text(
                    isLive ? 'Hosting Now' : 'Host Now',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isLive ? const Color(0xFF8E8E93) : Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCopyLink,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E5EA)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.link_rounded,
                    color: Color(0xFF1CB0F6), size: 16),
                const SizedBox(width: 6),
                Text('Copy Link',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1CB0F6))),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }
}