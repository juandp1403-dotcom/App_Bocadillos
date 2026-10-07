import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/formato.dart';
import '../../core/sesion.dart';
import '../../modelos/modelos.dart';
import '../../servicios/ventas_api.dart';
import '../widgets/comunes.dart';

class _ItemCarrito {
  _ItemCarrito(this.producto, this.cantidad);

  final Producto producto;
  int cantidad;

  double get subtotal => producto.precio * cantidad;
}

/// Formulario de nueva venta: cliente + carrito de productos.
///
/// El servidor calcula subtotal/total y descuenta el stock; aqui solo se
/// envian `idCliente` y `detalles[{idProducto, cantidad}]`.
class VentaFormulario extends StatefulWidget {
  const VentaFormulario({super.key});

  @override
  State<VentaFormulario> createState() => _VentaFormularioState();
}

class _VentaFormularioState extends State<VentaFormulario> {
  final _busquedaCliente = TextEditingController();
  final _busquedaProducto = TextEditingController();

  List<Cliente> _clientes = const [];
  List<Producto> _productos = const [];
  final List<_ItemCarrito> _carrito = [];

  int? _idCliente;
  Cliente? _clienteElegido;
  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _busquedaCliente.dispose();
    _busquedaProducto.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final sesion = context.read<Sesion>();
      final clientes = await sesion.clientes.listarTodos();
      final productos = await sesion.productos.listarTodos();
      if (!mounted) return;
      setState(() {
        _clientes = clientes;
        _productos = productos;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.detail);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  List<Cliente> get _clientesFiltrados {
    final texto = _busquedaCliente.text.trim().toLowerCase();
    final List<Cliente> base;
    if (texto.isEmpty) {
      base = _clientes;
    } else {
      base = _clientes
          .where(
            (c) =>
                c.nombreCliente.toLowerCase().contains(texto) ||
                '${c.idCliente}'.contains(texto),
          )
          .toList();
    }
    // El cliente elegido debe seguir en la lista aunque el filtro lo oculte,
    // de lo contrario el dropdown pierde su valor.
    final elegido = _clienteElegido;
    if (elegido != null && !base.any((c) => c.idCliente == elegido.idCliente)) {
      return [elegido, ...base];
    }
    return base;
  }

  List<Producto> get _productosFiltrados {
    final texto = _busquedaProducto.text.trim().toLowerCase();
    if (texto.isEmpty) return _productos;
    return _productos
        .where(
          (p) =>
              p.nombreProducto.toLowerCase().contains(texto) ||
              (p.tipo ?? '').toLowerCase().contains(texto),
        )
        .toList();
  }

  double get _total => _carrito.fold(0, (suma, item) => suma + item.subtotal);

  _ItemCarrito? _itemDe(int idProducto) {
    for (final item in _carrito) {
      if (item.producto.idProducto == idProducto) return item;
    }
    return null;
  }

  void _agregar(Producto producto) {
    if (producto.stock <= 0) {
      mostrarError(context, 'El producto no tiene stock disponible.');
      return;
    }
    final existente = _itemDe(producto.idProducto);
    if (existente != null && existente.cantidad >= producto.stock) {
      mostrarError(
        context,
        'Solo hay ${producto.stock} unidades de ${producto.nombreProducto}.',
      );
      return;
    }
    setState(() {
      if (existente == null) {
        _carrito.add(_ItemCarrito(producto, 1));
      } else {
        existente.cantidad++;
      }
    });
  }

  void _aumentar(_ItemCarrito item) {
    if (item.cantidad >= item.producto.stock) {
      mostrarError(
        context,
        'Solo hay ${item.producto.stock} unidades disponibles.',
      );
      return;
    }
    setState(() => item.cantidad++);
  }

  void _disminuir(_ItemCarrito item) {
    setState(() {
      if (item.cantidad > 1) {
        item.cantidad--;
      } else {
        _carrito.remove(item);
      }
    });
  }

  Future<void> _registrar() async {
    // Evita enviar dos veces la misma venta.
    if (_guardando) return;
    if (_idCliente == null) {
      mostrarError(context, 'Selecciona el cliente de la venta.');
      return;
    }
    if (_carrito.isEmpty) {
      mostrarError(context, 'Agrega al menos un producto a la venta.');
      return;
    }

    setState(() => _guardando = true);
    try {
      final venta = await context.read<Sesion>().ventas.crear(
        _idCliente!,
        _carrito
            .map(
              (i) => ItemVenta(
                idProducto: i.producto.idProducto,
                cantidad: i.cantidad,
              ),
            )
            .toList(),
      );
      if (!mounted) return;
      mostrarExito(
        context,
        'Venta #${venta.idVenta} registrada. Total ${dinero(venta.total)}',
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      mostrarError(context, e.detail);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva venta')),
      body: _cargando
          ? panelCargando('Cargando clientes y productos...')
          : _error != null
          ? panelError(_error!, reintento: _cargar)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _seccion(
                  titulo: '1. Cliente',
                  icono: Icons.person_outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _busquedaCliente,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Buscar cliente...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _busquedaCliente.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _busquedaCliente.clear();
                                    setState(() {});
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_clientes.isEmpty)
                        const Text('No hay clientes registrados.')
                      else ...[
                        DropdownButtonFormField<int>(
                          initialValue: _idCliente,
                          hint: const Text('Selecciona un cliente'),
                          items: [
                            for (final cliente in _clientesFiltrados)
                              DropdownMenuItem(
                                value: cliente.idCliente,
                                child: Text(
                                  '#${cliente.idCliente} - ${cliente.nombreCliente}',
                                ),
                              ),
                          ],
                          onChanged: (valor) {
                            setState(() {
                              _idCliente = valor;
                              _clienteElegido = null;
                              for (final c in _clientes) {
                                if (c.idCliente == valor) _clienteElegido = c;
                              }
                            });
                          },
                          validator: (_) => _idCliente == null
                              ? 'Selecciona un cliente'
                              : null,
                        ),
                        if (_clientesFiltrados.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Ningun cliente coincide con la busqueda.',
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _seccion(
                  titulo: '2. Productos',
                  icono: Icons.inventory_2_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _busquedaProducto,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Buscar producto...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _busquedaProducto.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _busquedaProducto.clear();
                                    setState(() {});
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_productos.isEmpty)
                        const Text('No hay productos registrados.')
                      else ...[
                        for (final producto in _productosFiltrados.take(50))
                          ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              child: Text('${producto.stock}'),
                            ),
                            title: Text(producto.nombreProducto),
                            subtitle: Text(
                              '${dinero(producto.precio)}  |  '
                              '${producto.tipo ?? "sin tipo"}',
                            ),
                            trailing: IconButton(
                              tooltip: 'Agregar al carrito',
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () => _agregar(producto),
                            ),
                          ),
                        if (_productosFiltrados.length > 50)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Se muestran los primeros 50 de '
                              '${_productosFiltrados.length}. '
                              'Usa la busqueda para encontrar los demas.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                      if (_productosFiltrados.isEmpty && _productos.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Ningun producto coincide con la busqueda.',
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _seccion(
                  titulo: '3. Carrito',
                  icono: Icons.shopping_cart_outlined,
                  child: _carrito.isEmpty
                      ? const Text('Aun no has agregado productos.')
                      : Column(
                          children: [
                            for (final item in _carrito)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(item.producto.nombreProducto),
                                subtitle: Text(
                                  '${dinero(item.producto.precio)} c/u  |  '
                                  'Subtotal ${dinero(item.subtotal)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () => _disminuir(item),
                                    ),
                                    Text('${item.cantidad}'),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () => _aumentar(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () =>
                                          setState(() => _carrito.remove(item)),
                                    ),
                                  ],
                                ),
                              ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total estimado',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                Text(
                                  dinero(_total),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'El total final lo calcula el servidor.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _guardando ? null : _registrar,
                  icon: _guardando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.point_of_sale),
                  label: Text(
                    _carrito.isEmpty
                        ? 'Registrar venta'
                        : 'Registrar venta  |  ${dinero(_total)}',
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _seccion({
    required String titulo,
    required IconData icono,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono),
                const SizedBox(width: 8),
                Text(titulo, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
