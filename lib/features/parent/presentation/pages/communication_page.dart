import 'package:flutter/material.dart';

import '../parent_theme.dart';

class ParentCommunicationPage extends StatelessWidget {
  const ParentCommunicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ParentTopBar(
              title: 'Communication',
              subtitle: 'Trainer chat',
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
                        Text('Trainer Chat', style: ParentTheme.title()),
                        const SizedBox(height: 12),
                        _ChatBubble(
                          text: 'Hello, updates from trainer will appear here.',
                          mine: false,
                        ),
                        const SizedBox(height: 10),
                        _ChatBubble(
                          text: 'Thanks, I will track the homework.',
                          mine: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ParentInfoCard(
                    icon: Icons.support_agent_rounded,
                    title: 'Contact Institute',
                    subtitle: 'Raise parent support requests',
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

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool mine;

  const _ChatBubble({required this.text, required this.mine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mine ? ParentTheme.blue : ParentTheme.tintGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: ParentTheme.body(
            color: mine ? Colors.white : ParentTheme.greenDark,
          ),
        ),
      ),
    );
  }
}
