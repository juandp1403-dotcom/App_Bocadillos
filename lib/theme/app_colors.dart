import 'package:flutter/material.dart';

/// Paleta natural organica del bocadillo veleno.
///
/// [fondo] beige organico, [superficie] blanco calido para tarjetas,
/// [guayaba] rosado para acciones principales, [verde] para exito,
/// [rojo] para alertas y [cafe] para texto y bordes.
class AppColors {
  AppColors._();

  /// Beige organico: fondo principal de la aplicacion.
  static const Color fondo = Color(0xFFF4EFE6);

  /// Beige claro / blanco calido: tarjetas, modales y superficies.
  static const Color superficie = Color(0xFFFAF8F5);

  /// Rosado guayaba: acentos principales y botones CTA.
  static const Color guayaba = Color(0xFFE06A7B);

  /// Verde hoja: exito, badges y estados positivos.
  static const Color verde = Color(0xFF4A7C59);

  /// Rojo bocadillo: alertas y elementos de contraste alto.
  static const Color rojo = Color(0xFFC63D2F);

  /// Cafe tierra: texto principal, bordes y sombras suaves.
  static const Color cafe = Color(0xFF3D2E24);

  /// Beige medio: bordes delgados que dan estructura sin saturar.
  static const Color borde = Color(0xFFE4D9C4);

  /// Sombra muy suave en tono cafe para tarjetas y superficies.
  static Color get sombra => cafe.withValues(alpha: 0.08);

  /// Cafe legible sobre fondo claro (texto secundario).
  static Color get cafeSuave => cafe.withValues(alpha: 0.70);

  /// Guayaba diluida para fondos de acento suaves.
  static Color get guayabaSuave => guayaba.withValues(alpha: 0.12);

  /// Verde diluido para fondos de exito suaves.
  static Color get verdeSuave => verde.withValues(alpha: 0.12);

  /// Rojo diluido para fondos de alerta suaves.
  static Color get rojoSuave => rojo.withValues(alpha: 0.12);
}
