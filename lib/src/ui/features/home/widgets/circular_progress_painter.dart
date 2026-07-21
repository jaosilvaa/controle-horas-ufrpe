import 'dart:math';
import 'package:flutter/material.dart';

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;

  /// Cor sólida do arco de progresso. Ignorada se [progressGradient] for informado.
  final Color progressColor;

  /// Gradiente opcional do arco de progresso (tem prioridade sobre [progressColor]).
  final Gradient? progressGradient;

  const CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    this.progressGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 6.0;
    final radius = (size.shortestSide - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (progressGradient != null) {
      progressPaint.shader = progressGradient!.createShader(rect);
    } else {
      progressPaint.color = progressColor;
    }

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(CircularProgressPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor ||
      old.progressGradient != progressGradient;
}
