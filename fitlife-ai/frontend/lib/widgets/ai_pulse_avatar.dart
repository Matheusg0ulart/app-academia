// lib/widgets/ai_pulse_avatar.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AiPulseAvatar extends StatefulWidget {
  final double size;

  const AiPulseAvatar({super.key, this.size = 54});

  @override
  State<AiPulseAvatar> createState() => _AiPulseAvatarState();
}

class _AiPulseAvatarState extends State<AiPulseAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Aura de pulso
            Container(
              width: widget.size * _scaleAnimation.value,
              height: widget.size * _scaleAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.18),
              ),
            ),
            // Avatar Central
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: AppTheme.cardDarkBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.primaryColor,
                size: widget.size * 0.45,
              ),
            ),
          ],
        );
      },
    );
  }
}

