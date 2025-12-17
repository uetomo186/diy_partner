import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../providers/light_providers.dart';

class ScreenMode extends ConsumerStatefulWidget {
  const ScreenMode({super.key});

  @override
  ConsumerState<ScreenMode> createState() => _ScreenModeState();
}

class _ScreenModeState extends ConsumerState<ScreenMode> {
  // Fluorescent Presets
  final Color _warmColor = const Color(0xFFFFA726);
  final Color _naturalColor = const Color(0xFFF5F5F5);
  final Color _coolColor = const Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable().catchError((e) {
       debugPrint('Wakelock enable error: $e');
    });
    // Brightness init is handled by provider, but we set wakelock here
  }

  @override
  void dispose() {
    WakelockPlus.disable().catchError((e) {
       debugPrint('Wakelock disable error: $e');
    });
    ScreenBrightness().resetScreenBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(screenSettingsProvider);
    final notifier = ref.read(screenSettingsProvider.notifier);

    return Stack(
      children: [
        // Background Color Layer (The Light)
        Container(
          color: settings.color,
          width: double.infinity,
          height: double.infinity,
        ),

        // Control Panel Layer (Always Visible)
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CONTROLS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Presets Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPresetBtn('Warm', _warmColor, settings.color, notifier),
                          _buildPresetBtn('Natural', _naturalColor, settings.color, notifier),
                          _buildPresetBtn('Cool', _coolColor, settings.color, notifier),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Brightness Slider
                      Row(
                        children: [
                          const Icon(Icons.brightness_low, color: Colors.white70, size: 20),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                activeTrackColor: Colors.cyanAccent,
                                inactiveTrackColor: Colors.white24,
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                value: settings.brightness,
                                onChanged: notifier.setBrightness,
                              ),
                            ),
                          ),
                          const Icon(Icons.brightness_high, color: Colors.white70, size: 20),
                        ],
                      ),
                      
                      // Custom Color Picker Link
                      Center(
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Pick a color'),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: settings.color,
                                    onColorChanged: notifier.setColor,
                                    displayThumbColor: true,
                                    enableAlpha: false,
                                    paletteType: PaletteType.hsvWithHue,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Done'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text(
                            'Custom Color',
                            style: TextStyle(color: Colors.cyanAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
  }

  Widget _buildPresetBtn(String label, Color color, Color currentColor, ScreenSettingsNotifier notifier) {
    bool isSelected = currentColor == color;
    return GestureDetector(
      onTap: () => notifier.setColor(color),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.cyanAccent, width: 3)
                  : Border.all(color: Colors.white24, width: 1),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.cyanAccent : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
