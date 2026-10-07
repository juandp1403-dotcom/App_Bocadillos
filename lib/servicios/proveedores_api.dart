import '../core/api_client.dart';
import '../modelos/modelos.dart';

class ProveedoresApi {
  ProveedoresApi(this.api);

  final ApiClient api;

  /// GET /api/proveedores?pagina=&tamano=
  Future<Pagina<Proveedor>> listar({int pagina = 1, int tamano = 20}) async {
    final datos = await api.get(
      '/api/proveedores',
      query: {'pagina': '$pagina', 'tamano': '$tamano'},
    );
    return Pagina.fromJson(datos, Proveedor.fromJson);
  }

  /// GET /api/proveedores/{id}
  Future<Proveedor> obtener(int id) async {
    return Proveedor.fromJson(await api.get('/api/proveedores/$id'));
  }

  /// POST /api/proveedores
  Future<Proveedor> crear(Map<String, dynamic> cuerpo) async {
    return Proveedor.fromJson(await api.post('/api/proveedores', body: cuerpo));
  }

  /// PUT /api/proveedores/{id}
  Future<Proveedor> actualizar(int id, Map<String, dynamic> cuerpo) async {
    return Proveedor.fromJson(
      await api.put('/api/proveedores/$id', body: cuerpo),
    );
  }

  /// DELETE /api/proveedores/{id}
  Future<void> eliminar(int id) async {
    await api.delete('/api/proveedores/$id');
  }

  /// Carga todas las paginas (util para los selectores).
  Future<List<Proveedor>> listarTodas({int tamano = 100}) async {
    final List<Proveedor> todos = [];
    var pagina = 1;
    var paginas = 1;
    do {
      final res = await listar(pagina: pagina, tamano: tamano);
      todos.addAll(res.items);
      paginas = res.paginas;
      if (res.items.isEmpty) break;
      pagina++;
    } while (pagina <= paginas && pagina <= 100);
    return todos;
  }
}
