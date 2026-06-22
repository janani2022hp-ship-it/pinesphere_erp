// features/student/presentation/widgets/certificates/certificate_preview.dart

import 'package:flutter/material.dart';

class CertificatePreview extends StatelessWidget {

  const CertificatePreview({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 240,
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: const [

          Icon(
            Icons.verified,
            size: 70,
            color: Colors.green,
          ),

          SizedBox(height: 20),

          Text(
            "Certificate Preview",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}