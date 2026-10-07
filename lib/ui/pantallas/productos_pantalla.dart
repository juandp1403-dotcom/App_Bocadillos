import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/formato.dart';
import '../../core/sesion.dart';
import '../../modelos/modelos.dart';
import '../../rutas/rutas.dart';
import '../widgets/comunes.dart';

/// Listado paginado de productos con stock y precio.
class ProductosPantalla extends StatefulWidget {
  const ProductosPantalla({super.key});

  @override
  State<ProductosPantalla> createState() => _ProductosPantallaState();
}

class _ProductosPantallaState extends State<ProductosPantalla> {
  final _busqueda = TextEditingController();

  List<Producto> _items = const [];
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
      final res = await context.read<Sesion>().productos.listar(
        pagina: _pagina,
      );
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

  List<Producto> get _visibles {
    final texto = _busqueda.text.trim().toLowerCase();
    if (texto.isEmpty) return _items;
    return _items
        .where(
          (p) =>
              p.nombreProducto.toLowerCase().contains(texto) ||
              (p.tipo ?? '').toLowerCase().contains(texto),
        )
        .toList();
  }

  Future<void> _crear() async {
    final guardado = await Navigator.of(context)
        .pushNamed(Rutas.productoFormulario);
    if (guardado == true) _cargar();
  }

  Future<void> _editar(Producto producto) async {
    final guardado = await Navigator.of(context)
        .pushNamed(Rutas.productoFormulario, arguments: producto);
    if (guardado == true) _cargar();
  }

  Future<void> _eliminar(Producto producto) async {
    final sesion = context.read<Sesion>();
    final ok = await confirmar(
      context,
      titulo: 'Eliminar producto',
      mensaje:
          'Deseas eliminar "${producto.nombreProducto}"? '
          'Si ya tiene ventas la API bloqueara la eliminacion.',
      aceptar: 'Eliminar',
    );
    if (!ok || !mounted) return;
    try {
      await sesion.productos.eliminar(producto.idProducto);
      if (!mounted) return;
      mostrarExito(context, 'Producto eliminado.');
      _cargar();
    } on ApiException catch (e) {
      if (!mounted) return;
      mostrarError(context, e.detail);
    }
  }

  Color _colorStock(int stock) {
    if (stock <= 0) return Colors.red.shade700;
    if (stock <= 5) return Colors.orange.shade800;
    return Colors.green.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<Sesion>();

    return Scaffold(
      floatingActionButton: sesion.puedeEditarProductos
          ? FloatingActionButton(
              tooltip: 'Nuevo producto',
              onPressed: _crear,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _busqueda,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar en la pagina actual...',
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
                    'No hay productos registrados.',
                    icono: Icons.inventory_2_outlined,
                  )
                : RefreshIndicator(
                    onRefresh: _cargar,
                    child: ListView.separated(
                      itemCount: _visibles.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final producto = _visibles[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _colorStock(producto.stock)
                                .withValues(alpha: 0.15),
                            child: Text(
                              '${producto.stock}',
                              style: TextStyle(
                                color: _colorStock(producto.stock),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(producto.nombreProducto),
                          subtitle: Text(
                            [
                              if ((producto.tipo ?? '').isNotEmpty)
                                producto.tipo,
                              'Proveedor #${producto.idProveedor ?? '-'}',
                            ].join('  |  '),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dinero(producto.precio),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (sesion.puedeEditarProductos)
                                PopupMenuButton<String>(
                                  onSelected: (valor) {
                                    if (valor == 'editar') {
                                      _editar(producto);
                                    }
                                    if (valor == 'eliminar') {
                                      _eliminar(producto);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'editar',
                                      child: ListTile(
                                        leading: Icon(Icons.edit_outlined),
                                        title: Text('Editar'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    if (sesion.puedeBorrar)
                                      const PopupMenuItem(
                                        value: 'eliminar',
                                        child: ListTile(
                                          leading: Icon(Icons.delete_outline),
                                          title: Text('Eliminar'),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                          onTap: sesion.puedeEditarProductos
                              ? () => _editar(producto)
                              : null,
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
