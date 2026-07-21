import '../db/database_helper.dart';

/// Sincronización OPCIONAL. La app funciona 100% offline sin esto.
/// Cuando el usuario activa "Sincronizar" en Ajustes, este servicio
/// sube las filas marcadas como dirty=1 a un backend (Firestore, REST propio,
/// etc.) y descarga cambios remotos.
///
/// Para activarlo con Firebase:
///  1. flutter pub add firebase_core cloud_firestore
///  2. Descomenta las dependencias en pubspec.yaml
///  3. Ejecuta `flutterfire configure`
///  4. Implementa _pushTable / _pullRemoteChanges usando FirebaseFirestore.instance
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  bool syncEnabled = false; // controlado desde pantalla de Ajustes

  Future<void> syncNow() async {
    if (!syncEnabled) return;
    final dirty = await DatabaseHelper.instance.getDirtyRows();

    for (final entry in dirty.entries) {
      final table = entry.key;
      final rows = entry.value;
      for (final row in rows) {
        await _pushRow(table, row);
        await DatabaseHelper.instance.markClean(table, row['id']);
      }
    }
    await _pullRemoteChanges();
  }

  Future<void> _pushRow(String table, Map<String, dynamic> row) async {
    // TODO: reemplazar por escritura real en Firestore/REST API.
    // Ejemplo con Firestore:
    // await FirebaseFirestore.instance.collection(table).doc(row['id']).set(row);
  }

  Future<void> _pullRemoteChanges() async {
    // TODO: descargar cambios remotos más nuevos y hacer upsert local.
  }
}
