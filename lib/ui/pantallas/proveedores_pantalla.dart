import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/sesion.dart';
import '../../modelos/modelos.dart';
import '../../rutas/rutas.dart';
import '../../theme/app_colors.dart';
import '../widgets/comunes.dart';

/// Listado paginado de proveedores (solo ADMIN y ALMACEN).
///
/// En movil se muestra como lista; en tablet y desktop como cuadricula de
/// tarjetas.
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

  String _contacto(Proveedor proveedor) {
    return [
      if ((proveedor.telefonoProveedor ?? '').isNotEmpty)
        proveedor.telefonoProveedor,
      if ((proveedor.correoProveedor ?? '').isNotEmpty)
        proveedor.correoProveedor,
      if ((proveedor.direccionProveedor ?? '').isNotEmpty)
        proveedor.direccionProveedor,
    ].join('  |  ');
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

  Widget _avatar() {
    return CircleAvatar(
      backgroundColor: AppColors.verdeSuave,
      foregroundColor: AppColors.verde,
      child: const Icon(Icons.factory_outlined),
    );
  }

  Widget _menu(Proveedor proveedor, Sesion sesion) {
    return PopupMenuButton<String>(
      onSelected: (valor) {
        if (valor == 'editar') _editar(proveedor);
        if (valor == 'eliminar') _eliminar(proveedor);
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
    );
  }

  Widget _filaLista(Proveedor proveedor, Sesion sesion) {
    final contacto = _contacto(proveedor);
    return ListTile(
      leading: _avatar(),
      title: Text(proveedor.nombreProveedor),
      subtitle: contacto.isEmpty
          ? null
          : Text(contacto, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: _menu(proveedor, sesion),
      onTap: () => _editar(proveedor),
    );
  }

  Widget _tarjeta(Proveedor proveedor, Sesion sesion) {
    final contacto = _contacto(proveedor);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _editar(proveedor),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _avatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      proveedor.nombreProveedor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _menu(proveedor, sesion),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  contacto.isEmpty ? 'Sin datos de contacto' : contacto,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.cafeSuave, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<Sesion>();
    final items = _visibles;

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
          ContenidoCentrado(
            relleno: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                : items.isEmpty
                ? panelVacio(
                    'No hay proveedores registrados.',
                    icono: Icons.local_shipping_outlined,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final esAncho = constraints.maxWidth >= 900;
                      return RefreshIndicator(
                        onRefresh: _cargar,
                        child: esAncho
                            ? GridView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  8,
                                  24,
                                  8,
                                ),
                                itemCount: items.length,
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 340,
                                      mainAxisExtent: 150,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                itemBuilder: (context, index) =>
                                    _tarjeta(items[index], sesion),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.only(bottom: 8),
                                itemCount: items.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) =>
                                    _filaLista(items[index], sesion),
                              ),
                      );
                    },
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
