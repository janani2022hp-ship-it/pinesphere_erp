class _ProfileCard extends StatelessWidget {
  final String name, role, initials, courses, certificates, attendance;
  final String? avatarUrl;
  final VoidCallback onEdit;
  final VoidCallback onAvatarTap;

  const _ProfileCard({
    required this.name, required this.role, required this.initials,
    required this.courses, required this.certificates, required this.attendance,
    required this.avatarUrl,
    required this.onEdit, required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardCream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border, width: .6),
      ),
      child: Column(children: [
        Stack(alignment: Alignment.bottomRight, children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _blue, width: 2),
              ),
              child: CircleAvatar(
                radius: 44,
                backgroundColor: _tintBlue,
                backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? NetworkImage('$_host$avatarUrl')
                    : null,
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? Text(initials,
                        style: GoogleFonts.inter(
                            fontSize: 28, fontWeight: FontWeight.w700, color: _blueDeep))
                    : null,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: _blue, shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Text(name,
            style: GoogleFonts.inter(
                fontSize: 22, fontWeight: FontWeight.w600,
                color: _textDark, letterSpacing: -.4)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _tintBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _blue.withValues(alpha: .25)),
          ),
          child: Text(role.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600, color: _blueDark)),
        ),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _ProfileStat(value: courses, label: 'Courses'),
          Container(width: 1, height: 34, color: _border),
          _ProfileStat(value: certificates, label: 'Certificates'),
          Container(width: 1, height: 34, color: _border),
          _ProfileStat(value: attendance, label: 'Attendance'),
        ]),
      ]),
    );
  }
}