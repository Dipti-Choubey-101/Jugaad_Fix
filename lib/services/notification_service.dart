import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:jugaad_fix/data/sample_data.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  static Future<void> requestPermission() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestExactAlarmsPermission();
      }
    } catch (e) {
      // Permission request failed silently
    }
  }

  static Future<void> scheduleDailyJugaad() async {
    try {
      await _plugin.cancel(0);

      final jugaads = List.from(initialJugaads);
      jugaads.shuffle();
      final jugaad = jugaads.first;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'daily_jugaad_channel',
        'Daily Jugaad',
        channelDescription:
            'Roz ek naya jugaad — seedha aapke phone pe!',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        color: Color(0xFFFF6B00),
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await _plugin.zonedSchedule(
        0,
        '🔧 Aaj ka Jugaad: ${jugaad.title}',
        jugaad.shortDescription,
        _nextInstanceOf9AM(),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Scheduling failed silently
    }
  }

  static Future<void> showTestNotification() async {
    try {
      final jugaads = List.from(initialJugaads);
      jugaads.shuffle();
      final jugaad = jugaads.first;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'daily_jugaad_channel',
        'Daily Jugaad',
        channelDescription:
            'Roz ek naya jugaad — seedha aapke phone pe!',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFFFF6B00),
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await _plugin.show(
        1,
        '🔧 Jugaad Fix: ${jugaad.title}',
        jugaad.shortDescription,
        notificationDetails,
      );
    } catch (e) {
      // Show failed silently
    }
  }

  static tz.TZDateTime _nextInstanceOf9AM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9,
      0,
      0,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}