// lib/widgets/plate_calculator_dialog.dart
//
// Calculadora Visual de Anilhas na Barra — CustomPainter

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class PlateInfo {
  final double weightKg;
  final Color color;
  final String label;

  const PlateInfo({required this.weightKg, required this.color, required this.label});
}

const _availablePlates = [
  PlateInfo(weightKg: 25.0, color: Color(0xFFE53935), label: '25'),
  PlateInfo(weightKg: 20.0, color: Color(0xFF1565C0), label: '20'),
  PlateInfo(weightKg: 15.0, color: Color(0xFFF9A825), label: '15'),
  PlateInfo(weightKg: 10.0, color: Color(0xFF2E7D32), label: '10'),
  PlateInfo(weightKg: 5.0, color: Color(0xFFBDBDBD), label: '5'),
  PlateInfo(weightKg: 2.5, color: Color(0xFFF48FB1), label: '2.5'),
  PlateInfo(weightKg: 1.25, color: Color(0xFFB0BEC5), label: '1.25'),
];

class PlateCalculatorDialog extends StatefulWidget {
  const PlateCalculatorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PlateCalculatorDialog(),
    );
  }

  @override
  State<PlateCalculatorDialog> createState() => _PlateCalculatorDialogState();
}

class _PlateCalculatorDialogState extends State<PlateCalculatorDialog> {
  double _totalWeight = 60.0;
  double _barWeight = 20.0;

  final List<Map<String, dynamic>> _barOptions = [
    {'label': 'Olímpica (20 kg)', 'weight': 20.0},
    {'label': 'Convencional (15 kg)', 'weight': 15.0},
    {'label': 'Barra W / EZ (10 kg)', 'weight': 10.0},
    {'label': 'Barra Feminina (15 kg)', 'weight': 15.0},
  ];

  List<PlateInfo> _calculatePlates() {
    double remaining = (_totalWeight - _barWeight) / 2.0;
    if (remaining <= 0) return [];

    final plates = <PlateInfo>[];
    for (final plate in _availablePlates) {
      while (remaining >= plate.weightKg) {
        plates.add(plate);
        remaining = double.parse((remaining - plate.weightKg).toStringAsFixed(4));
      }
    }
    return plates;
  }

  @override
  Widget build(BuildContext context) {
    final plates = _calculatePlates();
    final validLoad = _totalWeight >= _barWeight;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardDarkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 14),

            Row(
              children: const [
                Icon(Icons.fitness_center_rounded, color: AppTheme.primaryColor, size: 22),
                SizedBox(width: 10),
                Text('Calculadora de Anilhas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 20),

            // Seletor de Barra
            Text('Tipo de Barra', style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _barOptions.map((b) {
                  final isSelected = _barWeight == (b['weight'] as double);
                  return GestureDetector(
                    onTap: () => setState(() => _barWeight = b['weight'] as double),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.18) : AppTheme.darkBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.white12),
                      ),
                      child: Text(b['label'] as String, style: TextStyle(color: isSelected ? AppTheme.primaryColor : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Slider de Peso Total
            Text('Carga Total: ${_totalWeight.toStringAsFixed(1)} kg', style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.w600, fontSize: 13)),
            Slider(
              value: _totalWeight,
              min: _barWeight,
              max: 300,
              divisions: 580,
              activeColor: AppTheme.primaryColor,
              inactiveColor: AppTheme.darkBackground,
              label: '${_totalWeight.toStringAsFixed(1)} kg',
              onChanged: (v) => setState(() => _totalWeight = (v * 2).roundToDouble() / 2),
            ),

            // Informações
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChip('Barra', '${_barWeight.toStringAsFixed(0)} kg', Colors.grey[400]!),
                _buildChip('Anilhas (cada lado)', '${((_totalWeight - _barWeight) / 2.0).toStringAsFixed(2)} kg', AppTheme.primaryColor),
                _buildChip('Total', '${_totalWeight.toStringAsFixed(1)} kg', Colors.amberAccent),
              ],
            ),
            const SizedBox(height: 16),

            // Visualização Gráfica da Barra
            if (validLoad) ...[
              const Text('Montagem da Barra:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: CustomPaint(
                  size: const Size(double.infinity, 80),
                  painter: _BarPainter(plates: plates, barWeightKg: _barWeight),
                ),
              ),
              const SizedBox(height: 12),

              // Lista de Anilhas por Lado
              if (plates.isNotEmpty) ...[
                const Text('Anilhas por lado:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: plates.map((p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: p.color.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: p.color.withOpacity(0.6)),
                    ),
                    child: Text('${p.label} kg', style: TextStyle(color: p.color, fontWeight: FontWeight.bold, fontSize: 12)),
                  )).toList(),
                ),
              ] else ...[
                const Text('Sem anilhas — apenas a barra.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<PlateInfo> plates;
  final double barWeightKg;

  _BarPainter({required this.plates, required this.barWeightKg});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Barra (linha horizontal)
    final barPaint = Paint()
      ..color = Colors.grey[500]!
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.05, cy), Offset(size.width * 0.95, cy), barPaint);

    // Centro da barra (rosca/grip)
    final gripPaint = Paint()..color = Colors.grey[700]!;
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: 80, height: 14), gripPaint);

    // Anilhas do lado esquerdo
    double leftX = cx - 50;
    for (final plate in plates.reversed) {
      final plateHeight = _plateHeight(plate.weightKg);
      final plateWidth = _plateWidth(plate.weightKg);
      final platePaint = Paint()..color = plate.color;
      final borderPaint = Paint()..color = plate.color.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 1;

      final rect = Rect.fromCenter(center: Offset(leftX - plateWidth / 2, cy), width: plateWidth, height: plateHeight);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), platePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), borderPaint);

      final tp = TextPainter(
        text: TextSpan(text: plate.label, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftX - plateWidth / 2 - tp.width / 2, cy - tp.height / 2));

      leftX -= plateWidth + 2;
    }

    // Anilhas do lado direito
    double rightX = cx + 50;
    for (final plate in plates.reversed) {
      final plateHeight = _plateHeight(plate.weightKg);
      final plateWidth = _plateWidth(plate.weightKg);
      final platePaint = Paint()..color = plate.color;

      final rect = Rect.fromCenter(center: Offset(rightX + plateWidth / 2, cy), width: plateWidth, height: plateHeight);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), platePaint);

      rightX += plateWidth + 2;
    }
  }

  double _plateHeight(double kg) {
    if (kg >= 25) return 70;
    if (kg >= 20) return 62;
    if (kg >= 15) return 54;
    if (kg >= 10) return 46;
    if (kg >= 5) return 38;
    if (kg >= 2.5) return 30;
    return 24;
  }

  double _plateWidth(double kg) {
    if (kg >= 25) return 16;
    if (kg >= 20) return 14;
    if (kg >= 15) return 13;
    if (kg >= 10) return 12;
    if (kg >= 5) return 11;
    if (kg >= 2.5) return 10;
    return 9;
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.plates != plates || old.barWeightKg != barWeightKg;
}

