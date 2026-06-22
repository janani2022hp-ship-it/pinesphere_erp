// lib/features/trainer/presentation/pages/assignments_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

import 'create_assignment_page.dart';
import '../../../student/data/services/assignment_service.dart';
import '../widgets/assignments/submission_summary_card.dart';
import '../widgets/assignments/upload_assignment_card.dart';

class TrainerAssignmentsPage extends StatefulWidget {
  const TrainerAssignmentsPage({super.key});

  @override
  State<TrainerAssignmentsPage> createState() => _TrainerAssignmentsPageState();
}

class _TrainerAssignmentsPageState extends State<TrainerAssignmentsPage> {
  final _service = AssignmentService();
  List<TrainerAssignmentModel> _assignments = [];
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
      final data = await _service.fetchTrainerAssignments();
      if (mounted) setState(() { _assignments = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load'; _isLoading = false; });
    }
  }

  Future<void> _handleCreate() async {
    final created = await Navigator.push<TrainerAssignmentModel>(
      context,
      MaterialPageRoute(builder: (_) => const CreateAssignmentPage()),
    );
    if (created != null && mounted) {
      setState(() => _assignments.insert(0, created));
    }
  }

  Future<void> _viewSubmissions(TrainerAssignmentModel assignment) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SubmissionsPage(assignment: assignment, service: _service),
      ),
    );
  }

  List<TrainerAssignmentModel> _byStatus(String status) =>
      _assignments.where((a) => a.status == status).toList();

  // Type label + icon
  String _typeLabel(String type) {
    switch (type) {
      case 'quiz': return '🔗 Quiz';
      case 'file': return '📎 File';
      default:     return '✍️ Written';
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'quiz': return const Color(0xFF1CB0F6);
      case 'file': return const Color(0xFFFF9600);
      default:     return const Color(0xFF9B59B6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('📝 Assignments',
            style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(_error!, style: GoogleFonts.inter(color: AppColors.textGrey)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _load, child: const Text('Retry')),
                ]))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  children: [
                    SubmissionSummaryCard(
                      submitted:         _byStatus('Submitted').length,
                      reviewPending:     _byStatus('Submitted').length,
                      pendingSubmission: _byStatus('Open').length + _byStatus('Late').length,
                    ),
                    const SizedBox(height: 16),
                    UploadAssignmentCard(onUpload: _handleCreate),
                    const SizedBox(height: 24),
                    if (_assignments.isEmpty)
                      Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.assignment_outlined, size: 64, color: AppColors.primary.withAlpha(100)),
                        const SizedBox(height: 12),
                        Text('No assignments yet',
                            style: GoogleFonts.fredoka(
                                fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                      ]))
                    else ...[
                      Text('📚 Your Assignments',
                          style: GoogleFonts.fredoka(
                              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      const SizedBox(height: 16),
                      ..._assignments.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _AssignmentCard(
                          assignment: a,
                          typeLabel: _typeLabel(a.assignmentType),
                          typeColor: _typeColor(a.assignmentType),
                          onViewSubmissions: () => _viewSubmissions(a),
                        ),
                      )),
                    ],
                  ],
                ),
    );
  }
}

// ── Assignment card ───────────────────────────────────────────────────────────
class _AssignmentCard extends StatelessWidget {
  final TrainerAssignmentModel assignment;
  final String typeLabel;
  final Color typeColor;
  final VoidCallback onViewSubmissions;

