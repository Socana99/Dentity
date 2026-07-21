import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

/// Capa única de acceso a la base de datos local.
/// Toda la app trabaja "offline-first": se lee/escribe aquí siempre,
/// y el SyncService (services/sync_service.dart) se encarga de replicar
/// los cambios a la nube cuando el usuario activa sincronización.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dental_history.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE patients (
            id TEXT PRIMARY KEY,
            institucion TEXT, unidadOperativa TEXT, codUo TEXT,
            parroquia TEXT, canton TEXT, provincia TEXT,
            numeroHistoriaClinica TEXT,
            apellidoPaterno TEXT, apellidoMaterno TEXT,
            primerNombre TEXT, segundoNombre TEXT, cedula TEXT,
            direccion TEXT, barrio TEXT, zona TEXT, telefono TEXT,
            fechaNacimiento TEXT, lugarNacimiento TEXT, nacionalidad TEXT,
            grupoCultural TEXT, edad INTEGER, sexo TEXT, estadoCivil TEXT,
            instruccion TEXT, fechaAdmision TEXT, ocupacion TEXT,
            empresa TEXT, tipoSeguro TEXT, referidoDe TEXT,
            contactoEmergenciaNombre TEXT, contactoEmergenciaParentesco TEXT,
            contactoEmergenciaDireccion TEXT, contactoEmergenciaTelefono TEXT,
            dirty INTEGER DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE clinical_history (
            id TEXT PRIMARY KEY, patientId TEXT,
            motivoConsulta TEXT, enfermedadActual TEXT,
            antecedentes TEXT, antecedentesDetalle TEXT,
            presionArterial TEXT, frecuenciaCardiaca TEXT,
            temperatura TEXT, frecuenciaRespiratoria TEXT,
            examenEstomatognatico TEXT, dirty INTEGER DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE tooth_marks (
            id TEXT PRIMARY KEY, patientId TEXT, toothNumber INTEGER,
            surface TEXT, symbol TEXT, movilidad INTEGER, recesion INTEGER,
            color TEXT, freehandStrokes TEXT, dirty INTEGER DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE treatment_plan (
            id TEXT PRIMARY KEY, patientId TEXT, diagnostico TEXT,
            detalle TEXT, piezas TEXT, costo REAL, dirty INTEGER DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE treatment_sessions (
            id TEXT PRIMARY KEY, patientId TEXT, numeroSesion INTEGER,
            fecha TEXT, diagnosticosComplicaciones TEXT, procedimientos TEXT,
            prescripciones TEXT, profesionalCodigo TEXT, dirty INTEGER DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE payments (
            id TEXT PRIMARY KEY, patientId TEXT, fecha TEXT,
            tratamientoRealizado TEXT, debe REAL, haber REAL, saldo REAL,
            dirty INTEGER DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE consents (
            id TEXT PRIMARY KEY, patientId TEXT, propositos TEXT,
            terapiaProcedimientos TEXT, resultadosEsperados TEXT, riesgos TEXT,
            profesionalNombre TEXT, itemsAceptados TEXT,
            firmaPacienteBase64Png TEXT, firmaProfesionalBase64Png TEXT,
            fecha TEXT, dirty INTEGER DEFAULT 1
          )
        ''');
      },
    );
  }

  // ---------------- PATIENTS ----------------
  Future<void> upsertPatient(Patient p) async {
    final db = await database;
    await db.insert('patients', p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Patient>> getPatients({String? query}) async {
    final db = await database;
    final rows = query == null || query.isEmpty
        ? await db.query('patients', orderBy: 'apellidoPaterno')
        : await db.query('patients',
            where:
                'apellidoPaterno LIKE ? OR apellidoMaterno LIKE ? OR cedula LIKE ? OR numeroHistoriaClinica LIKE ?',
            whereArgs: List.filled(4, '%$query%'));
    return rows.map((m) => Patient.fromMap(m)).toList();
  }

  Future<Patient?> getPatient(String id) async {
    final db = await database;
    final rows = await db.query('patients', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Patient.fromMap(rows.first);
  }

  /// Elimina al paciente y todo lo asociado a él (historia clínica,
  /// odontograma, plan de tratamiento, sesiones, pagos, consentimientos)
  /// para no dejar registros huérfanos en el resto de tablas.
  Future<void> deletePatient(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final table in [
        'clinical_history',
        'tooth_marks',
        'treatment_plan',
        'treatment_sessions',
        'payments',
        'consents',
      ]) {
        await txn.delete(table, where: 'patientId = ?', whereArgs: [id]);
      }
      await txn.delete('patients', where: 'id = ?', whereArgs: [id]);
    });
  }

  // ---------------- CLINICAL HISTORY ----------------
  Future<void> upsertClinicalHistory(ClinicalHistory h) async {
    final db = await database;
    await db.insert('clinical_history', h.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<ClinicalHistory?> getClinicalHistory(String patientId) async {
    final db = await database;
    final rows = await db.query('clinical_history',
        where: 'patientId = ?', whereArgs: [patientId]);
    return rows.isEmpty ? null : ClinicalHistory.fromMap(rows.first);
  }

  // ---------------- ODONTOGRAM ----------------
  Future<void> upsertToothMark(ToothMark t) async {
    final db = await database;
    await db.insert('tooth_marks', t.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ToothMark>> getToothMarks(String patientId) async {
    final db = await database;
    final rows = await db
        .query('tooth_marks', where: 'patientId = ?', whereArgs: [patientId]);
    return rows.map((m) => ToothMark.fromMap(m)).toList();
  }

  // ---------------- TREATMENT PLAN ----------------
  Future<void> upsertTreatmentPlanItem(TreatmentPlanItem t) async {
    final db = await database;
    await db.insert('treatment_plan', t.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TreatmentPlanItem>> getTreatmentPlan(String patientId) async {
    final db = await database;
    final rows = await db.query('treatment_plan',
        where: 'patientId = ?', whereArgs: [patientId]);
    return rows.map((m) => TreatmentPlanItem.fromMap(m)).toList();
  }

  // ---------------- SESSIONS ----------------
  Future<void> upsertSession(TreatmentSession s) async {
    final db = await database;
    await db.insert('treatment_sessions', s.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TreatmentSession>> getSessions(String patientId) async {
    final db = await database;
    final rows = await db.query('treatment_sessions',
        where: 'patientId = ?',
        whereArgs: [patientId],
        orderBy: 'numeroSesion');
    return rows.map((m) => TreatmentSession.fromMap(m)).toList();
  }

  // ---------------- PAYMENTS ----------------
  Future<void> upsertPayment(PaymentRecord p) async {
    final db = await database;
    await db.insert('payments', p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PaymentRecord>> getPayments(String patientId) async {
    final db = await database;
    final rows = await db.query('payments',
        where: 'patientId = ?', whereArgs: [patientId], orderBy: 'fecha');
    return rows.map((m) => PaymentRecord.fromMap(m)).toList();
  }

  // ---------------- CONSENTS ----------------
  Future<void> upsertConsent(ConsentRecord c) async {
    final db = await database;
    await db.insert('consents', c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ConsentRecord>> getConsents(String patientId) async {
    final db = await database;
    final rows = await db.query('consents',
        where: 'patientId = ?', whereArgs: [patientId], orderBy: 'fecha');
    return rows.map((m) => ConsentRecord.fromMap(m)).toList();
  }

  /// Devuelve todas las filas marcadas dirty=1 en todas las tablas,
  /// usado por SyncService para saber qué subir a la nube.
  Future<Map<String, List<Map<String, dynamic>>>> getDirtyRows() async {
    final db = await database;
    final tables = [
      'patients',
      'clinical_history',
      'tooth_marks',
      'treatment_plan',
      'treatment_sessions',
      'payments',
      'consents'
    ];
    final result = <String, List<Map<String, dynamic>>>{};
    for (final t in tables) {
      result[t] = await db.query(t, where: 'dirty = 1');
    }
    return result;
  }

  Future<void> markClean(String table, String id) async {
    final db = await database;
    await db.update(table, {'dirty': 0}, where: 'id = ?', whereArgs: [id]);
  }
}
