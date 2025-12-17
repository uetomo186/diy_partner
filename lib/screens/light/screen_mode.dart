import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ScreenMode extends StatefulWidget {
  const ScreenMode({super.key});

  @override
  State<ScreenMode> createState() => _ScreenModeState();
}

class _ScreenModeState extends State<ScreenMode> {
  Color _screenColor = const Color(0xFFF5F5F5); // Default to Natural
  double _brightness = 0.5;

  // Fluorescent Presets
  final Color _warmColor = const Color(0xFFFFA726);
  final Color _naturalColor = const Color(0xFFF5F5F5);
  final Color _coolColor = const Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _initBrightness();
  }

  Future<void> _initBrightness() async {
    try {
      final brightness = await ScreenBrightness().current;
      setState(() {
        _brightness = brightness;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    ScreenBrightness().resetScreenBrightness();
    super.dispose();
  }

  Future<void> _setBrightness(double value) async {
    try {
      await ScreenBrightness().setScreenBrightness(value);
      setState(() {
        _brightness = value;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Color Layer (The Light)
        Container(
          color: _screenColor,
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
                          _buildPresetBtn('Warm', _warmColor),
                          _buildPresetBtn('Natural', _naturalColor),
                          _buildPresetBtn('Cool', _coolColor),
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
                                value: _brightness,
                                onChanged: _setBrightness,
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
                                    pickerColor: _screenColor,
                                    onColorChanged: _setColor,
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
      ),
    );
  }

  Widget _buildPresetBtn(String label, Color color) {
    bool isSelected = _screenColor == color;
    return GestureDetector(
      onTap: () => _setColor(color),
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
