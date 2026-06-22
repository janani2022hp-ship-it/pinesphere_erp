// lib/features/student/presentation/pages/submit_assignment_page.dart
// Student opens this page to answer/submit an assignment

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../student/data/services/assignment_service.dart';

const _green     = Color(0xFF58CC02);
const _greenDark = Color(0xFF45A700);
const _orange    = Color(0xFFFF9600);
const _blue      = Color(0xFF1CB0F6);
const _blueDark  = Color(0xFF0081C8);
const _bg        = Color(0xFFF9F4EC);
const _cardCream = Color(0xFFFFFAF4);
const _separator = Color(0xFFE5E5EA);
const _labelPrimary   = Color(0xFF1C1C1E);
const _labelTertiary  = Color(0xFF8E8E93);
const _tintGreen  = Color(0xFFEEFBDD);
const _tintBlue   = Color(0xFFE3F5FE);
const _tintOrange = Color(0xFFFFF3E0);

class SubmitAssignmentPage extends StatefulWidget {
  final StudentAssignment assignment;
  final VoidCallback onSubmitted;

  const SubmitAssignmentPage({
    super.key,
    required this.assignment,
    required this.onSubmitted,
  });

  @override
  State<SubmitAssignmentPage> createState() => _SubmitAssignmentPageState();
}

class _SubmitAssignmentPageState extends State<SubmitAssignmentPage> {
  final _service = AssignmentService();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  SubmissionModel? _result;

  // Written: one controller per question
  late List<TextEditingController> _answerControllers;

