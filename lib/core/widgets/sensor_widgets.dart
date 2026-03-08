import 'package:flutter/material.dart';
import '../services/shake_detector_service.dart';
import '../services/proximity_sensor_service.dart';
import '../services/tilt_scroll_service.dart';

/// Shake Detector Widget
class ShakeDetectorWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onShake;
  final bool enabled;

  const ShakeDetectorWidget({
    Key? key,
    required this.child,
    required this.onShake,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ShakeDetectorWidget> createState() => _ShakeDetectorWidgetState();
}

class _ShakeDetectorWidgetState extends State<ShakeDetectorWidget> {
  final ShakeDetectorService _shakeService = ShakeDetectorService();
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _shakeService.startListening(onShake: _handleShake);
    }
  }

  void _handleShake() {
    if (!mounted || !widget.enabled) return;

    setState(() => _isShaking = true);
    widget.onShake();

    // Reset shake animation after 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isShaking = false);
      }
    });
  }

  @override
  void dispose() {
    _shakeService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Visual feedback on shake
        if (_isShaking)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.blue.withOpacity(0.1),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.refresh, size: 32, color: Colors.blue),
                        SizedBox(height: 8),
                        Text(
                          'Refreshing...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Proximity Detector Widget
class ProximityDetectorWidget extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const ProximityDetectorWidget({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ProximityDetectorWidget> createState() =>
      _ProximityDetectorWidgetState();
}

class _ProximityDetectorWidgetState extends State<ProximityDetectorWidget> {
  final ProximitySensorService _proximityService = ProximitySensorService();

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _proximityService.startListening();
    }
  }

  @override
  void dispose() {
    _proximityService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Tilt Scroll Widget
class TiltScrollWidget extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final bool enabled;

  const TiltScrollWidget({
    Key? key,
    required this.child,
    required this.scrollController,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<TiltScrollWidget> createState() => _TiltScrollWidgetState();
}

class _TiltScrollWidgetState extends State<TiltScrollWidget> {
  final TiltScrollService _tiltService = TiltScrollService();

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _tiltService.startListening(widget.scrollController);
    }
  }

  @override
  void dispose() {
    _tiltService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
