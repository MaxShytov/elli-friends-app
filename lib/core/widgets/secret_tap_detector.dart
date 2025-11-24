import 'package:flutter/material.dart';

/// A widget that detects secret tap patterns (e.g., triple tap)
/// to unlock hidden features.
class SecretTapDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onSecretTap;
  final int requiredTaps;
  final Duration tapTimeout;

  const SecretTapDetector({
    super.key,
    required this.child,
    required this.onSecretTap,
    this.requiredTaps = 3,
    this.tapTimeout = const Duration(milliseconds: 500),
  });

  @override
  State<SecretTapDetector> createState() => _SecretTapDetectorState();
}

class _SecretTapDetectorState extends State<SecretTapDetector> {
  int _tapCount = 0;
  DateTime? _lastTap;

  void _handleTap() {
    final now = DateTime.now();

    // Reset if more than timeout between taps
    if (_lastTap != null && now.difference(_lastTap!) > widget.tapTimeout) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTap = now;

    if (_tapCount >= widget.requiredTaps) {
      _tapCount = 0;
      widget.onSecretTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}
