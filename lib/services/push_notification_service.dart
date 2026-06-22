import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // FCM background handling is intentionally lightweight here;
  // the local notification plugin is used for visible alerts.
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final bool isRead;
  final DateTime? createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? '',
      category: json['category']?.toString() ?? 'general',
      isRead: json['is_read'] == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class PushNotificationService {
  static const String _host =
      'https://vaguely-dastardly-pennant.ngrok-free.dev';
  static const String _deviceTokenKey = 'push_device_token';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'pinesphere_erp_channel',
    'Pinesphere ERP Notifications',
    description: 'Student, trainer, and parent alerts',
    importance: Importance.high,
  );

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessage(message);
    });

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    await registerCurrentDevice();
    _fcm.onTokenRefresh.listen((_) => registerCurrentDevice());
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'New notification';
    final body =
        message.notification?.body ?? message.data['body']?.toString() ?? '';

    if (title.isEmpty && body.isEmpty) return;

    final payload = message.data.isNotEmpty
        ? jsonEncode(message.data)
        : jsonEncode({'title': title, 'body': body});

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null || response.payload!.isEmpty) return;

    try {
      final payload = jsonDecode(response.payload!) as Map<String, dynamic>;
      _handleData(payload);
    } catch (_) {}
  }

  void _handleMessage(RemoteMessage message) {
    _handleData(message.data);
  }

  void _handleData(Map<String, dynamic> data) {
    final category = data['category']?.toString() ?? '';
    debugPrint('Notification category: $category');
  }

  Future<void> registerCurrentDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final role = prefs.getString('user_role') ?? 'student';
    if (userId.isEmpty) return;

    final token = await _fcm.getToken();
    if (token == null || token.isEmpty) return;

    await prefs.setString(_deviceTokenKey, token);

    await http
        .post(
          Uri.parse('$_host/notifications/devices'),
          headers: _headers,
          body: jsonEncode({
            'user_id': userId,
            'role': role,
            'token': token,
            'platform': _platformName(),
            'enabled': true,
          }),
        )
        .timeout(const Duration(seconds: 8));
  }

  Future<List<AppNotification>> fetchNotifications({
    bool unreadOnly = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    if (userId.isEmpty) return const [];

    final response = await http
        .get(
          Uri.parse('$_host/notifications/$userId?unread_only=$unreadOnly'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Failed to load notifications');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
  }

  Future<int> unreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    if (userId.isEmpty) return 0;

    final response = await http
        .get(
          Uri.parse('$_host/notifications/$userId/unread-count'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) return 0;
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return int.tryParse(decoded['unread_count']?.toString() ?? '0') ?? 0;
  }

  Future<void> markRead(String notificationId) async {
    if (notificationId.isEmpty) return;
    await http
        .patch(
          Uri.parse('$_host/notifications/$notificationId/read'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 8));
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }
}
