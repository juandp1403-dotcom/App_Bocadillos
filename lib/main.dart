import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/sesion.dart';
import 'rutas/rutas.dart';
import 'theme/app_theme.dart';
import 'ui/pantallas/login_pantalla.dart';
import 'ui/pantallas/shell_pantalla.dart';
import 'ui/widgets/comunes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  final sesion = Sesion();
  runApp(
    ChangeNotifierProvider<Sesion>.value(
      value: sesion,
      child: const AppBocadillos(),
    ),
  );
  // Se restaura el token despues de arrancar la interfaz para no bloquear el
  // primer pintado (si el backend no responde la app igual carga el login).
  await sesion.restaurar();
}

class AppBocadillos extends StatelessWidget {
  const AppBocadillos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fabrica de Bocadillos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      onGenerateRoute: Rutas.generarRuta,
      home: Consumer<Sesion>(
        builder: (context, sesion, _) {
          if (sesion.cargandoSesion) {
            return const Scaffold(body: PanelCargandoSesion());
          }
          if (!sesion.autenticado) {
            return const LoginPantalla();
          }
          return const ShellPantalla();
        },
      ),
    );
  }
}

class PanelCargandoSesion extends StatelessWidget {
  const PanelCargandoSesion({super.key});

  @override
  Widget build(BuildContext context) {
    return panelCargando('Preparando la aplicacion...');
  }
}
