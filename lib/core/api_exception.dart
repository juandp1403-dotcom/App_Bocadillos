/// Error que devuelve la API ({"detail", "code", "errors"}).
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.detail,
    this.code = 'error_negocio',
    this.errors = const [],
  });

  final int statusCode;
  final String detail;
  final String code;
  final List<dynamic> errors;

  bool get esNoAutorizado => statusCode == 401;
  bool get esSinPermiso => statusCode == 403;
  bool get esNoEncontrado => statusCode == 404;
  bool get esConflicto => statusCode == 409;

  @override
  String toString() => detail;
}
