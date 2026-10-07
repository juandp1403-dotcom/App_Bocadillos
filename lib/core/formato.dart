import 'package:intl/intl.dart';

/// Formatea un valor monetario en pesos colombianos.
String dinero(num valor) {
  return NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 2,
  ).format(valor);
}

/// Formatea una fecha/hora legible (dd/MM/yyyy HH:mm).
String fechaHora(DateTime fecha) {
  return DateFormat('dd/MM/yyyy HH:mm').format(fecha.toLocal());
}

/// Nombre amigable del rol del usuario.
String nombreRol(String rol) {
  switch (rol) {
    case 'ADMIN':
      return 'Administrador';
    case 'ALMACEN':
      return 'Almacen';
    case 'VENTAS':
      return 'Ventas';
    default:
      return rol;
  }
}
