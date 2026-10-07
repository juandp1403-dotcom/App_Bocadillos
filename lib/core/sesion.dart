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
  Sesion({ApiClient? api}) {
    this.api =
        api ??
        ApiClient(
          baseUrl: AppConfig.apiBaseUrl,
          obtenerToken: () => token,
          onNoAutorizado: _sesionExpiro,
        );
    this.api.onNoAutorizado = _sesionExpiro;
  }

  late final ApiClient api;
  SharedPreferences? _prefsCache;

  String? token;

  /// Esquema devuelto por el login ("bearer"); el encabezado Authorization
  /// usa "Bearer" (RFC 6750, la comparacion del backend no distingue mayusculas).
  String tipoToken = 'bearer';
  Usuario? usuario;
  bool cargandoSesion = true;
  String? avisoSesion;

  AuthApi get auth => AuthApi(api);
  ClientesApi get clientes => ClientesApi(api);
  ProveedoresApi get proveedores => ProveedoresApi(api);
  ProductosApi get productos => ProductosApi(api);
  VentasApi get ventas => VentasApi(api);

  bool get autenticado => usuario != null && token != null;

  Future<SharedPreferences> _preferencias() async {
    return _prefsCache ??= await SharedPreferences.getInstance();
  }

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

  /// Ventas: visibles y registrables solo para ADMIN y VENTAS.
  bool get puedeVerVentas => esAdmin || esVentas;

  // ------------------------------------------------------------------ acciones
  Future<void> restaurar() async {
    final prefs = await _preferencias();
    final guardado = prefs.getString(_claveToken);
    if (guardado != null && guardado.isNotEmpty) {
      token = guardado;
      try {
        usuario = await auth.miPerfil();
      } on ApiException catch (e) {
        if (e.esNoAutorizado) {
          // Token vencido o invalido: se descarta.
          token = null;
          await prefs.remove(_claveToken);
        } else {
          // Backend caido o sin conexion: se conserva el token para la
          // proxima vez y solo se avisa al usuario.
          avisoSesion = e.detail;
        }
      }
    }
    cargandoSesion = false;
    notifyListeners();
  }

  Future<void> iniciarSesion(String email, String password) async {
    final sesionToken = await auth.login(email, password);
    final prefs = await _preferencias();
    token = sesionToken.accessToken;
    tipoToken = sesionToken.tokenType;
    await prefs.setString(_claveToken, sesionToken.accessToken);
    usuario = await auth.miPerfil();
    avisoSesion = null;
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    token = null;
    tipoToken = 'bearer';
    usuario = null;
    avisoSesion = null;
    final prefs = await _preferencias();
    await prefs.remove(_claveToken);
    notifyListeners();
  }

  /// El backend respondio 401: la sesion no es valida.
  void _sesionExpiro() {
    if (token == null) return;
    token = null;
    tipoToken = 'bearer';
    usuario = null;
    avisoSesion = 'Tu sesion expiro. Vuelve a iniciar sesion.';
    final prefs = _prefsCache;
    if (prefs != null) prefs.remove(_claveToken);
    notifyListeners();
  }
}