  @override
  void initState() {
    super.initState();
    _answerControllers = List.generate(
      widget.assignment.questions.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (final c in _answerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final answers = _answerControllers.map((c) => c.text.trim()).toList();
    final result = await _service.submitAssignment(
      widget.assignment.id,
      answers: answers,
    );

    if (!mounted) return;
    setState(() { _submitting = false; _result = result; });

    if (result != null) {
      widget.onSubmitted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission failed. Try again.')),
      );
    }
  }

  Future<void> _submitQuiz() async {
    setState(() => _submitting = true);
    final result = await _service.submitAssignment(
      widget.assignment.id,
      notes: 'Completed via quiz link',
    );
    if (!mounted) return;
    setState(() { _submitting = false; _result = result; });
    if (result != null) widget.onSubmitted();
  }

  Future<void> _submitFile() async {
    // In a real app, use file_picker to pick a file and upload to your server.
    // For now we submit with a placeholder note.
    setState(() => _submitting = true);
    final result = await _service.submitAssignment(
      widget.assignment.id,
      notes: 'File submitted',
      fileUrl: 'pending_upload',
    );
    if (!mounted) return;
    setState(() { _submitting = false; _result = result; });
    if (result != null) widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    // If already submitted/graded — show result
    if (_result != null) return _buildResultView(_result!);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(widget.assignment.title,
            style: GoogleFonts.fredoka(
                fontSize: 18, fontWeight: FontWeight.w700, color: _labelPrimary)),
        backgroundColor: _cardCream,
        foregroundColor: _labelPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // Assignment info header
            _infoCard(),
            const SizedBox(height: 16),

            // Body based on type
            if (widget.assignment.assignmentType == 'written') _buildWritten(),
            if (widget.assignment.assignmentType == 'quiz')    _buildQuiz(),
            if (widget.assignment.assignmentType == 'file')    _buildFile(),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _separator, width: .8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _tintBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(widget.assignment.subject,
                style: GoogleFonts.fredoka(
                    fontSize: 11, fontWeight: FontWeight.w600, color: _blueDark)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _tintOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(widget.assignment.dueDate,
                style: GoogleFonts.fredoka(
                    fontSize: 11, fontWeight: FontWeight.w600, color: _orange)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(widget.assignment.description,
            style: GoogleFonts.inter(fontSize: 13, color: _labelTertiary, height: 1.5)),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.stars_rounded, size: 14, color: _orange),
          const SizedBox(width: 4),
          Text('Total marks: ${widget.assignment.totalMarks}',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _orange)),
        ]),
      ]),
    );
  }

  // ── Written ───────────────────────────────────────────────────────────────

  Widget _buildWritten() {
    return Column(children: [
      ...widget.assignment.questions.asMap().entries.map((entry) {
        final i = entry.key;
        final q = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardCream,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _separator, width: .8),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                    color: _blue, borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text('${i + 1}',
                      style: GoogleFonts.fredoka(
                          fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(q.question,
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _labelPrimary)),
              ),
            ]),
            const SizedBox(height: 6),
            Text('[${q.marks} marks]',
                style: GoogleFonts.inter(fontSize: 11, color: _labelTertiary)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _answerControllers[i],
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                hintStyle: GoogleFonts.inter(color: _labelTertiary, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _separator)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _separator)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _green, width: 1.5)),
              ),
              style: GoogleFonts.inter(fontSize: 13, color: _labelPrimary),
              maxLines: 4,
              validator: (v) => v == null || v.trim().isEmpty ? 'Please answer this question' : null,
            ),
          ]),
        );
      }),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _submitting
              ? const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('Submit & Auto-Grade',
                      style: GoogleFonts.fredoka(
                          fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ]),
        ),
      ),
    ]);
  }

  // ── Quiz ──────────────────────────────────────────────────────────────────

  Widget _buildQuiz() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardCream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _separator),
        ),
        child: Column(children: [
          const Icon(Icons.open_in_new_rounded, size: 48, color: _blue),
          const SizedBox(height: 12),
          Text('Open the quiz link, complete it, then come back and mark as done.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: _labelTertiary, height: 1.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final url = Uri.parse(widget.assignment.quizLink ?? '');
                if (await canLaunchUrl(url)) launchUrl(url);
              },
              icon: const Icon(Icons.link_rounded),
              label: Text('Open Quiz',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: const BorderSide(color: _blue),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submitQuiz,
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
              label: _submitting
                  ? const SizedBox(height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('I\'ve Completed the Quiz',
                      style: GoogleFonts.fredoka(
                          fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }

  // ── File ──────────────────────────────────────────────────────────────────

  Widget _buildFile() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardCream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _separator),
        ),
        child: Column(children: [
          const Icon(Icons.upload_file_rounded, size: 48, color: _orange),
          const SizedBox(height: 12),
          Text('Upload your completed assignment file',
              style: GoogleFonts.fredoka(
                  fontSize: 15, fontWeight: FontWeight.w700, color: _labelPrimary),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('PDF, Word, or Image accepted',
              style: GoogleFonts.inter(fontSize: 12, color: _labelTertiary)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: integrate file_picker package
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File picker — add file_picker package')),
                );
              },
              icon: const Icon(Icons.attach_file_rounded),
              label: Text('Choose File',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _orange,
                side: const BorderSide(color: _orange),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submitFile,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: _submitting
                  ? const SizedBox(height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Submit File',
                      style: GoogleFonts.fredoka(
                          fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }

  // ── Result view after submission ──────────────────────────────────────────

  Widget _buildResultView(SubmissionModel result) {
    final isGraded = result.status == 'Graded';
    final color = isGraded ? _green : _blue;
    final tint  = isGraded ? _tintGreen : _tintBlue;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text('Submission Result',
            style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: _cardCream,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withAlpha(80)),
            ),
            child: Column(children: [
              Icon(isGraded ? Icons.stars_rounded : Icons.check_circle_rounded,
                  size: 56, color: color),
              const SizedBox(height: 12),
              Text(isGraded ? '🎉 Assignment Graded!' : '✅ Submitted Successfully!',
                  style: GoogleFonts.fredoka(
                      fontSize: 20, fontWeight: FontWeight.w700, color: color),
                  textAlign: TextAlign.center),
              if (isGraded && result.marks != null) ...[
                const SizedBox(height: 16),
                Text('${result.marks} / ${widget.assignment.totalMarks}',
                    style: GoogleFonts.fredoka(
                        fontSize: 36, fontWeight: FontWeight.w700, color: color)),
                Text('marks', style: GoogleFonts.inter(fontSize: 14, color: _labelTertiary)),
              ],
              if (isGraded && result.grade != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(12)),
                  child: Text('Grade: ${result.grade}',
                      style: GoogleFonts.fredoka(
                          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
              if (isGraded && result.feedback != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Feedback',
                        style: GoogleFonts.fredoka(
                            fontSize: 14, fontWeight: FontWeight.w700, color: _labelPrimary)),
                    const SizedBox(height: 6),
                    Text(result.feedback!,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: _labelTertiary, height: 1.5)),
                  ]),
                ),
              ],
              if (!isGraded) ...[
                const SizedBox(height: 12),
                Text('Your submission has been recorded.\nYour trainer will review and grade it.',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: _labelTertiary, height: 1.5),
                    textAlign: TextAlign.center),
              ],
            ]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Back to Assignments',
                style: GoogleFonts.fredoka(
                    fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}