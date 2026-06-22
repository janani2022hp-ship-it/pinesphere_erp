import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  Future<List<String>> _loadAddedStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final students = prefs.getStringList('trainer_student_names') ?? [];
    return students;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight.withAlpha((.08 * 255).round()),
      appBar: AppBar(
        title: Text('Students', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: FutureBuilder<List<String>>(
        future: _loadAddedStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data ?? [];
          if (students.isEmpty) {
            return Center(
              child: Text(
                'No students have been added yet.',
                style: GoogleFonts.inter(fontSize: 16, color: AppColors.textDark),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${students.length} added student${students.length == 1 ? '' : 's'}',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: students.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final name = students[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          subtitle: Text('Added student', style: GoogleFonts.inter(color: AppColors.textGrey)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
