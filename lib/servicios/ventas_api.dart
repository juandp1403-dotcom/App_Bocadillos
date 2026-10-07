import '../core/api_client.dart';
import '../modelos/modelos.dart';

class ItemVenta {
  const ItemVenta({required this.idProducto, required this.cantidad});

  final int idProducto;
  final int cantidad;

  Map<String, dynamic> toJson() => {
    'idProducto': idProducto,
    'cantidad': cantidad,
  };
}

class VentasApi {
  VentasApi(this.api);

  final ApiClient api;

  /// GET /api/ventas?pagina=&tamano=
  Future<Pagina<Venta>> listar({int pagina = 1, int tamano = 20}) async {
    final datos = await api.get(
      '/api/ventas',
      query: {'pagina': '$pagina', 'tamano': '$tamano'},
    );
    return Pagina.fromJson(datos, Venta.fromJson);
  }

  /// GET /api/ventas/{id}
  Future<Venta> obtener(int id) async {
    return Venta.fromJson(await api.get('/api/ventas/$id'));
  }

  /// POST /api/ventas
  /// El servidor calcula subtotal/total y descuenta el stock.
  Future<Venta> crear(int idCliente, List<ItemVenta> detalles) async {
    final datos = await api.post(
      '/api/ventas',
      body: {
        'idCliente': idCliente,
        'detalles': detalles.map((d) => d.toJson()).toList(),
      },
    );
    return Venta.fromJson(datos);
  }

  /// DELETE /api/ventas/{id}
  Future<void> eliminar(int id) async {
    await api.delete('/api/ventas/$id');
  }
}
