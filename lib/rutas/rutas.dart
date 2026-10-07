import 'package:flutter/material.dart';

import '../modelos/modelos.dart';
import '../ui/pantallas/cliente_formulario.dart';
import '../ui/pantallas/producto_formulario.dart';
import '../ui/pantallas/proveedor_formulario.dart';
import '../ui/pantallas/venta_detalle_pantalla.dart';
import '../ui/pantallas/venta_formulario.dart';

/// Nombres de ruta de la aplicacion.
class Rutas {
  static const String inicio = '/inicio';
  static const String clientes = '/clientes';
  static const String productos = '/productos';
  static const String proveedores = '/proveedores';
  static const String ventas = '/ventas';

  static const String clienteFormulario = '/clientes/formulario';
  static const String productoFormulario = '/productos/formulario';
  static const String proveedorFormulario = '/proveedores/formulario';
  static const String ventaFormulario = '/ventas/nueva';
  static const String ventaDetalle = '/ventas/detalle';

  /// Genera las rutas de detalle y de formularios (se abren sobre el shell).
  static Route<dynamic>? generarRuta(RouteSettings settings) {
    switch (settings.name) {
      case Rutas.clienteFormulario:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) =>
              ClienteFormulario(cliente: settings.arguments as Cliente?),
        );
      case Rutas.productoFormulario:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) =>
              ProductoFormulario(producto: settings.arguments as Producto?),
        );
      case Rutas.proveedorFormulario:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) =>
              ProveedorFormulario(proveedor: settings.arguments as Proveedor?),
        );
      case Rutas.ventaFormulario:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const VentaFormulario(),
        );
      case Rutas.ventaDetalle:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) =>
              VentaDetallePantalla(venta: settings.arguments as Venta),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Ruta no encontrada')),
            body: Center(child: Text('No existe la ruta ${settings.name}')),
          ),
        );
    }
  }
}
