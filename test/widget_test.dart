import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:app_bocadillos/core/sesion.dart';
import 'package:app_bocadillos/modelos/modelos.dart';
import 'package:app_bocadillos/ui/pantallas/login_pantalla.dart';

void main() {
  testWidgets('La pantalla de login muestra el formulario', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<Sesion>.value(
        value: Sesion(),
        child: const MaterialApp(home: LoginPantalla()),
      ),
    );

    expect(find.text('Fabrica de Bocadillos'), findsOneWidget);
    expect(find.text('Correo electronico'), findsOneWidget);
    expect(find.text('Contrasena'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });

  testWidgets('El login valida campos vacios', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<Sesion>.value(
        value: Sesion(),
        child: const MaterialApp(home: LoginPantalla()),
      ),
    );

    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.text('Ingresa tu correo'), findsOneWidget);
    expect(find.text('Ingresa tu contrasena'), findsOneWidget);
  });

  group('Modelos de la API', () {
    test('Cliente.fromJson interpreta camelCase', () {
      final cliente = Cliente.fromJson({
        'idCliente': 7,
        'nombreCliente': 'Panaderia La 14',
        'telefono': '3001112233',
        'correo': 'cliente@correo.com',
        'direccion': 'Calle 10 # 20-30',
      });

      expect(cliente.idCliente, 7);
      expect(cliente.nombreCliente, 'Panaderia La 14');
      expect(cliente.correo, 'cliente@correo.com');
    });

    test('Pagina.fromJson lee la envoltura de paginacion', () {
      final pagina = Pagina.fromJson({
        'items': [
          {
            'idProducto': 1,
            'nombreProducto': 'Bocado',
            'precio': 3500,
            'stock': 12,
          },
        ],
        'total': 42,
        'pagina': 2,
        'tamano': 20,
        'paginas': 3,
      }, Producto.fromJson);

      expect(pagina.total, 42);
      expect(pagina.pagina, 2);
      expect(pagina.paginas, 3);
      expect(pagina.items.single.precio, 3500);
      expect(pagina.items.single.stock, 12);
    });

    test('Venta.fromJson convierte totales y detalles', () {
      final venta = Venta.fromJson({
        'idVenta': 3,
        'fecha': '2026-10-07T15:30:00Z',
        'total': '10500.50',
        'idCliente': 1,
        'detalles': [
          {
            'idDetalle': 9,
            'idVenta': 3,
            'idProducto': 1,
            'cantidad': 3,
            'precioUnitario': '3500.17',
            'subtotal': '10500.50',
          },
        ],
      });

      expect(venta.idVenta, 3);
      expect(venta.total, 10500.50);
      expect(venta.detalles, hasLength(1));
      expect(venta.detalles.first.cantidad, 3);
      expect(venta.detalles.first.subtotal, 10500.50);
    });
  });
}