  const _AssignmentCard({
    required this.assignment,
    required this.typeLabel,
    required this.typeColor,
    required this.onViewSubmissions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [BoxShadow(
            color: AppColors.primary.withAlpha(12),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(assignment.title,
                style: GoogleFonts.fredoka(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Row(children: [
              Text(assignment.subject,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(typeLabel,
                    style: GoogleFonts.inter(
                        fontSize: 10, color: typeColor, fontWeight: FontWeight.w700)),
              ),
            ]),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.schedule_rounded, size: 12, color: Colors.amber),
              const SizedBox(width: 4),
              Text(assignment.dueDate.split(',')[0],
                  style: GoogleFonts.inter(
                      fontSize: 10, color: Colors.amber.shade900, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),

        const SizedBox(height: 10),
        Text(assignment.description,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey, height: 1.5),
            maxLines: 2, overflow: TextOverflow.ellipsis),

        const SizedBox(height: 12),

        // Stats row
        Row(children: [
          _statChip(Icons.check_circle_rounded,
              '${assignment.submissions} submitted', AppColors.primary),
          const SizedBox(width: 8),
          if (assignment.assignmentType == 'written')
            _statChip(Icons.quiz_rounded,
                '${assignment.questions.length} questions', Colors.purple),
          if (assignment.assignmentType == 'quiz')
            _statChip(Icons.link_rounded, 'Quiz link', const Color(0xFF1CB0F6)),
          if (assignment.assignmentType == 'file')
            _statChip(Icons.upload_file_rounded, 'File upload', const Color(0xFFFF9600)),
        ]),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onViewSubmissions,
            icon: const Icon(Icons.remove_red_eye_rounded, size: 16, color: Colors.white),
            label: Text('View Submissions (${assignment.submissions})',
                style: GoogleFonts.fredoka(
                    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Submissions page ──────────────────────────────────────────────────────────
class _SubmissionsPage extends StatefulWidget {
  final TrainerAssignmentModel assignment;
  final AssignmentService service;

  const _SubmissionsPage({required this.assignment, required this.service});

  @override
  State<_SubmissionsPage> createState() => _SubmissionsPageState();
}

class _SubmissionsPageState extends State<_SubmissionsPage> {
  List<SubmissionModel> _submissions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await widget.service.fetchSubmissions(widget.assignment.id);
    if (mounted) setState(() { _submissions = data; _loading = false; });
  }

  Future<void> _grade(SubmissionModel sub) async {
    final gradeCtrl    = TextEditingController(text: sub.grade ?? '');
    final feedbackCtrl = TextEditingController(text: sub.feedback ?? '');
    final marksCtrl    = TextEditingController(
        text: sub.marks?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Grade Submission',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: marksCtrl,
            decoration: InputDecoration(
              labelText: 'Marks (out of ${widget.assignment.totalMarks})',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: gradeCtrl,
            decoration: const InputDecoration(
              labelText: 'Grade (A, B, C...)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: feedbackCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Feedback',
              border: OutlineInputBorder(),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await widget.service.gradeSubmission(
                sub.id,
                grade:    gradeCtrl.text.trim(),
                feedback: feedbackCtrl.text.trim(),
                marks:    int.tryParse(marksCtrl.text.trim()),
              );
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Graded successfully!')));
                _load();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Submit Grade',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Submissions',
            style: GoogleFonts.fredoka(
                fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _submissions.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('📭', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('No submissions yet',
                      style: GoogleFonts.fredoka(
                          fontSize: 16, color: AppColors.textGrey)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _submissions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final sub = _submissions[i];
                    final isGraded = sub.status == 'Graded';
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withAlpha(6),
                            blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary.withAlpha(30),
                            child: Text('${i + 1}',
                                style: GoogleFonts.fredoka(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Student ${i + 1}',
                                style: GoogleFonts.inter(
                                    fontSize: 14, fontWeight: FontWeight.w600,
                                    color: AppColors.textDark)),
                            Text(sub.status,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: isGraded ? const Color(0xFF45A700) : Colors.orange,
                                    fontWeight: FontWeight.w600)),
                          ])),
                          if (isGraded && sub.marks != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEFBDD),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('${sub.marks}/${widget.assignment.totalMarks}',
                                  style: GoogleFonts.fredoka(
                                      fontSize: 13, fontWeight: FontWeight.w700,
                                      color: const Color(0xFF45A700))),
                            ),
                        ]),

                        // Show answers for written assignments
                        if (widget.assignment.assignmentType == 'written' &&
                            sub.answers.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ...sub.answers.asMap().entries.map((e) {
                            final qi = e.key;
                            final answer = e.value;
                            final question = qi < widget.assignment.questions.length
                                ? widget.assignment.questions[qi].question
                                : 'Q${qi + 1}';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F7FA),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Q${qi + 1}: $question',
                                      style: GoogleFonts.inter(
                                          fontSize: 11, fontWeight: FontWeight.w600,
                                          color: AppColors.textGrey)),
                                  const SizedBox(height: 4),
                                  Text(answer,
                                      style: GoogleFonts.inter(
                                          fontSize: 12, color: AppColors.textDark)),
                                ]),
                              ),
                            );
                          }),
                        ],

                        // AI feedback if already graded
                        if (isGraded && sub.feedback != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEFBDD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('💬', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(sub.feedback!,
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: AppColors.textDark, height: 1.4))),
                            ]),
                          ),
                        ],

                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _grade(sub),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isGraded
                                    ? AppColors.textGrey.withAlpha(40)
                                    : AppColors.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(isGraded ? '✏️ Re-grade' : '📝 Grade',
                                  style: GoogleFonts.fredoka(
                                      fontSize: 13, fontWeight: FontWeight.w700,
                                      color: isGraded ? AppColors.textDark : Colors.white)),
                            ),
                          ),
                        ]),
                      ]),
                    );
                  },
                ),
    );
  }
}