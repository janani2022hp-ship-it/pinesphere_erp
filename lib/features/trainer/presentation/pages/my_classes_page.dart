import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/classes_service.dart';
import '../widgets/my_classes/active_class_card.dart';
import '../widgets/my_classes/class_details_card.dart';
import '../widgets/my_classes/lesson_plan_card.dart';
import '../widgets/my_classes/student_count_card.dart';

class MyClassesPage extends StatelessWidget {
  final ClassesService service = ClassesService();

  MyClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight.withAlpha((.12 * 255).round()),
      appBar: AppBar(
        title: Text('My Classes', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: FutureBuilder<List<TrainerClass>>(
        future: service.fetchMyClasses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final classes = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            children: [
              ActiveClassCard(classCount: classes.length, nextSession: classes.first.nextSession),
              const SizedBox(height: 16),
              ...classes.map((trainerClass) => Column(
                    children: [
                      ClassDetailsCard(trainerClass: trainerClass),
                      const SizedBox(height: 12),
                    ],
                  )),
              const SizedBox(height: 16),
              LessonPlanCard(title: 'Week 22 Plan', description: 'Review algebra, run lab practice, and assign reading'),
              const SizedBox(height: 16),
              StudentCountCard(count: classes.fold(0, (sum, item) => sum + item.studentCount)),
            ],
          );
        },
      ),
    );
  }
}
