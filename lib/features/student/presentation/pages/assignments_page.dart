// lib/features/student/presentation/pages/assignments_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../student/data/services/assignment_service.dart';
import 'submit_assignment_page.dart';

// ── Colours ───────────────────────────────────────────────────────────────────
const _green      = Color(0xFF58CC02);
const _greenDark  = Color(0xFF45A700);
const _orange     = Color(0xFFFF9600);
const _blue       = Color(0xFF1CB0F6);
const _blueDark   = Color(0xFF0081C8);
const _red        = Color(0xFFFF4B4B);
const _redDark    = Color(0xFFCB3E3E);

const _bg         = Color(0xFFF9F4EC);
const _cardCream  = Color(0xFFFFFAF4);
const _tintGreen  = Color(0xFFEEFBDD);
const _tintBlue   = Color(0xFFE3F5FE);
const _tintOrange = Color(0xFFFFF3E0);
const _tintRed    = Color(0xFFFFECEC);
const _tintPurple = Color(0xFFF7EEFF);
const _purple     = Color(0xFF9B59B6);
const _labelPrimary   = Color(0xFF1C1C1E);
const _labelTertiary  = Color(0xFF8E8E93);
const _separator      = Color(0xFFE5E5EA);

TextStyle _title2({Color? color}) => GoogleFonts.fredoka(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: color ?? _labelPrimary, height: 1.2);

TextStyle _subheadline({Color? color}) => GoogleFonts.fredoka(
    fontSize: 13, fontWeight: FontWeight.w500,
    color: color ?? _labelTertiary, height: 1.4);

TextStyle _caption1({Color? color}) => GoogleFonts.fredoka(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: color ?? _labelTertiary);

BoxDecoration _tintCard(Color tint, {double radius = 18}) => BoxDecoration(
    color: tint,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: tint.withAlpha(153), width: 0.5),
    boxShadow: [
      BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 12, offset: const Offset(0, 3)),
    ]);

// ── Page ──────────────────────────────────────────────────────────────────────
class StudentAssignmentsPage extends StatefulWidget {
  const StudentAssignmentsPage({super.key});

  @override
  State<StudentAssignmentsPage> createState() => _StudentAssignmentsPageState();
}

class _StudentAssignmentsPageState extends State<StudentAssignmentsPage> {
  int _selectedFilter = 0;
  final _filters     = ['All', 'Pending', 'Done', 'Overdue'];
  final _filterIcons = [
    Icons.list_rounded,
    Icons.access_time_rounded,
    Icons.check_rounded,
    Icons.warning_amber_rounded,
  ];

  final _service = AssignmentService();
  List<StudentAssignment> _all = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _service.fetchMyAssignments();
      if (mounted) setState(() { _all = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load assignments'; _isLoading = false; });
    }
  }

  List<StudentAssignment> get _filtered {
    switch (_selectedFilter) {
      case 1: return _all.where((a) => a.status == 'Open').toList();
      case 2: return _all.where((a) =>
          a.status == 'Submitted' || a.status == 'Graded').toList();
      case 3: return _all.where((a) => a.status == 'Late').toList();
      default: return _all;
    }
  }

  void _openSubmit(StudentAssignment a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubmitAssignmentPage(
          assignment: a,
          onSubmitted: _load,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onRefresh: _load),
            _FilterRow(
              filters: _filters,
              icons: _filterIcons,
              selected: _selectedFilter,
              onSelect: (i) => setState(() => _selectedFilter = i),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: _green));

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: _labelTertiary),
            const SizedBox(height: 12),
            Text(_error!, style: _subheadline()),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(12)),
                child: Text('Try again',
                    style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    }

    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No assignments here', style: _subheadline()),
        ]),
      );
    }

    return RefreshIndicator(
      color: _green,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        children: [
          _SummaryRow(assignments: _all),
          const SizedBox(height: 16),
          ...list.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AssignmentCard(
              assignment: a,
              onTap: () => _openSubmit(a),
            ),
          )),
        ],
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final VoidCallback onRefresh;
  const _TopBar({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: _cardCream,
        border: Border(bottom: BorderSide(color: _separator, width: 0.6)),
      ),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Track your work', style: _caption1()),
            const SizedBox(height: 4),
            Text('Assignments', style: _title2()),
          ],
        )),
        GestureDetector(
          onTap: onRefresh,
          child: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: _tintOrange, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.refresh_rounded, color: _orange),
          ),
        ),
      ]),
    );
  }
}

