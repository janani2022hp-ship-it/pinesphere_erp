import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/services/admin_students_service.dart';
import 'add_student_page.dart';
import 'student_details_page.dart';

class AdminStudentsPage extends StatefulWidget {
  const AdminStudentsPage({super.key});

  @override
  State<AdminStudentsPage> createState() => _AdminStudentsPageState();
}

class _AdminStudentsPageState extends State<AdminStudentsPage>
    with SingleTickerProviderStateMixin {
  final _service = AdminStudentsService();
  final _searchController = TextEditingController();

  List<StudentSummary> _all = [];
  List<StudentSummary> _filtered = [];
  bool _loading = true;
  String _activeFilter = 'all'; // all | active | on_hold | dropped

  final _filters = ['all', 'active', 'on_hold', 'dropped'];
  final _filterLabels = {
    'all': 'All',
    'active': 'Active',
    'on_hold': 'On Hold',
    'dropped': 'Dropped',
  };

  @override
  void initState() {
    super.initState();
    _fetch();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final result = await _service.getStudents();
      if (mounted) {
        setState(() {
          _all = result.students;
          _loading = false;
        });
        _applyFilter();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _all = StudentSummary.mockList();
          _loading = false;
        });
        _applyFilter();
      }
    }
  }

  void _applyFilter() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _all.where((s) {
        final matchSearch = q.isEmpty ||
            s.fullName.toLowerCase().contains(q) ||
            s.studentCode.toLowerCase().contains(q) ||
            s.phone.contains(q) ||
            s.course.toLowerCase().contains(q);
        final matchStatus =
            _activeFilter == 'all' || s.status == _activeFilter;
        return matchSearch && matchStatus;
      }).toList();
    });
  }

  void _setFilter(String f) {
    setState(() => _activeFilter = f);
    _applyFilter();
  }

  void _openDetail(StudentSummary s) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AdminStudentDetailsPage(studentId: s.studentId, summary: s),
    ));
  }

  void _openAdd() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AdminAddStudentPage()),
    );
    if (added == true) _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterTabs(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2B70C9), strokeWidth: 2.5))
                  : _filtered.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: _fetch,
                          color: const Color(0xFF2B70C9),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _StudentCard(
                              student: _filtered[i],
                              onTap: () => _openDetail(_filtered[i]),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        backgroundColor: const Color(0xFF2B70C9),
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          'Add Student',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final total = _all.length;
    final active = _all.where((s) => s.status == 'active').length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Students',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '$active active · $total total',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF888888),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2B70C9).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$total students',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF2B70C9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDD9B8)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2B70C9).withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.inter(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search by name, ID, phone, course...',
            hintStyle: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFFBBBBBB),
            ),
            prefixIcon: const Icon(Icons.search_rounded,
                color: Color(0xFFAAAAAA), size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFFAAAAAA), size: 18),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 0, 4),
      child: SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _filters.map((f) {
            final selected = f == _activeFilter;
            final count = f == 'all'
                ? _all.length
                : _all.where((s) => s.status == f).length;
            return GestureDetector(
              onTap: () => _setFilter(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF2B70C9)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF2B70C9)
                        : const Color(0xFFEDD9B8),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _filterLabels[f]!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : const Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFEDD9B8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color:
                              selected ? Colors.white : const Color(0xFF888888),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No students found',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF888888),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Try a different search or filter',
            style: GoogleFonts.inter(
                fontSize: 12, color: const Color(0xFFBBBBBB)),
          ),
        ],
      ),
    );
  }
}

// ─── Student Card ─────────────────────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  final StudentSummary student;
  final VoidCallback onTap;
  const _StudentCard({required this.student, required this.onTap});

  Color get _statusColor => switch (student.status) {
        'active' => const Color(0xFF45A700),
        'on_hold' => const Color(0xFFFF9600),
        _ => const Color(0xFFFF4B4B),
      };

  String get _statusLabel => switch (student.status) {
        'active' => 'Active',
        'on_hold' => 'On Hold',
        _ => 'Dropped',
      };

  Color get _attendanceColor {
    if (student.attendancePercent >= 80) return const Color(0xFF45A700);
    if (student.attendancePercent >= 60) return const Color(0xFFFF9600);
    return const Color(0xFFFF4B4B);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDD9B8)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2B70C9).withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF2B70C9).withValues(alpha: 0.1),
              child: Text(
                student.fullName.isNotEmpty
                    ? student.fullName[0].toUpperCase()
                    : '?',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2B70C9),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          student.fullName,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusBadge(
                          label: _statusLabel, color: _statusColor),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${student.studentCode} · ${student.course}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF888888),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.group_outlined,
                        label: student.batch,
                        color: const Color(0xFF2B70C9),
                      ),
                      const SizedBox(width: 6),
                      _InfoChip(
                        icon: Icons.how_to_reg_outlined,
                        label:
                            '${student.attendancePercent.toStringAsFixed(0)}%',
                        color: _attendanceColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}