// lib/widgets/macro_ring_widget.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class MacroRingWidget extends StatelessWidget {
  final double consumedCalories;
  final int targetCalories;
  final double proteinG;
  final int targetProteinG;
  final double carbsG;
  final int targetCarbsG;
  final double fatG;
  final int targetFatG;

  const MacroRingWidget({
    super.key,
    required this.consumedCalories,
    required this.targetCalories,
    required this.proteinG,
    required this.targetProteinG,
    required this.carbsG,
    required this.targetCarbsG,
    required this.fatG,
    required this.targetFatG,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = max(0, targetCalories - consumedCalories.toInt());
    final progress = (consumedCalories / (targetCalories > 0 ? targetCalories : 1)).clamp(0.0, 1.0);

    return Row(
      children: [
        // Anel Circular com Painter
        SizedBox(
          width: 110,
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(110, 110),
                painter: _MacroRingPainter(
                  calorieProgress: progress,
                  proteinRatio: (proteinG / (targetProteinG > 0 ? targetProteinG : 1)).clamp(0.0, 1.0),
                  carbsRatio: (carbsG / (targetCarbsG > 0 ? targetCarbsG : 1)).clamp(0.0, 1.0),
                  fatRatio: (fatG / (targetFatG > 0 ? targetFatG : 1)).clamp(0.0, 1.0),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${consumedCalories.toInt()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.extrabold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'kcal hoje',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),

        // Detalhes dos Macronutrientes
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Balanço Diário',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Restam $remaining kcal',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildMacroProgressBar('Proteínas', proteinG, targetProteinG, Colors.blueAccent),
              const SizedBox(height: 6),
              _buildMacroProgressBar('Carboidratos', carbsG, targetCarbsG, Colors.orangeAccent),
              const SizedBox(height: 6),
              _buildMacroProgressBar('Gorduras', fatG, targetFatG, Colors.pinkAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroProgressBar(String label, double current, int target, Color color) {
    final progress = (current / (target > 0 ? target : 1)).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
            Text(
              '${current.toInt()}g / ${target}g',
              style: TextStyle(color: Colors.grey[300], fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.darkBackground,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

class _MacroRingPainter extends CustomPainter {
  final double calorieProgress;
  final double proteinRatio;
  final double carbsRatio;
  final double fatRatio;

  _MacroRingPainter({
    required this.calorieProgress,
    required this.proteinRatio,
    required this.carbsRatio,
    required this.fatRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background Circle
    final bgPaint = Paint()
      ..color = AppTheme.darkBackground
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;
    canvas.drawCircle(center, radius, bgPaint);

    // Active Calorie Arc (Emerald Glow)
    final sweepAngle = 2 * pi * calorieProgress;
    final progressPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 9;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MacroRingPainter oldDelegate) {
    return oldDelegate.calorieProgress != calorieProgress ||
        oldDelegate.proteinRatio != proteinRatio;
  }
}

