import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/formato.dart';
import '../../core/sesion.dart';
import '../../modelos/modelos.dart';
import '../widgets/comunes.dart';

class _Resumen {
  const _Resumen({
    required this.clientes,
    required this.productos,
    required this.proveedores,
    required this.ventas,
    required this.stockBajo,
    required this.ultimasVentas,
  });

  final int clientes;
  final int productos;
  final int proveedores;
  final int ventas;
  final int stockBajo;
  final List<Venta> ultimasVentas;
}

/// Tablero inicial con indicadores de la fabrica.
class InicioPantalla extends StatefulWidget {
  const InicioPantalla({super.key});

  @override
  State<InicioPantalla> createState() => _InicioPantallaState();
}

class _InicioPantallaState extends State<InicioPantalla> {
  late Future<_Resumen> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<_Resumen> _cargar() async {
    final sesion = context.read<Sesion>();

    final fClientes = sesion.clientes.listar(pagina: 1, tamano: 1);
    final fProductos = sesion.productos.listarTodos();
    final fProveedores = sesion.puedeVerProveedores
        ? sesion.proveedores.listar(pagina: 1, tamano: 1)
        : null;
    final fVentas = sesion.puedeVerVentas
        ? sesion.ventas.listar(pagina: 1, tamano: 5)
        : null;

    final clientes = await fClientes;
    final productos = await fProductos;
    final proveedores = fProveedores == null ? null : await fProveedores;
    final ventas = fVentas == null ? null : await fVentas;

    return _Resumen(
      clientes: clientes.total,
      productos: productos.length,
      stockBajo: productos.where((p) => p.stock <= 5).length,
      proveedores: proveedores?.total ?? 0,
      ventas: ventas?.total ?? 0,
      ultimasVentas: ventas?.items ?? const [],
    );
  }

  void _reintentar() {
    setState(() => _futuro = _cargar());
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<Sesion>();
    return FutureBuilder<_Resumen>(
      future: _futuro,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return panelCargando('Cargando tablero...');
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          return panelError(
            error is ApiException
                ? error.detail
                : 'No se pudo cargar el tablero.',
            reintento: _reintentar,
          );
        }
        final resumen = snapshot.data;
        if (resumen == null) return panelError('No se pudo cargar el tablero.');

        final tarjetas = <Widget>[
          _Tarjeta(
            icono: Icons.people_outline,
            titulo: 'Clientes',
            valor: '${resumen.clientes}',
            color: Colors.blue,
          ),
          _Tarjeta(
            icono: Icons.inventory_2_outlined,
            titulo: 'Productos',
            valor: '${resumen.productos}',
            color: Colors.teal,
          ),
          if (sesion.puedeVerProveedores)
            _Tarjeta(
              icono: Icons.local_shipping_outlined,
              titulo: 'Proveedores',
              valor: '${resumen.proveedores}',
              color: Colors.brown,
            ),
          if (sesion.puedeVerVentas)
            _Tarjeta(
              icono: Icons.receipt_long_outlined,
              titulo: 'Ventas registradas',
              valor: '${resumen.ventas}',
              color: Colors.deepOrange,
            ),
          _Tarjeta(
            icono: Icons.warning_amber_outlined,
            titulo: 'Productos con stock bajo',
            valor: '${resumen.stockBajo}',
            color: resumen.stockBajo > 0 ? Colors.red : Colors.green,
          ),
        ];

        return RefreshIndicator(
          onRefresh: () async => _reintentar(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Hola, ${sesion.usuario?.nombre ?? ''}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Resumen general de la fabrica',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Wrap(spacing: 12, runSpacing: 12, children: tarjetas),
              const SizedBox(height: 24),
              if (sesion.puedeVerVentas) ...[
                Text(
                  'Ultimas ventas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: resumen.ultimasVentas.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Todavia no hay ventas registradas.'),
                        )
                      : Column(
                          children: [
                            for (final venta in resumen.ultimasVentas)
                              ListTile(
                                leading: const Icon(Icons.receipt_outlined),
                                title: Text('Venta #${venta.idVenta}'),
                                subtitle: Text(fechaHora(venta.fecha)),
                                trailing: Text(
                                  dinero(venta.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.dns_outlined),
                  title: const Text('Servidor conectado'),
                  subtitle: Text(
                    'API en ${Uri.parse(context.read<Sesion>().api.baseUrl).host}',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.color,
  });

  final IconData icono;
  final String titulo;
  final String valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                valor,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(titulo, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
