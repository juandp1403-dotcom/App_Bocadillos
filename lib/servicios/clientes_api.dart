import '../core/api_client.dart';
import '../modelos/modelos.dart';

class ClientesApi {
  ClientesApi(this.api);

  final ApiClient api;

  /// GET /api/clientes?pagina=&tamano=
  Future<Pagina<Cliente>> listar({int pagina = 1, int tamano = 20}) async {
    final datos = await api.get(
      '/api/clientes',
      query: {'pagina': '$pagina', 'tamano': '$tamano'},
    );
    return Pagina.fromJson(datos, Cliente.fromJson);
  }

  /// GET /api/clientes/{id}
  Future<Cliente> obtener(int id) async {
    return Cliente.fromJson(await api.get('/api/clientes/$id'));
  }

  /// POST /api/clientes
  Future<Cliente> crear(Map<String, dynamic> cuerpo) async {
    return Cliente.fromJson(await api.post('/api/clientes', body: cuerpo));
  }

  /// PUT /api/clientes/{id}
  Future<Cliente> actualizar(int id, Map<String, dynamic> cuerpo) async {
    return Cliente.fromJson(await api.put('/api/clientes/$id', body: cuerpo));
  }

  /// DELETE /api/clientes/{id}
  Future<void> eliminar(int id) async {
    await api.delete('/api/clientes/$id');
  }
}
