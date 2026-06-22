from pathlib import Path

files = {
    'lib/features/trainer/data/services/assignments_service.dart': """import 'dart:async';

class TrainerAssignment {
  final String id;
  final String title;
  final String subject;
  final String dueDate;
  final String status;
  final int submissions;

  TrainerAssignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.status,
    required this.submissions,
  });
}

class AssignmentsService {
  Future<List<TrainerAssignment>> fetchAssignments() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      TrainerAssignment(
        id: 'a1',
        title: 'Algebra worksheet review',
        subject: 'Mathematics',
        dueDate: 'Today, 5:00 PM',
        status: 'Open',
        submissions: 18,
      ),
      TrainerAssignment(
        id: 'a2',
        title: 'Physics lab grading',
        subject: 'Physics',
        dueDate: 'Tomorrow',
        status: 'Pending',
        submissions: 12,
      ),
      TrainerAssignment(
        id: 'a3',
        title: 'English essay feedback',
        subject: 'English',
        dueDate: 'In 2 days',
        status: 'Draft',
        submissions: 24,
      ),
    ];
  }

  Future<void> gradeAssignment(String assignmentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> publishAssignment(String assignmentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
""",
    'lib/features/trainer/data/services/attendance_service.dart': """import 'dart:async';

class AttendanceRecord {
  final String date;
  final int present;
  final int absent;
  final String status;

  AttendanceRecord({
    required this.date,
    required this.present,
    required this.absent,
    required this.status,
  });
}

class AttendanceService {
  Future<List<AttendanceRecord>> fetchAttendanceHistory() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      AttendanceRecord(date: 'Mon 3 Jun', present: 21, absent: 3, status: 'Completed'),
      AttendanceRecord(date: 'Tue 4 Jun', present: 23, absent: 1, status: 'Completed'),
      AttendanceRecord(date: 'Wed 5 Jun', present: 20, absent: 4, status: 'Completed'),
    ];
  }

  Future<void> submitDailyAttendance(String classId, List<String> presentStudents) async {
    await Future.delayed(const Duration(milliseconds: 250));
  }
}
""",
    'lib/features/trainer/data/services/classes_service.dart': """import 'dart:async';

class TrainerClass {
  final String id;
  final String title;
  final String subject;
  final int studentCount;
  final String nextSession;

  TrainerClass({
    required this.id,
    required this.title,
    required this.subject,
    required this.studentCount,
    required this.nextSession,
  });
}

class ClassesService {
  Future<List<TrainerClass>> fetchMyClasses() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      TrainerClass(
        id: 'c1',
        title: 'Grade 8 Mathematics',
        subject: 'Mathematics',
        studentCount: 22,
        nextSession: 'Today • 09:30 AM',
      ),
      TrainerClass(
        id: 'c2',
        title: 'Physics Lab Group',
        subject: 'Physics',
        studentCount: 18,
        nextSession: 'Today • 12:00 PM',
      ),
      TrainerClass(
        id: 'c3',
        title: 'English Literature',
        subject: 'English',
        studentCount: 20,
        nextSession: 'Thu • 02:00 PM',
      ),
    ];
  }
}
""",
    'lib/features/trainer/data/services/evaluation_service.dart': """import 'dart:async';

class EvaluationRecord {
  final String studentName;
  final String subject;
  final String progress;
  final String recommendation;

  EvaluationRecord({
    required this.studentName,
    required this.subject,
    required this.progress,
    required this.recommendation,
  });
}

class EvaluationService {
  Future<List<EvaluationRecord>> fetchEvaluations() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      EvaluationRecord(
        studentName: 'Anaya Sharma',
        subject: 'Mathematics',
        progress: 'Strong progress',
        recommendation: 'Award certificate',
      ),
      EvaluationRecord(
        studentName: 'Rohan Verma',
        subject: 'Physics',
        progress: 'Needs improvement',
        recommendation: 'Extra coaching',
      ),
      EvaluationRecord(
        studentName: 'Nisha Patel',
        subject: 'English',
        progress: 'Good performance',
        recommendation: 'Continue practice',
      ),
    ];
  }

  Future<void> submitFeedback(String studentId, String feedback) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> recommendCertificate(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
""",
    'lib/features/trainer/data/services/live_classes_service.dart': """import 'dart:async';

class TrainerLiveClass {
  final String id;
  final String title;
  final String subject;
  final String schedule;
  final bool isLive;
  final int attendees;

  TrainerLiveClass({
    required this.id,
    required this.title,
    required this.subject,
    required this.schedule,
    required this.isLive,
    required this.attendees,
  });
}

class LiveClassesService {
  Future<List<TrainerLiveClass>> fetchLiveSessions() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      TrainerLiveClass(
        id: 'l1',
        title: 'Math revision session',
        subject: 'Mathematics',
        schedule: 'Live now',
        isLive: true,
        attendees: 19,
      ),
      TrainerLiveClass(
        id: 'l2',
        title: 'Physics lab Q&A',
        subject: 'Physics',
        schedule: 'Today • 02:30 PM',
        isLive: false,
        attendees: 0,
      ),
    ];
  }

  Future<void> startSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
""",
    'lib/features/trainer/data/services/timetable_service.dart': """import 'dart:async';

class TimetableEvent {
  final String day;
  final String subject;
  final String time;
  final String location;

  TimetableEvent({
    required this.day,
    required this.subject,
    required this.time,
    required this.location,
  });
}

class TimetableService {
  Future<List<TimetableEvent>> fetchWeeklySchedule() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      TimetableEvent(day: 'Mon', subject: 'Mathematics', time: '09:30 AM', location: 'Room 204'),
      TimetableEvent(day: 'Tue', subject: 'Physics', time: '11:00 AM', location: 'Lab 1'),
      TimetableEvent(day: 'Wed', subject: 'English', time: '01:30 PM', location: 'Room 108'),
    ];
  }

  Future<void> requestLeave(String reason, String from, String to) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
""",
    'lib/features/trainer/data/services/trainer_api_service.dart': """import 'dart:async';

class TrainerProfile {
  final String name;
  final String subject;
  final String experience;
  final String email;

  TrainerProfile({
    required this.name,
    required this.subject,
    required this.experience,
    required this.email,
  });
}

class TrainerApiService {
  Future<TrainerProfile> fetchProfile() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return TrainerProfile(
      name: 'Meera Kapoor',
      subject: 'Mathematics & Physics',
      experience: '8 years teaching experience',
      email: 'meera.kapoor@pinesphere.com',
    );
  }

  Future<List<String>> fetchQualifications() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return ['M.Sc Mathematics', 'B.Ed.', 'Certificate in Physics Education'];
  }

  Future<void> updateSetting(String key, bool value) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
""",
    'lib/features/trainer/presentation/pages/assignments_page.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/assignments_service.dart';
import '../widgets/assignments/assignment_tile.dart';
import '../widgets/assignments/submission_summary_card.dart';
import '../widgets/assignments/upload_assignment_card.dart';

class AssignmentsPage extends StatelessWidget {
  final AssignmentsService service = AssignmentsService();

  AssignmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight.withOpacity(.16),
      appBar: AppBar(
        title: Text('Trainer Assignments', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: FutureBuilder<List<TrainerAssignment>>(
        future: service.fetchAssignments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final assignments = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            children: [
              SubmissionSummaryCard(total: assignments.length, pending: assignments.where((a) => a.status != 'Open').length),
              const SizedBox(height: 16),
              UploadAssignmentCard(onUpload: () {}),
              const SizedBox(height: 20),
              Text('Review assignments', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 12),
              ...assignments.map((assignment) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AssignmentTile(
                      assignment: assignment,
                      onGrade: () {},
                      onPublish: () {},
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/pages/attendance_page.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/attendance_service.dart';
import '../widgets/attendance/attendance_history_table.dart';
import '../widgets/attendance/attendance_marking_card.dart';
import '../widgets/attendance/attendance_stats_card.dart';

class AttendancePage extends StatelessWidget {
  final AttendanceService service = AttendanceService();

  AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight.withOpacity(.10),
      appBar: AppBar(
        title: Text('Attendance Control', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: FutureBuilder<List<AttendanceRecord>>(
        future: service.fetchAttendanceHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            children: [
              AttendanceStatsCard(totalStudents: 24, presentToday: 22, absentToday: 2),
              const SizedBox(height: 16),
              AttendanceMarkingCard(onSubmit: () {}, subject: 'Mathematics • 9:30 AM'),
              const SizedBox(height: 20),
              AttendanceHistoryTable(records: history),
            ],
          );
        },
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/pages/my_classes_page.dart': """import 'package:flutter/material.dart';
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
      backgroundColor: AppColors.primaryLight.withOpacity(.12),
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
""",
    'lib/features/trainer/presentation/pages/student_evaluation_page.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/evaluation_service.dart';
import '../widgets/student_evaluation/certificate_recommendation_card.dart';
import '../widgets/student_evaluation/feedback_card.dart';
import '../widgets/student_evaluation/marks_entry_card.dart';
import '../widgets/student_evaluation/performance_summary_card.dart';

class StudentEvaluationPage extends StatelessWidget {
  final EvaluationService service = EvaluationService();

  StudentEvaluationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight.withOpacity(.10),
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
""",
    'lib/features/trainer/presentation/pages/timetable_page.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/timetable_service.dart';
import '../widgets/timetable/daily_schedule_card.dart';
import '../widgets/timetable/leave_application_form.dart';
import '../widgets/timetable/leave_history_card.dart';
import '../widgets/timetable/weekly_schedule_card.dart';

class TimetablePage extends StatelessWidget {
  final TimetableService service = TimetableService();

  TimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight.withOpacity(.08),
      appBar: AppBar(
        title: Text('Trainer Timetable', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: FutureBuilder<List<TimetableEvent>>(
        future: service.fetchWeeklySchedule(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            children: [
              WeeklyScheduleCard(events: events),
              const SizedBox(height: 18),
              DailyScheduleCard(event: events.first),
              const SizedBox(height: 18),
              LeaveApplicationForm(onSubmit: () {}),
              const SizedBox(height: 18),
              LeaveHistoryCard(records: const ['Leave approved • 2 Jun', 'Leave pending • 25 May']),
            ],
          );
        },
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/pages/trainer_profile_page.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/trainer_api_service.dart';
import '../widgets/profile/qualification_card.dart';
import '../widgets/profile/settings_tile.dart';
import '../widgets/profile/trainer_info_card.dart';

class TrainerProfilePage extends StatefulWidget {
  const TrainerProfilePage({super.key});

  @override
  State<TrainerProfilePage> createState() => _TrainerProfilePageState();
}

class _TrainerProfilePageState extends State<TrainerProfilePage> {
  final TrainerApiService service = TrainerApiService();
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight.withOpacity(.12),
      appBar: AppBar(
        title: Text('Trainer Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: FutureBuilder<TrainerProfile>(
        future: service.fetchProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            children: [
              TrainerInfoCard(profile: profile),
              const SizedBox(height: 16),
              QualificationCard(qualifications: const ['M.Sc Mathematics', 'B.Ed.', 'Physics Education Program']),
              const SizedBox(height: 16),
              SettingsTile(label: 'Notifications', value: notificationsEnabled, onChanged: (value) {
                setState(() { notificationsEnabled = value; });
                service.updateSetting('notifications', value);
              }),
              const SettingsTile(label: 'Dark mode', value: false, onChanged: null),
            ],
          );
        },
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/assignments/assignment_tile.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/assignments_service.dart';

class AssignmentTile extends StatelessWidget {
  final TrainerAssignment assignment;
  final VoidCallback onGrade;
  final VoidCallback onPublish;

  const AssignmentTile({
    super.key,
    required this.assignment,
    required this.onGrade,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(assignment.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('${assignment.subject} • ${assignment.dueDate}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('${assignment.submissions} submissions', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: onGrade, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Grade')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: onPublish, style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary), child: const Text('Publish')),
            ],
          ),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/assignments/submission_summary_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class SubmissionSummaryCard extends StatelessWidget {
  final int total;
  final int pending;

  const SubmissionSummaryCard({super.key, required this.total, required this.pending});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: .7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SummaryItem(label: 'Total assignments', value: total.toString()),
          _SummaryItem(label: 'Pending review', value: pending.toString()),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
      ],
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/assignments/submission_tile.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class SubmissionTile extends StatelessWidget {
  final String studentName;
  final String assignmentTitle;
  final String submittedAt;
  final bool graded;

  const SubmissionTile({
    super.key,
    required this.studentName,
    required this.assignmentTitle,
    required this.submittedAt,
    required this.graded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(studentName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(assignmentTitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          Text(graded ? 'Graded' : 'Pending', style: GoogleFonts.inter(color: graded ? Colors.green : AppColors.primary)),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/assignments/upload_assignment_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class UploadAssignmentCard extends StatelessWidget {
  final VoidCallback onUpload;

  const UploadAssignmentCard({super.key, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.08), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upload new assignment', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 6),
                Text('Share worksheets, rubrics and submission instructions.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          ElevatedButton(onPressed: onUpload, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Upload')),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/attendance/attendance_history_table.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/attendance_service.dart';

class AttendanceHistoryTable extends StatelessWidget {
  final List<AttendanceRecord> records;

  const AttendanceHistoryTable({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attendance history', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...records.map((record) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(record.date, style: GoogleFonts.inter(color: AppColors.textGrey)),
                    Text('${record.present} present • ${record.absent} absent', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/attendance/attendance_marking_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class AttendanceMarkingCard extends StatelessWidget {
  final VoidCallback onSubmit;
  final String subject;

  const AttendanceMarkingCard({super.key, required this.onSubmit, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mark attendance', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(subject, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 14),
          Row(
            children: [
              _Badge(label: 'Present', color: AppColors.primaryLight, textColor: AppColors.primary),
              const SizedBox(width: 10),
              _Badge(label: 'Absent', color: const Color(0xFFFFECEC), textColor: const Color(0xFFE24B4A)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: onSubmit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Submit attendance')),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Badge({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/attendance/attendance_stats_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class AttendanceStatsCard extends StatelessWidget {
  final int totalStudents;
  final int presentToday;
  final int absentToday;

  const AttendanceStatsCard({
    super.key,
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(label: 'Students', value: totalStudents.toString()),
          _StatItem(label: 'Present', value: presentToday.toString()),
          _StatItem(label: 'Absent', value: absentToday.toString()),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
      ],
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/my_classes/active_class_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class ActiveClassCard extends StatelessWidget {
  final int classCount;
  final String nextSession;

  const ActiveClassCard({super.key, required this.classCount, required this.nextSession});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.15), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active classes', style: GoogleFonts.inter(fontSize: 13, color: AppColors.white)),
          const SizedBox(height: 8),
          Text('$classCount classes', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.white)),
          const SizedBox(height: 12),
          Text('Next session', style: GoogleFonts.inter(fontSize: 12, color: AppColors.white.withOpacity(.85))),
          const SizedBox(height: 4),
          Text(nextSession, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white)),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/my_classes/class_details_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/classes_service.dart';

class ClassDetailsCard extends StatelessWidget {
  final TrainerClass trainerClass;

  const ClassDetailsCard({super.key, required this.trainerClass});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trainerClass.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(trainerClass.subject, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 10),
          Row(
            children: [
              _Chip(label: '${trainerClass.studentCount} students'),
              const SizedBox(width: 8),
              _Chip(label: trainerClass.nextSession),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/my_classes/lesson_plan_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class LessonPlanCard extends StatelessWidget {
  final String title;
  final String description;

  const LessonPlanCard({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 10),
          Text(description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey, height: 1.5)),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/my_classes/student_count_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class StudentCountCard extends StatelessWidget {
  final int count;

  const StudentCountCard({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.people_outline, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count students', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text('Total across active classes', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
            ],
          ),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/profile/qualification_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class QualificationCard extends StatelessWidget {
  final List<String> qualifications;

  const QualificationCard({super.key, required this.qualifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Qualifications', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...qualifications.map((qualification) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text('• $qualification', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey)),
              )),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/profile/settings_tile.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class SettingsTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingsTile({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/profile/trainer_info_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/trainer_api_service.dart';

class TrainerInfoCard extends StatelessWidget {
  final TrainerProfile profile;

  const TrainerInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.15), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(profile.name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 6),
          Text(profile.subject, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 14),
          Text(profile.experience, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 12),
          Text(profile.email, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/student_evaluation/certificate_recommendation_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/evaluation_service.dart';

class CertificateRecommendationCard extends StatelessWidget {
  final EvaluationRecord record;
  final VoidCallback onRecommend;

  const CertificateRecommendationCard({super.key, required this.record, required this.onRecommend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recommend certificate', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Text(record.recommendation, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          ElevatedButton(onPressed: onRecommend, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Recommend')),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/student_evaluation/feedback_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/evaluation_service.dart';

class FeedbackCard extends StatelessWidget {
  final EvaluationRecord record;
  final VoidCallback onSendFeedback;
  final VoidCallback onRecommendCertificate;

  const FeedbackCard({
    super.key,
    required this.record,
    required this.onSendFeedback,
    required this.onRecommendCertificate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(record.studentName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text(record.subject, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 10),
          Text(record.progress, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: onSendFeedback, style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary), child: const Text('Send feedback'))),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: onRecommendCertificate, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Recommend')),
            ],
          ),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/student_evaluation/marks_entry_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class MarksEntryCard extends StatelessWidget {
  final VoidCallback onSave;
  final String description;

  const MarksEntryCard({super.key, required this.onSave, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Marks entry', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 10),
          Text(description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onSave, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Save marks'))),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/student_evaluation/performance_summary_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class PerformanceSummaryCard extends StatelessWidget {
  final String bestStudent;
  final String strongSubject;

  const PerformanceSummaryCard({super.key, required this.bestStudent, required this.strongSubject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance summary', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          Text('$bestStudent is the top performer.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey)),
          const SizedBox(height: 8),
          Text('Strong subject: $strongSubject', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/timetable/daily_schedule_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/timetable_service.dart';

class DailyScheduleCard extends StatelessWidget {
  final TimetableEvent event;

  const DailyScheduleCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey)),
          const SizedBox(height: 8),
          Text(event.subject, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('${event.time} • ${event.location}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/timetable/leave_application_form.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class LeaveApplicationForm extends StatelessWidget {
  final VoidCallback onSubmit;

  const LeaveApplicationForm({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leave application', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 10),
          Text('Request leave for upcoming sessions with a quick form.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onSubmit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Request leave'))),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/timetable/leave_history_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';

class LeaveHistoryCard extends StatelessWidget {
  final List<String> records;

  const LeaveHistoryCard({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leave history', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...records.map((record) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(record, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey)),
              )),
        ],
      ),
    );
  }
}
""",
    'lib/features/trainer/presentation/widgets/timetable/weekly_schedule_card.dart': """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/timetable_service.dart';

class WeeklyScheduleCard extends StatelessWidget {
  final List<TimetableEvent> events;

  const WeeklyScheduleCard({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly schedule', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...events.map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(event.day, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Expanded(child: Text('${event.subject} • ${event.time}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey), overflow: TextOverflow.ellipsis)),
                    Text(event.location, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
""",
}

for path, content in files.items():
    file_path = Path(path)
    if not file_path.parent.exists():
        file_path.parent.mkdir(parents=True, exist_ok=True)
    file_path.write_text(content, encoding='utf-8')
