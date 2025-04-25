import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
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
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        _handleNotificationTap();
      },
    );

    // Optional: explicitly create the notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'main_channel_id',
      'Main Channel',
      description: 'Used for important scheduled notifications.',
      importance: Importance.max,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel_id', // Must match the channel ID created in init
          'Main Channel',
          channelDescription: 'Used for important scheduled notifications.',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null, // Keep null unless repeating
    );
  }

  static void _handleNotificationTap() async {
    final service = FlutterBackgroundService();
    service.invoke('trigger_tts', {
      'message': 'You have received a scheduled notification!',
    });
  }
}
