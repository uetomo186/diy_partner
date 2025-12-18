import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/light_providers.dart';

class LightScreen extends ConsumerWidget {
  const LightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final torchState = ref.watch(torchProvider);
    final notifier = ref.read(torchProvider.notifier);

    final isOn = torchState.isAccurate;
    final intensity = torchState.intensity;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title or Header could go here
            const Text(
              'LIGHT',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 24,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            // Power Button
            GestureDetector(
              onTap: notifier.toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOn ? Colors.white : Colors.grey[900],
                  boxShadow: [
                    if (isOn)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: isOn ? Colors.white : Colors.white10,
                    width: 4,
                  ),
                ),
                child: Icon(
                  Icons.power_settings_new,
                  size: 80,
                  color: isOn ? Colors.black : Colors.white24,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Brightness Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(
                        Icons.brightness_low,
                        color: Colors.white54,
                        size: 20,
                      ),
                      Icon(
                        Icons.brightness_high,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,

                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 24,
                      ),
                    ),
                    child: Slider(
                      value: intensity,
                      onChanged: (val) {
                        notifier.setIntensity(val);
                      },
                      min: 0.01,
                      max: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
