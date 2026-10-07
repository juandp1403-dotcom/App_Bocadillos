import '../core/api_client.dart';
import '../modelos/modelos.dart';

class AuthApi {
  AuthApi(this.api);

  final ApiClient api;

  /// POST /api/auth/login -> accessToken
  Future<String> login(String email, String password) async {
    final datos = await api.post(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );
    return '${datos['accessToken']}';
  }

  /// GET /api/auth/me
  Future<Usuario> miPerfil() async {
    return Usuario.fromJson(await api.get('/api/auth/me'));
  }
}
