import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/sesion.dart';
import '../../theme/app_colors.dart';

class LoginPantalla extends StatefulWidget {
  const LoginPantalla({super.key});

  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  bool _enviando = false;
  bool _ocultarClave = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final sesion = context.read<Sesion>();
    _error = sesion.avisoSesion;
    sesion.avisoSesion = null;
  }

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await context.read<Sesion>().iniciarSesion(
        _correo.text.trim(),
        _clave.text,
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.detail);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo iniciar sesion. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Widget _marca(ThemeData tema) => Container(
    color: AppColors.rojo,
    padding: const EdgeInsets.all(32),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.spa, color: Colors.white, size: 48),
          const SizedBox(height: 20),
          Text(
            'DOÑA VÉLEZ',
            style: tema.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'FÁBRICA ARTESANAL · VÉLEZ SANTANDER',
            style: tema.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'El sabor de la guayaba, hecho con tradición.',
            style: tema.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _formulario(ThemeData tema) => Card(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bienvenido a la fábrica',
              style: tema.textTheme.headlineSmall,
            ),
            Text(
              'Ingresa para gestionar inventario y ventas.',
              style: tema.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Correo electronico',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: (valor) {
                final texto = valor?.trim() ?? '';
                if (texto.isEmpty) return 'Ingresa tu correo';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(texto)) {
                  return 'Correo no valido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clave,
              obscureText: _ocultarClave,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Contrasena',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _ocultarClave
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _ocultarClave = !_ocultarClave),
                ),
              ),
              validator: (valor) {
                if ((valor ?? '').isEmpty) return 'Ingresa tu contrasena';
                if (valor!.length < 6) return 'Minimo 6 caracteres';
                return null;
              },
              onFieldSubmitted: (_) => _ingresar(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: tema.colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _enviando ? null : _ingresar,
              child: _enviando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('INGRESAR A LA FÁBRICA'),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return ListView(
              children: [
                _marca(tema),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _formulario(tema),
                ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: Center(child: _marca(tema))),
              Expanded(
                flex: 6,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: _formulario(tema),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
