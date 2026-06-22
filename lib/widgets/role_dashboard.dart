// widgets/role_dashboard.dart

import 'package:flutter/material.dart';

class RoleDashboard extends StatelessWidget {

  final String role;

  const RoleDashboard({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(role),
      ),

      body: Center(
        child: Text(
          "$role Dashboard",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}