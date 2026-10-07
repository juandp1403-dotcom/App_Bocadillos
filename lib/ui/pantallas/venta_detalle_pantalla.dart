import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/formato.dart';
import '../../core/sesion.dart';
import '../../modelos/modelos.dart';
import '../widgets/comunes.dart';

/// Detalle de una venta: cabecera, productos vendidos y eliminacion (ADMIN).
class VentaDetallePantalla extends StatefulWidget {
  const VentaDetallePantalla({super.key, required this.venta});

  final Venta venta;

  @override
  State<VentaDetallePantalla> createState() => _VentaDetallePantallaState();
}

class _VentaDetallePantallaState extends State<VentaDetallePantalla> {
  late Future<Venta> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<Venta> _cargar() {
    return context.read<Sesion>().ventas.obtener(widget.venta.idVenta);
  }

  Future<void> _eliminar(Venta venta) async {
    final sesion = context.read<Sesion>();
    final ok = await confirmar(
      context,
      titulo: 'Eliminar venta',
      mensaje:
          'Deseas eliminar la venta #${venta.idVenta}? '
          'Si tiene detalles la API bloqueara la eliminacion para preservar el historico.',
      aceptar: 'Eliminar',
    );
    if (!ok || !mounted) return;
    try {
      await sesion.ventas.eliminar(venta.idVenta);
      if (!mounted) return;
      mostrarExito(context, 'Venta eliminada.');
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      mostrarError(context, e.detail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<Sesion>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Venta #${widget.venta.idVenta}'),
        actions: [
          if (sesion.esAdmin)
            IconButton(
              tooltip: 'Eliminar venta',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _eliminar(widget.venta),
            ),
        ],
      ),
      body: FutureBuilder<Venta>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return panelCargando('Cargando venta...');
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            return panelError(
              error is ApiException
                  ? error.detail
                  : 'No se pudo cargar la venta.',
              reintento: () => setState(() => _futuro = _cargar()),
            );
          }
          final venta = snapshot.data;
          if (venta == null) {
            return panelError('La venta no existe.', reintento: _volver);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venta #${venta.idVenta}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Fecha: ${fechaHora(venta.fecha)}'),
                      Text('Cliente #${venta.idCliente}'),
                      const Divider(),
                      Text(
                        'Total: ${dinero(venta.total)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Calculado por el servidor (suma de subtotales).',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Productos vendidos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (venta.detalles.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Esta venta no tiene detalles.'),
                  ),
                )
              else
                Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Producto')),
                        DataColumn(label: Text('Cantidad'), numeric: true),
                        DataColumn(label: Text('P. unitario'), numeric: true),
                        DataColumn(label: Text('Subtotal'), numeric: true),
                      ],
                      rows: [
                        for (final detalle in venta.detalles)
                          DataRow(
                            cells: [
                              DataCell(Text('#${detalle.idProducto}')),
                              DataCell(Text('${detalle.cantidad}')),
                              DataCell(Text(dinero(detalle.precioUnitario))),
                              DataCell(Text(dinero(detalle.subtotal))),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _volver() {
    Navigator.of(context).pop();
  }
}
