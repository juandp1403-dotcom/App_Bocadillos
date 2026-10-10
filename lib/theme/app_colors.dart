import 'package:flutter/material.dart';

/// Paleta Y2K del bocadillo veleño.
///
/// Crema de guayaba como fondo principal, cafe de panela para texto y
/// contraste, rojo bocadillo y rosado guayaba para destacar, ocre y verde hoja
/// como acentos. El rosa chicle y el azul pastel se reservan para reflejos y
/// gradientes pequeños.
class AppColors {
  AppColors._();

  /// Crema de guayaba: fondo principal y superficies suaves.
  static const Color crema = Color(0xFFF5EBDC);

  /// Cafe de panela: texto y elementos de contraste.
  static const Color cafe = Color(0xFF5B3A29);

  /// Rojo bocadillo: acciones principales y enfasis.
  static const Color rojo = Color(0xFFD62828);

  /// Rosado guayaba: acento visible en tarjetas, indicadores y detalles.
  static const Color rosado = Color(0xFFE86A83);

  /// Ocre: bordes, iconos y pequenos destellos.
  static const Color ocre = Color(0xFFC9951B);

  /// Verde hoja de guayaba: acento secundario para estados e iconografia.
  static const Color verde = Color(0xFF718B52);

  /// Rosa chicle: solo para reflejos o gradientes pequeños.
  static const Color rosa = Color(0xFFFF70A6);

  /// Azul pastel: solo para reflejos o gradientes pequeños.
  static const Color azul = Color(0xFF8FD3FF);

  /// Rojo profundo para errores: debe distinguirse de la accion principal.
  static const Color error = Color(0xFFB3261E);

  /// Blanco translucido para reflejos tipo burbuja.
  static const Color reflejo = Color(0x66FFFFFF);
}
