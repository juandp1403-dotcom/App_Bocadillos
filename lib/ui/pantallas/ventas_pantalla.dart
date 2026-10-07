import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/formato.dart';
import '../../core/sesion.dart';
import '../../modelos/modelos.dart';
import '../../rutas/rutas.dart';
import '../widgets/comunes.dart';

/// Listado paginado de ventas registradas.
class VentasPantalla extends StatefulWidget {
  const VentasPantalla({super.key});

  @override
  State<VentasPantalla> createState() => _VentasPantallaState();
}

class _VentasPantallaState extends State<VentasPantalla> {
  final _busqueda = TextEditingController();

  List<Venta> _items = const [];
  int _pagina = 1;
  int _paginas = 1;
  int _total = 0;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final res = await context.read<Sesion>().ventas.listar(pagina: _pagina);
      if (!mounted) return;
      setState(() {
        _items = res.items;
        _total = res.total;
        _paginas = res.paginas < 1 ? 1 : res.paginas;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.detail);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  List<Venta> get _visibles {
    final texto = _busqueda.text.trim().toLowerCase();
    if (texto.isEmpty) return _items;
    return _items
        .where(
          (v) =>
              '${v.idVenta}'.contains(texto) ||
              '${v.idCliente}'.contains(texto) ||
              '${v.total}'.contains(texto),
        )
        .toList();
  }

  Future<void> _nueva() async {
    final creada = await Navigator.of(context).pushNamed(Rutas.ventaFormulario);
    if (creada == true) _cargar();
  }

  Future<void> _abrir(Venta venta) async {
    await Navigator.of(context).pushNamed(Rutas.ventaDetalle, arguments: venta);
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nueva,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Nueva venta'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _busqueda,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por numero de venta o cliente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busqueda.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _busqueda.clear();
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: _cargando
                ? panelCargando()
                : _error != null
                ? panelError(_error!, reintento: _cargar)
                : _visibles.isEmpty
                ? panelVacio(
                    'Todavia no hay ventas registradas.',
                    icono: Icons.receipt_long_outlined,
                  )
                : RefreshIndicator(
                    onRefresh: _cargar,
                    child: ListView.separated(
                      itemCount: _visibles.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final venta = _visibles[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.receipt_outlined),
                          ),
                          title: Text('Venta #${venta.idVenta}'),
                          subtitle: Text(
                            '${fechaHora(venta.fecha)}  |  '
                            'Cliente #${venta.idCliente}',
                          ),
                          trailing: Text(
                            dinero(venta.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          onTap: () => _abrir(venta),
                        );
                      },
                    ),
                  ),
          ),
          BarraPaginacion(
            pagina: _pagina,
            paginas: _paginas,
            total: _total,
            onAnterior: _pagina > 1
                ? () {
                    setState(() => _pagina--);
                    _cargar();
                  }
                : null,
            onSiguiente: _pagina < _paginas
                ? () {
                    setState(() => _pagina++);
                    _cargar();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
