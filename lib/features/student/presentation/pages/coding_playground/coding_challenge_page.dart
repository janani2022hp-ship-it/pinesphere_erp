import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'coding_levels_page.dart' show CodingLevel;

class CodingChallengePage extends StatefulWidget {
  final CodingLevel level;
  final Future<void> Function(CodingLevel)? onCompleted;

  const CodingChallengePage({super.key, required this.level, this.onCompleted});

  @override
  State<CodingChallengePage> createState() => _CodingChallengePageState();
}

class _CodingChallengePageState extends State<CodingChallengePage> {
  late TextEditingController _codeCtrl;
  String? _output;
  String? _error;
  bool _running = false;
  bool _passed = false;

  static const String _host =
      'https://vaguely-dastardly-pennant.ngrok-free.dev';

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.level.starter);
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _runCode() async {
    setState(() {
      _running = true;
      _output = null;
      _error = null;
      _passed = false;
    });
    try {
      final resp = await http
          .post(
            Uri.parse('$_host/coding/run'),
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
            body: jsonEncode({'code': _codeCtrl.text}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => http.Response(
              jsonEncode({
                'output': '',
                'error': 'Backend is not responding. Please try again later.',
              }),
              504,
            ),
          );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final output = (data['output'] as String? ?? '').trim();
        final err = (data['error'] as String? ?? '').trim();
        setState(() {
          _output = output.isEmpty ? null : output;
          _error = err.isEmpty ? null : err;
          _passed = output == widget.level.expectedOutput.trim();
          _running = false;
        });
      } else {
        setState(() {
          _error = 'Server error ${resp.statusCode}';
          _running = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Could not reach backend: $e';
        _running = false;
      });
    }
  }

  Future<void> _complete() async {
    await widget.onCompleted?.call(widget.level);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2240),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3D6E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/coding_mascot.png',
              width: 28,
              height: 28,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.code_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 10),
            Text(
              widget.level.title,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── task description ─────────────────────────────────────────
            Container(
              color: const Color(0xFF1A3D6E),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.level.topic,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: const Color(0xFFADC8E6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D2240),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A5C9A)),
                    ),
                    child: Text(
                      widget.level.prompt,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: const Color(0xFFC7F9CC),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── code editor ───────────────────────────────────────────────
            SizedBox(
              height: 260,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF081A30),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2A5C9A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A3D6E),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.code_rounded,
                            color: Color(0xFF58CC02),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'main.py',
                            style: GoogleFonts.robotoMono(
                              fontSize: 12,
                              color: const Color(0xFFADC8E6),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _running ? null : _runCode,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF58CC02),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF3DAF00),
                                    blurRadius: 0,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: _running
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      '▶ Run',
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _codeCtrl,
                        maxLines: null,
                        expands: true,
                        style: GoogleFonts.robotoMono(
                          fontSize: 13,
                          color: const Color(0xFF7DD3FC),
                          height: 1.7,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── output panel ──────────────────────────────────────────────
            if (_output != null || _error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _passed
                      ? const Color(0xFF0D2A0D)
                      : _error != null
                      ? const Color(0xFF2A0D0D)
                      : const Color(0xFF081A30),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _passed
                        ? const Color(0xFF58CC02)
                        : _error != null
                        ? const Color(0xFFFF4B4B)
                        : const Color(0xFF2A5C9A),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _passed
                              ? Icons.check_circle_rounded
                              : _error != null
                              ? Icons.error_rounded
                              : Icons.terminal_rounded,
                          color: _passed
                              ? const Color(0xFF58CC02)
                              : _error != null
                              ? const Color(0xFFFF4B4B)
                              : const Color(0xFFADC8E6),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _passed
                              ? 'Correct! Output matches ✓'
                              : _error != null
                              ? 'Error'
                              : 'Output',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _passed
                                ? const Color(0xFF58CC02)
                                : _error != null
                                ? const Color(0xFFFF4B4B)
                                : const Color(0xFFADC8E6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_output != null)
                      Text(
                        _output!,
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          color: const Color(0xFFFDE68A),
                          height: 1.6,
                        ),
                      ),
                    if (_error != null)
                      Text(
                        _error!,
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          color: const Color(0xFFFF4B4B),
                          height: 1.6,
                        ),
                      ),
                    if (!_passed && _output != null && _error == null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Expected: ${widget.level.expectedOutput}',
                        style: GoogleFonts.robotoMono(
                          fontSize: 11,
                          color: const Color(0xFF58CC02),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // ── complete button ───────────────────────────────────────────
            if (_passed)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                child: GestureDetector(
                  onTap: _complete,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF3DAF00),
                          blurRadius: 0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/star_filled.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Complete Level',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
