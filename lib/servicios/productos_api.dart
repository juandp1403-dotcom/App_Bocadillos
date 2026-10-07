import '../core/api_client.dart';
import '../modelos/modelos.dart';

class ProductosApi {
  ProductosApi(this.api);

  final ApiClient api;

  /// GET /api/productos?pagina=&tamano=
  Future<Pagina<Producto>> listar({int pagina = 1, int tamano = 20}) async {
    final datos = await api.get(
      '/api/productos',
      query: {'pagina': '$pagina', 'tamano': '$tamano'},
    );
    return Pagina.fromJson(datos, Producto.fromJson);
  }

  /// GET /api/productos/{id}
  Future<Producto> obtener(int id) async {
    return Producto.fromJson(await api.get('/api/productos/$id'));
  }

  /// POST /api/productos
  Future<Producto> crear(Map<String, dynamic> cuerpo) async {
    return Producto.fromJson(await api.post('/api/productos', body: cuerpo));
  }

  /// PUT /api/productos/{id}
  Future<Producto> actualizar(int id, Map<String, dynamic> cuerpo) async {
    return Producto.fromJson(await api.put('/api/productos/$id', body: cuerpo));
  }

  /// DELETE /api/productos/{id}
  Future<void> eliminar(int id) async {
    await api.delete('/api/productos/$id');
  }

  /// Carga todas las paginas (util para los selectores y el tablero).
  Future<List<Producto>> listarTodos({int tamano = 100}) async {
    final List<Producto> todos = [];
    var pagina = 1;
    var paginas = 1;
    do {
      final res = await listar(pagina: pagina, tamano: tamano);
      todos.addAll(res.items);
      paginas = res.paginas;
      pagina++;
    } while (pagina <= paginas && pagina <= 20);
    return todos;
  }
}
