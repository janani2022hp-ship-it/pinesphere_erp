// lib/features/trainer/presentation/pages/create_assignment_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import '../../../student/data/services/assignment_service.dart';
import '../../../../services/course_service.dart';

class CreateAssignmentPage extends StatefulWidget {
  const CreateAssignmentPage({super.key});

  @override
  State<CreateAssignmentPage> createState() => _CreateAssignmentPageState();
}

class _CreateAssignmentPageState extends State<CreateAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final AssignmentService _service = AssignmentService();

  final CourseService _courseService = CourseService();

  // Basic fields
  final _titleCtrl      = TextEditingController();
  final _subjectCtrl    = TextEditingController();
  final _descCtrl       = TextEditingController();
  final _dueDateCtrl    = TextEditingController();
  final _totalMarksCtrl = TextEditingController(text: '100');

  // Course selection
  List<CourseItem> _courses = [];
  String? _selectedCourseId;
  bool _loadingCourses = true;

  // Type selection
  String _type = 'written'; // written | quiz | file

  // Written: list of question rows
  final List<Map<String, TextEditingController>> _questions = [];

  // Quiz: link
  final _quizLinkCtrl = TextEditingController();

  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _addQuestion();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await _courseService.getTrainerCourses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _loadingCourses = false;
        });
      }
    } catch (e) {
      debugPrint('🔴 _loadCourses error: $e');
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    _dueDateCtrl.dispose();
    _totalMarksCtrl.dispose();
    _quizLinkCtrl.dispose();
    for (final q in _questions) {
      q['question']!.dispose();
      q['model_answer']!.dispose();
      q['marks']!.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'question':     TextEditingController(),
        'model_answer': TextEditingController(),
        'marks':        TextEditingController(text: '10'),
      });
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions[index]['question']!.dispose();
      _questions[index]['model_answer']!.dispose();
      _questions[index]['marks']!.dispose();
      _questions.removeAt(index);
    });
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPublishing = true);

    final questions = _type == 'written'
        ? _questions.map((q) => AssignmentQuestion(
              question:    q['question']!.text.trim(),
              modelAnswer: q['model_answer']!.text.trim(),
              marks:       int.tryParse(q['marks']!.text.trim()) ?? 10,
            )).toList()
        : <AssignmentQuestion>[];

    final created = await _service.createAssignment(
      title:          _titleCtrl.text.trim(),
      description:    _descCtrl.text.trim(),
      subject:        _subjectCtrl.text.trim().isEmpty ? 'General' : _subjectCtrl.text.trim(),
      dueDate:        _dueDateCtrl.text.trim(),
      assignmentType: _type,
      questions:      questions,
      quizLink:       _type == 'quiz' ? _quizLinkCtrl.text.trim() : null,
      totalMarks:     int.tryParse(_totalMarksCtrl.text.trim()) ?? 100,
      courseId:       _selectedCourseId,
    );

    if (!mounted) return;
    setState(() => _isPublishing = false);

    if (created != null) {
      Navigator.pop(context, created);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to publish. Check your connection.')),
      );
    }
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 13),
        hintStyle: GoogleFonts.inter(color: AppColors.textGrey.withAlpha(150), fontSize: 13),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Create Assignment',
            style: GoogleFonts.fredoka(
                fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
          children: [
            _sectionCard('📋 Basic Details', [
              TextFormField(
                controller: _titleCtrl,
                decoration: _dec('Title', hint: 'e.g. Algebra Worksheet'),
                style: GoogleFonts.inter(fontSize: 14),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subjectCtrl,
                decoration: _dec('Subject', hint: 'e.g. Mathematics'),
                style: GoogleFonts.inter(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: _dec('Description / Instructions'),
                style: GoogleFonts.inter(fontSize: 14),
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _dueDateCtrl,
                    decoration: _dec('Due Date', hint: 'e.g. 2025-12-31'),
                    style: GoogleFonts.inter(fontSize: 14),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        _dueDateCtrl.text =
                            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                      }
                    },
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: _totalMarksCtrl,
                    decoration: _dec('Total Marks'),
                    style: GoogleFonts.inter(fontSize: 14),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // ── Course dropdown ──────────────────────────────────────────
              _loadingCourses
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📚 Assign to Course',
                          style: GoogleFonts.fredoka(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedCourseId,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              style: GoogleFonts.inter(
                                  fontSize: 14, color: AppColors.textDark),
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(
                                    'All Students (no specific course)',
                                    style: GoogleFonts.inter(
                                        fontSize: 13, color: AppColors.textGrey),
                                  ),
                                ),
                                ..._courses.map((c) => DropdownMenuItem<String?>(
                                      value: c.id,
                                      child: Text(
                                        c.title,
                                        style: GoogleFonts.inter(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedCourseId = val),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _selectedCourseId == null
                              ? '⚠️ No course selected — all students will see this'
                              : '✅ Only students enrolled in this course will see this',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: _selectedCourseId == null
                                ? Colors.orange.shade800
                                : const Color(0xFF45A700),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ]),

            const SizedBox(height: 16),

            // Assignment type selector
            _sectionCard('📝 Assignment Type', [
              Row(children: [
                _typeChip('written', '✍️ Written', Icons.edit_note_rounded),
                const SizedBox(width: 10),
                _typeChip('quiz', '🔗 Quiz Link', Icons.link_rounded),
                const SizedBox(width: 10),
                _typeChip('file', '📎 File Upload', Icons.upload_file_rounded),
              ]),
              const SizedBox(height: 8),
              Text(
                _type == 'written'
                    ? 'Students type their answers directly. AI will auto-grade based on your model answers.'
                    : _type == 'quiz'
                        ? 'Share a Google Form or any quiz link. Students mark it as done after completing.'
                        : 'Students upload a file (PDF, image, doc) as their submission.',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textGrey, height: 1.5),
              ),
            ]),

            const SizedBox(height: 16),

            // Type-specific content
            if (_type == 'written') _buildWrittenSection(),
            if (_type == 'quiz') _buildQuizSection(),
            if (_type == 'file') _buildFileSection(),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPublishing ? null : _publish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: _isPublishing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        _selectedCourseId == null
                            ? '🚀 Publish to All Students'
                            : '🚀 Publish to Course Students',
                        style: GoogleFonts.fredoka(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label, IconData icon) {
    final active = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
                width: 1.5),
          ),
          child: Column(children: [
            Icon(icon,
                size: 18, color: active ? Colors.white : AppColors.textGrey),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppColors.textGrey)),
          ]),
        ),
      ),
    );
  }

  Widget _buildWrittenSection() {
    return _sectionCard('❓ Questions', [
      Text(
          'Add questions with model answers. AI will use these to auto-grade student submissions.',
          style:
              GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey, height: 1.5)),
      const SizedBox(height: 16),
      ..._questions.asMap().entries.map((entry) {
        final i = entry.key;
        final q = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text('${i + 1}',
                      style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              Text('Question ${i + 1}',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              const Spacer(),
              if (_questions.length > 1)
                GestureDetector(
                  onTap: () => _removeQuestion(i),
                  child:
                      const Icon(Icons.close_rounded, size: 18, color: Colors.red),
                ),
            ]),
            const SizedBox(height: 10),
            TextFormField(
              controller: q['question'],
              decoration: _dec('Question text'),
              style: GoogleFonts.inter(fontSize: 13),
              maxLines: 2,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter question' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: q['model_answer'],
              decoration: _dec('Model answer (for AI grading)',
                  hint: 'Expected correct answer'),
              style: GoogleFonts.inter(fontSize: 13),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: q['marks'],
                decoration: _dec('Marks'),
                style: GoogleFonts.inter(fontSize: 13),
                keyboardType: TextInputType.number,
              ),
            ),
          ]),
        );
      }),
      TextButton.icon(
        onPressed: _addQuestion,
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: Text('Add Question',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
    ]);
  }

  Widget _buildQuizSection() {
    return _sectionCard('🔗 Quiz Link', [
      Text('Paste a Google Forms link, Quizlet, or any external quiz URL.',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
      const SizedBox(height: 12),
      TextFormField(
        controller: _quizLinkCtrl,
        decoration:
            _dec('Quiz URL', hint: 'https://forms.google.com/...'),
        style: GoogleFonts.inter(fontSize: 14),
        keyboardType: TextInputType.url,
        validator: (v) {
          if (_type == 'quiz' && (v == null || v.trim().isEmpty)) {
            return 'Enter a quiz link';
          }
          return null;
        },
      ),
    ]);
  }

  Widget _buildFileSection() {
    return _sectionCard('📎 File Submission', [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withAlpha(30),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.primary.withAlpha(80), width: 1.5),
        ),
        child: Column(children: [
          Icon(Icons.upload_file_rounded, size: 40, color: AppColors.primary),
          const SizedBox(height: 8),
          Text('Students will upload a file as their submission',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('Supported: PDF, Word, Images',
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textGrey)),
        ]),
      ),
    ]);
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: .8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 14),
        ...children,
      ]),
    );
  }
}