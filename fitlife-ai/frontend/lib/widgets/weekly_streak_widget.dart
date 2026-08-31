// lib/widgets/weekly_streak_widget.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class WeeklyStreakWidget extends StatelessWidget {
  final int completedWorkoutsThisWeek;
  final List<bool>? daysCompleted; // Seg, Ter, Qua, Qui, Sex, Sab, Dom

  const WeeklyStreakWidget({
    super.key,
    required this.completedWorkoutsThisWeek,
    this.daysCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final defaultDays = [true, true, false, true, false, false, false];
    final activeDays = daysCompleted ?? defaultDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Sequência da Semana',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$completedWorkoutsThisWeek / 5 meta',
                  style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final isTrained = index < activeDays.length && activeDays[index];
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isTrained ? AppTheme.primaryColor : AppTheme.darkBackground,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isTrained ? AppTheme.primaryColor : Colors.white12,
                        width: 1.5,
                      ),
                    ),
                    child: isTrained
                        ? const Icon(Icons.check_rounded, color: Colors.black, size: 18)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[index],
                    style: TextStyle(
                      color: isTrained ? Colors.white : Colors.grey[600],
                      fontSize: 11,
                      fontWeight: isTrained ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

