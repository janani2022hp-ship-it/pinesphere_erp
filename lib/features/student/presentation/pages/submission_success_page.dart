// features/student/presentation/pages/submission_success_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmissionSuccessPage extends StatefulWidget {
  const SubmissionSuccessPage({super.key});

  @override
  State<SubmissionSuccessPage> createState() =>
      _SubmissionSuccessPageState();
}

class _SubmissionSuccessPageState extends State<SubmissionSuccessPage>
    with TickerProviderStateMixin {

  late AnimationController _mainController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, .3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOutCubic,
      ),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            // ✅ SingleChildScrollView fixes the 99410px overflow
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text("🎉", style: TextStyle(fontSize: 70)),

                  const SizedBox(height: 18),

                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 150, height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF58CC02),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF58CC02).withValues(alpha: .30),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    'Assignment Completed!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 30, fontWeight: FontWeight.w800,
                        color: const Color(0xFF1C1C1E), letterSpacing: -0.5),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Excellent work! Your assignment\nhas been submitted successfully.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 15, height: 1.6,
                        color: const Color(0xFF8E8E93),
                        fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 40),

                  // XP CARD
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 24),
                      decoration: BoxDecoration(
                        // ✅ color only inside BoxDecoration
                        color: const Color(0xFF58CC02),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF58CC02).withValues(alpha: .25),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [

                          Text(
                            '✨ GREAT JOB ✨',
                            style: GoogleFonts.inter(
                                fontSize: 22, fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),

                          const SizedBox(height: 22),

                          Container(
                            width: 120, height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: .15),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              size: 72, color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 26),

                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) =>
                                Transform.scale(scale: value, child: child),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.star_rounded,
                                    color: Color(0xFFFFD900), size: 42),
                                SizedBox(width: 10),
                                Icon(Icons.star_rounded,
                                    color: Color(0xFFFFD900), size: 52),
                                SizedBox(width: 10),
                                Icon(Icons.star_rounded,
                                    color: Color(0xFFFFD900), size: 42),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            '+25 XP',
                            style: GoogleFonts.inter(
                                fontSize: 42, fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔥',
                                    style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text('5 Day Streak!',
                                    style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          Text('Level 7 Scholar',
                              style: GoogleFonts.inter(
                                  fontSize: 18, fontWeight: FontWeight.w700,
                                  color: Colors.white)),

                          const SizedBox(height: 18),

                          Text('Assignment Submitted',
                              style: GoogleFonts.inter(
                                  fontSize: 16, fontWeight: FontWeight.w600,
                                  color: Colors.white)),

                          const SizedBox(height: 28),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: 0.72,
                              minHeight: 12,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(
                                  Colors.white),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text('72 XP to next level 🚀',
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C1C1E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.inter(
                            fontSize: 17, fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}