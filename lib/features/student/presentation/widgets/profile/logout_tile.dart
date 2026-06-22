// features/student/presentation/widgets/profile/logout_tile.dart

import 'package:flutter/material.dart';

class LogoutTile extends StatelessWidget {

  final VoidCallback onTap;

  const LogoutTile({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius:
              BorderRadius.circular(18),
        ),

        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              Icons.logout,
              color: Colors.red,
            ),

            SizedBox(width: 12),

            Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}