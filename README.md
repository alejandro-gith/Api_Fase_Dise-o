# Tacomanda — contrato de API (fase de diseño)

**Proyecto académico:** Tacomanda, sistema de gestión de comandas para el restaurante Tacos Angy.

**Estado real del repositorio:** documentación y diseño. Los 16 endpoints están **especificados**, pero **no implementados ni publicados** como servicio ASP.NET Core. El archivo OpenAPI no se conecta automáticamente a MySQL y por sí solo no permite procesar peticiones del frontend.

## 1. ¿Qué es la API y por qué se necesita?

Tacomanda divide su aplicación en dos componentes: un **frontend Angular**, que presenta las pantallas para administrador, mesero, cajero y cocina, y un **backend ASP.NET Core**, que deberá aplicar las reglas del restaurante y consultar o modificar la base de datos.

La API REST será el **contrato de comunicación** entre ambos. Angular enviará solicitudes HTTP y datos JSON; el backend validará datos, permisos y procesos como registrar una comanda, cambiar su estado o efectuar un cobro. Las operaciones que requieren identidad utilizarán un token **JWT**. De esta forma, la interfaz no accede directamente a las tablas de MySQL.

En esta fase se documenta **qué rutas existirán, qué reciben, qué responden y qué errores contemplan**, de acuerdo con el punto **13. Diseño de API** de la guía de Diseño de Software. La programación de controllers, handlers, repositorios y conexión real con la base de datos corresponde a la fase de implementación.

## 2. Contenido del repositorio

```text
Tacomanda/
├── README.md
├── index.html                          # Página estática informativa (GitHub Pages)
├── .gitignore                          # Excluye archivos sensibles y temporales
├── docs/
│   ├── swagger.json                    # Contrato OpenAPI 3.0.3 (16 operaciones)
│   ├── flujos-cqrs-crc.pdf             # PDF original del proyecto (referencia)
│   ├── flujos-cqrs-crc_bn.docx         # Flujos y 56 tarjetas CRC, Times New Roman
│   ├── flujos-cqrs-crc_bn.pdf          # Mismos flujos, edición blanco y negro
│   ├── Documento_API_Tacomanda.docx    # Informe académico editable
│   ├── Documento_API_Tacomanda.pdf     # Informe académico para consulta
│   └── OBSERVACIONES_DEL_DISENO.md    # Diferencias y validaciones pendientes
└── database/
    ├── schema.sql                     # 10 tablas + datos iniciales
    └── seed-empleados.sql             # 3 empleados de prueba
```

> **Importante:** en este repositorio no hay `Tacomanda.sln`, `src/` ni un servidor HTTP ejecutable. La página `index.html` es documentación estática; no hace llamadas a MySQL ni sustituye al backend.

## 3. Cómo visualizar `swagger.json` paso a paso

**Opción A: Swagger Editor (recomendada para la revisión docente).**

1. Abre <https://editor.swagger.io/> en tu navegador.
2. Descarga el archivo [`docs/swagger.json`](docs/swagger.json) desde este repositorio (en GitHub, abre el archivo y usa **Download raw file**).
3. En Swagger Editor, entra a **File → Import file** y selecciona `swagger.json`.
4. Se mostrarán los grupos **Auth, Platillos, Mesas, Comandas, Cobros, Cierre de caja y Retroalimentación**.
5. Expande un endpoint para consultar **método**, **ruta**, parámetros, **Request body**, **Responses** y esquemas JSON.
6. Para revisar los modelos de datos, busca **Schemas** en la interfaz de Swagger.

**Opción B: visualizar como página web en GitHub Pages.**

