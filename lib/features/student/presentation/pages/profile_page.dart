// features/student/presentation/pages/profile_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinesphere_erp/features/auth/presentation/pages/login_screen.dart';
import '../../../auth/services/auth_service.dart';

const _host = 'https://vaguely-dastardly-pennant.ngrok-free.dev';

// ── Palette (matches dashboard _T theme) ────────────────────────────────────
const _green      = Color(0xFF58CC02);
const _greenDark  = Color(0xFF45A700);
const _orange     = Color(0xFFFF9600);
const _blue       = Color(0xFF1CB0F6);
const _blueDark   = Color(0xFF0081C8);
const _blueDeep   = Color(0xFF2B70C9);
const _red        = Color(0xFFFF4B4B);
const _redDark    = Color(0xFFCB3E3E);
const _purple     = Color(0xFFCE82FF);
const _yellow     = Color(0xFFFFD900);

const _bg         = Color(0xFFFDF6EC);
const _cardCream  = Color(0xFFFFFAF4);
const _border     = Color(0xFFE5E5EA);
const _textDark   = Color(0xFF1C1C1E);
const _textGrey   = Color(0xFF8E8E93);
const _textLight  = Color(0xFFC7C7CC);

const _tintGreen  = Color(0xFFEEFBDD);
const _tintBlue   = Color(0xFFE3F5FE);
const _tintOrange = Color(0xFFFFF3E0);
const _tintRed    = Color(0xFFFFECEC);
const _tintPurple = Color(0xFFF8EDFF);
const _tintYellow = Color(0xFFFFFBE0);

// ── Typography helpers (mirrors dashboard's _T text styles) ─────────────────
// Dashboard uses GoogleFonts.fredoka for headings/values (playful, rounded)
// and GoogleFonts.inter / GoogleFonts.nunito for body/labels.
class _Fonts {
  // Big rounded "cartoon" numbers / headings — Fredoka
  static TextStyle heading({
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color color = _textDark,
    double letterSpacing = -0.4,
    double height = 1.1,
  }) => GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Section titles — Fredoka, slightly smaller
  static TextStyle title({
    double size = 15,
    FontWeight weight = FontWeight.w600,
    Color color = _textDark,
  }) => GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: -0.2,
      );

  // Body text — Inter
  static TextStyle body({
    double size = 12,
    FontWeight weight = FontWeight.w600,
    Color color = _textDark,
  }) => GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  // Small labels / captions — Inter
  static TextStyle label({
    double size = 11,
    FontWeight weight = FontWeight.w500,
    Color color = _textGrey,
  }) => GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  // Pill/badge text — Nunito (matches dashboard quick-action labels)
  static TextStyle pill({
    double size = 11,
    FontWeight weight = FontWeight.w800,
    Color color = _textDark,
  }) => GoogleFonts.nunito(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );
}

