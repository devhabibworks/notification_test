import 'package:flutter_background_service/flutter_background_service.dart';
import 'tts_service.dart';

void onStart(ServiceInstance service) {
  service.on('trigger_tts').listen((event) {
    final message = event?['message'] ?? 'Default TTS message';
    TTSService.speak(message);
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
        foregroundServiceNotificationId: 999,
        initialNotificationTitle: 'Background Service',
        initialNotificationContent: 'Listening for TTS triggers',
      ),
      iosConfiguration: IosConfiguration(),
    );
    await service.startService();
  }
}
