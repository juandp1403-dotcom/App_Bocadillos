import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/sesion.dart';
import 'rutas/rutas.dart';
import 'ui/pantallas/login_pantalla.dart';
import 'ui/pantallas/shell_pantalla.dart';
import 'ui/widgets/comunes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  final sesion = Sesion();
  await sesion.restaurar();

  runApp(
    ChangeNotifierProvider<Sesion>.value(
      value: sesion,
      child: const AppBocadillos(),
    ),
  );
}

class AppBocadillos extends StatelessWidget {
  const AppBocadillos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fabrica de Bocadillos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE65100)),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
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
