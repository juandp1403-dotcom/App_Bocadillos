import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Marca mínima de guayaba/bocadillo veleño.
class GuavaMark extends StatelessWidget {
  const GuavaMark({super.key, this.size = 64, this.color = AppColors.rosado});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _GuavaPainter(color));
  }
}

class _GuavaPainter extends CustomPainter {
  const _GuavaPainter(this.color);

  final Color color;

  Color _claro(double mezcla) => Color.lerp(color, Colors.white, mezcla)!;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final radio = size.width / 2;
    final ref = size.width / 64;

    final hoja = Paint()..color = AppColors.verde;
    canvas.save();
    canvas.translate(size.width * 0.78, size.height * 0.12);
    canvas.rotate(-0.45);
    final caminoHoja = Path()
      ..moveTo(0, 0)
      ..cubicTo(
        size.width * 0.08,
        -size.height * 0.22,
        size.width * 0.34,
        -size.height * 0.22,
        size.width * 0.44,
        0,
      )
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.2,
        size.width * 0.08,
        size.height * 0.2,
        0,
        0,
      )
      ..close();
    canvas.drawPath(caminoHoja, hoja);
    canvas.restore();

    canvas.drawCircle(centro, radio, Paint()..color = color);
    canvas.drawCircle(centro, radio * 0.74, Paint()..color = _claro(0.35));
    canvas.drawCircle(centro, radio * 0.42, Paint()..color = _claro(0.62));

    final semilla = Paint()..color = AppColors.ocre;
    for (var i = 0; i < 5; i++) {
      final angulo = (i * 2 * math.pi) / 5 - 1.25;
      final p =
          centro +
          Offset(
            math.cos(angulo) * radio * 0.6,
            math.sin(angulo) * radio * 0.6,
          );
      canvas.drawCircle(p, ref * 1.6, semilla);
    }

    final brillo = Paint()..color = AppColors.reflejo;
    final caminoBrillo = Path()
      ..moveTo(centro.dx - radio * 0.62, centro.dy - radio * 0.5)
      ..cubicTo(
        centro.dx - radio * 0.2,
        centro.dy - radio * 0.82,
        centro.dx + radio * 0.35,
        centro.dy - radio * 0.62,
        centro.dx + radio * 0.28,
        centro.dy - radio * 0.3,
      )
      ..cubicTo(
        centro.dx - radio * 0.25,
        centro.dy - radio * 0.45,
        centro.dx - radio * 0.4,
        centro.dy - radio * 0.32,
        centro.dx - radio * 0.27,
        centro.dy - radio * 0.12,
      )
      ..close();
    canvas.drawPath(caminoBrillo, brillo);
  }

  @override
  bool shouldRepaint(covariant _GuavaPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
