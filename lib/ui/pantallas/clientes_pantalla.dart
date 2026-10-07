import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/sesion.dart';
import '../../modelos/modelos.dart';
import '../../rutas/rutas.dart';
import '../widgets/comunes.dart';

/// Listado paginado de clientes con buscar, crear, editar y eliminar.
class ClientesPantalla extends StatefulWidget {
  const ClientesPantalla({super.key});

  @override
  State<ClientesPantalla> createState() => _ClientesPantallaState();
}

class _ClientesPantallaState extends State<ClientesPantalla> {
  final _busqueda = TextEditingController();

  List<Cliente> _items = const [];
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
      final res = await context.read<Sesion>().clientes.listar(pagina: _pagina);
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

  List<Cliente> get _visibles {
    final texto = _busqueda.text.trim().toLowerCase();
    if (texto.isEmpty) return _items;
    return _items
        .where(
          (c) =>
              c.nombreCliente.toLowerCase().contains(texto) ||
              (c.correo ?? '').toLowerCase().contains(texto) ||
              (c.telefono ?? '').contains(texto),
        )
        .toList();
  }

  Future<void> _crear() async {
    final guardado = await Navigator.of(context)
        .pushNamed(Rutas.clienteFormulario);
    if (guardado == true) _cargar();
  }

  Future<void> _editar(Cliente cliente) async {
    final guardado = await Navigator.of(context)
        .pushNamed(Rutas.clienteFormulario, arguments: cliente);
    if (guardado == true) _cargar();
  }

  Future<void> _eliminar(Cliente cliente) async {
    final sesion = context.read<Sesion>();
    final ok = await confirmar(
      context,
      titulo: 'Eliminar cliente',
      mensaje:
          'Deseas eliminar a "${cliente.nombreCliente}"? '
          'Si tiene ventas asociadas la API bloqueara la eliminacion.',
      aceptar: 'Eliminar',
    );
    if (!ok || !mounted) return;
    try {
      await sesion.clientes.eliminar(cliente.idCliente);
      if (!mounted) return;
      mostrarExito(context, 'Cliente eliminado.');
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
      floatingActionButton: sesion.puedeEditarClientes
          ? FloatingActionButton(
              tooltip: 'Nuevo cliente',
              onPressed: _crear,
              child: const Icon(Icons.person_add_alt_1),
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
                    'No hay clientes. Registra el primero con el boton +.',
                    icono: Icons.people_outline,
                  )
                : RefreshIndicator(
                    onRefresh: _cargar,
                    child: ListView.separated(
                      itemCount: _visibles.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final cliente = _visibles[index];
                        final contacto = [
                          if ((cliente.telefono ?? '').isNotEmpty)
                            cliente.telefono,
                          if ((cliente.correo ?? '').isNotEmpty) cliente.correo,
                          if ((cliente.direccion ?? '').isNotEmpty)
                            cliente.direccion,
                        ].join('  |  ');
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              cliente.nombreCliente.isNotEmpty
                                  ? cliente.nombreCliente[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(cliente.nombreCliente),
                          subtitle: contacto.isEmpty
                              ? null
                              : Text(
                                  contacto,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (valor) {
                              if (valor == 'editar') _editar(cliente);
                              if (valor == 'eliminar') _eliminar(cliente);
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
                          onTap: () => _editar(cliente),
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
