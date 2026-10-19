import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Pantalla de carga centrada.
Widget panelCargando([String texto = 'Cargando...']) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 12),
        Text(texto, style: TextStyle(color: AppColors.cafeSuave)),
      ],
    ),
  );
}

/// Pantalla de error con boton de reintento.
Widget panelError(String texto, {VoidCallback? reintento}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.rojoSuave,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.rojo,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.cafe),
            ),
            if (reintento != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: reintento,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Pantalla sin registros.
Widget panelVacio(String texto, {IconData icono = Icons.inbox_outlined}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.guayabaSuave,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 40, color: AppColors.guayaba),
            ),
            const SizedBox(height: 16),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.cafeSuave),
            ),
          ],
        ),
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
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(texto)),
          ],
        ),
        backgroundColor: AppColors.rojo,
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
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(texto)),
          ],
        ),
        backgroundColor: AppColors.verde,
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
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Text(mensaje),
      ),
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

/// Ancho maximo del contenido centrado en pantallas grandes.
const double kAnchoMaximoContenido = 1100;

/// Centra el contenido y limita su ancho para que en desktop no quede
/// estirado de borde a borde.
class ContenidoCentrado extends StatelessWidget {
  const ContenidoCentrado({
    super.key,
    required this.child,
    this.anchoMaximo = kAnchoMaximoContenido,
    this.relleno = const EdgeInsets.all(16),
  });

  final Widget child;
  final double anchoMaximo;
  final EdgeInsetsGeometry relleno;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: anchoMaximo),
        child: Padding(padding: relleno, child: child),
      ),
    );
  }
}

/// Columnas de cuadricula segun el ancho disponible.
int columnasAdaptativas(
  double ancho, {
  double compacto = 380,
  double mediano = 620,
  double amplio = 900,
  double muyAmplio = 1200,
}) {
  if (ancho >= muyAmplio) return 5;
  if (ancho >= amplio) return 4;
  if (ancho >= mediano) return 3;
  if (ancho >= compacto) return 2;
  return 1;
}

/// Cuadricula responsiva de tarjetas: 1 columna en móvil, varias en
/// tablet/desktop, sin desbordes gracias a [SliverGridDelegateWithMaxCrossAxisExtent].
class CuadriculaAdaptativa extends StatelessWidget {
  const CuadriculaAdaptativa({
    super.key,
    required this.items,
    required this.tarjeta,
    this.relleno = const EdgeInsets.all(16),
    this.espaciado = 16,
    this.altoTarjeta = 160,
    this.anchoMaximo = kAnchoMaximoContenido,
  });

  final List<Widget> items;
  final Widget Function(BuildContext, int) tarjeta;
  final EdgeInsetsGeometry relleno;
  final double espaciado;
  final double altoTarjeta;
  final double anchoMaximo;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: anchoMaximo),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columnas = columnasAdaptativas(constraints.maxWidth);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: relleno,
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnas,
                crossAxisSpacing: espaciado,
                mainAxisSpacing: espaciado,
                mainAxisExtent: altoTarjeta,
              ),
              itemBuilder: tarjeta,
            );
          },
        ),
      ),
    );
  }
}

/// Formulario centrado y responsivo: una columna en movil y dos en
/// escritorio, con ancho maximo para mantener la comodidad de lectura.
class FormularioAdaptativo extends StatelessWidget {
  const FormularioAdaptativo({
    super.key,
    required this.campos,
    required this.accion,
    this.anchoMaximo = 720,
  });

  /// Campos del formulario. En pantallas anchas se disponen de a dos por
  /// fila para aprovechar el espacio horizontal.
  final List<Widget> campos;

  /// Boton principal al final del formulario.
  final Widget accion;

  final double anchoMaximo;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: anchoMaximo),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, restricciones) {
                final dosColumnas = restricciones.maxWidth >= 640;
                final gap = const SizedBox(height: 16);
                final filas = <Widget>[];
                for (var i = 0; i < campos.length; i++) {
                  if (dosColumnas && i.isEven && i + 1 < campos.length) {
                    filas.add(
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: campos[i]),
                          const SizedBox(width: 16),
                          Expanded(child: campos[i + 1]),
                        ],
                      ),
                    );
                    filas.add(gap);
                    i++;
                  } else {
                    filas.add(campos[i]);
                    filas.add(gap);
                  }
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [...filas, accion],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
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
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.cafeSuave),
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
