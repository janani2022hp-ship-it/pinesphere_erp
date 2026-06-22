import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/services/auth_service.dart';
import '../../../auth/models/user_model.dart';
import '../../../admin/presentation/pages/admin_screen.dart';
import '../../../parent/presentation/pages/parent_screen.dart';
import '../../../student/presentation/pages/student_screen.dart';
import '../../../trainer/presentation/pages/trainer_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService        = AuthService();

  bool _isLoading       = false;
  bool _obscurePassword = true;
  String _role          = 'student';
  String? _errorMessage;

  static const _roles = ['student', 'trainer', 'parent', 'admin'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name     = _nameController.text.trim();
    final email    = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all required fields');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final user = UserModel(
        username: username,
        password: password,
        role: _role,
        fullName: name,
        email: email,
      );

      final String? error = await _authService.signup(user);
      if (!mounted) return;

      if (error == null) {
        // Signup successful — navigate to the right screen
        final Widget screen = switch (_role) {
          'trainer' => const TrainerScreen(),
          'parent'  => const ParentScreen(),
          'admin'   => AdminScreen(),
          _         => const StudentScreen(),
        };
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => screen),
          (route) => false,
        );
      } else {
        // Show the actual error from the backend
        setState(() => _errorMessage = error);
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Connection failed. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Back + Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1C1C1E)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Create Account', style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C1E))),
                ],
              ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 54),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Join PineSphere today', style: GoogleFonts.fredoka(fontSize: 13, color: const Color(0xFF8E8E93))),
                ),
              ),

              const SizedBox(height: 32),

              // Full name
              _InputField(controller: _nameController, hint: 'Full Name', icon: Icons.badge_outlined),
              const SizedBox(height: 14),

              // Email
              _InputField(controller: _emailController, hint: 'Email (optional)', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),

              // Username
              _InputField(controller: _usernameController, hint: 'Username', icon: Icons.person_outline_rounded),
              const SizedBox(height: 14),

              // Password
              _InputField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePassword,
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF8E8E93), size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Role picker
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 14),
                      child: Icon(Icons.school_outlined, color: Color(0xFF8E8E93), size: 20),
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _role,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          borderRadius: BorderRadius.circular(16),
                          style: GoogleFonts.fredoka(fontSize: 15, color: const Color(0xFF1C1C1E)),
                          items: _roles.map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r[0].toUpperCase() + r.substring(1)),
                          )).toList(),
                          onChanged: (r) { if (r != null) setState(() => _role = r); },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Error
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFFFECEC), borderRadius: BorderRadius.circular(12)),
                  child: Text(_errorMessage!, style: GoogleFonts.fredoka(fontSize: 13, color: const Color(0xFFCB3E3E))),
                ),
              ],

              const SizedBox(height: 28),

              // Signup button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: GestureDetector(
                  onTap: _isLoading ? null : _signup,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: const Color(0xFF58CC02).withValues(alpha: .35), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text('Create Account', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: GoogleFonts.fredoka(fontSize: 14, color: const Color(0xFF8E8E93))),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Login', style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1CB0F6))),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.fredoka(fontSize: 15, color: const Color(0xFF1C1C1E)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.fredoka(fontSize: 14, color: const Color(0xFFC7C7CC)),
          prefixIcon: Icon(icon, color: const Color(0xFF8E8E93), size: 20),
          suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}