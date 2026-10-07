import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../modelos/modelos.dart';

/// Respuesta de POST /api/auth/login.
class SesionToken {
  const SesionToken({required this.accessToken, required this.tokenType});

  final String accessToken;

  /// Esquema del encabezado Authorization (el backend devuelve "bearer").
  final String tokenType;
}

class AuthApi {
  AuthApi(this.api);

  final ApiClient api;

  /// POST /api/auth/login -> {accessToken, tokenType}
  Future<SesionToken> login(String email, String password) async {
    final datos = await api.post(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );
    final mapa = datos is Map<String, dynamic> ? datos : <String, dynamic>{};
    final accessToken = mapa['accessToken'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const ApiException(
        statusCode: 500,
        detail: 'La respuesta de inicio de sesion no es valida.',
        code: 'respuesta_invalida',
      );
    }
    final tokenType = mapa['tokenType'];
    return SesionToken(
      accessToken: accessToken,
      tokenType: tokenType is String && tokenType.isNotEmpty
          ? tokenType
          : 'bearer',
    );
  }

  /// GET /api/auth/me
  Future<Usuario> miPerfil() async {
    return Usuario.fromJson(await api.get('/api/auth/me'));
  }
}
