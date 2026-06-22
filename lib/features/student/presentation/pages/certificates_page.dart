// features/student/presentation/pages/certificates_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _K {
  static const green = Color(0xFF46A800);
  static const orange = Color(0xFFF59000);
  static const blue = Color(0xFF14A0E0);
  static const bg = Color(0xFF171A34);
  static const card = Color(0xFF24284A);
  static const tintBlue = Color(0xFF1E2A4A);
  static const tintGreen = Color(0xFF24312D);
  static const tintOrange = Color(0xFF3A2B1E);
  static const labelPrimary = Color(0xFFFFFFFF);
  static const labelTertiary = Color(0xFFBFC2D6);

  static TextStyle title({Color? color}) => GoogleFonts.fredoka(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: color ?? labelPrimary,
  );

  static TextStyle body({Color? color}) => GoogleFonts.fredoka(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: color ?? labelTertiary,
    height: 1.3,
  );
}

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  final Set<String> _downloaded = {};

  static const _certificates = [
    {
      "title": "Python Fundamentals",
      "issued": "Issued today",
      "score": "0 XP course certificate",
      "tint": _K.tintBlue,
      "color": _K.blue,
    },
    {
      "title": "AI Basics",
      "issued": "Locked until completion",
      "score": "Complete lessons to unlock",
      "tint": _K.tintGreen,
      "color": _K.green,
    },
    {
      "title": "Project Builder",
      "issued": "Locked until project submit",
      "score": "Submit task to unlock",
      "tint": _K.tintOrange,
      "color": _K.orange,
    },
  ];

  void _download(String title) {
    setState(() => _downloaded.add(title));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title certificate downloaded')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: AppBar(
        backgroundColor: _K.bg,
        elevation: 0,
        foregroundColor: _K.labelPrimary,
        title: Text('🏆 Certificates', style: _K.title()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _K.tintOrange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: _K.orange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Download Center', style: _K.title()),
                      Text(
                        'Certificates unlock as the student completes courses and tasks.',
                        style: _K.body(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._certificates.map((certificate) {
            final title = certificate["title"]! as String;
            final downloaded = _downloaded.contains(title);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _CertificateCard(
                title: title,
                issued: certificate["issued"]! as String,
                score: certificate["score"]! as String,
                tint: certificate["tint"]! as Color,
                color: certificate["color"]! as Color,
                downloaded: downloaded,
                onDownload: () => _download(title),
              ),
            );
          }),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: _K.card,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .06),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class _CertificateCard extends StatelessWidget {
  final String title;
  final String issued;
  final String score;
  final Color tint;
  final Color color;
  final bool downloaded;
  final VoidCallback onDownload;

  const _CertificateCard({
    required this.title,
    required this.issued,
    required this.score,
    required this.tint,
    required this.color,
    required this.downloaded,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _K.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 145,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_rounded, color: color, size: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(issued, style: _K.body()),
                      const SizedBox(height: 4),
                      Text(score, style: _K.body(color: _K.labelPrimary)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onDownload,
                  icon: Icon(
                    downloaded
                        ? Icons.check_circle_rounded
                        : Icons.download_rounded,
                    size: 18,
                  ),
                  label: Text(downloaded ? 'Done' : 'Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: downloaded ? _K.green : color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
