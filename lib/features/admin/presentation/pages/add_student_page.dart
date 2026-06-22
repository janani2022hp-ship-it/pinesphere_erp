// features/admin/presentation/pages/add_student_page.dart
// ─────────────────────────────────────────────────────────────
// Add Student form. On success, creates BOTH the student profile
// and a login account (username = entered by admin, auto-generated
// temp password), then shows the credentials to the admin so
// they can hand them to the student.
// ─────────────────────────────────────────────────────────────

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/services/admin_students_service.dart';

class AdminAddStudentPage extends StatefulWidget {
  const AdminAddStudentPage({super.key});

  @override
  State<AdminAddStudentPage> createState() => _AdminAddStudentPageState();
}

class _AdminAddStudentPageState extends State<AdminAddStudentPage> {
  final _service = AdminStudentsService();
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();
  final _parentNameCtrl = TextEditingController();
  final _parentPhoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _submitting = false;

  static const _blue = Color(0xFF2B70C9);
  static const _bg = Color(0xFFFDF6EC);
  static const _border = Color(0xFFEDD9B8);
  static const _ink = Color(0xFF1A1A2E);
  static const _muted = Color(0xFF888888);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _courseCtrl.dispose();
    _batchCtrl.dispose();
    _parentNameCtrl.dispose();
    _parentPhoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // ─── Credential generation ──────────────────────────────────────────────

  String _generateTempPassword({int length = 8}) {
    // Avoids visually-ambiguous characters (0/O, 1/l/I) for easier sharing.
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789';
    final rnd = Random.secure();
    return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  // Simple client-side sanity check so obviously-bad usernames don't even
  // hit the network. The backend should still be the source of truth for
  // uniqueness (race conditions, case-folding, etc).
  String? _validateUsername(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Required';
    if (value.length < 4) return 'At least 4 characters';
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
      return 'Letters, numbers, dot, underscore only';
    }
    return null;
  }

  // ─── Submit ─────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final username = _usernameCtrl.text.trim();
    final password = _generateTempPassword();

    final credentials = await _service.addStudent({
      'full_name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      'course': _courseCtrl.text.trim(),
      'batch': _batchCtrl.text.trim(),
      'parent_name': _parentNameCtrl.text.trim().isEmpty ? null : _parentNameCtrl.text.trim(),
      'parent_phone': _parentPhoneCtrl.text.trim().isEmpty ? null : _parentPhoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      // Login fields — the backend's /admin/students handler needs to read
      // these and create the auth/User row alongside the student profile.
      'username': username,
      'password': password,
      'role': 'student',
    });

    if (!mounted) return;
    setState(() => _submitting = false);

    await _showCredentialsDialog(username, password);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _showCredentialsDialog(String username, String password) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF45A700)),
            const SizedBox(width: 8),
            Expanded(child: Text('Student added', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share these login details with the student:',
              style: GoogleFonts.inter(fontSize: 13, color: _muted),
            ),
            const SizedBox(height: 14),
            _CredentialRow(label: 'Username', value: username),
            const SizedBox(height: 8),
            _CredentialRow(label: 'Password', value: password),
            const SizedBox(height: 12),
            Text(
              'They can log in with these right away. Consider asking them to change the password after first login.',
              style: GoogleFonts.inter(fontSize: 11, color: _muted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Username: $username\nPassword: $password'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            child: const Text('Copy Both'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // ─── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Add Student', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: _ink)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _SectionTitle('Student Details'),
            _field(controller: _nameCtrl, label: 'Full Name *', icon: Icons.badge_outlined, required: true),
            _field(
              controller: _usernameCtrl,
              label: 'Username *',
              icon: Icons.person_outline_rounded,
              validator: _validateUsername,
              textCapitalization: TextCapitalization.none,
            ),
            _field(
              controller: _phoneCtrl,
              label: 'Phone Number *',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              required: true,
            ),
            _field(
              controller: _emailCtrl,
              label: 'Email (optional)',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            _field(controller: _courseCtrl, label: 'Course *', icon: Icons.menu_book_outlined, required: true),
            _field(controller: _batchCtrl, label: 'Batch *', icon: Icons.group_outlined, required: true),
            const SizedBox(height: 8),
            const _SectionTitle('Parent / Guardian (optional)'),
            _field(controller: _parentNameCtrl, label: 'Parent Name', icon: Icons.family_restroom_outlined),
            _field(
              controller: _parentPhoneCtrl,
              label: 'Parent Phone',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            _field(controller: _addressCtrl, label: 'Address', icon: Icons.home_outlined, maxLines: 2),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _blue.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: _blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'A login account will be created using the username entered above. A temporary password will be generated automatically and shown after saving.',
                      style: GoogleFonts.inter(fontSize: 11.5, color: _blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                      )
                    : Text('Add Student', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool required = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
        style: GoogleFonts.inter(fontSize: 13, color: _ink),
        validator: validator ?? (required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 12, color: _muted),
          prefixIcon: Icon(icon, size: 18, color: _muted),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _blue, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF888888))),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  final String label;
  final String value;
  const _CredentialRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF888888)))),
          Expanded(
            child: Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied')));
            },
            child: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF2B70C9)),
          ),
        ],
      ),
    );
  }
}