1. Sube el repositorio completo a GitHub y mantenlo público, si tu profesora necesita consultarlo sin iniciar sesión.
2. Ve a **Settings → Pages** del repositorio. En **Build and deployment**, selecciona **Deploy from a branch**.
3. Elige la rama `main` y la carpeta `/(root)`, y guarda la configuración.
4. GitHub Pages publicará el archivo `index.html` como una página informativa con las rutas y enlaces a los archivos. La dirección tendrá el formato `https://TU-USUARIO.github.io/Tacomanda/`.
5. Para explorar los esquemas y respuestas detallados, sigue utilizando Swagger Editor con `docs/swagger.json`. La página pública no ejecuta la API.

**¿Se puede utilizar “Try it out”?** La especificación declara `http://localhost:5000` como URL de desarrollo **de referencia**, no un servidor disponible. Sin un backend ASP.NET Core ejecutándose, las operaciones de Swagger son solo documentación; las solicitudes reales fallarán.

## 4. Endpoints del contrato

| Método | Ruta | Propósito |
|:--|:--|:--|
| `POST` | `/api/auth/login` | Iniciar sesión |
| `GET` | `/api/platillos` | Listar platillos |
| `POST` | `/api/platillos` | Crear platillo |
| `PUT` | `/api/platillos/{id}` | Actualizar platillo |
| `DELETE` | `/api/platillos/{id}` | Eliminar platillo |
| `GET` | `/api/mesas` | Listar mesas |
| `GET` | `/api/comandas` | Listar comandas |
| `POST` | `/api/comandas` | Enviar comanda |
| `GET` | `/api/comandas/{id}` | Obtener una comanda |
| `PUT` | `/api/comandas/{id}/estado` | Avanzar el estado de una comanda |
| `POST` | `/api/comandas/{id}/cobrar` | Cobrar una comanda |
| `GET` | `/api/pedidos/{id}/ticket` | Obtener el ticket de un cobro |
| `GET` | `/api/cierre-caja` | Historial de cierres de caja |
| `POST` | `/api/cierre-caja` | Registrar cierre de caja |
| `GET` | `/api/retroalimentacion` | Historial de calificaciones de la app |
| `POST` | `/api/retroalimentacion` | Calificar la app |

**Total:** 16 operaciones HTTP agrupadas en 7 áreas funcionales. `GET /api/comandas` acepta el filtro opcional `?estado=abierta`, por ejemplo.

## 5. Ejemplos de datos de entrada (solo contrato, no ejecución)

**Inicio de sesión** — `POST /api/auth/login`:
```json
{"noControl": "1", "contrasena": "admin123"}
```
Si las credenciales se validaran correctamente en una implementación real, respondería con un objeto `LoginResponse` que incluye `token`, `noControl`, `nombre`, `rol` y `permisos`.

**Registrar una comanda** — `POST /api/comandas`:
```json
{"mesaNumero": 3, "items": [{"idPlatillo": 1, "cantidad": 2, "nota": "Sin cebolla"}]}
```
El servidor deberá obtener el identificador del mesero a partir del JWT, consultar los precios reales y calcular los subtotales. **No se envían precios ni número de control** en este cuerpo JSON.

**Seguridad** — salvo `POST /api/auth/login`, las rutas documentadas requieren la cabecera `Authorization: Bearer <token>`. La matriz completa de permisos por rol y las respuestas `403 Forbidden` aún deben definirse en el contrato antes de implementar.

## 6. Base de datos de diseño

El archivo [`database/schema.sql`](database/schema.sql) define **10 tablas**: `empleados`, `mesas`, `platillos`, `productos`, `platillo_producto`, `comandas`, `detalle_comanda`, `pedidos`, `encuestas_cierre`, `retroalimentacion_app`. También incluye datos iniciales de mesas, productos, platillos y relaciones.

Para crearla en un entorno **local de desarrollo** con MySQL 8 o posterior:
1. Abre **MySQL Workbench** y conéctate a tu servidor local.
2. Ejecuta primero `database/schema.sql` (crea y selecciona la base `tacomanda`).
3. Ejecuta después `database/seed-empleados.sql` (crea tres usuarios de **prueba**, si las claves aún no existen).
4. Comprueba los registros con `USE tacomanda; SHOW TABLES; SELECT no_control, nombre, tipo_empleado FROM empleados;`.

