import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/services/admin_students_service.dart';

class AdminStudentDetailsPage extends StatefulWidget {
  final String studentId;
  final StudentSummary summary;

  const AdminStudentDetailsPage({
    super.key,
    required this.studentId,
    required this.summary,
  });

  @override
  State<AdminStudentDetailsPage> createState() => _AdminStudentDetailsPageState();
}

class _AdminStudentDetailsPageState extends State<AdminStudentDetailsPage> {
  final _service = AdminStudentsService();
  StudentDetail? _details;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await _service.getStudentDetail(widget.studentId);
      if (mounted) setState(() { _details = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String s) => switch (s) {
        'active'  => const Color(0xFF45A700),
        'on_hold' => const Color(0xFFFF9600),
        _         => const Color(0xFFFF4B4B),
      };

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Student Details', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2B70C9), strokeWidth: 2.5))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Profile card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B70C9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(s.fullName.isNotEmpty ? s.fullName[0].toUpperCase() : '?',
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                    Text(s.fullName, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(s.studentCode, style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text(s.status, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // Info rows
                _InfoCard(title: 'Course Details', items: [
                  _InfoRow(label: 'Course',      value: s.course),
                  _InfoRow(label: 'Batch',       value: s.batch),
                  _InfoRow(label: 'Attendance',  value: '${s.attendancePercent.toStringAsFixed(1)}%'),
                  _InfoRow(label: 'Phone',       value: s.phone),
                ]),
                const SizedBox(height: 12),

                if (_details != null) ...[
                _InfoCard(
                  title: 'Additional Info',
                  items: [
                    _InfoRow(label: 'Email', value: _details!.email),
                    _InfoRow(label: 'Parent Phone', value: _details!.parentPhone),
                    _InfoRow(label: 'Gender', value: _details!.gender),
                    _InfoRow(label: 'DOB', value: _details!.dob),
                    _InfoRow(label: 'Status', value: _details!.status),
                  ],
                ),
],
              ]),
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoRow> items;
  const _InfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDD9B8)),
        boxShadow: [BoxShadow(color: const Color(0xFF2B70C9).withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF888888))),
        const SizedBox(height: 12),
        ...items.map((row) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            SizedBox(width: 110, child: Text(row.label, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF888888)))),
            Expanded(child: Text(row.value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)))),
          ]),
        )),
      ]),
    );
  }
}

class _InfoRow {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
}