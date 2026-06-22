import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final List<AdminAlert> _alerts = [
    AdminAlert(
      title: 'Low Attendance Alert',
      message: 'Deepan Raj has attendance below 75%',
      type: 'warning',
      timestamp: '2 hours ago',
      isRead: false,
    ),
    AdminAlert(
      title: 'Fee Payment Due',
      message: 'Rajesh Kumar has pending fees of ₹5000',
      type: 'alert',
      timestamp: '5 hours ago',
      isRead: false,
    ),
    AdminAlert(
      title: 'New Enrollment',
      message: 'Priya Sharma enrolled in Data Science',
      type: 'info',
      timestamp: '1 day ago',
      isRead: true,
    ),
    AdminAlert(
      title: 'Class Scheduled',
      message: 'Flutter Development Batch A class at 10:00 AM',
      type: 'info',
      timestamp: '2 days ago',
      isRead: true,
    ),
    AdminAlert(
      title: 'Assignment Submitted',
      message: '8 students submitted the Flutter assignment',
      type: 'success',
      timestamp: '3 days ago',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _alerts.where((a) => !a.isRead).length;

    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: _T.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Alerts & Notifications', style: _T.headline().copyWith(color: _T.labelPrimary)),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _T.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unreadCount',
                  style: _T.caption1().copyWith(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          return _AlertCard(
            alert: _alerts[index],
            onDismiss: () {
              setState(() => _alerts.removeAt(index));
            },
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AdminAlert alert;
  final VoidCallback onDismiss;

  const _AlertCard({required this.alert, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    Color typeColor = alert.type == 'warning'
        ? _T.orange
        : alert.type == 'alert'
            ? _T.red
            : alert.type == 'success'
                ? _T.green
                : _T.blue;

    IconData typeIcon = alert.type == 'warning'
        ? Icons.warning_rounded
        : alert.type == 'alert'
            ? Icons.error_rounded
            : alert.type == 'success'
                ? Icons.check_circle_rounded
                : Icons.info_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: alert.isRead ? _T.bgElevated : typeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.isRead ? Colors.transparent : typeColor.withValues(alpha: 0.3),
          width: alert.isRead ? 0 : 1,
        ),
        boxShadow: [
          if (!alert.isRead)
            BoxShadow(
              color: typeColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(typeIcon, color: typeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: _T.headline().copyWith(
                            color: _T.labelPrimary,
                            fontWeight: alert.isRead ? FontWeight.w500 : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!alert.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: typeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: _T.caption1().copyWith(color: _T.labelSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alert.timestamp,
                    style: _T.caption1().copyWith(color: _T.labelTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(Icons.close_rounded, color: _T.labelTertiary, size: 20),
              onPressed: onDismiss,
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminAlert {
  final String title;
  final String message;
  final String type; // warning | alert | success | info
  final String timestamp;
  final bool isRead;

  AdminAlert({
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });
}

// Design Tokens
class _T {
  static const green = Color(0xFF46A800);
  static const orange = Color(0xFFF59000);
  static const blue = Color(0xFF14A0E0);
  static const red = Color(0xFFEC3A3A);

  static const bg = Color(0xFFFdf6EC);
  static const bgElevated = Color(0xFFFFFAF4);

  static const labelPrimary = Color(0xFF1C1C1E);
  static const labelSecondary = Color(0xFF3C3C43);
  static const labelTertiary = Color(0xFF8E8E93);

  static TextStyle headline() => GoogleFonts.fredoka(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: labelPrimary,
      );

  static TextStyle caption1() => GoogleFonts.fredoka(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: labelPrimary,
      );
}
