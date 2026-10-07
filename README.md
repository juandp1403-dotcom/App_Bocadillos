# App Bocadillos — Frontend Flutter

Aplicación de gestión para la fábrica de bocadillos (clientes, proveedores,
productos y ventas). Consumidor del backend FastAPI del proyecto
`App_fastAPI` bajo `/api`.

## Requisitos

- Flutter 3.47.6 / Dart 3.13.5 (instalado en `C:\Users\ASUS\flutter`)
- Backend corriendo en `http://localhost:8000` (`uvicorn app.main:app --reload`)

## Ejecutar

```powershell
$env:PATH += ";C:\Users\ASUS\flutter\bin"
cd C:\Users\ASUS\Documents\App_Bocadillos

# Web (la única plataforma soportada sin Android SDK/Visual Studio)
flutter run -d chrome --web-port 5173
```

El backend acepta CORS en `http://localhost:5173`; por eso el puerto 5173.

### URL del API (`API_BASE_URL`)

| Plataforma | Valor por defecto | Cómo cambiarlo |
|---|---|---|
| Android | `http://10.0.2.2:8000` | `flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000` |
| Web / Desktop | `http://localhost:8000` | `flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000` |

- Android: el emulador accede al host como `10.0.2.2`; un móvil real requiere
  la IP de la PC en la misma red. `AndroidManifest.xml` ya incluye
  `android:usesCleartextTraffic="true"` para HTTP.
- Web: también sirve con `flutter build web` y servir `build/web`.

## Comandos de verificación

```powershell
dart format lib test
flutter analyze        # 0 issues
flutter test           # 5 tests
flutter build web --release
```

## Estructura

```
lib/
  core/        config (URL), api_client, api_exception, sesion (token+permisos), formato
  modelos/     Cliente, Proveedor, Producto, Venta, DetalleVenta, Pagina<T>, Usuario
  servicios/   auth_api, clientes_api, proveedores_api, productos_api, ventas_api
  rutas/       Rutas (rutas de detalle y formularios)
  ui/
    widgets/   comunes (cargando, error, vacío, paginación, diálogos)
    pantallas/ login, shell (Drawer), inicio, clientes(+form), proveedores(+form),
               productos(+form), ventas, venta_detalle, venta_formulario
  main.dart    arranque, sesión restaurada, MaterialApp
test/widget_test.dart   login + modelos
```

## Rutas y vistas

| Ruta | Pantalla | Acceso |
|---|---|---|
| `/login` | `LoginPantalla` | público |
| `/` → `ShellPantalla` | Drawer + `IndexedStack` | sesión activa |
| Inicio | `InicioPantalla` (resúmenes) | todos |
| `/clientes`, `/clientes/nuevo`, `/clientes/editar/{id}` | `ClientesPantalla`, `ClienteFormulario` | GET/POST/PUT: todos; DELETE: ADMIN |
| `/proveedores`, `/proveedores/nuevo`, `/proveedores/editar/{id}` | `ProveedoresPantalla`, `ProveedorFormulario` | ADMIN + ALMACEN |
| `/productos`, `/productos/nuevo`, `/productos/editar/{id}` | `ProductosPantalla`, `ProductoFormulario` | GET: todos; POST/PUT: ADMIN + ALMACEN; DELETE: ADMIN |
| `/ventas`, `/ventas/detalle/{id}`, `/ventas/nueva` | `VentasPantalla`, `VentaDetallePantalla`, `VentaFormulario` | GET/POST: ADMIN + VENTAS; DELETE: ADMIN |

## API usada

- `POST /api/auth/login {email, password}` → `{accessToken, tokenType}`
- `GET /api/auth/me`
- CRUD `/api/clientes`, `/api/proveedores`, `/api/productos`
- `GET /api/ventas` (lista), `GET /api/ventas/{id}` (detalle), `POST /api/ventas`
  `{idCliente, detalles:[{idProducto, cantidad}]}` → el servidor calcula
  subtotal/total y descuenta stock (409 si stock insuficiente)
- Listas: query `?pagina=1&tamano=20` → `{items,total,pagina,tamano,paginas}`
- JSON camelCase; token `Authorization: Bearer <jwt>`; expira en 30 min → 401 cierra sesión
- Errores: `{"detail","code","errors"}`

## Roles

`ADMIN` (todo), `ALMACEN` (productos/proveedores), `VENTAS` (ventas/clientes).
El Drawer muestra solo los destinos permitidos por `Sesion`.
