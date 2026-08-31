// lib/widgets/measurement_bars_chart.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class MeasurementComparison {
  final String label;
  final double initialValue;
  final double currentValue;
  final String unit;

  const MeasurementComparison({
    required this.label,
    required this.initialValue,
    required this.currentValue,
    this.unit = 'cm',
  });

  double get diff => currentValue - initialValue;
}

class MeasurementBarsChart extends StatelessWidget {
  final List<MeasurementComparison> items;

  const MeasurementBarsChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Sem medições suficientes para comparação.', style: TextStyle(color: Colors.grey, fontSize: 12)));
    }

    return Column(
      children: items.map((item) {
        final isPositive = item.diff > 0;
        final diffStr = item.diff == 0 ? '0 cm' : '${isPositive ? '+' : ''}${item.diff.toStringAsFixed(1)} ${item.unit}';
        final diffColor = isPositive ? AppTheme.primaryColor : Colors.orangeAccent;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Row(
                    children: [
                      Text('${item.initialValue.toStringAsFixed(1)} ➔ ${item.currentValue.toStringAsFixed(1)} ${item.unit}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: diffColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(diffStr, style: TextStyle(color: diffColor, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (item.currentValue / (item.currentValue > item.initialValue ? item.currentValue * 1.1 : item.initialValue * 1.1)).clamp(0.1, 1.0),
                  backgroundColor: AppTheme.darkBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(diffColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

