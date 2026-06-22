import 'package:flutter/material.dart';

import '../parent_theme.dart';

class ParentProgressPage extends StatelessWidget {
  const ParentProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ParentTopBar(
              title: 'Progress Reports',
              subtitle: 'Academic performance',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: ParentTheme.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Learning Summary', style: ParentTheme.title()),
                        const SizedBox(height: 12),
                        _ProgressRow(
                          label: 'Courses completed',
                          value: '0%',
                          color: ParentTheme.green,
                        ),
                        _ProgressRow(
                          label: 'Assignment score',
                          value: '0%',
                          color: ParentTheme.blue,
                        ),
                        _ProgressRow(
                          label: 'Attendance trend',
                          value: '0%',
                          color: ParentTheme.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ParentInfoCard(
                    icon: Icons.description_rounded,
                    title: 'Academic Reports',
                    subtitle: 'No published reports yet',
                    color: ParentTheme.purple,
                    tint: ParentTheme.tintPurple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: ParentTheme.body(color: ParentTheme.labelPrimary),
                ),
              ),
              Text(value, style: ParentTheme.body(color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: 0,
              minHeight: 7,
              backgroundColor: color.withValues(alpha: .12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
