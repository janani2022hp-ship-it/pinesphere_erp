import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'video_player_screen.dart';

// ─── Config ────────────────────────────────────────────────────────────────────

const String baseUrl = 'https://vaguely-dastardly-pennant.ngrok-free.dev';
const Map<String, String> _headers = {'ngrok-skip-browser-warning': 'true'};

// ─── Models ───────────────────────────────────────────────────────────────────

enum UserRole { trainer, student }

class CourseVideo {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final String videoUrl; // .m3u8 HLS URL from Cloudinary
  final Duration duration;
  final int sequence;
  final DateTime uploadedAt;

  const CourseVideo({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.duration,
    required this.sequence,
    required this.uploadedAt,
  });

  factory CourseVideo.fromJson(Map<String, dynamic> json) => CourseVideo(
        id: json['id'].toString(),
        courseId: json['course_id'].toString(),
        title: json['title'],
        description: json['description'] ?? '',
        videoUrl: json['video_url'], // already .m3u8 from DB
        duration: Duration(minutes: json['duration_minutes'] ?? 0),
        sequence: json['sequence'] ?? 0,
        uploadedAt: DateTime.parse(json['created_at']),
      );
}

class Course {
  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final List<CourseVideo> videos;

  const Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.videos,
  });

  Course copyWith({List<CourseVideo>? videos}) => Course(
        id: id,
        title: title,
        subtitle: subtitle,
        color: color,
        icon: icon,
        videos: videos ?? this.videos,
      );

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'].toString(),
        title: json['title'],
        subtitle: json['description'] ?? '',
        color: _colorFromTitle(json['title']),
        icon: _iconFromTitle(json['title']),
        videos: (json['videos'] as List? ?? [])
            .map((v) => CourseVideo.fromJson(v))
            .toList(),
      );

  static Color _colorFromTitle(String title) {
    final colors = [
      const Color(0xFF4F7FE8),
      const Color(0xFF22B07D),
      const Color(0xFFF0A500),
      const Color(0xFFE85E5E),
      const Color(0xFF9B59B6),
      const Color(0xFF16A3B8),
    ];
    return colors[title.hashCode.abs() % colors.length];
  }

  static IconData _iconFromTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('communication')) return Icons.record_voice_over_rounded;
    if (t.contains('data') || t.contains('analytics')) return Icons.bar_chart_rounded;
    if (t.contains('project') || t.contains('management')) return Icons.account_tree_rounded;
    if (t.contains('financial') || t.contains('finance')) return Icons.account_balance_wallet_rounded;
    if (t.contains('leadership')) return Icons.group_rounded;
    if (t.contains('marketing')) return Icons.campaign_rounded;
    if (t.contains('python') || t.contains('stack')) return Icons.code_rounded;
    if (t.contains('machine') || t.contains('ml')) return Icons.psychology_rounded;
    if (t.contains('web')) return Icons.web_rounded;
    if (t.contains('cyber') || t.contains('security')) return Icons.security_rounded;
    if (t.contains('science')) return Icons.science_rounded;
    return Icons.book_rounded;
  }
}

// ─── API Layer ─────────────────────────────────────────────────────────────────

Future<List<Course>> fetchAllCourses() async {
  final res = await http.get(
    Uri.parse('$baseUrl/trainer/courses'),
    headers: _headers,
  );
  final List data = jsonDecode(res.body);
  final courses = <Course>[];
  for (final c in data) {
    final course = Course.fromJson(c);
    final videos = await fetchCourseVideos(course.id);
    courses.add(course.copyWith(videos: videos));
  }
  return courses;
}

Future<List<Course>> fetchStudentCourses(String studentId) async {
  final res = await http.get(
    Uri.parse('$baseUrl/trainer/students/$studentId/courses'),
    headers: _headers,
  );
  final List data = jsonDecode(res.body);
  final courses = <Course>[];
  for (final c in data) {
    final course = Course.fromJson(c);
    final videos = await fetchCourseVideos(course.id);
    courses.add(course.copyWith(videos: videos));
  }
  return courses;
}

Future<List<CourseVideo>> fetchCourseVideos(String courseId) async {
  final res = await http.get(
    Uri.parse('$baseUrl/trainer/courses/$courseId/videos'),
    headers: _headers,
  );
  if (res.statusCode != 200) return [];
  final List data = jsonDecode(res.body);
  return data.map((v) => CourseVideo.fromJson(v)).toList();
}

