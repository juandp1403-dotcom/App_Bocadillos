import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:app_bocadillos/core/api_client.dart';
import 'package:app_bocadillos/core/api_exception.dart';
import 'package:app_bocadillos/servicios/auth_api.dart';
import 'package:app_bocadillos/servicios/ventas_api.dart';

http.Response _json(int codigo, Object cuerpo) {
  return http.Response(
    jsonEncode(cuerpo),
    codigo,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  late int sesionesExpiradas;

  ApiClient crear(MockClient cliente, {String? token}) {
    sesionesExpiradas = 0;
    return ApiClient(
      baseUrl: 'http://localhost:8000',
      obtenerToken: () => token,
      onNoAutorizado: () => sesionesExpiradas++,
      cliente: cliente,
      tiempoLimite: const Duration(seconds: 5),
    );
  }

  group('ApiClient: cabeceras', () {
    test('GET envia Accept y Authorization y no envia Content-Type', () async {
      late http.Request capturada;
      final api = crear(
        MockClient((req) async {
          capturada = req;
          return _json(200, {'items': [], 'total': 0});
        }),
        token: 'abc123',
      );

      await api.get('/api/clientes', query: {'pagina': '1', 'tamano': '20'});

      expect(capturada.url.path, '/api/clientes');
      expect(capturada.url.queryParameters, {'pagina': '1', 'tamano': '20'});
      expect(capturada.headers['accept'], 'application/json');
      expect(capturada.headers['authorization'], 'Bearer abc123');
      expect(capturada.headers.containsKey('content-type'), isFalse);
    });

    test('GET sin sesion no envia Authorization', () async {
      late http.Request capturada;
      final api = crear(
        MockClient((req) async {
          capturada = req;
          return _json(200, {'items': []});
        }),
      );

      await api.get('/api/auth/me');

      expect(capturada.headers.containsKey('authorization'), isFalse);
    });

    test('POST envia Content-Type json y el cuerpo serializado', () async {
      late http.Request capturada;
      final api = crear(
        MockClient((req) async {
          capturada = req;
          return _json(200, {'accessToken': 'xyz', 'tokenType': 'bearer'});
        }),
      );

      await api.post(
        '/api/auth/login',
        body: {'email': 'a@b.co', 'password': '123456'},
      );

      expect(capturada.headers['content-type'], 'application/json');
      expect(jsonDecode(capturada.body), {
        'email': 'a@b.co',
        'password': '123456',
      });
    });

    test('La URL base con barra final no produce doble barra', () async {
      late Uri url;
      final api = ApiClient(
        baseUrl: 'http://localhost:8000/',
        obtenerToken: () => null,
        cliente: MockClient((req) async {
          url = req.url;
          return _json(200, {});
        }),
      );

      await api.get('/api/ventas');

      expect(url.toString(), 'http://localhost:8000/api/ventas');
    });
  });

  group('ApiClient: respuestas exitosas', () {
    test('200 devuelve el JSON', () async {
      final api = crear(MockClient((_) async => _json(200, {'total': 3})));
      expect(await api.get('/api/clientes'), {'total': 3});
    });

    test('201 devuelve el JSON creado', () async {
      final api = crear(MockClient((_) async => _json(201, {'idCliente': 9})));
      expect(await api.post('/api/clientes', body: {'nombreCliente': 'X'}), {
        'idCliente': 9,
      });
    });

    test('204 devuelve null', () async {
      final api = crear(MockClient((_) async => http.Response('', 204)));
      expect(await api.delete('/api/clientes/1'), isNull);
    });
  });

  group('ApiClient: errores', () {
    test(
      '401 lanza ApiException con no_autorizado y avisa a la sesion',
      () async {
        final api = crear(
          MockClient(
            (_) async => _json(401, {
              'detail': 'Credenciales invalidas',
              'code': 'no_autorizado',
              'errors': [],
            }),
          ),
          token: 'vencido',
        );

        final excepcion = await _capturar(() => api.get('/api/auth/me'));

        expect(excepcion.statusCode, 401);
        expect(excepcion.detail, 'Credenciales invalidas');
        expect(excepcion.code, 'no_autorizado');
        expect(excepcion.esNoAutorizado, isTrue);
        expect(sesionesExpiradas, 1);
      },
    );

    test('403 expone detail y code permiso', () async {
      final api = crear(
        MockClient(
          (_) async => _json(403, {
            'detail': 'No tienes permisos para realizar esta accion',
            'code': 'permiso',
            'errors': [],
          }),
        ),
        token: 'x',
      );

      final excepcion = await _capturar(() => api.get('/api/proveedores'));

      expect(excepcion.statusCode, 403);
      expect(excepcion.code, 'permiso');
      expect(excepcion.esSinPermiso, isTrue);
      expect(sesionesExpiradas, 0);
    });

    test('404 expone code no_encontrado', () async {
      final api = crear(
        MockClient(
          (_) async => _json(404, {
            'detail': 'Venta no encontrada',
            'code': 'no_encontrado',
            'errors': [],
          }),
        ),
        token: 'x',
      );

      final excepcion = await _capturar(() => api.get('/api/ventas/7'));

      expect(excepcion.statusCode, 404);
      expect(excepcion.detail, 'Venta no encontrada');
      expect(excepcion.esNoEncontrado, isTrue);
    });

    test('409 expone code stock_insuficiente', () async {
      final api = crear(
        MockClient(
          (_) async => _json(409, {
            'detail': 'No hay stock suficiente para Bocado',
            'code': 'stock_insuficiente',
            'errors': [],
          }),
        ),
        token: 'x',
      );

      final excepcion = await _capturar(
        () => api.post('/api/ventas', body: {'idCliente': 1, 'detalles': []}),
      );

      expect(excepcion.statusCode, 409);
      expect(excepcion.code, 'stock_insuficiente');
      expect(excepcion.esConflicto, isTrue);
      expect(excepcion.detail, contains('stock suficiente'));
    });

    test('422 de regla de negocio expone detail y code', () async {
      final api = crear(
        MockClient(
          (_) async => _json(422, {
            'detail': 'La venta debe incluir al menos un detalle',
            'code': 'regla_negocio',
            'errors': [],
          }),
        ),
        token: 'x',
      );

      final excepcion = await _capturar(
        () => api.post('/api/ventas', body: {'idCliente': 1, 'detalles': []}),
      );

      expect(excepcion.statusCode, 422);
      expect(excepcion.code, 'regla_negocio');
      expect(excepcion.detail, contains('al menos un detalle'));
    });

    test('422 de validacion de FastAPI arma mensajes por campo', () async {
      final api = crear(
        MockClient(
          (_) async => _json(422, [
            {
              'loc': ['body', 'email'],
              'msg': 'value is not a valid email address',
              'type': 'value_error.email',
            },
          ]),
        ),
        token: 'x',
      );

      final excepcion = await _capturar(
        () => api.post('/api/auth/login', body: {'email': 'malo'}),
      );

      expect(excepcion.statusCode, 422);
      expect(excepcion.code, 'validacion');
      expect(excepcion.detail, contains('email'));
      expect(excepcion.detail, contains('value is not a valid email'));
    });

    test('El backend caido se traduce en error de conexion', () async {
      final api = crear(
        MockClient((_) async => throw http.ClientException('connection')),
      );

      final excepcion = await _capturar(() => api.get('/api/clientes'));

      expect(excepcion.statusCode, 0);
      expect(excepcion.code, 'sin_conexion');
      expect(excepcion.detail, contains('No se pudo conectar'));
    });

    test('El tiempo de espera agotado tiene codigo propio', () async {
      final api = ApiClient(
        baseUrl: 'http://localhost:8000',
        obtenerToken: () => null,
        tiempoLimite: const Duration(milliseconds: 20),
        cliente: MockClient((_) => Completer<http.Response>().future),
      );

      final excepcion = await _capturar(() => api.get('/api/clientes'));

      expect(excepcion.statusCode, 0);
      expect(excepcion.code, 'tiempo_excedido');
    });
  });

  group('Contrato de autenticacion', () {
    test('POST /api/auth/login lee accessToken y tokenType', () async {
      late http.Request capturada;
      final api = crear(
        MockClient((req) async {
          capturada = req;
          return _json(200, {
            'accessToken': 'jwt-de-prueba',
            'tokenType': 'bearer',
          });
        }),
      );

      final sesion = await AuthApi(api).login('admin@fabrica.co', 'secreta1');

      expect(capturada.url.path, '/api/auth/login');
      expect(jsonDecode(capturada.body), {
        'email': 'admin@fabrica.co',
        'password': 'secreta1',
      });
      expect(sesion.accessToken, 'jwt-de-prueba');
      expect(sesion.tokenType, 'bearer');
    });

    test('GET /api/auth/me devuelve el perfil en camelCase', () async {
      final api = crear(
        MockClient(
          (_) async => _json(200, {
            'idUsuario': 4,
            'username': 'ana',
            'email': 'ana@fabrica.co',
            'nombre': 'Ana Torres',
            'rol': 'VENTAS',
            'activo': true,
          }),
        ),
        token: 'jwt-de-prueba',
      );

      final usuario = await AuthApi(api).miPerfil();

      expect(usuario.idUsuario, 4);
      expect(usuario.nombre, 'Ana Torres');
      expect(usuario.rol, 'VENTAS');
      expect(usuario.activo, isTrue);
    });
  });

  group('Contrato POST /api/ventas', () {
    test('Solo envia idCliente y detalles con idProducto y cantidad', () async {
      late http.Request capturada;
      final api = crear(
        MockClient((req) async {
          capturada = req;
          return _json(201, {
            'idVenta': 12,
            'fecha': '2026-10-07T15:30:00Z',
            'total': '7000.00',
            'idCliente': 3,
            'detalles': [],
          });
        }),
        token: 'x',
      );

      final venta = await VentasApi(api).crear(3, [
        const ItemVenta(idProducto: 1, cantidad: 2),
        const ItemVenta(idProducto: 5, cantidad: 1),
      ]);

      expect(capturada.method, 'POST');
      expect(capturada.url.path, '/api/ventas');
      expect(capturada.headers['authorization'], 'Bearer x');
      expect(capturada.headers['content-type'], 'application/json');

      final cuerpo = jsonDecode(capturada.body) as Map<String, dynamic>;
      expect(cuerpo.keys.toList()..sort(), ['detalles', 'idCliente']);
      expect(cuerpo['idCliente'], 3);
      expect(cuerpo['detalles'], [
        {'idProducto': 1, 'cantidad': 2},
        {'idProducto': 5, 'cantidad': 1},
      ]);

      // No se envian campos que calcula el servidor.
      expect(cuerpo.containsKey('total'), isFalse);
      expect(cuerpo.containsKey('subtotal'), isFalse);
      expect(cuerpo.containsKey('precioUnitario'), isFalse);

      // El total llega como texto decimal y el modelo lo acepta.
      expect(venta.idVenta, 12);
      expect(venta.total, 7000.0);
    });
  });
}

Future<ApiException> _capturar(Future<dynamic> Function() accion) async {
  try {
    await accion();
  } on ApiException catch (e) {
    return e;
  }
  fail('La peticion debia fallar con ApiException');
}