| Número de control | Rol | Clave ficticia de desarrollo |
|:--|:--|:--|
| 1 | admin | `admin123` |
| 2 | mesero | `mesero123` |
| 3 | cajero | `cajero123` |

Las contraseñas se almacenan como hashes BCrypt en el script SQL, pero las claves **son públicas y deliberadamente débiles**: **no deben reutilizarse en producción**. El repositorio **no publica credenciales reales ni cadenas de conexión**. Si cambias el nombre de la BD, modifica `CREATE DATABASE`/`USE` en `schema.sql` y `USE` en `seed-empleados.sql`.

## 7. Arquitectura prevista para la implementación

```text
Angular (features, core, shared)
        ↓ solicitudes HTTP/JSON y token JWT
ASP.NET Core API (Controllers y Middleware)
        ↓ comandos o consultas
Application (Validators, Commands, Queries, Handlers)
        ↓ contratos
Domain (entidades, reglas e interfaces)
        ↑ implementaciones proporcionadas por Infrastructure
Infrastructure (EF Core, repositorios, BCrypt, JWT)
        ↓
MySQL
```
Se planea utilizar **Clean Architecture, CQRS y SOLID**. En comandos, el flujo conceptual será `Controller → Command → Validator → Handler → Repository`; las consultas usarán `Query → Handler → Reader/Repository`. Las reglas de negocio y el acceso a datos deberán implementarse después.

## 8. Diferencias detectadas y pendientes de decisión

Este paquete mantiene los archivos originales de Swagger, SQL y flujos para conservar sus evidencias y añade una versión académica en blanco y negro de los flujos. Antes de desarrollar el backend es necesario revisar:

- **Identidad en comandos:** el PDF CRC previo incluye el número de control en el cuerpo de algunas peticiones; `swagger.json` dispone que se obtenga del JWT. **El contrato Swagger es la referencia propuesta para la integración**.
- **Cierre de caja:** `CierreCajaRequest` aún recibe `totalSistema` desde el cliente; conviene que la versión final lo calcule en el servidor. Esta modificación **no se aplicó al contrato original**.
- **Autorización:** Swagger declara autenticación JWT, pero aún no documenta una matriz completa de autorización por rol ni respuestas `403` de cada operación.
- **Cocina:** hay una interfaz de cocina, mientras que las cuentas de empleados descritas en el SQL son `admin`, `mesero` y `cajero`. La política de acceso de cocina sigue por acordarse.
- **Ejecución:** falta programar controllers, validadores, handlers, repositorios, integración MySQL, pruebas y despliegue.

Ver también [`docs/OBSERVACIONES_DEL_DISENO.md`](docs/OBSERVACIONES_DEL_DISENO.md).

## 9. Publicar en GitHub y entregar el enlace

Crea un repositorio público **vacío**, por ejemplo `Tacomanda` (no agregues README o licencia desde el formulario porque ya vienen aquí). Descomprime este paquete, entra a la carpeta `Tacomanda/` y ejecuta:
```bash
git init
git add .
git commit -m "Fase de diseño: contrato OpenAPI y documentación"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/Tacomanda.git
git push -u origin main
```
Cambia `TU-USUARIO` por tu usuario real de GitHub. Verifica el repositorio en una ventana de incógnito y entrega su URL; si habilitas GitHub Pages, puedes incluir también la URL de la página estática.

## 10. ¿Qué se puede afirmar en la entrega?

**Sí:** “Se diseñó y documentó una API REST en OpenAPI 3.0.3, con 16 operaciones, esquemas JSON, códigos de respuesta y autenticación JWT, además del modelo de datos y flujos CQRS/CRC”.

**Todavía no:** “La API está desplegada, los controladores funcionan y Angular ya puede consumir las rutas”. Eso solo se podrá afirmar cuando exista el backend y se prueben las peticiones reales.
