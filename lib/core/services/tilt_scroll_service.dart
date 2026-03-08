import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class TiltScrollService {
  static final TiltScrollService _instance = TiltScrollService._internal();
  factory TiltScrollService() => _instance;
  TiltScrollService._internal();

  StreamSubscription<AccelerometerEvent>? _subscription;
  ScrollController? _scrollController;
  Timer? _scrollTimer;
  bool _isListening = false;

  // ✅ UPDATED: Higher threshold for better control
  // Old: 2.0 (too sensitive)
  // New: 4.5 (requires more intentional tilt)
  static const double tiltThreshold = 4.5; // Minimum tilt to trigger scroll

  // Dead zone - small movements ignored
  static const double deadZone = 3.0; // Ignore tiny tilts

  static const double maxScrollSpeed = 20.0; // Max pixels per tick
  static const int scrollInterval = 50; // ms between scroll ticks

  bool get isListening => _isListening;

  void startListening(ScrollController scrollController) {
    if (_isListening) return;

    _scrollController = scrollController;
    _isListening = true;

    print('📐 Tilt scroll started (threshold: $tiltThreshold)');

    _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      // Y-axis: negative = tilt forward, positive = tilt backward
      final double tiltY = event.y;

      // ✅ DEBUG: Uncomment to see tilt values
      // print('Tilt Y: ${tiltY.toStringAsFixed(2)} / Threshold: $tiltThreshold');

      // ✅ UPDATED: Check against higher threshold
      if (tiltY.abs() > tiltThreshold) {
        _startAutoScroll(tiltY);
      } else {
        _stopAutoScroll();
      }
    });
  }

  void _startAutoScroll(double tiltY) {
    // Stop existing timer
    _scrollTimer?.cancel();

    // ✅ UPDATED: Better speed calculation
    // Only scroll if tilt exceeds dead zone
    if (tiltY.abs() < deadZone) {
      _stopAutoScroll();
      return;
    }

    // Calculate scroll speed based on tilt angle
    // Subtract dead zone from calculation for smoother experience
    final double effectiveTilt = tiltY.abs() - deadZone;
    final double speed = (effectiveTilt / 10.0 * maxScrollSpeed).clamp(
      1.0,
      maxScrollSpeed,
    );

    // Positive tiltY = scroll down, negative = scroll up
    final double scrollDelta = tiltY > 0 ? speed : -speed;

    // ✅ DEBUG: Uncomment to see scroll activity
    // print('📜 Scrolling at speed: ${speed.toStringAsFixed(2)} px/tick');

    _scrollTimer = Timer.periodic(
      const Duration(milliseconds: scrollInterval),
      (timer) {
        if (_scrollController == null || !_scrollController!.hasClients) {
          timer.cancel();
          return;
        }

        final double currentOffset = _scrollController!.offset;
        final double maxScroll = _scrollController!.position.maxScrollExtent;
        final double newOffset = (currentOffset + scrollDelta).clamp(
          0.0,
          maxScroll,
        );

        _scrollController!.jumpTo(newOffset);
      },
    );
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  void stopListening() {
    _stopAutoScroll();
    _subscription?.cancel();
    _subscription = null;
    _scrollController = null;
    _isListening = false;
    print('📐 Tilt scroll stopped');
  }

  void dispose() {
    stopListening();
  }
}
