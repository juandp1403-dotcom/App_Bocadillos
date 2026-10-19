import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tema global Neo-Memphis de la fabrica.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.outfit().fontFamily,
    );

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.rojo,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.rojo,
          onPrimary: Colors.white,
          secondary: AppColors.rosa,
          onSecondary: Colors.white,
          tertiary: AppColors.verde,
          onTertiary: Colors.white,
          surface: AppColors.crema,
          onSurface: AppColors.cafe,
          onSurfaceVariant: AppColors.cafe.withValues(alpha: 0.72),
          outline: AppColors.cafe,
          outlineVariant: AppColors.ocre,
          error: AppColors.rojo,
          onError: Colors.white,
        );

    final textTheme = _aplicarFredoka(base.textTheme)
        .apply(bodyColor: AppColors.cafe, displayColor: AppColors.cafe);

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.crema,
      textTheme: textTheme,
      appBarTheme: _appBarTheme(),
      cardTheme: _cardTheme(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(),
      floatingActionButtonTheme: _floatingActionButtonTheme(),
      chipTheme: _chipTheme(),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(),
    );
  }

  /// Usa Rubik para titulares y Outfit para lectura y formularios.
  static TextTheme _aplicarFredoka(TextTheme base) {
    TextStyle titular(TextStyle? estilo) =>
        GoogleFonts.rubik(textStyle: estilo);
    TextStyle cuerpo(TextStyle? estilo) =>
        GoogleFonts.outfit(textStyle: estilo);
    return base.copyWith(
      displayLarge: titular(base.displayLarge),
      displayMedium: titular(base.displayMedium),
      displaySmall: titular(base.displaySmall),
      headlineLarge: titular(base.headlineLarge),
      headlineMedium: titular(base.headlineMedium),
      headlineSmall: titular(base.headlineSmall),
      titleLarge: titular(base.titleLarge),
      titleMedium: titular(base.titleMedium),
      titleSmall: titular(base.titleSmall),
      bodyLarge: cuerpo(base.bodyLarge),
      bodyMedium: cuerpo(base.bodyMedium),
      bodySmall: cuerpo(base.bodySmall),
      labelLarge: cuerpo(base.labelLarge),
      labelMedium: cuerpo(base.labelMedium),
      labelSmall: cuerpo(base.labelSmall),
    );
  }

  static AppBarTheme _appBarTheme() {
    return AppBarTheme(
      backgroundColor: AppColors.crema,
      foregroundColor: AppColors.cafe,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: AppColors.cafe.withValues(alpha: 0.2),
      centerTitle: false,
      titleTextStyle: GoogleFonts.rubik(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.cafe,
      ),
    );
  }

  static CardThemeData _cardTheme() {
    return CardThemeData(
      color: AppColors.crema,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shadowColor: AppColors.cafe.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.cafe, width: 2.5),
      ),
      margin: const EdgeInsets.all(4),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((estados) {
          if (estados.contains(WidgetState.disabled)) {
            return AppColors.cafe.withValues(alpha: 0.25);
          }
          if (estados.contains(WidgetState.pressed)) {
            return AppColors.rojo.withValues(alpha: 0.85);
          }
          if (estados.contains(WidgetState.hovered)) {
            return AppColors.rojo.withValues(alpha: 0.92);
          }
          return AppColors.rojo;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((estados) {
          if (estados.contains(WidgetState.disabled)) {
            return AppColors.cafe.withValues(alpha: 0.5);
          }
          return Colors.white;
        }),
        overlayColor: WidgetStateProperty.resolveWith((estados) {
          if (estados.contains(WidgetState.focused)) {
            return Colors.white.withValues(alpha: 0.12);
          }
          return Colors.white.withValues(alpha: 0.06);
        }),
        elevation: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.disabled) ? 0 : 4,
        ),
        shadowColor: WidgetStateProperty.all(
          AppColors.cafe.withValues(alpha: 0.35),
        ),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: AppColors.cafe, width: 2.5),
          ),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((estados) {
          if (estados.contains(WidgetState.disabled)) {
            return AppColors.cafe.withValues(alpha: 0.4);
          }
          if (estados.contains(WidgetState.pressed)) {
            return AppColors.rojo;
          }
          return AppColors.cafe;
        }),
        side: WidgetStateProperty.resolveWith((estados) {
          if (estados.contains(WidgetState.disabled)) {
            return BorderSide(
              color: AppColors.cafe.withValues(alpha: 0.3),
              width: 1.4,
            );
          }
          if (estados.contains(WidgetState.hovered)) {
            return BorderSide(color: AppColors.ocre, width: 2);
          }
          return BorderSide(color: AppColors.ocre, width: 1.6);
        }),
        overlayColor: WidgetStateProperty.resolveWith((estados) {
          if (estados.contains(WidgetState.focused)) {
            return AppColors.ocre.withValues(alpha: 0.16);
          }
          return AppColors.ocre.withValues(alpha: 0.08);
        }),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: AppColors.cafe, width: 2),
          ),
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((estados) {
          if (estados.contains(WidgetState.disabled)) {
            return AppColors.cafe.withValues(alpha: 0.38);
          }
          if (estados.contains(WidgetState.pressed)) {
            return AppColors.rojo.withValues(alpha: 0.85);
          }
          return AppColors.rojo;
        }),
        overlayColor: WidgetStateProperty.resolveWith((estados) {
          if (estados.contains(WidgetState.focused)) {
            return AppColors.rojo.withValues(alpha: 0.12);
          }
          return AppColors.rojo.withValues(alpha: 0.06);
        }),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.55),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: GoogleFonts.fredoka(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.cafe.withValues(alpha: 0.82),
      ),
      hintStyle: GoogleFonts.fredoka(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.cafe.withValues(alpha: 0.5),
      ),
      helperStyle: GoogleFonts.fredoka(
        fontSize: 12,
        color: AppColors.cafe.withValues(alpha: 0.65),
      ),
      prefixIconColor: AppColors.ocre,
      suffixIconColor: AppColors.cafe.withValues(alpha: 0.7),
      border: _campoBorde(AppColors.ocre.withValues(alpha: 0.7), 1.5),
      enabledBorder: _campoBorde(AppColors.ocre.withValues(alpha: 0.7), 1.5),
      focusedBorder: _campoBorde(AppColors.rojo, 2),
      errorBorder: _campoBorde(AppColors.rojo.withValues(alpha: 0.7), 1.5),
      focusedErrorBorder: _campoBorde(AppColors.rojo, 2),
    );
  }

  static OutlineInputBorder _campoBorde(Color color, double ancho) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: color, width: ancho),
    );
  }

  static FloatingActionButtonThemeData _floatingActionButtonTheme() {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.rojo,
      foregroundColor: Colors.white,
      elevation: 5,
      focusElevation: 6,
      hoverElevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.cafe, width: 2.5),
      ),
    );
  }

  static ChipThemeData _chipTheme() {
    return ChipThemeData(
      backgroundColor: AppColors.crema,
      selectedColor: AppColors.rosado.withValues(alpha: 0.35),
      disabledColor: AppColors.cafe.withValues(alpha: 0.12),
      side: BorderSide(
        color: AppColors.cafe.withValues(alpha: 0.35),
        width: 1.2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.cafe, width: 2),
      ),
      labelStyle: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.cafe,
      ),
      secondaryLabelStyle: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.cafe,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  static BottomNavigationBarThemeData _bottomNavigationBarTheme() {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.crema,
      selectedItemColor: AppColors.rojo,
      unselectedItemColor: AppColors.cafe.withValues(alpha: 0.6),
      selectedIconTheme: IconThemeData(color: AppColors.rojo),
      unselectedIconTheme: IconThemeData(
        color: AppColors.cafe.withValues(alpha: 0.55),
      ),
      selectedLabelStyle: GoogleFonts.fredoka(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.fredoka(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      elevation: 8,
    );
  }
}
