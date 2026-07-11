# Historia Clínica Dental — App Flutter

Esqueleto funcional de una app Android/iOS (Flutter) que digitaliza el
formulario de historia clínica odontológica (SNS-MSP HCU-form 001, 033 y 024):
admisión, historia clínica, odontograma, plan de tratamiento, sesiones,
historial de pagos y consentimiento informado.

## Cómo abrirlo

1. Instala Flutter (https://docs.flutter.dev/get-started/install).
2. Descomprime este proyecto y entra a la carpeta:
   ```
   cd dental_history_app
   flutter pub get
   ```
3. Conecta tu tablet Android (con depuración USB activada) o usa un emulador:
   ```
   flutter run
   ```
4. Para generar el APK instalable:
   ```
   flutter build apk --release
   ```
   El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`.

## Cómo está resuelto lo que pediste

- **Formulario dinámico**: cada sección del papel (admisión, antecedentes,
  signos vitales, examen, etc.) es una pestaña independiente que se guarda
  sola en SQLite (`lib/db/database_helper.dart`), así que se puede llenar en
  cualquier orden, en varias visitas, y crecer con nuevos campos fácilmente
  (agregar una columna a la tabla + un campo en el modelo + un `TextField`).
- **Lápiz o teclado**:
  - Los campos de texto normales (nombre, dirección, motivo de consulta,
    etc.) ya aceptan tanto teclado como escritura a mano con stylus, porque
    Android convierte la escritura a texto automáticamente sobre cualquier
    `TextField` (Scribble/reconocimiento de escritura del sistema) en
    tablets compatibles (Samsung S Pen, Android 14 Scribble, etc.). No hace
    falta código adicional para eso.
  - El **odontograma** (`lib/widgets/odontogram_widget.dart`) y las
    **firmas** (`lib/widgets/signature_pad.dart`) sí necesitan trazo real,
    así que usan `Listener` + `CustomPaint`, que captura directamente los
    eventos de puntero del lápiz (con soporte de presión) y permite dibujar
    encima del diagrama, además de la opción de marcar con símbolos
    tocando cada pieza dental.
- **Guardado local + sincronización opcional**: todo se guarda primero en
  SQLite local (`sqflite`), funciona 100% sin internet. El archivo
  `lib/services/sync_service.dart` es el punto de extensión para conectar
  Firebase/Firestore u otro backend propio cuando quieras activar
  sincronización entre dispositivos — está dejado como stub con instrucciones.

## Estructura

```
lib/
  models/models.dart          # Paciente, historia clínica, odontograma, etc.
  db/database_helper.dart     # SQLite local (offline-first)
  services/sync_service.dart  # Sincronización opcional a la nube
  widgets/
    odontogram_widget.dart    # Odontograma interactivo (toque + lápiz)
    signature_pad.dart        # Firma digital reutilizable
  screens/
    home_screen.dart          # Lista/búsqueda de pacientes
    patient_detail_screen.dart# Pestañas de la ficha del paciente
    tabs/                     # Una pantalla por sección del formulario
```

## Configurar Supabase (autenticación + almacenamiento en la nube)

1. Crea un proyecto gratis en https://supabase.com
2. En el SQL Editor del proyecto, pega y ejecuta `supabase_schema.sql`
   (incluido en la raíz de este repo) — crea las tablas y las políticas de
   seguridad (cada usuario ve solo sus propios pacientes).
3. En Settings → API copia tu **Project URL** y **anon public key**.
4. Corre la app pasando esas credenciales sin dejarlas escritas en el código:
   ```
   flutter run --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
               --dart-define=SUPABASE_ANON_KEY=tu-anon-key
   ```
5. Al abrir la app verás una pantalla de login. Puedes "Crear cuenta",
   "Iniciar sesión", o "Continuar sin cuenta" para seguir usando la app
   100% local como hasta ahora.
6. Activa `SupabaseService.instance.syncEnabled = true` (por ejemplo desde
   una pantalla de Ajustes que agregues) para que cada guardado también
   suba los datos a Supabase.

## Siguientes pasos sugeridos

1. **Exportar a PDF** con el mismo diseño del formulario original (ya se
   incluyó el paquete `pdf`/`printing` en `pubspec.yaml` para esto).
2. **Piezas deciduales** (55-51/61-65/85-81/71-75): el odontograma ya está
   preparado para agregarlas, solo falta sumar esas listas de números y
   otra fila en `odontogram_widget.dart`.
3. **Autenticación/roles** (odontólogo, admisionista) si varias personas
   van a usar la app.
4. **Activar sincronización real** siguiendo las instrucciones dentro de
   `sync_service.dart` (Firebase es la opción más rápida de integrar).
5. Ajustar las provincias/cantones/parroquias de Ecuador como listas
   desplegables en vez de texto libre, si quieres evitar errores de tipeo.

Este es un punto de partida sólido y funcional, no un producto terminado:
cubre la arquitectura completa y las partes más difíciles (odontograma con
lápiz, firmas, base de datos), y deja las pantallas restantes con el mismo
patrón para que sea fácil seguir extendiéndolas.
