import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';
import '../providers/level_providers.dart';

class LevelScreen extends ConsumerStatefulWidget {
  const LevelScreen({super.key});

  @override
  ConsumerState<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends ConsumerState<LevelScreen> {
  double _x = 0;
  double _y = 0;
  bool _isBalanced = false;

  @override
  void initState() {
    super.initState();
    // We listen to the stream in build via ref.watch
  }

  void _updateLevel(AccelerometerEvent event) {
    // Basic low-pass filter
    setState(() {
      _x = _x * 0.9 + event.x * 0.1;
      _y = _y * 0.9 + event.y * 0.1;
    });
    _checkLevel();
  }

  void _checkLevel() async {
    // Threshold for "level"
    // Accelerometer returns ~0 for x/y when flat on table
    bool isLevel = (_x.abs() < 0.2 && _y.abs() < 0.2);

    if (isLevel && !_isBalanced) {
      HapticFeedback.mediumImpact();
    }
    if (mounted) {
      setState(() {
        _isBalanced = isLevel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accelerometerAsync = ref.watch(levelSensorProvider);

    // React to stream changes
    accelerometerAsync.whenData((event) {
      // We need to update state based on event, but doing setState during build is bad.
      // However, for high-frequency sensor data, using a StreamBuilder or ref.watch directly in build
      // and calculating position there is better than setting state.
      // Let's adjust logic: calculate values directly from the latest async value
      // But we applied a low-pass filter before.
      // For simplicity in this refactor, we can just use the raw event or specific filtered provider.
      // To keep the filter logic simple without complex providers, we'll keep the side-effect based approach
      // but strictly speaking, we should use a StreamProvider.family or similar.
      // A better way for Riverpod is to have a provider yielding the filtered value.
      // For now, let's use a workaround:
      // We will perform the logic in the listener below.
    });

    // Better approach: use ref.listen to update manual state with filter
    ref.listen(levelSensorProvider, (previous, next) {
      next.whenData((event) => _updateLevel(event));
    });

    // Calculate display values
    // Angle calculation (approximate for display)
    // x/y are acceleration in m/s^2. max is ~9.8
    double xAngle = (_x / 9.8) * 90;
    double yAngle = (_y / 9.8) * 90;

    // Visual constraints
    double bubbleX = -_x * 20; // Scale factor
    double bubbleY =
        _y * 20; // Y axis is inverted on screen relative to sensor usually

    // Clamp for UI
    bubbleX = bubbleX.clamp(-100.0, 100.0);
    bubbleY = bubbleY.clamp(-100.0, 100.0);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[900],
              border: Border.all(
                color: _isBalanced
                    ? Colors.greenAccent
                    : Colors.cyanAccent.withOpacity(0.5),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isBalanced
                      ? Colors.greenAccent.withOpacity(0.3)
                      : Colors.cyanAccent.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Crosshair
                Container(width: 280, height: 1, color: Colors.white12),
                Container(width: 1, height: 280, color: Colors.white12),

                // Center target
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                ),

                // The Bubble
                Transform.translate(
                  offset: Offset(bubbleX, bubbleY),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isBalanced
                          ? Colors.greenAccent
                          : Colors.cyanAccent,
                      boxShadow: [
                        BoxShadow(
                          color: _isBalanced
                              ? Colors.greenAccent
                              : Colors.cyanAccent,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildValueDisplay("左右", xAngle),
              _buildValueDisplay("前後", yAngle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplay(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "${value.toStringAsFixed(1)}°",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w300,
            fontFamily: "Courier", // Monospace for stability
          ),
        ),
      ],
    );
  }
}
