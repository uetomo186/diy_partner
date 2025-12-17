import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/glow_button.dart';
import '../../providers/light_providers.dart';

class TorchMode extends ConsumerStatefulWidget {
  const TorchMode({super.key});

  @override
  ConsumerState<TorchMode> createState() => _TorchModeState();
}

class _TorchModeState extends ConsumerState<TorchMode> {


  @override
  Widget build(BuildContext context) {
    final isTorchOn = ref.watch(torchProvider);
    final notifier = ref.read(torchProvider.notifier);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlowButton(
            onTap: notifier.toggle,
            isActive: isTorchOn,
          ),
          const SizedBox(height: 40),
          Text(
            isTorchOn ? 'ON' : 'OFF',
            style: TextStyle(
              color: isTorchOn ? Colors.cyanAccent : Colors.grey,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: isTorchOn
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
