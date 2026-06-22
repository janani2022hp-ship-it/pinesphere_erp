// features/student/presentation/widgets/notifications/notification_switch_tile.dart

import 'package:flutter/material.dart';

class NotificationSwitchTile extends StatefulWidget {

  final String title;

  const NotificationSwitchTile({
    super.key,
    required this.title,
  });

  @override
  State<NotificationSwitchTile> createState() =>
      _NotificationSwitchTileState();
}

class _NotificationSwitchTileState
    extends State<NotificationSwitchTile> {

  bool value = true;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          Switch(
            value: value,
            onChanged: (v) {
              setState(() {
                value = v;
              });
            },
          )
        ],
      ),
    );
  }
}