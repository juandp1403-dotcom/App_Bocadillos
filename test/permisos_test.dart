import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:app_bocadillos/core/api_client.dart';
import 'package:app_bocadillos/core/sesion.dart';
import 'package:app_bocadillos/modelos/modelos.dart';
import 'package:app_bocadillos/ui/pantallas/shell_pantalla.dart';

const _paginaVacia = {
  'items': <Object>[],
  'total': 0,
  'pagina': 1,
  'tamano': 20,
  'paginas': 0,
};

/// Cliente HTTP de prueba: responde paginas vacias y el perfil de usuario.
MockClient _api(Usuario usuario) {
  return MockClient((req) async {
    final cuerpo = req.url.path.endsWith('/auth/me')
        ? <String, Object>{
            'idUsuario': usuario.idUsuario,
            'username': usuario.username,
            'email': usuario.email,
            'nombre': usuario.nombre,
            'rol': usuario.rol,
            'activo': usuario.activo,
          }
        : _paginaVacia;
    return http.Response(
      jsonEncode(cuerpo),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
}

Sesion _sesion(String rol) {
  final usuario = Usuario(
    idUsuario: 1,
    username: 'prueba',
    email: 'prueba@fabrica.co',
    nombre: 'Usuario $rol',
    rol: rol,
    activo: true,
  );
  final sesion = Sesion(
    api: ApiClient(
      baseUrl: 'http://localhost:8000',
      obtenerToken: () => 'token-de-prueba',
      cliente: _api(usuario),
    ),
  );
  sesion
    ..token = 'token-de-prueba'
    ..usuario = usuario
    ..cargandoSesion = false;
  return sesion;
}

Future<void> _abrirApp(WidgetTester tester, Sesion sesion) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<Sesion>.value(
      value: sesion,
      child: const MaterialApp(home: ShellPantalla()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Busca un texto unicamente dentro del cajon de navegacion.
Finder _enDrawer(String texto) {
  return find.descendant(of: find.byType(Drawer), matching: find.text(texto));
}

Future<void> _abrirCajon(WidgetTester tester) async {
  final boton = find.byType(DrawerButton);
  await tester.tap(boton.evaluate().isEmpty ? find.byIcon(Icons.menu) : boton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ADMIN ve clientes, productos, proveedores y ventas', (
    tester,
  ) async {
    await _abrirApp(tester, _sesion('ADMIN'));
    await _abrirCajon(tester);

    expect(_enDrawer('Clientes'), findsAtLeastNWidgets(1));
    expect(_enDrawer('Productos'), findsAtLeastNWidgets(1));
    expect(_enDrawer('Proveedores'), findsAtLeastNWidgets(1));
    expect(_enDrawer('Ventas'), findsAtLeastNWidgets(1));
  });

  testWidgets('ALMACEN ve proveedores y oculta ventas', (tester) async {
    await _abrirApp(tester, _sesion('ALMACEN'));
    await _abrirCajon(tester);

    expect(_enDrawer('Clientes'), findsAtLeastNWidgets(1));
    expect(_enDrawer('Productos'), findsAtLeastNWidgets(1));
    expect(_enDrawer('Proveedores'), findsAtLeastNWidgets(1));
    expect(_enDrawer('Ventas'), findsNothing);
  });

  testWidgets('VENTAS ve ventas y oculta proveedores', (tester) async {
    await _abrirApp(tester, _sesion('VENTAS'));
    await _abrirCajon(tester);

    expect(_enDrawer('Clientes'), findsAtLeastNWidgets(1));
    expect(_enDrawer('Productos'), findsAtLeastNWidgets(1));
    expect(_enDrawer('Proveedores'), findsNothing);
    expect(_enDrawer('Ventas'), findsAtLeastNWidgets(1));
  });
}
