import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_bocadillos/core/api_client.dart';
import 'package:app_bocadillos/core/sesion.dart';
import 'package:app_bocadillos/modelos/modelos.dart';

http.Response _json(Object cuerpo, [int statusCode = 200]) {
  return http.Response(
    jsonEncode(cuerpo),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}

const _usuario = {
  'idUsuario': 1,
  'username': 'admin',
  'email': 'admin@fabrica.co',
  'nombre': 'Administrador',
  'rol': 'ADMIN',
  'activo': true,
};

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('iniciarSesion guarda token, perfil y notifica cambios', () async {
    final api = ApiClient(
      baseUrl: 'http://localhost:8000',
      obtenerToken: () => null,
      cliente: MockClient((req) async {
        if (req.url.path.endsWith('/auth/login')) {
          return _json({'accessToken': 'jwt', 'tokenType': 'bearer'});
        }
        return _json(_usuario);
      }),
    );
    final sesion = Sesion(api: api);
    var cambios = 0;
    sesion.addListener(() => cambios++);

    await sesion.iniciarSesion('admin@fabrica.co', 'secreta');

    final prefs = await SharedPreferences.getInstance();
    expect(sesion.autenticado, isTrue);
    expect(sesion.esAdmin, isTrue);
    expect(sesion.usuario?.nombre, 'Administrador');
    expect(prefs.getString('token_fabrica'), 'jwt');
    expect(cambios, 1);
  });

  test('cerrarSesion elimina token y usuario', () async {
    SharedPreferences.setMockInitialValues({'token_fabrica': 'jwt'});
    final sesion = Sesion(
      api: ApiClient(
        baseUrl: 'http://localhost:8000',
        obtenerToken: () => 'jwt',
        cliente: MockClient((_) async => _json(_usuario)),
      ),
    )..token = 'jwt';

    await sesion.cerrarSesion();

    final prefs = await SharedPreferences.getInstance();
    expect(sesion.autenticado, isFalse);
    expect(sesion.usuario, isNull);
    expect(prefs.containsKey('token_fabrica'), isFalse);
  });

  test('los permisos coinciden con cada rol del backend', () {
    final casos = {
      'ADMIN': [true, true, true],
      'ALMACEN': [false, true, false],
      'VENTAS': [false, false, true],
    };

    for (final entrada in casos.entries) {
      final sesion = Sesion()..token = 'jwt';
      sesion.usuario = Usuario(
        idUsuario: 1,
        username: 'usuario',
        email: 'usuario@fabrica.co',
        nombre: 'Usuario',
        rol: entrada.key,
        activo: true,
      );

      expect(sesion.puedeVerProveedores, entrada.value[1], reason: entrada.key);
      expect(sesion.puedeVerVentas, entrada.value[2], reason: entrada.key);
      expect(
        sesion.puedeEditarProductos,
        entrada.key != 'VENTAS',
        reason: entrada.key,
      );
    }
  });
}
