import 'package:flutter/foundation.dart';

/// Configuracion de conexion con el backend FastAPI.
///
/// La URL base se puede sobreescribir en tiempo de compilacion:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8000
class AppConfig {
  static const String _urlDefinida = String.fromEnvironment('API_BASE_URL');

  /// URL base de la API.
  ///
  /// - Android (emulador): 10.0.2.2 equivale al localhost de la maquina.
  /// - Windows / Web / iOS / Android (fisico con IP local): localhost.
  static String get apiBaseUrl {
    if (_urlDefinida.isNotEmpty) return _urlDefinida;
    if (kIsWeb) return 'http://localhost:8000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://localhost:8000';
    }
  }
}
