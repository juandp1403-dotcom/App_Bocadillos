import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:app_bocadillos/core/api_client.dart';
import 'package:app_bocadillos/servicios/clientes_api.dart';
import 'package:app_bocadillos/servicios/productos_api.dart';
import 'package:app_bocadillos/servicios/proveedores_api.dart';

http.Response _json(Object cuerpo, [int statusCode = 200]) {
  return http.Response(
    jsonEncode(cuerpo),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}

ApiClient _api(MockClient cliente) {
  return ApiClient(
    baseUrl: 'http://localhost:8000',
    obtenerToken: () => 'token',
    cliente: cliente,
  );
}

Map<String, Object> _pagina(Object item, {int pagina = 1, int paginas = 1}) => {
  'items': [item],
  'total': paginas,
  'pagina': pagina,
  'tamano': 20,
  'paginas': paginas,
};

void main() {
  test(
    'ClientesApi cubre listar, obtener, crear, actualizar y eliminar',
    () async {
      final rutas = <String>[];
      final api = _api(
        MockClient((req) async {
          rutas.add('${req.method} ${req.url.path}');
          if (req.method == 'DELETE') return http.Response('', 204);
          if (req.method == 'GET' && req.url.path.endsWith('/clientes')) {
            return _json(_pagina({'idCliente': 1, 'nombreCliente': 'Cliente'}));
          }
          return _json({
            'idCliente': 1,
            'nombreCliente': 'Cliente actualizado',
          });
        }),
      );
      final clientes = ClientesApi(api);

      expect((await clientes.listar()).items.single.nombreCliente, 'Cliente');
      expect((await clientes.obtener(1)).idCliente, 1);
      expect((await clientes.crear({'nombreCliente': 'Cliente'})).idCliente, 1);
      expect(
        (await clientes.actualizar(1, {
          'nombreCliente': 'Cliente actualizado',
        })).nombreCliente,
        'Cliente actualizado',
      );
      await clientes.eliminar(1);

      expect(
        rutas,
        containsAll([
          'GET /api/clientes',
          'GET /api/clientes/1',
          'POST /api/clientes',
          'PUT /api/clientes/1',
          'DELETE /api/clientes/1',
        ]),
      );
    },
  );

  test('ProductosApi lista todas las paginas sin perder productos', () async {
    final api = _api(
      MockClient((req) async {
        final pagina = int.parse(req.url.queryParameters['pagina']!);
        if (pagina == 1) {
          return _json({
            'items': [
              {
                'idProducto': 1,
                'nombreProducto': 'Bocado 1',
                'precio': '10.00',
                'stock': 4,
              },
            ],
            'total': 2,
            'pagina': 1,
            'tamano': 1,
            'paginas': 2,
          });
        }
        return _json({
          'items': [
            {
              'idProducto': 2,
              'nombreProducto': 'Bocado 2',
              'precio': 20,
              'stock': 9,
            },
          ],
          'total': 2,
          'pagina': 2,
          'tamano': 1,
          'paginas': 2,
        });
      }),
    );

    final productos = await ProductosApi(api).listarTodos(tamano: 1);

    expect(productos, hasLength(2));
    expect(productos.map((p) => p.nombreProducto), ['Bocado 1', 'Bocado 2']);
    expect(productos.first.precio, 10.0);
  });

  test('ProveedoresApi convierte la respuesta y envia paginacion', () async {
    late Uri url;
    final api = _api(
      MockClient((req) async {
        url = req.url;
        return _json(
          _pagina({
            'idProveedor': 8,
            'nombreProveedor': 'Proveedor',
            'telefonoProveedor': '3000000000',
          }),
        );
      }),
    );

    final pagina = await ProveedoresApi(api).listar(pagina: 3, tamano: 10);

    expect(url.path, '/api/proveedores');
    expect(url.queryParameters, {'pagina': '3', 'tamano': '10'});
    expect(pagina.items.single.idProveedor, 8);
    expect(pagina.items.single.telefonoProveedor, '3000000000');
  });
}
