import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/sesion.dart';
import '../../modelos/modelos.dart';
import '../widgets/comunes.dart';

/// Formulario para crear o editar un cliente.
class ClienteFormulario extends StatefulWidget {
  const ClienteFormulario({super.key, this.cliente});

  final Cliente? cliente;

  @override
  State<ClienteFormulario> createState() => _ClienteFormularioState();
}

class _ClienteFormularioState extends State<ClienteFormulario> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late final TextEditingController _correo;
  late final TextEditingController _direccion;
  bool _guardando = false;

  bool get _esEdicion => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    final cliente = widget.cliente;
    _nombre = TextEditingController(text: cliente?.nombreCliente ?? '');
    _telefono = TextEditingController(text: cliente?.telefono ?? '');
    _correo = TextEditingController(text: cliente?.correo ?? '');
    _direccion = TextEditingController(text: cliente?.direccion ?? '');
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
    // Evita enviar dos veces la misma peticion.
    if (_guardando) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);

    final cuerpo = <String, dynamic>{
      'nombreCliente': _nombre.text.trim(),
      'telefono': _telefono.text.trim().isEmpty ? null : _telefono.text.trim(),
      'correo': _correo.text.trim().isEmpty ? null : _correo.text.trim(),
      'direccion': _direccion.text.trim().isEmpty
          ? null
          : _direccion.text.trim(),
    };

    try {
      final sesion = context.read<Sesion>();
      if (_esEdicion) {
        await sesion.clientes.actualizar(widget.cliente!.idCliente, cuerpo);
      } else {
        await sesion.clientes.crear(cuerpo);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {});
      mostrarError(context, e.detail);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar cliente' : 'Nuevo cliente'),
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
                      prefixIcon: Icon(Icons.person_outline),
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
                      final texto = valor?.trim() ?? '';
                      if (texto.length > 30) return 'Maximo 30 caracteres';
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
                      _esEdicion ? 'Guardar cambios' : 'Crear cliente',
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
