import 'package:flutter/material.dart';

class GlowButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isActive;
  final double size;
  final Color glowColor;

  const GlowButton({
    super.key,
    required this.onTap,
    required this.isActive,
    this.size = 150.0,
    this.glowColor = Colors.cyanAccent,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(GlowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: widget.size * (widget.isActive ? _scaleAnimation.value : 1.0),
            height: widget.size * (widget.isActive ? _scaleAnimation.value : 1.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[900],
              boxShadow: [
                if (widget.isActive)
                  BoxShadow(
                    color: widget.glowColor.withOpacity(0.6),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                if (widget.isActive)
                  BoxShadow(
                    color: widget.glowColor.withOpacity(0.3),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
              ],
              border: Border.all(
                color: widget.isActive ? widget.glowColor : Colors.grey[700]!,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.power_settings_new,
                size: widget.size * 0.4,
                color: widget.isActive ? Colors.white : Colors.grey[700],
              ),
            ),
          );
        },
      ),
    );
  }
}
