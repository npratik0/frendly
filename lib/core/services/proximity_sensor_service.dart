import 'dart:async';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:screen_brightness/screen_brightness.dart';

class ProximitySensorService {
  static final ProximitySensorService _instance =
      ProximitySensorService._internal();
  factory ProximitySensorService() => _instance;
  ProximitySensorService._internal();

  StreamSubscription<int>? _subscription;
  bool _isListening = false;
  bool _isNear = false;
  double? _originalBrightness;

  bool get isListening => _isListening;
  bool get isNear => _isNear;

  Future<void> startListening() async {
    if (_isListening) return;

    try {
      // Store original brightness
      _originalBrightness = await ScreenBrightness().current;

      _isListening = true;

      _subscription = ProximitySensor.events.listen((int event) async {
        // event: 0 = far, 1-10 = near (varies by device)
        final bool near = event > 0;

        if (near != _isNear) {
          _isNear = near;
          print('💡 Proximity: ${near ? "NEAR" : "FAR"}');

          // Adjust brightness
          if (near) {
            // Dim to 10% when near
            await ScreenBrightness().setScreenBrightness(0.1);
          } else {
            // Restore original brightness when far
            if (_originalBrightness != null) {
              await ScreenBrightness().setScreenBrightness(
                _originalBrightness!,
              );
            }
          }
        }
      });
    } catch (e) {
      print('❌ Proximity sensor error: $e');
    }
  }

  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    _isNear = false;

    // Restore original brightness
    if (_originalBrightness != null) {
      try {
        await ScreenBrightness().setScreenBrightness(_originalBrightness!);
      } catch (e) {
        print('Error restoring brightness: $e');
      }
    }
  }

  void dispose() {
    stopListening();
  }
}
