# Observaciones y acuerdos técnicos pendientes

Documento de revisión del diseño. No acredita que exista una API ejecutable.

1. **Fuente del número de control:** el contrato `swagger.json` indica que la identidad del operador se toma del token JWT y no de los cuerpos de creación de comanda, cobro, cierre y retroalimentación. Algunas descripciones anteriores del PDF `flujos-cqrs-crc.pdf` todavía incluyen `noControl` en el comando; al implementar se deberá mantener una única regla.
2. **Cierre de caja:** el esquema `CierreCajaRequest` conserva `totalSistema` como entrada. Se recomienda que el backend lo calcule desde los pedidos cerrados. No se alteró el JSON proporcionado.
3. **Permisos:** el contrato exige JWT en todas las rutas salvo login, pero no incluye reglas exhaustivas por rol ni códigos 403 en las respuestas. Incorporarlos cuando se apruebe la matriz de permisos.
4. **Cocina:** el diseño contiene una pantalla para cocina, aunque la BD solo contempla roles `mesero`, `cajero` y `admin`. Definir si cocina usará un rol nuevo o una política de acceso distinta.
5. **Infraestructura y pruebas:** no se puede utilizar `Try it out` contra los 16 endpoints sin ejecutar el backend ASP.NET Core correspondiente. El `localhost:5000` es ilustrativo.
6. **Seguridad de credenciales:** los hashes BCrypt pertenecen a usuarios públicos de prueba y no justifican usar sus claves en producción.

Estado: decisiones **pendientes de validación con el equipo y el responsable del restaurante**.
