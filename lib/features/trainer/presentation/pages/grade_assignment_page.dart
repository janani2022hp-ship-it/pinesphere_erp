import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/assignments_service.dart';



class GradeAssignmentPage extends StatefulWidget {
  final TrainerAssignment assignment;

  const GradeAssignmentPage({super.key, required this.assignment});

  @override
  State<GradeAssignmentPage> createState() => _GradeAssignmentPageState();
}

class _GradeAssignmentPageState extends State<GradeAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _gradeController = TextEditingController();
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _gradeController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  InputDecoration _buildDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: AppColors.textGrey),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
    );
  }

  Future<void> _submitGrade() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    await AssignmentsService().gradeAssignment(widget.assignment.id);

    final updatedAssignment = widget.assignment.copyWith(
      status: AssignmentStatus.graded,
      grade: _gradeController.text.trim(),
      feedback: _feedbackController.text.trim(),
    );

    if (!mounted) return;
    Navigator.pop(context, updatedAssignment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight.withAlpha((.16 * 255).round()),
      appBar: AppBar(
        title: Text('Grade Assignment', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: .8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.assignment.title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Text('${widget.assignment.subject} • ${widget.assignment.dueDate}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
                const SizedBox(height: 18),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _gradeController,
                        decoration: _buildDecoration('Grade'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a grade' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _feedbackController,
                        maxLines: 5,
                        decoration: _buildDecoration('Feedback'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter feedback' : null,
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitGrade,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: Text(_isSubmitting ? 'Grading...' : 'Submit Grade', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
