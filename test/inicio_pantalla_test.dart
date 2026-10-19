import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:app_bocadillos/core/api_client.dart';
import 'package:app_bocadillos/core/sesion.dart';
import 'package:app_bocadillos/modelos/modelos.dart';
import 'package:app_bocadillos/theme/app_colors.dart';
import 'package:app_bocadillos/ui/pantallas/inicio_pantalla.dart';

http.Response _json(Object cuerpo) => http.Response(
  jsonEncode(cuerpo),
  200,
  headers: {'content-type': 'application/json'},
);

void main() {
  testWidgets(
    'el tablero muestra resumen, tarjetas coloreadas y ultimas ventas',
    (tester) async {
      final sesion =
          Sesion(
              api: ApiClient(
                baseUrl: 'http://localhost:8000',
                obtenerToken: () => 'token',
                cliente: MockClient((req) async {
                  if (req.url.path.endsWith('/clientes')) {
                    return _json({
                      'items': [],
                      'total': 4,
                      'pagina': 1,
                      'tamano': 1,
                      'paginas': 1,
                    });
                  }
                  if (req.url.path.endsWith('/productos')) {
                    return _json({
                      'items': [
                        {
                          'idProducto': 1,
                          'nombreProducto': 'Bocado',
                          'precio': 100,
                          'stock': 2,
                        },
                        {
                          'idProducto': 2,
                          'nombreProducto': 'Caja',
                          'precio': 200,
                          'stock': 12,
                        },
                      ],
                      'total': 2,
                      'pagina': 1,
                      'tamano': 100,
                      'paginas': 1,
                    });
                  }
                  if (req.url.path.endsWith('/proveedores')) {
                    return _json({
                      'items': [],
                      'total': 3,
                      'pagina': 1,
                      'tamano': 1,
                      'paginas': 1,
                    });
                  }
                  return _json({
                    'items': [
                      {
                        'idVenta': 9,
                        'fecha': '2026-10-19T15:30:00Z',
                        'total': '3500.00',
                        'idCliente': 4,
                        'detalles': [],
                      },
                    ],
                    'total': 1,
                    'pagina': 1,
                    'tamano': 5,
                    'paginas': 1,
                  });
                }),
              ),
            )
            ..token = 'token'
            ..usuario = const Usuario(
              idUsuario: 1,
              username: 'admin',
              email: 'admin@fabrica.co',
              nombre: 'Admin',
              rol: 'ADMIN',
              activo: true,
            )
            ..cargandoSesion = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<Sesion>.value(
          value: sesion,
          child: MaterialApp(
            theme: ThemeData(scaffoldBackgroundColor: AppColors.crema),
            home: const InicioPantalla(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PANEL DE MANDO'), findsOneWidget);
      expect(find.text('Clientes'), findsOneWidget);
      expect(find.text('Productos'), findsOneWidget);
      expect(find.text('Proveedores'), findsOneWidget);
      expect(find.text('Ventas registradas'), findsOneWidget);
      expect(find.text('Productos con stock bajo'), findsOneWidget);
      expect(find.text('Venta #9'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    },
  );
}
