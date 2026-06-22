import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

import '../models/student_assignment.dart';

class StudentAssignmentSubmissionPage extends StatefulWidget {
  final StudentAssignment assignment;
  final String studentId;

  const StudentAssignmentSubmissionPage({
    super.key,
    required this.assignment,
    required this.studentId,
  });

  @override
  State<StudentAssignmentSubmissionPage> createState() => _StudentAssignmentSubmissionPageState();
}

class _StudentAssignmentSubmissionPageState extends State<StudentAssignmentSubmissionPage> {
  final TextEditingController _submissionController = TextEditingController();
  bool _isSubmitting = false;
  String? _fileName;

  @override
  void dispose() {
    _submissionController.dispose();
    super.dispose();
  }

  Future<void> _handleFileUpload() async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload File', style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)),
        content: Text('This is a mock upload flow for the UI-only assignment pages.', style: GoogleFonts.inter(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _fileName = 'submission_${DateTime.now().millisecondsSinceEpoch}.pdf');
              Navigator.pop(context);
            },
            child: Text('Use mock file', style: GoogleFonts.inter(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textGrey)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_submissionController.text.isEmpty && _fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter an answer or attach a file.', style: GoogleFonts.inter()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context, {'submitted': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Submit Assignment', style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withAlpha((.08 * 255).round()),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.assignment.title, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Text(widget.assignment.description, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey, height: 1.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 8),
                    Text('Due: ${widget.assignment.dueDate}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Your Answer', style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 10),
          TextField(
            controller: _submissionController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Enter your answer here...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
              filled: true,
              fillColor: AppColors.white,
            ),
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
          ),
          const SizedBox(height: 20),
          Text('Attach file (optional)', style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _handleFileUpload,
            child: Container(
              padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                 color: AppColors.primaryLight.withAlpha((.1 * 255).round()),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 34, color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text('Tap to attach a file', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey)),
                  if (_fileName != null) ...[
                    const SizedBox(height: 10),
                    Text(_fileName!, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Submit Assignment', style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
