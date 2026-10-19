import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tema global organico de la fabrica: esquinas suaves, sombras cafe
/// tenues y la paleta natural definida en [AppColors].
class AppTheme {
  AppTheme._();

  static const double radio = 16;

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.outfit().fontFamily,
    );

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.guayaba,
      onPrimary: Colors.white,
      primaryContainer: AppColors.guayabaSuave,
      onPrimaryContainer: AppColors.cafe,
      secondary: AppColors.verde,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.verdeSuave,
      onSecondaryContainer: AppColors.cafe,
      tertiary: AppColors.cafe,
      onTertiary: Colors.white,
      error: AppColors.rojo,
      onError: Colors.white,
      errorContainer: AppColors.rojoSuave,
      onErrorContainer: AppColors.cafe,
      surface: AppColors.superficie,
      onSurface: AppColors.cafe,
      onSurfaceVariant: AppColors.cafeSuave,
      outline: AppColors.borde,
      outlineVariant: AppColors.borde,
      shadow: AppColors.cafe,
      scrim: AppColors.cafe.withValues(alpha: 0.4),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.superficie,
      surfaceContainer: AppColors.superficie,
      surfaceContainerHigh: AppColors.superficie,
      surfaceContainerHighest: AppColors.superficie,
    );

    final textTheme = _tipografia(base.textTheme)
        .apply(bodyColor: AppColors.cafe, displayColor: AppColors.cafe);

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.fondo,
      textTheme: textTheme,
      appBarTheme: _appBarTheme(),
      cardTheme: _cardTheme(),
      dialogTheme: _dialogTheme(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      filledButtonTheme: _filledButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(),
      floatingActionButtonTheme: _floatingActionButtonTheme(),
      chipTheme: _chipTheme(),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(),
      navigationRailTheme: _navigationRailTheme(),
      snackBarTheme: _snackBarTheme(),
      dividerTheme: DividerThemeData(
        color: AppColors.borde,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        iconColor: AppColors.cafeSuave,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.superficie,
        elevation: 6,
        shadowColor: AppColors.sombra,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radio),
          side: BorderSide(color: AppColors.borde.withValues(alpha: 0.8)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.guayaba,
      ),
    );
  }

  /// Rubik para titulares y Outfit para lectura y formularios.
  static TextTheme _tipografia(TextTheme base) {
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
      backgroundColor: AppColors.fondo,
      foregroundColor: AppColors.cafe,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.rubik(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.cafe,
      ),
      iconTheme: const IconThemeData(color: AppColors.cafe),
      actionsIconTheme: IconThemeData(
        color: AppColors.cafe.withValues(alpha: 0.8),
      ),
    );
  }

  static CardThemeData _cardTheme() {
    return CardThemeData(
      color: AppColors.superficie,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: AppColors.sombra,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radio),
        side: BorderSide(color: AppColors.borde.withValues(alpha: 0.9)),
      ),
    );
  }

  static DialogThemeData _dialogTheme() {
    return DialogThemeData(
      backgroundColor: AppColors.superficie,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: AppColors.sombra,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: GoogleFonts.rubik(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.cafe,
      ),
      contentTextStyle: GoogleFonts.outfit(
        fontSize: 15,
        color: AppColors.cafeSuave,
      ),
    );
  }

  static ButtonStyle _botonBase({
    required Color fondo,
    required Color texto,
    Color? borde,
  }) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((estados) {
        if (estados.contains(WidgetState.disabled)) {
          return AppColors.cafe.withValues(alpha: 0.12);
        }
        if (estados.contains(WidgetState.pressed)) {
          return Color.lerp(fondo, AppColors.cafe, 0.14);
        }
        if (estados.contains(WidgetState.hovered)) {
          return Color.lerp(fondo, Colors.white, 0.12);
        }
        return fondo;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((estados) {
        if (estados.contains(WidgetState.disabled)) {
          return AppColors.cafe.withValues(alpha: 0.38);
        }
        return texto;
      }),
      overlayColor: WidgetStateProperty.resolveWith((estados) {
        if (estados.contains(WidgetState.focused)) {
          return texto.withValues(alpha: 0.14);
        }
        return texto.withValues(alpha: 0.08);
      }),
      elevation: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.disabled) ? 0 : 0,
      ),
      shadowColor: WidgetStateProperty.all(AppColors.sombra),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radio),
          side: borde == null
              ? BorderSide.none
              : BorderSide(color: borde, width: 1.4),
        ),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: _botonBase(fondo: AppColors.guayaba, texto: Colors.white),
    );
  }

  static FilledButtonThemeData _filledButtonTheme() {
    return FilledButtonThemeData(
      style: _botonBase(fondo: AppColors.guayaba, texto: Colors.white),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: _botonBase(
        fondo: Colors.transparent,
        texto: AppColors.cafe,
        borde: AppColors.borde,
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
            return AppColors.guayaba.withValues(alpha: 0.85);
          }
          return AppColors.guayaba;
        }),
        overlayColor: WidgetStateProperty.resolveWith(
          (estados) => AppColors.guayaba.withValues(alpha: 0.08),
        ),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radio)),
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.cafeSuave,
      ),
      hintStyle: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.cafe.withValues(alpha: 0.45),
      ),
      helperStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.cafeSuave),
      prefixIconColor: AppColors.guayaba.withValues(alpha: 0.8),
      suffixIconColor: AppColors.cafeSuave,
      border: _campoBorde(AppColors.borde, 1.4),
      enabledBorder: _campoBorde(AppColors.borde, 1.4),
      focusedBorder: _campoBorde(AppColors.guayaba, 2),
      errorBorder: _campoBorde(AppColors.rojo.withValues(alpha: 0.7), 1.4),
      focusedErrorBorder: _campoBorde(AppColors.rojo, 2),
    );
  }

  static OutlineInputBorder _campoBorde(Color color, double ancho) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: ancho),
    );
  }

  static FloatingActionButtonThemeData _floatingActionButtonTheme() {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.guayaba,
      foregroundColor: Colors.white,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  static ChipThemeData _chipTheme() {
    return ChipThemeData(
      backgroundColor: AppColors.superficie,
      selectedColor: AppColors.guayabaSuave,
      disabledColor: AppColors.cafe.withValues(alpha: 0.1),
      side: BorderSide(color: AppColors.borde, width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.cafe,
      ),
      secondaryLabelStyle: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.cafe,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  static BottomNavigationBarThemeData _bottomNavigationBarTheme() {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.superficie,
      selectedItemColor: AppColors.guayaba,
      unselectedItemColor: AppColors.cafe.withValues(alpha: 0.55),
      selectedIconTheme: const IconThemeData(color: AppColors.guayaba),
      unselectedIconTheme: IconThemeData(
        color: AppColors.cafe.withValues(alpha: 0.5),
      ),
      selectedLabelStyle: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }

  static NavigationRailThemeData _navigationRailTheme() {
    return NavigationRailThemeData(
      backgroundColor: AppColors.superficie,
      indicatorColor: AppColors.guayabaSuave,
      selectedIconTheme: const IconThemeData(color: AppColors.guayaba),
      unselectedIconTheme: IconThemeData(
        color: AppColors.cafe.withValues(alpha: 0.5),
      ),
      selectedLabelTextStyle: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.guayaba,
      ),
      unselectedLabelTextStyle: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.cafeSuave,
      ),
    );
  }

  static SnackBarThemeData _snackBarTheme() {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.cafe,
      contentTextStyle: GoogleFonts.outfit(fontSize: 14, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
