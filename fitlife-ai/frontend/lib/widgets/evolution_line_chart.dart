// lib/widgets/evolution_line_chart.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ChartDataPoint {
  final DateTime date;
  final double value;
  final String label;

  const ChartDataPoint({
    required this.date,
    required this.value,
    this.label = '',
  });
}

class EvolutionLineChart extends StatelessWidget {
  final List<ChartDataPoint> points;
  final String unit;
  final double? targetValue;
  final Color lineColor;
  final double height;

  const EvolutionLineChart({
    super.key,
    required this.points,
    this.unit = 'kg',
    this.targetValue,
    this.lineColor = AppTheme.primaryColor,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        child: const Text('Sem dados suficientes para o gráfico.', style: TextStyle(color: Colors.grey, fontSize: 12)),
      );
    }

    final values = points.map((p) => p.value).toList();
    if (targetValue != null) values.add(targetValue!);

    final double minVal = (values.reduce((a, b) => a < b ? a : b) * 0.95).floorToDouble();
    final double maxVal = (values.reduce((a, b) => a > b ? a : b) * 1.05).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Info (Min, Max, Meta)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Min: ${minVal.toStringAsFixed(1)} $unit', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            if (targetValue != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Meta: ${targetValue!.toStringAsFixed(1)} $unit', style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            Text('Máx: ${maxVal.toStringAsFixed(1)} $unit', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
        const SizedBox(height: 8),

        // Área do Gráfico
        SizedBox(
          height: height,
          child: CustomPaint(
            painter: _LineChartPainter(
              points: points,
              minVal: minVal,
              maxVal: maxVal,
              targetValue: targetValue,
              lineColor: lineColor,
            ),
          ),
        ),

        // Eixo X Datas
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDate(points.first.date), style: TextStyle(color: Colors.grey[500], fontSize: 10)),
            if (points.length > 2)
              Text(_formatDate(points[points.length ~/ 2].date), style: TextStyle(color: Colors.grey[500], fontSize: 10)),
            Text(_formatDate(points.last.date), style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ChartDataPoint> points;
  final double minVal;
  final double maxVal;
  final double? targetValue;
  final Color lineColor;

  _LineChartPainter({
    required this.points,
    required this.minVal,
    required this.maxVal,
    this.targetValue,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);
    final width = size.width;
    final height = size.height;

    // ── Linhas de Grade de Fundo ──────────────────────────────
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // ── Linha Tracejada de Meta ───────────────────────────────
    if (targetValue != null && targetValue! >= minVal && targetValue! <= maxVal) {
      final targetY = height - ((targetValue! - minVal) / range * height);
      final targetPaint = Paint()
        ..color = Colors.amberAccent.withOpacity(0.6)
        ..strokeWidth = 1.5;

      const dashWidth = 5.0;
      const dashSpace = 4.0;
      double startX = 0;
      while (startX < width) {
        canvas.drawLine(Offset(startX, targetY), Offset(startX + dashWidth, targetY), targetPaint);
        startX += dashWidth + dashSpace;
      }
    }

    // ── Coordenadas dos Pontos ────────────────────────────────
    final offsets = <Offset>[];
    if (points.length == 1) {
      final y = height - ((points[0].value - minVal) / range * height);
      offsets.add(Offset(width / 2, y));
    } else {
      for (int i = 0; i < points.length; i++) {
        final x = (i / (points.length - 1)) * width;
        final y = height - ((points[i].value - minVal) / range * height);
        offsets.add(Offset(x, y.clamp(8, height - 8)));
      }
    }

    // ── Curva Suave e Gradiente ───────────────────────────────
    if (offsets.length > 1) {
      final path = Path();
      final fillPath = Path();

      path.moveTo(offsets[0].dx, offsets[0].dy);
      fillPath.moveTo(offsets[0].dx, height);
      fillPath.lineTo(offsets[0].dx, offsets[0].dy);

      for (int i = 0; i < offsets.length - 1; i++) {
        final p0 = offsets[i];
        final p1 = offsets[i + 1];
        final midX = (p0.dx + p1.dx) / 2;

        path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
        fillPath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
      }

      fillPath.lineTo(offsets.last.dx, height);
      fillPath.close();

      // Gradiente sob a curva
      final fillPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(0, height),
          [lineColor.withOpacity(0.35), lineColor.withOpacity(0.0)],
        );
      canvas.drawPath(fillPath, fillPaint);

      // Traço da linha principal
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, linePaint);
    }

    // ── Pontos / Marcadores Iluminados ────────────────────────
    final dotBgPaint = Paint()..color = AppTheme.cardDarkBackground;
    final dotPaint = Paint()..color = lineColor;

    for (int i = 0; i < offsets.length; i++) {
      final off = offsets[i];
      canvas.drawCircle(off, 6, dotPaint);
      canvas.drawCircle(off, 3.5, dotBgPaint);

      // Se for o último ponto, exibe o valor destacado
      if (i == offsets.length - 1) {
        canvas.drawCircle(off, 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => true;
}

