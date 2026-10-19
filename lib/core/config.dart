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

  /// URL por defecto cuando no se define API_BASE_URL.
  ///
  /// La aplicacion distribuida debe usar el backend publicado. Para desarrollo
  /// local se puede sobreescribir con `--dart-define=API_BASE_URL=...`.
  static String _porDefecto() {
    return 'https://backendfast.softlane.click';
  }

  /// URL base de la API (sin barra final).
  static String get apiBaseUrl {
    if (_urlDefinida.isNotEmpty) return normalizar(_urlDefinida);
    return _porDefecto();
  }
}
