import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

typedef TokenGetter = String? Function();
typedef AccionNoAutorizado = void Function();

/// Cliente HTTP generico para la API de la fabrica.
///
/// - Agrega `Authorization: Bearer <token>` cuando hay sesion.
/// - Convierte los errores 4xx/5xx en [ApiException] con el mensaje del backend.
/// - Notifica via [onNoAutorizado] cuando el token expira (401).
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.obtenerToken,
    this.onNoAutorizado,
  });

  final String baseUrl;
  final TokenGetter obtenerToken;
  AccionNoAutorizado? onNoAutorizado;

  final http.Client _http = http.Client();

  Map<String, String> _cabeceras({String? token}) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$baseUrl$path');
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
    final cabeceras = _cabeceras(token: token);
    final contenido = body == null ? null : jsonEncode(body);

    try {
      final http.Response respuesta;
      switch (metodo) {
        case 'GET':
          respuesta = await _http.get(uri, headers: cabeceras);
        case 'POST':
          respuesta = await _http.post(
            uri,
            headers: cabeceras,
            body: contenido,
          );
        case 'PUT':
          respuesta = await _http.put(uri, headers: cabeceras, body: contenido);
        case 'DELETE':
          respuesta = await _http.delete(uri, headers: cabeceras);
        default:
          throw ArgumentError('Metodo no soportado: $metodo');
      }
      return _procesar(respuesta);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        detail: 'No se pudo conectar con el servidor. Verifica que el backend este en ejecucion.',
        code: 'sin_conexion',
      );
    } on http.ClientException {
      throw const ApiException(
        statusCode: 0,
        detail: 'No se pudo conectar con el servidor. Verifica que el backend este en ejecucion.',
        code: 'sin_conexion',
      );
    }
  }

  dynamic _procesar(http.Response respuesta) {
    final cuerpo = _decodificar(respuesta.bodyBytes);

    if (respuesta.statusCode >= 400) {
      final detalle = _extraerDetalle(cuerpo);
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
      return 'La solicitud no pudo procesarse.';
    }
    if (cuerpo is List) return _detalleDeValidacion(cuerpo);
    return 'La solicitud no pudo procesarse.';
  }

  String _detalleDeValidacion(List<dynamic> errores) {
    final mensajes = errores.whereType<Map<String, dynamic>>().map((e) {
      final lugar = e['loc'];
      final campo = lugar is List && lugar.length > 1 ? '${lugar.last}: ' : '';
      return '$campo${e['msg'] ?? 'valor invalido'}';
    }).toList();
    if (mensajes.isEmpty) return 'Datos invalidos.';
    return mensajes.join('\n');
  }

  String _extraerCodigo(dynamic cuerpo) {
    if (cuerpo is Map<String, dynamic> && cuerpo['code'] is String) {
      return cuerpo['code'] as String;
    }
    return 'error_negocio';
  }
}