// ── Profile Page ──────────────────────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      if (userId.isEmpty) {
        setState(() { _error = 'Not logged in'; _loading = false; });
        return;
      }
      final resp = await http.get(
        Uri.parse('$_host/profile/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        if (mounted) {
          setState(() {
          _profile = jsonDecode(resp.body) as Map<String, dynamic>;
          _loading = false;
        });
        }
      } else {
        setState(() { _error = 'Failed to load profile'; _loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not reach server'; _loading = false; });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final uri = Uri.parse('$_host/profile/$userId/avatar');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', picked.path));

      final streamed = await request.send().timeout(const Duration(seconds: 15));
      if (streamed.statusCode == 200) {
        await _load();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload picture')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not reach server')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onRefresh: _load),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: _green))
                  : _error != null
                      ? _ErrorView(message: _error!, onRetry: _load)
                      : _ProfileContent(
                          profile: _profile!,
                          onReload: _load,
                          onAvatarTap: _pickAndUploadAvatar,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final VoidCallback onRefresh;
  const _TopBar({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(
        color: _cardCream,
        border: Border(bottom: BorderSide(color: _border, width: .5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Student profile', style: _Fonts.label(size: 11)),
              const SizedBox(height: 2),
              Text('Profile', style: _Fonts.heading(size: 18, height: 1.1)),
            ]),
          ),
          GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); onRefresh(); },
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _tintBlue,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _blue.withValues(alpha: .25)),
              ),
              child: const Icon(Icons.refresh_rounded, color: _blue, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded, size: 48, color: _textGrey),
        const SizedBox(height: 12),
        Text(message, style: _Fonts.body(size: 14, weight: FontWeight.w500, color: _textGrey)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(12)),
            child: Text('Try again',
                style: _Fonts.body(size: 14, weight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

// ── Main scrollable content ───────────────────────────────────────────────────
class _ProfileContent extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onReload;
  final VoidCallback onAvatarTap;
  const _ProfileContent({
    required this.profile,
    required this.onReload,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final name         = profile['name']?.toString() ?? 'Student';
    final email        = profile['email']?.toString() ?? '—';
    final username     = profile['username']?.toString() ?? '—';
    final role         = profile['role']?.toString() ?? 'student';
    final courses      = profile['courses']?.toString() ?? '0';
    final certificates = profile['certificates']?.toString() ?? '0';
    final attendance   = profile['attendance']?.toString() ?? '—';
    final streak       = (profile['streak'] as num?)?.toInt() ?? 0;
    final xp           = (profile['total_xp'] as num?)?.toInt() ?? 0;
    final done         = (profile['assignments_done'] as num?)?.toInt() ?? 0;
    final total        = (profile['assignments_total'] as num?)?.toInt() ?? 0;
    final avgScore     = profile['avg_score']?.toString() ?? '0.0';
    final avatarUrl    = profile['avatar_url']?.toString();

    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Profile hero card ──────────────────────────────────────
          _ProfileCard(
            name: name,
            role: role,
            initials: initials,
            courses: courses,
            certificates: certificates,
            attendance: attendance,
            avatarUrl: avatarUrl,
            onAvatarTap: onAvatarTap,
            onEdit: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => _EditProfilePage(profile: profile)));
              onReload();
            },
          ),

          const SizedBox(height: 16),

          // ── Achievements row ───────────────────────────────────────
          Row(children: [
            Expanded(child: _AchievementCard(
              imagePath: 'assets/images/fire_mascot.png',
              iconBg: _tintOrange,
              value: '$streak', label: 'Day streak',
            )),
            const SizedBox(width: 10),
            Expanded(child: _AchievementCard(
              imagePath: 'assets/images/trophy_icon.png',
              iconBg: _tintBlue,
              value: '$xp', label: 'Total XP',
            )),
            const SizedBox(width: 10),
            Expanded(child: _AchievementCard(
              imagePath: 'assets/images/tick_icon.png',
              iconBg: _tintGreen,
              value: '$done/$total', label: 'Tasks done',
            )),
            const SizedBox(width: 10),
            Expanded(child: _AchievementCard(
              imagePath: 'assets/images/star_filled.png',
              iconBg: _tintYellow,
              value: avgScore, label: 'Avg score',
            )),
          ]),

          const SizedBox(height: 20),

          // ── Personal information ───────────────────────────────────
          const _SectionLabel(title: 'Personal information'),
          const SizedBox(height: 12),
          _InfoCard(icon: Icons.email_rounded, iconBg: _tintBlue, iconColor: _blueDeep,
              title: 'Email', value: email),
          const SizedBox(height: 10),
          _InfoCard(icon: Icons.alternate_email_rounded, iconBg: _tintOrange, iconColor: _orange,
              title: 'Username', value: username),
          const SizedBox(height: 10),
          _InfoCard(icon: Icons.school_rounded, iconBg: _tintPurple, iconColor: _purple,
              title: 'Role', value: role.toUpperCase()),

          const SizedBox(height: 20),

          // ── Settings ───────────────────────────────────────────────
          const _SectionLabel(title: 'Settings'),
          const SizedBox(height: 12),
          const _SettingTile(icon: Icons.notifications_active_rounded,
              iconBg: _tintOrange, iconColor: _orange,
              title: 'Notifications', subtitle: 'Manage alerts & reminders'),
          const SizedBox(height: 10),
          const _SettingTile(icon: Icons.lock_rounded,
              iconBg: _tintBlue, iconColor: _blueDeep,
              title: 'Privacy & Security', subtitle: 'Password, 2FA, data'),
          const SizedBox(height: 10),
          const _SettingTile(icon: Icons.palette_rounded,
              iconBg: _tintPurple, iconColor: _purple,
              title: 'Appearance', subtitle: 'Theme, font size'),
          const SizedBox(height: 10),
          const _SettingTile(icon: Icons.help_rounded,
              iconBg: _tintGreen, iconColor: _greenDark,
              title: 'Help & Support', subtitle: 'FAQs, contact us'),

          const SizedBox(height: 24),

          // ── Logout ─────────────────────────────────────────────────
          _LogoutButton(),
        ],
      ),
    );
  }
}

// ── Profile card ──────────────────────────────────────────────────────────────
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
                    ? Text(initials, style: _Fonts.heading(size: 22, color: _blueDeep, letterSpacing: 0))
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
        Text(name, style: _Fonts.heading(size: 18)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _tintBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _blue.withValues(alpha: .25)),
          ),
          child: Text(role.toUpperCase(), style: _Fonts.pill(size: 11, color: _blueDark)),
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

