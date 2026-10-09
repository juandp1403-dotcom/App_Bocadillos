import 'package:flutter/material.dart';

/// Paleta Y2K nostalgica de la fabrica.
///
/// Colores de la paleta Y2K: beige para superficies, rojo como primario
/// fuerte, ocre para bordes/accesorios, cafe para texto y contornos, y rosa
/// chicle / azul pastel reservados para gradientes sutiles y reflejos.
class AppColors {
  AppColors._();

  /// Fondo y superficies.
  static const Color beige = Color(0xFFF5EBDC);

  /// Primario: botones y acentos fuertes.
  static const Color rojo = Color(0xFFD62828);

  /// Bordes, iconos y destellos.
  static const Color ocre = Color(0xFFC9951B);

  /// Texto y contornos.
  static const Color cafe = Color(0xFF5B3A29);

  /// Rosa chicle: solo gradientes sutiles y reflejos.
  static const Color rosa = Color(0xFFFF70A6);

  /// Azul pastel: solo gradientes sutiles y reflejos.
  static const Color azul = Color(0xFF8FD3FF);

  /// Blanco translucido para reflejos tipo burbuja.
  static const Color reflejo = Color(0x66FFFFFF);
}
