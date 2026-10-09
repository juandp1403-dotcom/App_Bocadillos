import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

typedef TokenGetter = String? Function();
typedef AccionNoAutorizado = void Function();

const _mensajeConexion =
    'No se pudo conectar con el servidor. Verifica que el backend este en ejecucion y la URL API_BASE_URL.';

/// Cliente HTTP generico para la API de la fabrica.
///
/// - Multiplataforma: no usa `dart:io`; los fallos de red llegan como
///   [http.ClientException] en Web, Android y Desktop (el paquete `http`
///   envuelve los `SocketException` nativos).
/// - Agrega `Accept` y, cuando hay cuerpo, `Content-Type: application/json`.
/// - Agrega `Authorization: Bearer <token>` cuando hay sesion.
/// - Procesa 200/201 (JSON) y 204 (sin cuerpo).
/// - Convierte 4xx/5xx en [ApiException] con `detail`, `code` y `errors`
///   del backend y notifica via [onNoAutorizado] en 401.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.obtenerToken,
    this.onNoAutorizado,
    this.tiempoLimite = const Duration(seconds: 20),
    http.Client? cliente,
  }) : _http = cliente ?? http.Client();

  final String baseUrl;
  final TokenGetter obtenerToken;
  AccionNoAutorizado? onNoAutorizado;
  final Duration tiempoLimite;

  final http.Client _http;

  Map<String, String> _cabeceras({String? token, bool conContenido = false}) {
    return <String, String>{
      'Accept': 'application/json',
      if (conContenido) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final Uri uri;
    try {
      // Barra final de la base: 'host:8000/' + '/api/...' no debe ser '//api/...'.
      final base = baseUrl.trimRight().replaceFirst(RegExp(r'/+$'), '');
      uri = Uri.parse('$base$path');
    } on FormatException {
      throw const ApiException(
        statusCode: 0,
        detail: 'La URL de la API no es valida. Revisa API_BASE_URL.',
        code: 'url_invalida',
      );
    }
    if (!uri.hasScheme || !uri.hasAuthority) {
      throw const ApiException(
        statusCode: 0,
        detail: 'La URL de la API debe incluir http:// y el host. Revisa API_BASE_URL.',
        code: 'url_invalida',
      );
    }
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: {...uri.queryParameters, ...query});
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    return _enviar('GET', _uri(path, query));
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, String>? query,
  }) {
    return _enviar('POST', _uri(path, query), body: body);
  }

  Future<dynamic> put(String path, {Object? body, Map<String, String>? query}) {
    return _enviar('PUT', _uri(path, query), body: body);
  }

  Future<dynamic> delete(String path, {Map<String, String>? query}) {
    return _enviar('DELETE', _uri(path, query));
  }

  Future<dynamic> _enviar(String metodo, Uri uri, {Object? body}) async {
    final token = obtenerToken();
    final cabeceras = _cabeceras(token: token, conContenido: body != null);
    final contenido = body == null ? null : jsonEncode(body);

    try {
      final Future<http.Response> peticion;
      switch (metodo) {
        case 'GET':
          peticion = _http.get(uri, headers: cabeceras);
        case 'POST':
          peticion = _http.post(uri, headers: cabeceras, body: contenido);
        case 'PUT':
          peticion = _http.put(uri, headers: cabeceras, body: contenido);
        case 'DELETE':
          peticion = _http.delete(uri, headers: cabeceras);
        default:
          throw ArgumentError('Metodo no soportado: $metodo');
      }
      final respuesta = await peticion.timeout(tiempoLimite);
      return _procesar(respuesta);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        statusCode: 0,
        detail:
            'El servidor tardo demasiado en responder. Verifica tu conexion.',
        code: 'tiempo_excedido',
      );
    } on http.ClientException {
      throw const ApiException(
        statusCode: 0,
        detail: _mensajeConexion,
        code: 'sin_conexion',
      );
    } on Exception {
      // Cualquier otro fallo de transporte (TLS, DNS, red) sin usar dart:io.
      throw const ApiException(
        statusCode: 0,
        detail: _mensajeConexion,
        code: 'sin_conexion',
      );
    }
  }

  dynamic _procesar(http.Response respuesta) {
    final cuerpo = _decodificar(respuesta.bodyBytes);

    if (respuesta.statusCode >= 400) {
      // Si el backend responde 5xx sin cuerpo JSON (p. ej. SQLite aun sin
      // inicializar), se da un mensaje accionable en lugar de un generico.
      final detalle = cuerpo == null && respuesta.statusCode >= 500
          ? 'El servidor respondio con un error interno '
              '(HTTP ${respuesta.statusCode}). Verifica que el backend este '
              'inicializado y tenga usuarios semilla:\n'
              '1. alembic upgrade head (crea las tablas)\n'
              '2. python seed.py (crea los usuarios)'
          : _extraerDetalle(cuerpo);
      final codigo = _extraerCodigo(cuerpo);
      final errores = cuerpo is Map<String, dynamic> && cuerpo['errors'] is List
          ? cuerpo['errors'] as List<dynamic>
          : <dynamic>[];

      if (respuesta.statusCode == 401) {
        onNoAutorizado?.call();
      }

      throw ApiException(
        statusCode: respuesta.statusCode,
        detail: detalle,
        code: codigo,
        errors: errores,
      );
    }

    if (respuesta.statusCode == 204 || cuerpo == null) return null;
    return cuerpo;
  }

  dynamic _decodificar(List<int> bytes) {
    if (bytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(bytes));
    } on FormatException {
      return null;
    }
  }

  String _extraerDetalle(dynamic cuerpo) {
    if (cuerpo is Map<String, dynamic>) {
      final detalle = cuerpo['detail'];
      if (detalle is String && detalle.isNotEmpty) return detalle;
      if (detalle is List) return _detalleDeValidacion(detalle);
      if (cuerpo['errors'] is List && (cuerpo['errors'] as List).isNotEmpty) {
        return _detalleDeErrores(cuerpo['errors'] as List<dynamic>);
      }
      return 'La solicitud no pudo procesarse.';
    }
    if (cuerpo is List) return _detalleDeValidacion(cuerpo);
    return 'La solicitud no pudo procesarse.';
  }

  /// Errores de validacion de FastAPI: `[{loc, message, type}, ...]`.
  /// El backend de este proyecto emite `message`; se acepta también `msg`
  /// (el formato crudo de FastAPI) por compatibilidad.
  String _detalleDeValidacion(List<dynamic> errores) {
    final mensajes = errores.whereType<Map<String, dynamic>>().map((e) {
      final lugar = e['loc'];
      final campo = lugar is List && lugar.length > 1 ? '${lugar.last}: ' : '';
      final detalle = e['message'] ?? e['msg'] ?? 'valor invalido';
      return '$campo$detalle';
    }).toList();
    if (mensajes.isEmpty) return 'Datos invalidos.';
    return mensajes.join('\n');
  }

  /// Errores propios del backend: `errors: [{campo, mensaje}, ...]`.
  String _detalleDeErrores(List<dynamic> errores) {
    final mensajes = errores.whereType<Map<String, dynamic>>().map((e) {
      final campo = e['campo'] ?? e['field'];
      final mensaje = e['mensaje'] ?? e['message'] ?? e['msg'] ?? e;
      return campo == null ? '$mensaje' : '$campo: $mensaje';
    }).toList();
    if (mensajes.isEmpty) return 'Datos invalidos.';
    return mensajes.join('\n');
  }

  String _extraerCodigo(dynamic cuerpo) {
    // Validacion propia de FastAPI (422): viene como lista `[{loc, msg, ...}]`.
    if (cuerpo is List) return 'validacion';
    if (cuerpo is! Map<String, dynamic>) return 'error_negocio';
    final codigo = cuerpo['code'];
    if (codigo is String && codigo.isNotEmpty) return codigo;
    if (cuerpo['detail'] is List) return 'validacion';
    return 'error_negocio';
  }
}
