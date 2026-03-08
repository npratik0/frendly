import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectorService {
  static final ShakeDetectorService _instance =
      ShakeDetectorService._internal();
  factory ShakeDetectorService() => _instance;
  ShakeDetectorService._internal();

  StreamSubscription<AccelerometerEvent>? _subscription;
  Function? _onShake;

  // Shake detection parameters
  static const double shakeThreshold = 15.0;
  static const int shakeDuration = 500; // ms

  DateTime? _lastShakeTime;
  bool _isListening = false;

  bool get isListening => _isListening;

  void startListening({required Function onShake}) {
    if (_isListening) return;

    _onShake = onShake;
    _isListening = true;

    _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      // Calculate total acceleration
      final double acceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      // Check if acceleration exceeds threshold
      if (acceleration > shakeThreshold) {
        final now = DateTime.now();

        // Prevent multiple triggers
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!).inMilliseconds > shakeDuration) {
          _lastShakeTime = now;
          print(
            '🔄 Shake detected! Acceleration: ${acceleration.toStringAsFixed(2)}',
          );
          _onShake?.call();
        }
      }
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    _onShake = null;
  }

  void dispose() {
    stopListening();
  }
}
