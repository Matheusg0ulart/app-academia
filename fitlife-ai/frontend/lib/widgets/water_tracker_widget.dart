// lib/widgets/water_tracker_widget.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class WaterTrackerWidget extends StatefulWidget {
  final int targetMl;
  final int initialMl;
  final Function(int)? onWaterChanged;

  const WaterTrackerWidget({
    super.key,
    this.targetMl = 3000,
    this.initialMl = 1250,
    this.onWaterChanged,
  });

  @override
  State<WaterTrackerWidget> createState() => _WaterTrackerWidgetState();
}

class _WaterTrackerWidgetState extends State<WaterTrackerWidget> {
  late int _currentMl;

  @override
  void initState() {
    super.initState();
    _currentMl = widget.initialMl;
  }

  void _addWater(int amount) {
    setState(() {
      _currentMl = (_currentMl + amount).clamp(0, widget.targetMl + 2000);
    });
    widget.onWaterChanged?.call(_currentMl);
  }

  void _resetWater() {
    setState(() => _currentMl = 0);
    widget.onWaterChanged?.call(0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentMl / widget.targetMl).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.water_drop_rounded, color: Colors.cyanAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Hidratação Diária',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                ],
              ),
              Text(
                '${(_currentMl / 1000).toStringAsFixed(1)}L / ${(widget.targetMl / 1000).toStringAsFixed(1)}L ($percentage%)',
                style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.darkBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent.withOpacity(0.15),
                  foregroundColor: Colors.cyanAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('+250 ml', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () => _addWater(250),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent.withOpacity(0.15),
                  foregroundColor: Colors.cyanAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('+500 ml', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () => _addWater(500),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.restart_alt_rounded, color: Colors.grey, size: 18),
                tooltip: 'Zerar hidratação',
                onPressed: _resetWater,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

