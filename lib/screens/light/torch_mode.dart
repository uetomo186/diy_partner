import 'package:flutter/material.dart';
import '../../widgets/glow_button.dart';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';

class TorchMode extends StatefulWidget {
  const TorchMode({super.key});

  @override
  State<TorchMode> createState() => _TorchModeState();
}

class _TorchModeState extends State<TorchMode> {
  bool _isTorchOn = false;

  Future<void> _toggleTorch() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 50); // Haptic feedback
      }

      if (_isTorchOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e) {
      // Handle error (e.g., no torch available)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ライトを制御できませんでした')),
      );
    }
  }

  @override
  void dispose() {
    // Ensure torch is off when leaving
    TorchLight.disableTorch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlowButton(
            onTap: _toggleTorch,
            isActive: _isTorchOn,
          ),
          const SizedBox(height: 40),
          Text(
            _isTorchOn ? 'ON' : 'OFF',
            style: TextStyle(
              color: _isTorchOn ? Colors.cyanAccent : Colors.grey,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: _isTorchOn
                  ? [
                      const Shadow(
                        blurRadius: 10.0,
                        color: Colors.cyanAccent,
                        offset: Offset(0, 0),
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
