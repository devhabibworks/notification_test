import 'package:flutter_background_service/flutter_background_service.dart';
import 'tts_service.dart';

String log = "notificaion_log";

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  service.on('trigger_tts').listen((event) {
    
    try{
          print("$log $event");
        print("$log ${event?['message']}");

    final message = event?['message'] ?? 'Default TTS message';
    TTSService.speak(message);
    }
    catch(e){
          print("$log error = ${e.toString()}");

    }

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
