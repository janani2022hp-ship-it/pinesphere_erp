// features/student/presentation/widgets/certificates/certificate_card.dart

import 'package:flutter/material.dart';

class CertificateCard extends StatelessWidget {

  final String title;

  const CertificateCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [

          Container(
            height: 180,

            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),

            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
    );
  }
}