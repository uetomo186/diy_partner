import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;
import 'package:vibration/vibration.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  double _x = 0;
  double _y = 0;
  DateTime _lastVibrationTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          // Low-pass filter to smooth out noise
          _x = _x * 0.9 + event.x * 0.1;
          _y = _y * 0.9 + event.y * 0.1;
        });
        _checkLevel();
      }
    });
  }

  void _checkLevel() async {
    // Check if device is roughly flat (within 1 degree essentially)
    // x and y are roughly 0 when flat on table
    bool isLevel = (_x.abs() < 0.2 && _y.abs() < 0.2);

    if (isLevel) {
      final now = DateTime.now();
      // Vibrate only once every 500ms to avoid constant buzzing
      if (now.difference(_lastVibrationTime).inMilliseconds > 500) {
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 50);
        }
        _lastVibrationTime = now;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate position for the bubble
    // Clamp values to keep bubble inside the circle
    final double bubbleX = (-_x * 20).clamp(-100.0, 100.0);
    final double bubbleY = (_y * 20).clamp(-100.0, 100.0);
    
    // Check level for UI feedback
    final bool isLevel = (_x.abs() < 0.3 && _y.abs() < 0.3);

    return Scaffold(
      appBar: AppBar(title: const Text('水平器')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(
                  color: isLevel ? Colors.green : Colors.grey,
                  width: 5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Crosshair
                  Container(width: 200, height: 1, color: Colors.grey[400]),
                  Container(width: 1, height: 200, color: Colors.grey[400]),
                  
                  // Center target zone
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 1,
                      ),
                    ),
                  ),

                  // The Bubble
                  Transform.translate(
                    offset: Offset(bubbleX, bubbleY),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isLevel ? Colors.green : Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isLevel ? Colors.green : Colors.red).withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'X: ${_x.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontFamily: 'monospace'),
            ),
            Text(
              'Y: ${_y.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 20),
            Text(
              isLevel ? '水平です！' : '傾いています',
              style: TextStyle(
                color: isLevel ? Colors.green : Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