class _ProfileStat extends StatelessWidget {
  final String value, label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: _Fonts.heading(size: 16)),
      const SizedBox(height: 3),
      Text(label, style: _Fonts.label(size: 11)),
    ]);
  }
}

// ── Achievement card ──────────────────────────────────────────────────────────
class _AchievementCard extends StatelessWidget {
  final String imagePath;
  final Color iconBg;
  final String value, label;
  const _AchievementCard({
    required this.imagePath, required this.iconBg,
    required this.value, required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: _cardCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: .5),
      ),
      child: Column(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
          child: Center(
            child: Image.asset(imagePath, width: 24, height: 24, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 8),
        Text(value, style: _Fonts.heading(size: 13)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: _Fonts.label(size: 9)),
      ]),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: _Fonts.title(size: 17));
  }
}

// ── Info card (read-only) ─────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, value;
  const _InfoCard({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: .5),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(13)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: _Fonts.label(size: 11)),
          const SizedBox(height: 3),
          Text(value, style: _Fonts.body(size: 14, weight: FontWeight.w600)),
        ])),
      ]),
    );
  }
}

// ── Setting tile ──────────────────────────────────────────────────────────────
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  const _SettingTile({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _cardCream,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border, width: .5),
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: _Fonts.title(size: 13, weight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, style: _Fonts.label(size: 11, weight: FontWeight.w400)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _textLight),
        ]),
      ),
    );
  }
}

// ── Logout button ─────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Logout', style: TextStyle(color: _red))),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          await AuthService().logout();
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
        }
      },
      child: Container(
        height: 56, width: double.infinity,
        decoration: BoxDecoration(
          color: _tintRed,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _red.withValues(alpha: .25)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.logout_rounded, color: _red, size: 20),
          const SizedBox(width: 8),
          Text('Log out', style: _Fonts.body(size: 14, weight: FontWeight.w600, color: _red)),
        ]),
      ),
    );
  }
}

// ── Edit Profile Page ─────────────────────────────────────────────────────────
class _EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;
  const _EditProfilePage({required this.profile});

  @override
  State<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<_EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _usernameCtrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl     = TextEditingController(text: widget.profile['name']?.toString() ?? '');
    _emailCtrl    = TextEditingController(text: widget.profile['email']?.toString() ?? '');
    _usernameCtrl = TextEditingController(text: widget.profile['username']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final resp = await http.put(
        Uri.parse('$_host/profile/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name':     _nameCtrl.text.trim(),
          'email':    _emailCtrl.text.trim(),
          'username': _usernameCtrl.text.trim(),
        }),
      ).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        await prefs.setString('student_name', _nameCtrl.text.trim());
        if (mounted) Navigator.pop(context);
      } else {
        final body = jsonDecode(resp.body);
        setState(() { _error = body['detail']?.toString() ?? 'Failed to save'; });
      }
    } catch (_) {
      setState(() { _error = 'Could not reach server'; });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            decoration: const BoxDecoration(
              color: _cardCream,
              border: Border(bottom: BorderSide(color: _border, width: .5)),
            ),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 15, color: _textDark),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Edit profile', style: _Fonts.label(size: 11)),
                Text('Update your information', style: _Fonts.heading(size: 15)),
              ])),
              GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: _green, borderRadius: BorderRadius.circular(14)),
                  child: _saving
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Save', style: _Fonts.body(size: 13, weight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 40),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _tintRed,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _red.withValues(alpha: .3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline_rounded, color: _red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: _Fonts.body(size: 13, weight: FontWeight.w400, color: _redDark))),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],
                const _SectionLabel(title: 'Basic details'),
                const SizedBox(height: 12),
                _EditField(controller: _nameCtrl,
                    icon: Icons.person_rounded, iconBg: _tintGreen, iconColor: _greenDark,
                    label: 'Full Name'),
                const SizedBox(height: 10),
                _EditField(controller: _emailCtrl,
                    icon: Icons.email_rounded, iconBg: _tintBlue, iconColor: _blueDeep,
                    label: 'Email', keyboard: TextInputType.emailAddress),
                const SizedBox(height: 10),
                _EditField(controller: _usernameCtrl,
                    icon: Icons.alternate_email_rounded, iconBg: _tintOrange, iconColor: _orange,
                    label: 'Username'),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Edit field ────────────────────────────────────────────────────────────────
class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final Color iconBg, iconColor;
  final String label;
  final TextInputType? keyboard;

  const _EditField({
    required this.controller, required this.icon,
    required this.iconBg, required this.iconColor,
    required this.label, this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: .5),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(13)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: _Fonts.label(size: 11)),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            keyboardType: keyboard,
            style: _Fonts.body(size: 14, weight: FontWeight.w600),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 2),
            ),
          ),
        ])),
      ]),
    );
  }
}