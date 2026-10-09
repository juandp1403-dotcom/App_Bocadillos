import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Estrella `✦` de estilo Y2K, reutilizable y configurable.
///
/// Por defecto usa ocre con opacidad total; se puede ajustar tamano, color y
/// opacidad para usarla como detalle decorativo.
class SparkleStar extends StatelessWidget {
  const SparkleStar({
    super.key,
    this.size = 18,
    this.color = AppColors.ocre,
    this.opacidad = 1,
  });

  final double size;
  final Color color;
  final double opacidad;

  @override
  Widget build(BuildContext context) {
    return Text(
      '\u2726',
      style: TextStyle(
        fontSize: size,
        height: 1,
        color: color.withValues(alpha: opacidad.clamp(0, 1)),
      ),
    );
  }
}
