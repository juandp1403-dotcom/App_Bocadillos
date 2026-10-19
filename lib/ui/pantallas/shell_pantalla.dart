import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formato.dart';
import '../../core/sesion.dart';
import '../../modelos/modelos.dart';
import '../../rutas/rutas.dart';
import '../../theme/app_colors.dart';
import '../widgets/comunes.dart';
import 'clientes_pantalla.dart';
import 'inicio_pantalla.dart';
import 'productos_pantalla.dart';
import 'proveedores_pantalla.dart';
import 'ventas_pantalla.dart';

class _Destino {
  const _Destino(this.ruta, this.icono, this.titulo, this.pantalla);

  final String ruta;
  final IconData icono;
  final String titulo;
  final Widget pantalla;
}

/// Estructura principal: NavigationRail en pantallas amplias (tablet y
/// desktop) y BottomNavigationBar en movil, con el contenido centrado.
class ShellPantalla extends StatefulWidget {
  const ShellPantalla({super.key});

  @override
  State<ShellPantalla> createState() => _ShellPantallaState();
}

class _ShellPantallaState extends State<ShellPantalla> {
  int _indice = 0;

  List<_Destino> _destinos(Sesion sesion) {
    final destinos = <_Destino>[
      _Destino(
        Rutas.inicio,
        Icons.storefront_outlined,
        'Inicio',
        const InicioPantalla(),
      ),
      _Destino(
        Rutas.clientes,
        Icons.people_outline,
        'Clientes',
        const ClientesPantalla(),
      ),
      _Destino(
        Rutas.productos,
        Icons.inventory_2_outlined,
        'Productos',
        const ProductosPantalla(),
      ),
    ];
    if (sesion.puedeVerProveedores) {
      destinos.add(
        _Destino(
          Rutas.proveedores,
          Icons.local_shipping_outlined,
          'Proveedores',
          const ProveedoresPantalla(),
        ),
      );
    }
    if (sesion.puedeVerVentas) {
      destinos.add(
        _Destino(
          Rutas.ventas,
          Icons.receipt_long_outlined,
          'Ventas',
          const VentasPantalla(),
        ),
      );
    }
    return destinos;
  }

  Future<void> _cerrarSesion() async {
    final salir = await confirmar(
      context,
      titulo: 'Cerrar sesion',
      mensaje: 'Deseas salir de la aplicacion?',
      aceptar: 'Cerrar sesion',
    );
    if (salir && mounted) {
      await context.read<Sesion>().cerrarSesion();
    }
  }

  Widget _menuCuenta(Usuario? usuario) {
    return PopupMenuButton<String>(
      tooltip: 'Cuenta',
      onSelected: (valor) {
        if (valor == 'salir') _cerrarSesion();
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usuario?.nombre ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(usuario?.email ?? ''),
              Text(
                nombreRol(usuario?.rol ?? ''),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.cafeSuave),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'salir',
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar sesion'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      icon: const Icon(Icons.account_circle_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<Sesion>();
    final destinos = _destinos(sesion);
    if (_indice >= destinos.length) _indice = 0;
    final actual = destinos[_indice];
    final usuario = sesion.usuario;
    final ancho = MediaQuery.sizeOf(context).width;
    // En pantallas amplias se usa NavigationRail; en movil, barra inferior.
    final usaRail = ancho >= 900;

    final contenido = IndexedStack(
      index: _indice,
      children: destinos.map((d) => d.pantalla).toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'DOÑA VÉLEZ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.guayaba,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (ancho >= 560) ...[
              const SizedBox(width: 12),
              Container(width: 1, height: 20, color: AppColors.borde),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  actual.titulo.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.cafeSuave,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [_menuCuenta(usuario)],
      ),
      drawer: usaRail
          ? null
          : Drawer(
              backgroundColor: AppColors.superficie,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.guayaba, AppColors.rojo],
                      ),
                    ),
                    accountName: Text(usuario?.nombre ?? ''),
                    accountEmail: Text(usuario?.email ?? ''),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.guayaba,
                      child: Text(
                        (usuario?.nombre.isNotEmpty ?? false)
                            ? usuario!.nombre[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    otherAccountsPictures: [
                      Center(
                        child: Tooltip(
                          message: nombreRol(usuario?.rol ?? ''),
                          child: Chip(
                            label: Text(
                              nombreRol(usuario?.rol ?? ''),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (var i = 0; i < destinos.length; i++)
                    ListTile(
                      leading: Icon(destinos[i].icono),
                      title: Text(destinos[i].titulo),
                      selected: _indice == i,
                      selectedTileColor: AppColors.guayabaSuave,
                      selectedColor: AppColors.guayaba,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        setState(() => _indice = i);
                        Navigator.of(context).pop();
                      },
                    ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Cerrar sesion'),
                    onTap: _cerrarSesion,
                  ),
                ],
              ),
            ),
      body: usaRail
          ? Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: _indice,
                    onDestinationSelected: (i) => setState(() => _indice = i),
                    extended: ancho >= 1200,
                    backgroundColor: AppColors.superficie,
                    indicatorColor: AppColors.guayabaSuave,
                    selectedIconTheme: const IconThemeData(
                      color: AppColors.guayaba,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: AppColors.cafe.withValues(alpha: 0.5),
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      color: AppColors.guayaba,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: AppColors.cafeSuave,
                      fontWeight: FontWeight.w500,
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Icon(
                        Icons.spa_outlined,
                        color: AppColors.guayaba,
                        size: 30,
                      ),
                    ),
                    trailing: Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: IconButton(
                            tooltip: 'Cerrar sesion',
                            onPressed: _cerrarSesion,
                            icon: const Icon(Icons.logout),
                          ),
                        ),
                      ),
                    ),
                    destinations: [
                      for (final d in destinos)
                        NavigationRailDestination(
                          icon: Icon(d.icono),
                          selectedIcon: Icon(d.icono),
                          label: Text(d.titulo),
                        ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: contenido),
              ],
            )
          : SafeArea(top: false, child: contenido),
      bottomNavigationBar: usaRail
          ? null
          : BottomNavigationBar(
              currentIndex: _indice,
              onTap: (i) => setState(() => _indice = i),
              items: [
                for (final d in destinos)
                  BottomNavigationBarItem(icon: Icon(d.icono), label: d.titulo),
              ],
            ),
    );
  }
}