// ── Filter row ────────────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final List<String> filters;
  final List<IconData> icons;
  final int selected;
  final ValueChanged<int> onSelect;
  const _FilterRow({required this.filters, required this.icons,
      required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _cardCream,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(filters.length, (i) {
            final active = i == selected;
            return GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? _tintGreen : _cardCream,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: active ? _green.withAlpha(71) : _separator),
                ),
                child: Row(children: [
                  Icon(icons[i], size: 14, color: active ? _greenDark : _labelTertiary),
                  const SizedBox(width: 6),
                  Text(filters[i], style: _subheadline(color: active ? _greenDark : _labelTertiary)),
                ]),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final List<StudentAssignment> assignments;
  const _SummaryRow({required this.assignments});

  @override
  Widget build(BuildContext context) {
    final pending = assignments.where((a) => a.status == 'Open').length;
    final done    = assignments.where((a) =>
        a.status == 'Submitted' || a.status == 'Graded').length;
    final overdue = assignments.where((a) => a.status == 'Late').length;
    return Row(children: [
      Expanded(child: _SummaryCard(label: 'Pending', value: '$pending', color: _orange)),
      const SizedBox(width: 10),
      Expanded(child: _SummaryCard(label: 'Done',    value: '$done',    color: _green)),
      const SizedBox(width: 10),
      Expanded(child: _SummaryCard(label: 'Overdue', value: '$overdue', color: _red)),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _tintCard(color.withAlpha(46)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label, style: _caption1()),
      ]),
    );
  }
}

// ── Assignment card ───────────────────────────────────────────────────────────
class _AssignmentCard extends StatelessWidget {
  final StudentAssignment assignment;
  final VoidCallback onTap;
  const _AssignmentCard({required this.assignment, required this.onTap});

  bool get _isDone => assignment.status == 'Submitted' || assignment.status == 'Graded';
  bool get _isLate => assignment.status == 'Late';
  bool get _isGraded => assignment.status == 'Graded';

  Color get _badgeBg    => _isLate ? _tintRed : _isDone ? _tintGreen : _tintOrange;
  Color get _badgeColor => _isLate ? _redDark : _isDone ? _greenDark : _orange;

  // Type icon and color
  IconData get _typeIcon {
    switch (assignment.assignmentType) {
      case 'quiz': return Icons.link_rounded;
      case 'file': return Icons.upload_file_rounded;
      default:     return Icons.edit_note_rounded;
    }
  }

  Color get _typeColor {
    switch (assignment.assignmentType) {
      case 'quiz': return _blue;
      case 'file': return _orange;
      default:     return _purple;
    }
  }

  Color get _typeTint {
    switch (assignment.assignmentType) {
      case 'quiz': return _tintBlue;
      case 'file': return _tintOrange;
      default:     return _tintPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isDone ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardCream,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _isLate ? _red.withAlpha(100) : _separator,
            width: _isLate ? 1.2 : 0.8,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: _typeTint, borderRadius: BorderRadius.circular(14)),
              child: Icon(_typeIcon, color: _typeColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(assignment.title, style: _title2()),
              const SizedBox(height: 2),
              Text(assignment.subject, style: _caption1()),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: _badgeBg, borderRadius: BorderRadius.circular(16)),
              child: Text(assignment.status,
                  style: GoogleFonts.fredoka(
                      fontSize: 11, fontWeight: FontWeight.w600, color: _badgeColor)),
            ),
          ]),

          // Grade row if graded
          if (_isGraded && assignment.marks != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: _tintGreen, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.stars_rounded, color: _greenDark, size: 16),
                const SizedBox(width: 8),
                Text('${assignment.marks}/${assignment.totalMarks} marks',
                    style: GoogleFonts.fredoka(
                        fontSize: 13, fontWeight: FontWeight.w700, color: _greenDark)),
                if (assignment.grade != null) ...[
                  const SizedBox(width: 8),
                  Text('• Grade: ${assignment.grade}',
                      style: GoogleFonts.inter(fontSize: 12, color: _greenDark, fontWeight: FontWeight.w600)),
                ],
              ]),
            ),
          ],

          const SizedBox(height: 12),
          Divider(color: _separator, thickness: 0.6),
          const SizedBox(height: 10),

          Row(children: [
            _InfoChip(icon: Icons.access_time_rounded, text: assignment.dueDate),
            const SizedBox(width: 8),
            _InfoChip(
              icon: _typeIcon,
              text: assignment.assignmentType == 'written'
                  ? '${assignment.questions.length} questions'
                  : assignment.assignmentType == 'quiz'
                      ? 'Quiz link'
                      : 'File upload',
            ),
            const Spacer(),
            if (_isDone)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: _tintGreen, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.check_rounded, color: _greenDark, size: 14),
                  const SizedBox(width: 4),
                  Text('Done', style: GoogleFonts.fredoka(
                      fontSize: 12, fontWeight: FontWeight.w700, color: _greenDark)),
                ]),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _isLate ? _red : _green,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                    color: (_isLate ? _red : _green).withAlpha(76),
                    blurRadius: 6, offset: const Offset(0, 3),
                  )],
                ),
                child: Text(
                  _isLate ? 'Submit now' : 'Start',
                  style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
          ]),
        ]),
      ),
    );
  }
}

// ── Info chip ─────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _separator, width: 0.8),
      ),
      child: Row(children: [
        Icon(icon, size: 12, color: _labelTertiary),
        const SizedBox(width: 5),
        Text(text, style: _caption1()),
      ]),
    );
  }
}