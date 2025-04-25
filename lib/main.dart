import 'package:flutter/material.dart';
import 'package:notification_test/services/tts_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

import 'services/notification_service.dart';
import 'services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request notification permission (Android 13+)
  await _requestNotificationPermission();

  // Initialize time zones
  tz.initializeTimeZones();
  final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

  // Initialize notification & background services
  await NotificationService.init();
  await BackgroundService.initialize();

  runApp(const MyApp());
}

/// Request permission for notifications (Android 13+)
Future<void> _requestNotificationPermission() async {
  final notificationStatus = await Permission.notification.status;
  if (!notificationStatus.isGranted) {
    await Permission.notification.request();
  }

  final alarmStatus = await Permission.scheduleExactAlarm.status;
  if (!alarmStatus.isGranted) {
    await Permission.scheduleExactAlarm.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification TTS App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification + TTS')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // // TTSService.speak("Hello World");
             final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));


            print("$log $scheduledDate");
            try {
              await NotificationService.scheduleNotification(
                id: 0,
                title: 'Scheduled Reminder',
                body: 'This is your scheduled TTS notification.',
                scheduledDate: scheduledDate,
              );
              print('Notification scheduled for $scheduledDate');
            } catch (e) {
              print('Error scheduling notification: $e');
            }

            //  NotificationService.testNotificaoin();
          },
          child: const Text('Schedule Notification (10s)'),
        ),
      ),
    );
  }
}