/// Upload MP4 to FastAPI → FastAPI uploads to Cloudinary → saves .m3u8 URL
Future<void> uploadVideo({
  required String courseId,
  required String trainerId,
  required String title,
  required String description,
  required int durationMinutes,
  required int sequence,
  required File file,
}) async {
  final uri = Uri.parse('$baseUrl/trainer/courses/$courseId/videos');
  final request = http.MultipartRequest('POST', uri)
    ..headers.addAll(_headers)
    ..fields['trainer_id'] = trainerId
    ..fields['title'] = title
    ..fields['description'] = description
    ..fields['duration_minutes'] = durationMinutes.toString()
    ..fields['sequence'] = sequence.toString()
    ..files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType('video', 'mp4'),
    ));

  final streamed = await request.send();
  if (streamed.statusCode != 200 && streamed.statusCode != 201) {
    final body = await streamed.stream.bytesToString();
    throw Exception('Upload failed ${streamed.statusCode}: $body');
  }
}

Future<void> deleteVideo(String courseId, String videoId) async {
  final res = await http.delete(
    Uri.parse('$baseUrl/trainer/courses/$courseId/videos/$videoId'),
    headers: _headers,
  );
  if (res.statusCode != 200) {
    throw Exception('Delete failed: ${res.statusCode}');
  }
}

// ─── Main Page ─────────────────────────────────────────────────────────────────

class CourseVideoPage extends StatefulWidget {
  final UserRole userRole;
  final String userId;

  const CourseVideoPage({
    super.key,
    this.userRole = UserRole.student,
    required this.userId,
  });

  @override
  State<CourseVideoPage> createState() => _CourseVideoPageState();
}

