import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formato.dart';
import '../../core/sesion.dart';
import '../../rutas/rutas.dart';
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

/// Estructura principal con cajon de navegacion y pestanas.
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

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<Sesion>();
    final destinos = _destinos(sesion);
    if (_indice >= destinos.length) _indice = 0;
    final actual = destinos[_indice];
    final usuario = sesion.usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text(actual.titulo),
        actions: [
          PopupMenuButton<String>(
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
                      style: Theme.of(context).textTheme.bodySmall,
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
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(usuario?.nombre ?? ''),
              accountEmail: Text(usuario?.email ?? ''),
              currentAccountPicture: CircleAvatar(
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
      body: IndexedStack(
        index: _indice,
        children: destinos.map((d) => d.pantalla).toList(),
      ),
    );
  }
}
