import 'package:flutter/material.dart';

/// Pantalla de carga centrada.
Widget panelCargando([String texto = 'Cargando...']) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 12),
        Text(texto),
      ],
    ),
  );
}

/// Pantalla de error con boton de reintento.
Widget panelError(String texto, {VoidCallback? reintento}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(texto, textAlign: TextAlign.center),
          if (reintento != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: reintento,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Pantalla sin registros.
Widget panelVacio(String texto, {IconData icono = Icons.inbox_outlined}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(texto, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

/// Muestra un mensaje de error en un SnackBar.
void mostrarError(BuildContext context, String texto) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

/// Muestra un mensaje de exito en un SnackBar.
void mostrarExito(BuildContext context, String texto) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

/// Dialogo de confirmacion. Devuelve true si el usuario acepta.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String aceptar = 'Aceptar',
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(aceptar),
        ),
      ],
    ),
  );
  return resultado ?? false;
}

/// Pie de paginacion estandar de los listados.
class BarraPaginacion extends StatelessWidget {
  const BarraPaginacion({
    super.key,
    required this.pagina,
    required this.paginas,
    required this.total,
    this.onAnterior,
    this.onSiguiente,
  });

  final int pagina;
  final int paginas;
  final int total;
  final VoidCallback? onAnterior;
  final VoidCallback? onSiguiente;

  @override
  Widget build(BuildContext context) {
    final limite = paginas < 1 ? 1 : paginas;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Pagina anterior',
              onPressed: pagina > 1 ? onAnterior : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                'Pagina $pagina de $limite  |  $total registros',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            IconButton(
              tooltip: 'Pagina siguiente',
              onPressed: pagina < limite ? onSiguiente : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}