class _CourseVideoPageState extends State<CourseVideoPage>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _error;
  List<Course> _displayedCourses = [];
  late TabController _tabController;
  int _selectedCourseIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() { _loading = true; _error = null; });
    try {
      final courses = widget.userRole == UserRole.trainer
          ? await fetchAllCourses()
          : await fetchStudentCourses(widget.userId);
      if (!mounted) return;
      setState(() {
        _displayedCourses = courses;
        _loading = false;
        _tabController = TabController(
          length: _displayedCourses.length,
          vsync: this,
        );
        _tabController.addListener(() {
          if (!_tabController.indexIsChanging) return;
          setState(() => _selectedCourseIndex = _tabController.index);
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _refreshCourseVideos(String courseId) async {
    final videos = await fetchCourseVideos(courseId);
    if (!mounted) return;
    setState(() {
      _displayedCourses = _displayedCourses.map((c) {
        return c.id == courseId ? c.copyWith(videos: videos) : c;
      }).toList();
    });
  }

  @override
  void dispose() {
    if (!_loading) _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFBCC2CE)),
              const SizedBox(height: 16),
              Text('Failed to load courses',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextButton(onPressed: _loadCourses, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final isTrainer = widget.userRole == UserRole.trainer;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          isTrainer ? 'Course Videos' : 'My Courses',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEF0F4)),
        ),
        actions: [
          if (isTrainer)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TextButton.icon(
                onPressed: () => _showUploadDialog(context),
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: Text('Upload',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.primary.withAlpha(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ),
          IconButton(
            onPressed: _loadCourses,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              tabs: List.generate(_displayedCourses.length, (i) {
                final course = _displayedCourses[i];
                final selected = _selectedCourseIndex == i;
                return _CourseTabChip(course: course, selected: selected);
              }),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _displayedCourses.map((course) {
                return _CourseVideoList(
                  course: course,
                  isTrainer: isTrainer,
                  onUpload: () => _showUploadDialog(context, course: course),
                  onDelete: (video) => _handleDelete(context, video, course),
                  onPlay: (video) => _openPlayer(context, video),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _openPlayer(BuildContext context, CourseVideo video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          hlsUrl: video.videoUrl, // .m3u8 from Cloudinary via DB
          title: video.title,
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context, {Course? course}) {
    final selectedCourse = course ?? _displayedCourses[_selectedCourseIndex];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadVideoSheet(
        courses: _displayedCourses,
        initialCourse: selectedCourse,
        trainerId: widget.userId,
        onUploaded: (courseId) async {
          await _refreshCourseVideos(courseId);
        },
      ),
    );
  }

  void _handleDelete(BuildContext context, CourseVideo video, Course course) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Video?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          '"${video.title}" will be permanently removed from ${course.title}.',
          style:
              GoogleFonts.inter(fontSize: 14, color: const Color(0xFF5A6478)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: const Color(0xFF8A94A6),
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await deleteVideo(course.id, video.id);
                await _refreshCourseVideos(course.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Video deleted', style: GoogleFonts.inter()),
                  backgroundColor: const Color(0xFFE85E5E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ));
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Delete failed: $e', style: GoogleFonts.inter()),
                  backgroundColor: const Color(0xFFE85E5E),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85E5E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Upload Sheet ──────────────────────────────────────────────────────────────

class _UploadVideoSheet extends StatefulWidget {
  final List<Course> courses;
  final Course initialCourse;
  final String trainerId;
  final Future<void> Function(String courseId) onUploaded;

  const _UploadVideoSheet({
    required this.courses,
    required this.initialCourse,
    required this.trainerId,
    required this.onUploaded,
  });

  @override
  State<_UploadVideoSheet> createState() => _UploadVideoSheetState();
}

class _UploadVideoSheetState extends State<_UploadVideoSheet> {
  late String _selectedCourseId;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController();
  final _sequenceController = TextEditingController();
  File? _pickedFile;
  String? _pickedFileName;
  bool _uploading = false;
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.initialCourse.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _sequenceController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        _pickedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    final sequence = int.tryParse(_sequenceController.text.trim()) ?? 1;

    if (title.isEmpty || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill the title and pick a video file.',
            style: GoogleFonts.inter()),
        backgroundColor: const Color(0xFFE85E5E),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() {
      _uploading = true;
      _uploadStatus = 'Uploading to Cloudinary…';
    });

    try {
      await uploadVideo(
        courseId: _selectedCourseId,
        trainerId: widget.trainerId,
        title: title,
        description: desc,
        durationMinutes: duration,
        sequence: sequence,
        file: _pickedFile!,
      );

      if (!mounted) return;
      setState(() => _uploadStatus = 'Transcoding to HLS…');

      Navigator.pop(context);
      await widget.onUploaded(_selectedCourseId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Video uploaded! HLS streaming ready.',
                style: GoogleFonts.inter()),
          ],
        ),
        backgroundColor: const Color(0xFF22B07D),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() { _uploading = false; _uploadStatus = ''; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Upload failed: $e', style: GoogleFonts.inter()),
        backgroundColor: const Color(0xFFE85E5E),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE1E9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Upload Video',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.cloud_rounded,
                    size: 14, color: Color(0xFF8A94A6)),
                const SizedBox(width: 4),
                Text(
                  'Uploads to Cloudinary → Auto HLS (.m3u8)',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF8A94A6)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _label('Course'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEEF0F4)),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCourseId,
                  isExpanded: true,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark),
                  items: widget.courses.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.title));
                  }).toList(),
                  onChanged: (val) =>
                      setState(() => _selectedCourseId = val!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _label('Video Title'),
            const SizedBox(height: 8),
            _textField(_titleController, 'e.g. Introduction to Module 2'),
            const SizedBox(height: 16),

            _label('Description'),
            const SizedBox(height: 8),
            _textField(_descController,
                'Brief description of what this video covers',
                maxLines: 3),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Duration (mins)'),
                      const SizedBox(height: 8),
                      _textField(_durationController, '0',
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Sequence #'),
                      const SizedBox(height: 8),
                      _textField(_sequenceController, '1',
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _label('Video File (MP4)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _uploading ? null : _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: _pickedFile != null
                      ? const Color(0xFF22B07D).withAlpha(15)
                      : AppColors.primary.withAlpha(12),
                  border: Border.all(
                    color: _pickedFile != null
                        ? const Color(0xFF22B07D).withAlpha(80)
                        : AppColors.primary.withAlpha(60),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(
                      _pickedFile != null
                          ? Icons.check_circle_rounded
                          : Icons.video_file_rounded,
                      color: _pickedFile != null
                          ? const Color(0xFF22B07D)
                          : AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pickedFile != null
                          ? _pickedFileName!
                          : 'Tap to select MP4 file',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _pickedFile != null
                            ? const Color(0xFF22B07D)
                            : AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _pickedFile != null
                          ? 'Tap to change • Cloudinary converts to HLS'
                          : 'MP4 → Cloudinary → HLS .m3u8',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: const Color(0xFF8A94A6)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Upload progress status
            if (_uploading) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(_uploadStatus,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _uploading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8A94A6),
                      side: const BorderSide(color: Color(0xFFDDE1E9)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text('Cancel',
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _uploading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: _uploading
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_upload_rounded, size: 18),
                              const SizedBox(width: 6),
                              Text('Upload',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF8A94A6),
          letterSpacing: 0.5,
        ),
      );

  Widget _textField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
              color: const Color(0xFFBCC2CE), fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEEF0F4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEEF0F4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      );
}

// ─── Course Tab Chip ───────────────────────────────────────────────────────────

class _CourseTabChip extends StatelessWidget {
  final Course course;
  final bool selected;
  const _CourseTabChip({required this.course, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? course.color : const Color(0xFFF0F2F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(course.icon,
              size: 14,
              color: selected ? Colors.white : const Color(0xFF8A94A6)),
          const SizedBox(width: 6),
          Text(
            course.title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF5A6478),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Video List per Course ─────────────────────────────────────────────────────

class _CourseVideoList extends StatelessWidget {
  final Course course;
  final bool isTrainer;
  final VoidCallback onUpload;
  final void Function(CourseVideo) onDelete;
  final void Function(CourseVideo) onPlay;

  const _CourseVideoList({
    required this.course,
    required this.isTrainer,
    required this.onUpload,
    required this.onDelete,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final videos = course.videos;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: course.color, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(course.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(course.subtitle,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withAlpha(200))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${videos.length} ${videos.length == 1 ? 'video' : 'videos'}',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (isTrainer)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: OutlinedButton.icon(
                onPressed: onUpload,
                icon: Icon(Icons.add_circle_outline_rounded,
                    size: 16, color: course.color),
                label: Text('Add video to this course',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: course.color)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: course.color.withAlpha(100)),
                  backgroundColor: course.color.withAlpha(12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

        if (videos.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text('LESSONS',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFBCC2CE),
                          letterSpacing: 1)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22B07D).withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('HLS',
                        style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF22B07D))),
                  ),
                ],
              ),
            ),
          ),

        if (videos.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _VideoCard(
                video: videos[i],
                index: i + 1,
                courseColor: course.color,
                isTrainer: isTrainer,
                onDelete: () => onDelete(videos[i]),
                onPlay: () => onPlay(videos[i]),
              ),
              childCount: videos.length,
            ),
          ),

        if (videos.isEmpty)
          SliverFillRemaining(
            child: _EmptyVideosState(
              isTrainer: isTrainer,
              courseColor: course.color,
              onUpload: onUpload,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ─── Video Card ────────────────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  final CourseVideo video;
  final int index;
  final Color courseColor;
  final bool isTrainer;
  final VoidCallback onDelete;
  final VoidCallback onPlay;

  const _VideoCard({
    required this.video,
    required this.index,
    required this.courseColor,
    required this.isTrainer,
    required this.onDelete,
    required this.onPlay,
  });

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPlay, // ← opens HLS player
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 70,
              decoration: BoxDecoration(
                color: courseColor.withAlpha(30),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text('$index',
                      style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: courseColor.withAlpha(50))),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: courseColor, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 12, color: Color(0xFFBCC2CE)),
                        const SizedBox(width: 4),
                        Text(_formatDuration(video.duration),
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF8A94A6))),
                        const SizedBox(width: 8),
                        // HLS badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22B07D).withAlpha(20),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text('HLS',
                              style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF22B07D))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isTrainer)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 20, color: Color(0xFFBCC2CE)),
                tooltip: 'Delete video',
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right_rounded,
                    color: const Color(0xFFBCC2CE)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────

class _EmptyVideosState extends StatelessWidget {
  final bool isTrainer;
  final Color courseColor;
  final VoidCallback onUpload;

  const _EmptyVideosState({
    required this.isTrainer,
    required this.courseColor,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: courseColor.withAlpha(20), shape: BoxShape.circle),
              child: Icon(Icons.video_library_outlined,
                  size: 40, color: courseColor),
            ),
            const SizedBox(height: 16),
            Text(
              isTrainer ? 'No videos yet' : 'No videos available',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              isTrainer
                  ? 'Upload the first lesson video for this course.'
                  : 'Your trainer hasn\'t uploaded any videos here yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13, color: const Color(0xFF8A94A6)),
            ),
            if (isTrainer) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_rounded, size: 16),
                label: Text('Upload First Video',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: courseColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}