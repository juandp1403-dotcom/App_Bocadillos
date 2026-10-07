/// Modelos de datos que devuelve la API (JSON en camelCase).
library;

double _aDouble(dynamic valor) {
  if (valor is num) return valor.toDouble();
  return double.tryParse('$valor') ?? 0;
}

int _aInt(dynamic valor) {
  if (valor is int) return valor;
  if (valor is num) return valor.toInt();
  return int.tryParse('$valor') ?? 0;
}

Map<String, dynamic> _mapa(dynamic valor) {
  return valor is Map<String, dynamic> ? valor : <String, dynamic>{};
}

class Pagina<T> {
  const Pagina({
    required this.items,
    required this.total,
    required this.pagina,
    required this.tamano,
    required this.paginas,
  });

  factory Pagina.fromJson(
    dynamic json,
    T Function(Map<String, dynamic>) desdeJson,
  ) {
    final mapa = _mapa(json);
    final items = (mapa['items'] as List<dynamic>? ?? const [])
        .map((e) => desdeJson(_mapa(e)))
        .toList();
    return Pagina(
      items: items,
      total: _aInt(mapa['total']),
      pagina: _aInt(mapa['pagina']),
      tamano: _aInt(mapa['tamano']),
      paginas: _aInt(mapa['paginas']),
    );
  }

  final List<T> items;
  final int total;
  final int pagina;
  final int tamano;
  final int paginas;
}

class Usuario {
  const Usuario({
    required this.idUsuario,
    required this.username,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.activo,
  });

  factory Usuario.fromJson(dynamic json) {
    final mapa = _mapa(json);
    return Usuario(
      idUsuario: _aInt(mapa['idUsuario']),
      username: '${mapa['username'] ?? ''}',
      email: '${mapa['email'] ?? ''}',
      nombre: '${mapa['nombre'] ?? ''}',
      rol: '${mapa['rol'] ?? ''}',
      activo: mapa['activo'] as bool? ?? true,
    );
  }

  final int idUsuario;
  final String username;
  final String email;
  final String nombre;
  final String rol;
  final bool activo;
}

class Cliente {
  const Cliente({
    required this.idCliente,
    required this.nombreCliente,
    this.telefono,
    this.correo,
    this.direccion,
  });

  factory Cliente.fromJson(dynamic json) {
    final mapa = _mapa(json);
    return Cliente(
      idCliente: _aInt(mapa['idCliente']),
      nombreCliente: '${mapa['nombreCliente'] ?? ''}',
      telefono: mapa['telefono'] as String?,
      correo: mapa['correo'] as String?,
      direccion: mapa['direccion'] as String?,
    );
  }

  final int idCliente;
  final String nombreCliente;
  final String? telefono;
  final String? correo;
  final String? direccion;
}

class Proveedor {
  const Proveedor({
    required this.idProveedor,
    required this.nombreProveedor,
    this.telefonoProveedor,
    this.correoProveedor,
    this.direccionProveedor,
  });

  factory Proveedor.fromJson(dynamic json) {
    final mapa = _mapa(json);
    return Proveedor(
      idProveedor: _aInt(mapa['idProveedor']),
      nombreProveedor: '${mapa['nombreProveedor'] ?? ''}',
      telefonoProveedor: mapa['telefonoProveedor'] as String?,
      correoProveedor: mapa['correoProveedor'] as String?,
      direccionProveedor: mapa['direccionProveedor'] as String?,
    );
  }

  final int idProveedor;
  final String nombreProveedor;
  final String? telefonoProveedor;
  final String? correoProveedor;
  final String? direccionProveedor;
}

class Producto {
  const Producto({
    required this.idProducto,
    required this.nombreProducto,
    required this.precio,
    required this.stock,
    this.tipo,
    this.idProveedor,
  });

  factory Producto.fromJson(dynamic json) {
    final mapa = _mapa(json);
    return Producto(
      idProducto: _aInt(mapa['idProducto']),
      nombreProducto: '${mapa['nombreProducto'] ?? ''}',
      tipo: mapa['tipo'] as String?,
      precio: _aDouble(mapa['precio']),
      stock: _aInt(mapa['stock']),
      idProveedor: mapa['idProveedor'] == null
          ? null
          : _aInt(mapa['idProveedor']),
    );
  }

  final int idProducto;
  final String nombreProducto;
  final String? tipo;
  final double precio;
  final int stock;
  final int? idProveedor;
}

class DetalleVenta {
  const DetalleVenta({
    required this.idDetalle,
    required this.idVenta,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetalleVenta.fromJson(dynamic json) {
    final mapa = _mapa(json);
    return DetalleVenta(
      idDetalle: _aInt(mapa['idDetalle']),
      idVenta: _aInt(mapa['idVenta']),
      idProducto: _aInt(mapa['idProducto']),
      cantidad: _aInt(mapa['cantidad']),
      precioUnitario: _aDouble(mapa['precioUnitario']),
      subtotal: _aDouble(mapa['subtotal']),
    );
  }

  final int idDetalle;
  final int idVenta;
  final int idProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
}

class Venta {
  const Venta({
    required this.idVenta,
    required this.fecha,
    required this.total,
    required this.idCliente,
    this.detalles = const [],
  });

  factory Venta.fromJson(dynamic json) {
    final mapa = _mapa(json);
    return Venta(
      idVenta: _aInt(mapa['idVenta']),
      fecha: DateTime.tryParse('${mapa['fecha'] ?? ''}') ?? DateTime.now(),
      total: _aDouble(mapa['total']),
      idCliente: _aInt(mapa['idCliente']),
      detalles: (mapa['detalles'] as List<dynamic>? ?? const [])
          .map((e) => DetalleVenta.fromJson(_mapa(e)))
          .toList(),
    );
  }

  final int idVenta;
  final DateTime fecha;
  final double total;
  final int idCliente;
  final List<DetalleVenta> detalles;
}
