import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/modelos.dart';
import '../servicios/auth_api.dart';
import '../servicios/clientes_api.dart';
import '../servicios/productos_api.dart';
import '../servicios/proveedores_api.dart';
import '../servicios/ventas_api.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'config.dart';

const _claveToken = 'token_fabrica';

/// Sesion de la aplicacion: token JWT, usuario autenticado y permisos por rol.
class Sesion extends ChangeNotifier {
  Sesion() {
    api = ApiClient(
      baseUrl: AppConfig.apiBaseUrl,
      obtenerToken: () => token,
      onNoAutorizado: _sesionExpiro,
    );
  }

  late final ApiClient api;
  late final SharedPreferences _prefs;

  String? token;
  Usuario? usuario;
  bool cargandoSesion = true;
  String? avisoSesion;

  AuthApi get auth => AuthApi(api);
  ClientesApi get clientes => ClientesApi(api);
  ProveedoresApi get proveedores => ProveedoresApi(api);
  ProductosApi get productos => ProductosApi(api);
  VentasApi get ventas => VentasApi(api);

  bool get autenticado => usuario != null && token != null;

  // ---------------------------------------------------------------- permisos
  String get rol => usuario?.rol ?? '';
  bool get esAdmin => rol == 'ADMIN';
  bool get esAlmacen => rol == 'ALMACEN';
  bool get esVentas => rol == 'VENTAS';

  /// Clientes: lectura y escritura para todos los roles; borrar solo ADMIN.
  bool get puedeEditarClientes => autenticado;
  bool get puedeBorrar => esAdmin;

  /// Productos: lectura para todos; crear/editar ADMIN y ALMACEN.
  bool get puedeEditarProductos => esAdmin || esAlmacen;

  /// Proveedores: visibles solo para ADMIN y ALMACEN.
  bool get puedeVerProveedores => esAdmin || esAlmacen;

  /// Ventas: visibles para ADMIN y VENTAS.
  bool get puedeVerVentas => esAdmin || esVentas;

  // ------------------------------------------------------------------ acciones
  Future<void> restaurar() async {
    _prefs = await SharedPreferences.getInstance();
    final guardado = _prefs.getString(_claveToken);
    if (guardado != null && guardado.isNotEmpty) {
      token = guardado;
      try {
        usuario = await auth.miPerfil();
      } on ApiException catch (e) {
        if (!e.esNoAutorizado) avisoSesion = e.detail;
        token = null;
        await _prefs.remove(_claveToken);
      }
    }
    cargandoSesion = false;
    notifyListeners();
  }

  Future<void> iniciarSesion(String email, String password) async {
    final accessToken = await auth.login(email, password);
    token = accessToken;
    await _prefs.setString(_claveToken, accessToken);
    usuario = await auth.miPerfil();
    avisoSesion = null;
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    token = null;
    usuario = null;
    await _prefs.remove(_claveToken);
    notifyListeners();
  }

  void _sesionExpiro() {
    if (!autenticado) return;
    token = null;
    usuario = null;
    avisoSesion = 'Tu sesion expiro. Vuelve a iniciar sesion.';
    notifyListeners();
  }
}
