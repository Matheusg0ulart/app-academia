// lib/widgets/hourly_water_tracker_widget.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'glass_card.dart';

class HourlyWaterSlot {
  final String timeLabel;
  final String periodName;
  final int targetMl;
  final IconData icon;

  const HourlyWaterSlot({
    required this.timeLabel,
    required this.periodName,
    required this.targetMl,
    required this.icon,
  });
}

class HourlyWaterTrackerWidget extends StatefulWidget {
  final double currentWaterL;
  final double targetWaterL;
  final ValueChanged<double>? onWaterChanged;

  const HourlyWaterTrackerWidget({
    super.key,
    required this.currentWaterL,
    this.targetWaterL = 2.5,
    this.onWaterChanged,
  });

  @override
  State<HourlyWaterTrackerWidget> createState() => _HourlyWaterTrackerWidgetState();
}

class _HourlyWaterTrackerWidgetState extends State<HourlyWaterTrackerWidget> {
  late double _currentL;

  final List<HourlyWaterSlot> _slots = const [
    HourlyWaterSlot(timeLabel: '07:00', periodName: 'Ao Acordar', targetMl: 400, icon: Icons.wb_twilight),
    HourlyWaterSlot(timeLabel: '10:00', periodName: 'Manhã', targetMl: 500, icon: Icons.wb_sunny_outlined),
    HourlyWaterSlot(timeLabel: '14:00', periodName: 'Tarde', targetMl: 500, icon: Icons.lunch_dining_outlined),
    HourlyWaterSlot(timeLabel: '17:00', periodName: 'Treino', targetMl: 600, icon: Icons.fitness_center),
    HourlyWaterSlot(timeLabel: '20:00', periodName: 'Noite', targetMl: 400, icon: Icons.nightlight_round),
  ];

  @override
  void initState() {
    super.initState();
    _currentL = widget.currentWaterL;
  }

  @override
  void didUpdateWidget(covariant HourlyWaterTrackerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWaterL != widget.currentWaterL) {
      _currentL = widget.currentWaterL;
    }
  }

  void _addWater(double amountL) {
    setState(() {
      _currentL = (_currentL + amountL).clamp(0.0, 10.0);
    });
    widget.onWaterChanged?.call(_currentL);
  }

  @override
  Widget build(BuildContext context) {
    final targetL = widget.targetWaterL > 0 ? widget.targetWaterL : 2.5;
    final progress = (_currentL / targetL).clamp(0.0, 1.0);
    final remainingL = (targetL - _currentL).clamp(0.0, targetL);
    final currentMl = (_currentL * 1000).toInt();
    final targetMl = (targetL * 1000).toInt();

    return GlassCard(
      borderColor: Colors.blueAccent.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.water_drop_rounded, color: Colors.blueAccent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cronograma de Hidratação', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Distribuição inteligente por horário', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_currentL.toStringAsFixed(1)} / ${targetL.toStringAsFixed(1)} L',
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    remainingL > 0 ? 'Faltam ${(remainingL * 1000).toInt()} ml' : 'Meta batida! 🎉',
                    style: TextStyle(color: remainingL > 0 ? Colors.grey[400] : Colors.greenAccent, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Barra de Progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.darkBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),

          // Slots Horários
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _slots.map((slot) {
                // Cálculo de se este slot já foi atingido
                final slotCumulativeMl = _slots.take(_slots.indexOf(slot) + 1).fold<int>(0, (sum, s) => sum + s.targetMl);
                final isDone = currentMl >= slotCumulativeMl;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDone ? Colors.blueAccent.withOpacity(0.18) : AppTheme.darkBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDone ? Colors.blueAccent.withOpacity(0.5) : Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Icon(slot.icon, color: isDone ? Colors.blueAccent : Colors.grey, size: 16),
                      const SizedBox(height: 4),
                      Text(slot.timeLabel, style: TextStyle(color: isDone ? Colors.white : Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 11)),
                      Text(slot.periodName, style: TextStyle(color: Colors.grey[400], fontSize: 9)),
                      const SizedBox(height: 2),
                      Text('${slot.targetMl}ml', style: TextStyle(color: isDone ? Colors.blueAccent : Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Botões de Incremento Rápido
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickButton('+200 ml', 0.200),
              _buildQuickButton('+350 ml', 0.350),
              _buildQuickButton('+500 ml', 0.500),
              _buildQuickButton('+1.0 L', 1.000),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, double amount) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.darkBackground,
        foregroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.blueAccent.withOpacity(0.3))),
        elevation: 0,
      ),
      onPressed: () => _addWater(amount),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

