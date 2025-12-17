import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torch_light/torch_light.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:vibration/vibration.dart';

// --- Torch Provider ---
// --- Torch Provider ---
class TorchNotifier extends AutoDisposeNotifier<bool> {
  @override
  bool build() {
    ref.onDispose(() async {
      try {
        await TorchLight.disableTorch();
      } catch (e) {
        // Ignore torch errors on simulator
      }
    });
    return false;
  }

  Future<void> toggle() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 50);
      }

      if (state) {
        await TorchLight.disableTorch();
        state = false;
      } else {
        await TorchLight.enableTorch();
        state = true;
      }
    } catch (e) {
      debugPrint('Torch error: $e'); // Safe to ignore on simulator
    }
  }

  Future<void> disable() async {
    if (state) {
      try {
        await TorchLight.disableTorch();
      } catch (e) {
         // Ignore torch errors on simulator
      }
      state = false;
    }
  }
}

final torchProvider = AutoDisposeNotifierProvider<TorchNotifier, bool>(TorchNotifier.new);

// --- Screen Settings Provider ---
class ScreenSettingsState {
  final Color color;
  final double brightness;

  ScreenSettingsState({
    this.color = const Color(0xFFF5F5F5), // Default Natural
    this.brightness = 0.5,
  });

  ScreenSettingsState copyWith({Color? color, double? brightness}) {
    return ScreenSettingsState(
      color: color ?? this.color,
      brightness: brightness ?? this.brightness,
    );
  }
}

class ScreenSettingsNotifier extends Notifier<ScreenSettingsState> {
  @override
  ScreenSettingsState build() {
    _initBrightness();
    return ScreenSettingsState();
  }

  Future<void> _initBrightness() async {
    try {
      final brightness = await ScreenBrightness().current;
      state = state.copyWith(brightness: brightness);
    } catch (e) {
      debugPrint('Brightness init error: $e');
    }
  }

  Future<void> setBrightness(double value) async {
    try {
      await ScreenBrightness().setScreenBrightness(value);
      state = state.copyWith(brightness: value);
    } catch (e) {
      debugPrint('Brightness set error: $e');
    }
  }

  void setColor(Color color) {
    state = state.copyWith(color: color);
  }
}

final screenSettingsProvider =
    NotifierProvider<ScreenSettingsNotifier, ScreenSettingsState>(
        ScreenSettingsNotifier.new);
