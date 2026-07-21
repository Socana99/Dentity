import 'package:supabase_flutter/supabase_flutter.dart';
import '../db/database_helper.dart';

/// Todo el acceso a Supabase pasa por aquí: autenticación y sincronización
/// de las tablas locales (SQLite) hacia Postgres en Supabase.
///
/// CONFIGURACIÓN (una sola vez):
/// 1. Crea un proyecto en https://supabase.com
/// 2. Copia tu Project URL y anon key (Settings > API)
/// 3. Reemplázalos abajo en `supabaseUrl` / `supabaseAnonKey`
///    (o mejor, pásalos por --dart-define para no subirlos al repo)
/// 4. Corre el script `supabase_schema.sql` (incluido en la raíz del
///    proyecto) en el SQL Editor de Supabase para crear las tablas y las
///    políticas de RLS (cada usuario solo ve sus propios pacientes).
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://TU-PROYECTO.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'TU-ANON-KEY',
  );

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // ---------------- AUTENTICACIÓN ----------------
  User? get currentUser => client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<void> signUp(String email, String password) async {
    await client.auth.signUp(email: email, password: password);
  }

  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => client.auth.signOut();

  // ---------------- SINCRONIZACIÓN ----------------
  bool syncEnabled = false;

  final _tables = [
    'patients', 'clinical_history', 'tooth_marks',
    'treatment_plan', 'treatment_sessions', 'payments', 'consents',
  ];

  /// Sube todas las filas marcadas dirty=1 y luego descarga cambios
  /// remotos más nuevos que los datos locales. Se recomienda llamarlo
  /// al abrir la app, al guardar cada formulario, y con un botón manual
  /// "Sincronizar ahora" en Ajustes.
  Future<void> syncNow() async {
    if (!syncEnabled || !isLoggedIn) return;
    final uid = currentUser!.id;
    final dirty = await DatabaseHelper.instance.getDirtyRows();

    for (final table in _tables) {
      final rows = dirty[table] ?? [];
      for (final row in rows) {
        final payload = Map<String, dynamic>.from(row)
          ..remove('dirty')
          ..['user_id'] = uid; // cada fila queda asociada al usuario dueño
        await client.from(table).upsert(payload);
        await DatabaseHelper.instance.markClean(table, row['id']);
      }
    }
    // La descarga de cambios remotos (por ejemplo si el mismo profesional
    // usa dos tablets) se puede añadir aquí con:
    // final remoteRows = await client.from(table).select().eq('user_id', uid);
    // ...upsert local con DatabaseHelper para cada fila descargada.
  }
}
