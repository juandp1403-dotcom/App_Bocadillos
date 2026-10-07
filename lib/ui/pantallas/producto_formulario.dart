import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/sesion.dart';
import '../../modelos/modelos.dart';
import '../widgets/comunes.dart';

/// Formulario para crear o editar un producto.
class ProductoFormulario extends StatefulWidget {
  const ProductoFormulario({super.key, this.producto});

  final Producto? producto;

  @override
  State<ProductoFormulario> createState() => _ProductoFormularioState();
}

class _ProductoFormularioState extends State<ProductoFormulario> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _tipo;
  late final TextEditingController _precio;
  late final TextEditingController _stock;

  List<Proveedor> _proveedores = const [];
  int? _idProveedor;
  bool _cargandoProveedores = true;
  bool _guardando = false;

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    final producto = widget.producto;
    _nombre = TextEditingController(text: producto?.nombreProducto ?? '');
    _tipo = TextEditingController(text: producto?.tipo ?? '');
    _precio = TextEditingController(
      text: producto == null ? '' : producto.precio.toStringAsFixed(2),
    );
    _stock = TextEditingController(text: '${producto?.stock ?? 0}');
    _idProveedor = producto?.idProveedor;
    _cargarProveedores();
  }

  Future<void> _cargarProveedores() async {
    try {
      final lista = await context.read<Sesion>().proveedores.listarTodas();
      if (!mounted) return;
      setState(() {
        _proveedores = lista;
        _cargandoProveedores = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _cargandoProveedores = false);
      mostrarError(context, e.detail);
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _tipo.dispose();
    _precio.dispose();
    _stock.dispose();
    super.dispose();
  }

  double? _parsearPrecio(String valor) {
    final texto = valor.trim().replaceAll(',', '.');
    final precio = double.tryParse(texto);
    if (precio == null || precio <= 0) return null;
    final decimales = texto.split('.').length > 1
        ? texto.split('.').last.length
        : 0;
    if (decimales > 2) return null;
    return precio;
  }

  Future<void> _guardar() async {
    // Evita enviar dos veces la misma peticion.
    if (_guardando) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);

    final precio = _parsearPrecio(_precio.text);
    final cuerpo = <String, dynamic>{
      'nombreProducto': _nombre.text.trim(),
      'tipo': _tipo.text.trim().isEmpty ? null : _tipo.text.trim(),
      // Se envia como texto con dos decimales para que el backend reciba un
      // Decimal exacto (evita artefactos de punto flotante).
      'precio': precio?.toStringAsFixed(2),
      'stock': int.tryParse(_stock.text.trim()) ?? 0,
      'idProveedor': _idProveedor,
    };

    try {
      final sesion = context.read<Sesion>();
      if (_esEdicion) {
        await sesion.productos.actualizar(widget.producto!.idProducto, cuerpo);
      } else {
        await sesion.productos.crear(cuerpo);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      mostrarError(context, e.detail);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  /// Opciones del selector de proveedor. Si el proveedor actual no esta en la
  /// lista cargada se agrega una entrada para que el dropdown conserve el valor
  /// (Flutter exige que el valor elegido exista entre los items).
  List<DropdownMenuItem<int?>> _itemsProveedor() {
    final items = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(value: null, child: Text('Sin proveedor')),
    ];
    final List<Proveedor> restantes = [..._proveedores];
    final idActual = _idProveedor;
    if (idActual != null && !restantes.any((p) => p.idProveedor == idActual)) {
      restantes.insert(
        0,
        Proveedor(
          idProveedor: idActual,
          nombreProveedor: 'Proveedor #$idActual',
        ),
      );
    }
    for (final proveedor in restantes) {
      items.add(
        DropdownMenuItem<int?>(
          value: proveedor.idProveedor,
          child: Text(proveedor.nombreProveedor),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombre,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      prefixIcon: Icon(Icons.fastfood_outlined),
                    ),
                    validator: (valor) {
                      final texto = valor?.trim() ?? '';
                      if (texto.isEmpty) return 'El nombre es obligatorio';
                      if (texto.length > 120) return 'Maximo 120 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tipo,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      hintText: 'Ej. horneado, relleno, empaque...',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    validator: (valor) {
                      if ((valor ?? '').length > 80) {
                        return 'Maximo 80 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _precio,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Precio *',
                      hintText: 'Ej. 3500.00',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (valor) {
                      if ((valor ?? '').trim().isEmpty) {
                        return 'El precio es obligatorio';
                      }
                      if (_parsearPrecio(valor!) == null) {
                        return 'Precio no valido (maximo 2 decimales y mayor a 0)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stock,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stock *',
                      hintText: 'Unidades disponibles',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (valor) {
                      final texto = (valor ?? '').trim();
                      final cantidad = int.tryParse(texto);
                      if (texto.isEmpty) return 'El stock es obligatorio';
                      if (cantidad == null || cantidad < 0) {
                        return 'Debe ser un numero mayor o igual a 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_cargandoProveedores)
                    const LinearProgressIndicator()
                  else
                    DropdownButtonFormField<int?>(
                      initialValue: _idProveedor,
                      decoration: const InputDecoration(
                        labelText: 'Proveedor',
                        prefixIcon: Icon(Icons.local_shipping_outlined),
                      ),
                      items: _itemsProveedor(),
                      onChanged: (valor) =>
                          setState(() => _idProveedor = valor),
                    ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: _guardando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _esEdicion ? 'Guardar cambios' : 'Crear producto',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
