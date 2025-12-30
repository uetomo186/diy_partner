import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../providers/level_providers.dart';

class LevelScreen extends ConsumerStatefulWidget {
  const LevelScreen({super.key});

  @override
  ConsumerState<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends ConsumerState<LevelScreen> {
  // Low-pass filter factors to reduce jitter
  double _x = 0;
  double _y = 0;
  bool _isBalanced = false;

  @override
  void initState() {
    super.initState();
  }

  void _updateLevel(AccelerometerEvent event) {
    // Smoother interpolation factor
    const double alpha = 0.1;

    setState(() {
      _x = _x * (1 - alpha) + event.x * alpha;
      _y = _y * (1 - alpha) + event.y * alpha;
    });

    _checkLevel();
  }

  void _checkLevel() {
    // Threshold for perfect level (allow slight error)
    bool isLevel = (_x.abs() < 0.2 && _y.abs() < 0.2);

    if (isLevel && !_isBalanced) {
      HapticFeedback.heavyImpact(); // Stronger feedback for success
    }
    if (mounted) {
      if (_isBalanced != isLevel) {
        setState(() {
          _isBalanced = isLevel;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to sensor updates
    ref.listen(levelSensorProvider, (previous, next) {
      next.whenData((event) => _updateLevel(event));
    });

    // Calculate angles
    // x/y are roughly m/s^2 (max ~9.8)
    // Map to degrees locally for display
    double xDegree = (_x / 9.8) * 90;
    double yDegree = (_y / 9.8) * 90;

    // Constrain for bubble movement (-1 to 1 range for alignment)
    // Invert X because tilting left (positive X accel) should move bubble right
    // Invert Y because tilting down (positive Y accel) should move bubble up
    double alignX = (-_x / 5).clamp(-1.0, 1.0);
    double alignY = (_y / 5).clamp(-1.0, 1.0);

    final bgColor = const Color(0xFF121212);
    final accentColor = _isBalanced
        ? const Color(0xFF00FF88)
        : Colors.cyanAccent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('LEVEL', style: TextStyle(letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white.withOpacity(0.8),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Outer Neumorphic Container
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                boxShadow: [
                  // Light source (Top Left)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    offset: const Offset(-10, -10),
                    blurRadius: 20,
                  ),
                  // Shadow (Bottom Right)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: const Offset(10, 10),
                    blurRadius: 20,
                  ),
                  // Inner Glow for depth if balanced
                  if (_isBalanced)
                    BoxShadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Inner Concave Surface
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withOpacity(0.9), // Darker inner shadow
                          bgColor,
                        ],
                      ),
                    ),
                  ),

                  // Target Ring (Center)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 2,
                      ),
                      boxShadow: _isBalanced
                          ? [
                              BoxShadow(
                                color: accentColor.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                  ),

                  // Crosshair lines
                  Container(width: 200, height: 1, color: Colors.white10),
                  Container(width: 1, height: 200, color: Colors.white10),

                  // The "Liquid" Bubble
                  AnimatedAlign(
                    alignment: Alignment(alignX, alignY),
                    duration: const Duration(
                      milliseconds: 100,
                    ), // Smooth intertia
                    curve: Curves.easeOutCubic,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withOpacity(0.8),
                        boxShadow: [
                          // Glow
                          BoxShadow(
                            color: accentColor,
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                          // Highlight (Glossy effect)
                          const BoxShadow(
                            color: Colors.white54,
                            offset: Offset(-8, -8),
                            blurRadius: 15,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.9),
                                accentColor.withOpacity(0.0),
                              ],
                              center: const Alignment(-0.3, -0.3),
                              radius: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Digital Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDigitalDisplay('ROLL (X)', xDegree),
                Container(width: 1, height: 40, color: Colors.white12),
                _buildDigitalDisplay('PITCH (Y)', yDegree),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalDisplay(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${value.toStringAsFixed(1)}°",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w200,
            fontFamily: "Courier",
            shadows: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
