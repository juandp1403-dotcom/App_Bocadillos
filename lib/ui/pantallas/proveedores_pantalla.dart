import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/sesion.dart';
import '../../modelos/modelos.dart';
import '../../rutas/rutas.dart';
import '../widgets/comunes.dart';

/// Listado paginado de proveedores (solo ADMIN y ALMACEN).
class ProveedoresPantalla extends StatefulWidget {
  const ProveedoresPantalla({super.key});

  @override
  State<ProveedoresPantalla> createState() => _ProveedoresPantallaState();
}

class _ProveedoresPantallaState extends State<ProveedoresPantalla> {
  final _busqueda = TextEditingController();

  List<Proveedor> _items = const [];
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
      final res = await context.read<Sesion>().proveedores.listar(
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

  List<Proveedor> get _visibles {
    final texto = _busqueda.text.trim().toLowerCase();
    if (texto.isEmpty) return _items;
    return _items
        .where(
          (p) =>
              p.nombreProveedor.toLowerCase().contains(texto) ||
              (p.correoProveedor ?? '').toLowerCase().contains(texto) ||
              (p.telefonoProveedor ?? '').contains(texto),
        )
        .toList();
  }

  Future<void> _crear() async {
    final guardado = await Navigator.of(context)
        .pushNamed(Rutas.proveedorFormulario);
    if (guardado == true) _cargar();
  }

  Future<void> _editar(Proveedor proveedor) async {
    final guardado = await Navigator.of(context)
        .pushNamed(Rutas.proveedorFormulario, arguments: proveedor);
    if (guardado == true) _cargar();
  }

  Future<void> _eliminar(Proveedor proveedor) async {
    final sesion = context.read<Sesion>();
    final ok = await confirmar(
      context,
      titulo: 'Eliminar proveedor',
      mensaje:
          'Deseas eliminar a "${proveedor.nombreProveedor}"? '
          'Si tiene productos asociados la API bloqueara la eliminacion.',
      aceptar: 'Eliminar',
    );
    if (!ok || !mounted) return;
    try {
      await sesion.proveedores.eliminar(proveedor.idProveedor);
      if (!mounted) return;
      mostrarExito(context, 'Proveedor eliminado.');
      _cargar();
    } on ApiException catch (e) {
      if (!mounted) return;
      mostrarError(context, e.detail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<Sesion>();

    return Scaffold(
      floatingActionButton: sesion.puedeEditarProductos
          ? FloatingActionButton(
              tooltip: 'Nuevo proveedor',
              onPressed: _crear,
              child: const Icon(Icons.add_business_outlined),
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
                    'No hay proveedores registrados.',
                    icono: Icons.local_shipping_outlined,
                  )
                : RefreshIndicator(
                    onRefresh: _cargar,
                    child: ListView.separated(
                      itemCount: _visibles.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final proveedor = _visibles[index];
                        final contacto = [
                          if ((proveedor.telefonoProveedor ?? '').isNotEmpty)
                            proveedor.telefonoProveedor,
                          if ((proveedor.correoProveedor ?? '').isNotEmpty)
                            proveedor.correoProveedor,
                          if ((proveedor.direccionProveedor ?? '').isNotEmpty)
                            proveedor.direccionProveedor,
                        ].join('  |  ');
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.factory_outlined),
                          ),
                          title: Text(proveedor.nombreProveedor),
                          subtitle: contacto.isEmpty
                              ? null
                              : Text(
                                  contacto,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (valor) {
                              if (valor == 'editar') _editar(proveedor);
                              if (valor == 'eliminar') {
                                _eliminar(proveedor);
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
                          onTap: () => _editar(proveedor),
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
