import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/sesion.dart';
import '../../modelos/modelos.dart';
import '../widgets/comunes.dart';

/// Formulario para crear o editar un proveedor.
class ProveedorFormulario extends StatefulWidget {
  const ProveedorFormulario({super.key, this.proveedor});

  final Proveedor? proveedor;

  @override
  State<ProveedorFormulario> createState() => _ProveedorFormularioState();
}

class _ProveedorFormularioState extends State<ProveedorFormulario> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late final TextEditingController _correo;
  late final TextEditingController _direccion;
  bool _guardando = false;

  bool get _esEdicion => widget.proveedor != null;

  @override
  void initState() {
    super.initState();
    final proveedor = widget.proveedor;
    _nombre = TextEditingController(text: proveedor?.nombreProveedor ?? '');
    _telefono = TextEditingController(text: proveedor?.telefonoProveedor ?? '');
    _correo = TextEditingController(text: proveedor?.correoProveedor ?? '');
    _direccion = TextEditingController(
      text: proveedor?.direccionProveedor ?? '',
    );
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _correo.dispose();
    _direccion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);

    final cuerpo = <String, dynamic>{
      'nombreProveedor': _nombre.text.trim(),
      'telefonoProveedor': _telefono.text.trim().isEmpty
          ? null
          : _telefono.text.trim(),
      'correoProveedor': _correo.text.trim().isEmpty
          ? null
          : _correo.text.trim(),
      'direccionProveedor': _direccion.text.trim().isEmpty
          ? null
          : _direccion.text.trim(),
    };

    try {
      final sesion = context.read<Sesion>();
      if (_esEdicion) {
        await sesion.proveedores.actualizar(
          widget.proveedor!.idProveedor,
          cuerpo,
        );
      } else {
        await sesion.proveedores.crear(cuerpo);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar proveedor' : 'Nuevo proveedor'),
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
                      prefixIcon: Icon(Icons.factory_outlined),
                    ),
                    validator: (valor) {
                      final texto = valor?.trim() ?? '';
                      if (texto.isEmpty) return 'El nombre es obligatorio';
                      if (texto.length > 100) return 'Maximo 100 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telefono,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefono',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (valor) {
                      if ((valor ?? '').length > 30) {
                        return 'Maximo 30 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _correo,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: (valor) {
                      final texto = valor?.trim() ?? '';
                      if (texto.isEmpty) return null;
                      final valido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(texto);
                      if (!valido) return 'Correo no valido';
                      if (texto.length > 150) return 'Maximo 150 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _direccion,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Direccion',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (valor) {
                      if ((valor ?? '').length > 200) {
                        return 'Maximo 200 caracteres';
                      }
                      return null;
                    },
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
                      _esEdicion ? 'Guardar cambios' : 'Crear proveedor',
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
