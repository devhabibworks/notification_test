import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'background_service.dart';
import 'tts_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

static Future<void> init() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  await _notifications.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      print("$log onDidReceiveNotificationResponse");
      _handleNotificationTap();
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

    // ⬇️ Important NEW: request permission for exact alarm
    final bool? canScheduleExactNotifications = await androidPlugin.requestExactAlarmsPermission();
    print("$log canScheduleExactNotifications: $canScheduleExactNotifications");
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
  scheduledDate, // <- must be tz.TZDateTime
  const NotificationDetails(
    android: AndroidNotificationDetails(
      'main_channel_id',
      'Main Channel',
      channelDescription: 'Used for important scheduled notifications.',
      importance: Importance.max,
      priority: Priority.high,
    ),
  ),
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  matchDateTimeComponents: null, // Only needed if you want repeating
);
}
  static void _handleNotificationTap() async {
    print("$log _handleNotificationTap");

    final service = FlutterBackgroundService();
    service.invoke('trigger_tts', {
      'message': 'You have received a scheduled notification!',
    });
  }

 static testNotificaoin(){
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


}
