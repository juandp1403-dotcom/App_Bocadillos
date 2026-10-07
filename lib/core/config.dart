import 'package:flutter/foundation.dart';

/// Configuracion de conexion con el backend FastAPI.
///
/// La URL base se puede sobreescribir en tiempo de compilacion:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8000
class AppConfig {
  static const String _urlDefinida = String.fromEnvironment('API_BASE_URL');

  /// Quita espacios y la barra final para evitar doble barra en las rutas
  /// (`http://host:8000/` + `/api/...` no debe producir `//api/...`).
  static String normalizar(String url) {
    var limpio = url.trim();
    while (limpio.endsWith('/')) {
      limpio = limpio.substring(0, limpio.length - 1);
    }
    return limpio;
  }

  /// URL por defecto de cada plataforma cuando no se define API_BASE_URL.
  ///
  /// - Android (emulador): 10.0.2.2 equivale al localhost de la maquina.
  /// - Android (fisico) / Web / Windows: localhost; en el celular fisico se
  ///   debe pasar `--dart-define=API_BASE_URL=http://IP-DE-LA-PC:8000`
  static String _porDefecto() {
    if (kIsWeb) return 'http://localhost:8000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://localhost:8000';
    }
  }

  /// URL base de la API (sin barra final).
  static String get apiBaseUrl {
    if (_urlDefinida.isNotEmpty) return normalizar(_urlDefinida);
    return _porDefecto();
  }
}
