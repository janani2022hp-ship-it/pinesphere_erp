import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_screen.dart';

// ← ADD THIS - handles notification when app is fully closed
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📩 Background notification: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ← ADD THIS - background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ← ADD THIS - foreground handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 Foreground notification: ${message.notification?.title}");
  });

  // ← ADD THIS - notification tap handler
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("📩 Notification tapped: ${message.notification?.title}");
  });

  runApp(const PineSphereApp());
}

class PineSphereApp extends StatelessWidget {
  const PineSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PineSphere ERP',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}