import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/evaluation_service.dart';
import '../widgets/student_evaluation/feedback_card.dart';
import '../widgets/student_evaluation/marks_entry_card.dart';
import '../widgets/student_evaluation/performance_summary_card.dart';

class StudentEvaluationPage extends StatelessWidget {
  final EvaluationService service = EvaluationService();

  StudentEvaluationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight.withAlpha((.10 * 255).round()),
      appBar: AppBar(
        title: Text('Student Evaluation', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: FutureBuilder<List<EvaluationRecord>>(
        future: service.fetchEvaluations(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final evaluations = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            children: [
              PerformanceSummaryCard(bestStudent: evaluations.first.studentName, strongSubject: evaluations.first.subject),
              const SizedBox(height: 16),
              ...evaluations.map((item) => FeedbackCard(record: item, onSendFeedback: () {}, onRecommendCertificate: () {})),
              const SizedBox(height: 16),
              MarksEntryCard(onSave: () {}, description: 'Enter marks and keep the evaluation up to date.'),
            ],
          );
        },
      ),
    );
  }
}
