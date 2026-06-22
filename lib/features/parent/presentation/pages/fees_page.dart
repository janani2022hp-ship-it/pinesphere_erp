import 'package:flutter/material.dart';

import '../parent_theme.dart';

class ParentFeesPage extends StatelessWidget {
  const ParentFeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ParentTopBar(
              title: 'Fees',
              subtitle: 'Payments and invoices',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: ParentTheme.cardDecoration(
                      color: ParentTheme.orange,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outstanding Balance',
                          style: ParentTheme.body(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹0',
                          style: ParentTheme.title(
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No pending payment for now',
                          style: ParentTheme.body(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ParentInfoCard(
                    icon: Icons.payment_rounded,
                    title: 'Payments',
                    subtitle: 'Pay fees online',
                    color: ParentTheme.green,
                    tint: ParentTheme.tintGreen,
                  ),
                  SizedBox(height: 12),
                  const ParentInfoCard(
                    icon: Icons.receipt_rounded,
                    title: 'Invoices',
                    subtitle: 'Download GST invoices',
                    color: ParentTheme.blue,
                    tint: ParentTheme.tintBlue,
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
