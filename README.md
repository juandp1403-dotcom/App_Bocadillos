# App Bocadillos — Frontend Flutter

Aplicación de gestión para la fábrica de bocadillos (clientes, proveedores,
productos y ventas). Consumidor del backend FastAPI del proyecto
`App_fastAPI` bajo `/api`.

## Requisitos

- Flutter 3.47.6 / Dart 3.13.5 (instalado en `C:\Users\ASUS\flutter`)
- Backend corriendo en `http://localhost:8000`:

```powershell
cd C:\Users\ASUS\Documents\App_fastAPI
uvicorn app.main:app --reload --port 8000
```

## Arranque

Prepara el PATH de Flutter en cada sesión:

```powershell
$env:PATH += ";C:\Users\ASUS\flutter\bin"
cd C:\Users\ASUS\Documents\App_Bocadillos
```

### 1. Flutter Web (puerto 5173, obligatorio por CORS)

```powershell
$env:PATH += ";C:\Users\ASUS\flutter\bin"
cd C:\Users\ASUS\Documents\App_Bocadillos
flutter pub get
flutter run -d chrome --web-port 5173
```

El backend acepta CORS en `http://localhost:5173`; abre la app siempre en
**http://localhost:5173** (no `127.0.0.1:5173`, que sería otro origen).

### 2. Android Emulator (API 28+)

```powershell
flutter run -d emulator
# Equivale a definir la URL, porque el valor por defecto en Android ya es 10.0.2.2:
flutter run -d emulator --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

### 3. Dispositivo físico Android (misma red que la PC)

```powershell
flutter devices                  # copia el id del dispositivo
flutter run -d <device-id> --dart-define=API_BASE_URL=http://192.168.1.50:8000
```

Usa la IP de la PC (`ipconfig` → IPv4). El backend debe escuchar en
`0.0.0.0` o al menos aceptar conexiones locales; el celular necesita
permiso de red en el firewall.

### 4. Windows / Desktop

```powershell
flutter run -d windows
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:8000
```

### API_BASE_URL (ejemplos)

| Entorno | Ejemplo |
|---|---|
| Web / Windows / Mac (local) | `http://localhost:8000` |
| Emulador Android | `http://10.0.2.2:8000` |
| Dispositivo físico | `http://192.168.1.50:8000` (IP de la PC) |
| Servidor de la red | `http://192.168.1.20:8000` |

```powershell
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://192.168.1.50:8000
```

Sin `--dart-define` los valores por defecto son:

| Plataforma | Valor por defecto |
|---|---|
| Web | `http://localhost:8000` |
| Android (emulador) | `http://10.0.2.2:8000` |
| Windows / resto | `http://localhost:8000` |

La barra final se elimina sola (`lib/core/config.dart`).

## Comandos de verificación

```powershell
dart format lib test     # sin cambios pendientes
flutter analyze          # 0 issues
flutter test             # 26 tests
flutter build web --release
```

## Notas multiplataforma

- **Sin `dart:io`**: `ApiClient` solo usa `dart:async` + `package:http`, así
  compila igual en Web, Android y Desktop. El paquete `http` envuelve los
  `SocketException` nativos en `ClientException`, que se traduce a
  `code: sin_conexion`.
- **Timeout** de 20 s por petición → `code: tiempo_excedido`.
- **Android**: `android.permission.INTERNET` está en el manifest principal
  (también aplica a release) y `android:usesCleartextTraffic="true"` permite
  HTTP local durante el desarrollo.
- **`flutter build windows`** requiere Visual Studio con el workload C++;
  **`flutter build android`** requiere Android SDK. En este equipo solo se
  verifica con analyze/test/build web.

## Estructura

```
lib/
  core/        config (URL), api_client, api_exception, sesion (token+permisos), formato
  modelos/     Cliente, Proveedor, Producto, Venta, DetalleVenta, Pagina<T>, Usuario
  servicios/   auth_api, clientes_api, proveedores_api, productos_api, ventas_api
  rutas/       Rutas (rutas de detalle y formularios)
  ui/
    widgets/   comunes (cargando, error, vacio, paginacion, dialogos)
    pantallas/ login, shell (Drawer), inicio, clientes(+form), proveedores(+form),
               productos(+form), ventas, venta_detalle, venta_formulario
  main.dart    arranque, sesion restaurada, MaterialApp
test/
  widget_test.dart      login y modelos
  api_client_test.dart  cabeceras, 200/201/204, 401/403/404/409/422, timeout
  permisos_test.dart    destinos del Drawer por rol (ADMIN/ALMACEN/VENTAS)
```

## Rutas y vistas

| Ruta | Pantalla | Acceso |
|---|---|---|
| `/login` | `LoginPantalla` | publico |
| `/` → `ShellPantalla` | Drawer + `IndexedStack` | sesion activa |
| Inicio | `InicioPantalla` (resumenes) | todos |
| `/clientes`, `/clientes/formulario` | `ClientesPantalla`, `ClienteFormulario` | GET/POST/PUT: todos; DELETE: ADMIN |
| `/proveedores`, `/proveedores/formulario` | `ProveedoresPantalla`, `ProveedorFormulario` | ADMIN + ALMACEN |
| `/productos`, `/productos/formulario` | `ProductosPantalla`, `ProductoFormulario` | GET: todos; POST/PUT: ADMIN + ALMACEN; DELETE: ADMIN |
| `/ventas`, `/ventas/detalle`, `/ventas/nueva` | `VentasPantalla`, `VentaDetallePantalla`, `VentaFormulario` | GET/POST: ADMIN + VENTAS; DELETE: ADMIN |

## Contrato con el backend (sin cambios)

- `POST /api/auth/login {email, password}` → `{accessToken, tokenType}`
- `GET /api/auth/me` → `{idUsuario, username, email, nombre, rol, activo}`
- CRUD `/api/clientes`, `/api/proveedores`, `/api/productos`
- `GET /api/ventas`, `GET /api/ventas/{id}`, `DELETE /api/ventas/{id}`
- `POST /api/ventas` → solo `{idCliente, detalles:[{idProducto, cantidad}]}`
  (nunca subtotal, precioUnitario ni total); el servidor calcula totales y
  descuenta stock; `409 stock_insuficiente` si no alcanza.
- Listas: `?pagina=1&tamano=20` → `{items, total, pagina, tamano, paginas}`
  (`tamano` 1..100).
- JSON camelCase; `Authorization: Bearer <jwt>`; el JWT expira en 30 min →
  cualquier 401 cierra la sesion y limpia el token guardado.
- Errores: `{"detail", "code", "errors"}`; `422` de validacion de FastAPI
  llega como lista `[{loc, message, type}]` (el backend emite `message`) y se
  traduce a mensajes por campo.
- Precios decimales: se aceptan como numero o texto (`"3500.50"`); el
  formulario de producto envia el precio como texto con dos decimales.

## Roles

`ADMIN` (todo), `ALMACEN` (productos/proveedores), `VENTAS` (ventas/clientes).
El Drawer muestra solo los destinos permitidos por `Sesion` y cada pantalla
oculta los botones de crear/editar/eliminar que el rol no puede usar.
