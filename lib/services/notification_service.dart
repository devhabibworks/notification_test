import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'background_service.dart';
import 'tts_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

        static const platform = MethodChannel('com.example.notification_test/alarm');


  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) async {
        print("$log onDidReceiveNotificationResponse");
      //  _handleNotificationTap();
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'main_channel_id',
      'Main Channel',
      description: 'Used for important scheduled notifications.',
      importance: Importance.max,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);

      // Request permission explicitly
      final granted = await androidPlugin.requestExactAlarmsPermission();
      print('$log requestExactAlarmsPermission: $granted');

      final canSchedule = await androidPlugin.canScheduleExactNotifications();
      print('$log canScheduleExactNotifications: $canSchedule');
    }
  }

static Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required tz.TZDateTime scheduledDate,
}) async {
  await _notifications.zonedSchedule(
    id,
    title,
    body,
    scheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'main_channel_id',
        'Main Channel',
        channelDescription: 'Used for important scheduled notifications.',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: null,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    payload: body, // ✅ pass the message text as payload
  );
}

  // static void _handleNotificationTap() async {
  //   print("$log _handleNotificationTap");

  //   final service = FlutterBackgroundService();
  //   service.invoke('trigger_tts', {
  //     'message': 'You have received a scheduled notification!',
  //   });
  // }

  static void triggerNotificationLogic() {
    // Allow programmatic (automatic) execution
  //  _handleNotificationTap();
  }

  static void testNotification() {
    NotificationService._notifications.show(
      0,
      'Test Immediate Notification',
      'This should appear instantly.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel_id',
          'Main Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
 static Future<void> scheduleAndroidAlarm(DateTime datetime) async {
    if (Platform.isAndroid) {
      final int alarmTimeMillis = datetime.millisecondsSinceEpoch;
      try {
        await platform.invokeMethod('scheduleAlarm', {'time': alarmTimeMillis});
      } on PlatformException catch (e) {
        print("Failed to schedule alarm: '${e.message}'.");
      }
    }
  }

}
