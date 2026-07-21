import 'dart:convert';

/// ---------------------------------------------------------------------
/// PACIENTE + REGISTRO DE PRIMERA ADMISIÓN (hoja 001)
/// ---------------------------------------------------------------------
class Patient {
  final String id; // uuid
  String institucion;
  String unidadOperativa;
  String codUo;
  String parroquia;
  String canton;
  String provincia;
  String numeroHistoriaClinica;

  String apellidoPaterno;
  String apellidoMaterno;
  String primerNombre;
  String segundoNombre;
  String cedula;

  String direccion;
  String barrio;
  String zona; // U / R
  String telefono;

  DateTime? fechaNacimiento;
  String lugarNacimiento;
  String nacionalidad;
  String grupoCultural;
  int edad;
  String sexo; // M / F
  String estadoCivil; // SOL, CAS, DIV, VIU, U-L
  String instruccion;

  DateTime fechaAdmision;
  String ocupacion;
  String empresa;
  String tipoSeguro;
  String referidoDe;

  String contactoEmergenciaNombre;
  String contactoEmergenciaParentesco;
  String contactoEmergenciaDireccion;
  String contactoEmergenciaTelefono;

  Patient({
    required this.id,
    this.institucion = '',
    this.unidadOperativa = '',
    this.codUo = '',
    this.parroquia = '',
    this.canton = '',
    this.provincia = '',
    this.numeroHistoriaClinica = '',
    this.apellidoPaterno = '',
    this.apellidoMaterno = '',
    this.primerNombre = '',
    this.segundoNombre = '',
    this.cedula = '',
    this.direccion = '',
    this.barrio = '',
    this.zona = 'U',
    this.telefono = '',
    this.fechaNacimiento,
    this.lugarNacimiento = '',
    this.nacionalidad = 'Ecuatoriana',
    this.grupoCultural = '',
    this.edad = 0,
    this.sexo = 'F',
    this.estadoCivil = 'SOL',
    this.instruccion = '',
    DateTime? fechaAdmision,
    this.ocupacion = '',
    this.empresa = '',
    this.tipoSeguro = '',
    this.referidoDe = '',
    this.contactoEmergenciaNombre = '',
    this.contactoEmergenciaParentesco = '',
    this.contactoEmergenciaDireccion = '',
    this.contactoEmergenciaTelefono = '',
  }) : fechaAdmision = fechaAdmision ?? DateTime.now();

  String get nombreCompleto =>
      '$apellidoPaterno $apellidoMaterno $primerNombre $segundoNombre'.trim();

  Map<String, dynamic> toMap() => {
        'id': id,
        'institucion': institucion,
        'unidadOperativa': unidadOperativa,
        'codUo': codUo,
        'parroquia': parroquia,
        'canton': canton,
        'provincia': provincia,
        'numeroHistoriaClinica': numeroHistoriaClinica,
        'apellidoPaterno': apellidoPaterno,
        'apellidoMaterno': apellidoMaterno,
        'primerNombre': primerNombre,
        'segundoNombre': segundoNombre,
        'cedula': cedula,
        'direccion': direccion,
        'barrio': barrio,
        'zona': zona,
        'telefono': telefono,
        'fechaNacimiento': fechaNacimiento?.toIso8601String(),
        'lugarNacimiento': lugarNacimiento,
        'nacionalidad': nacionalidad,
        'grupoCultural': grupoCultural,
        'edad': edad,
        'sexo': sexo,
        'estadoCivil': estadoCivil,
        'instruccion': instruccion,
        'fechaAdmision': fechaAdmision.toIso8601String(),
        'ocupacion': ocupacion,
        'empresa': empresa,
        'tipoSeguro': tipoSeguro,
        'referidoDe': referidoDe,
        'contactoEmergenciaNombre': contactoEmergenciaNombre,
        'contactoEmergenciaParentesco': contactoEmergenciaParentesco,
        'contactoEmergenciaDireccion': contactoEmergenciaDireccion,
        'contactoEmergenciaTelefono': contactoEmergenciaTelefono,
      };

  factory Patient.fromMap(Map<String, dynamic> m) => Patient(
        id: m['id'],
        institucion: m['institucion'] ?? '',
        unidadOperativa: m['unidadOperativa'] ?? '',
        codUo: m['codUo'] ?? '',
        parroquia: m['parroquia'] ?? '',
        canton: m['canton'] ?? '',
        provincia: m['provincia'] ?? '',
        numeroHistoriaClinica: m['numeroHistoriaClinica'] ?? '',
        apellidoPaterno: m['apellidoPaterno'] ?? '',
        apellidoMaterno: m['apellidoMaterno'] ?? '',
        primerNombre: m['primerNombre'] ?? '',
        segundoNombre: m['segundoNombre'] ?? '',
        cedula: m['cedula'] ?? '',
        direccion: m['direccion'] ?? '',
        barrio: m['barrio'] ?? '',
        zona: m['zona'] ?? 'U',
        telefono: m['telefono'] ?? '',
        fechaNacimiento: m['fechaNacimiento'] != null
            ? DateTime.tryParse(m['fechaNacimiento'])
            : null,
        lugarNacimiento: m['lugarNacimiento'] ?? '',
        nacionalidad: m['nacionalidad'] ?? '',
        grupoCultural: m['grupoCultural'] ?? '',
        edad: m['edad'] ?? 0,
        sexo: m['sexo'] ?? 'F',
        estadoCivil: m['estadoCivil'] ?? 'SOL',
        instruccion: m['instruccion'] ?? '',
        fechaAdmision: DateTime.tryParse(m['fechaAdmision'] ?? '') ??
            DateTime.now(),
        ocupacion: m['ocupacion'] ?? '',
        empresa: m['empresa'] ?? '',
        tipoSeguro: m['tipoSeguro'] ?? '',
        referidoDe: m['referidoDe'] ?? '',
        contactoEmergenciaNombre: m['contactoEmergenciaNombre'] ?? '',
        contactoEmergenciaParentesco: m['contactoEmergenciaParentesco'] ?? '',
        contactoEmergenciaDireccion: m['contactoEmergenciaDireccion'] ?? '',
        contactoEmergenciaTelefono: m['contactoEmergenciaTelefono'] ?? '',
      );
}

/// ---------------------------------------------------------------------
/// HISTORIA CLÍNICA ODONTOLÓGICA (hoja 033: motivo, antecedentes, signos,
/// examen del sistema estomatognático)
/// ---------------------------------------------------------------------
class ClinicalHistory {
  final String id;
  final String patientId;
  String motivoConsulta;
  String enfermedadActual;

  // Antecedentes personales y familiares (checkbox + detalle)
  Map<String, bool> antecedentes; // alergiaAntibiotico, alergiaAnestesia, ...
  String antecedentesDetalle;

  // Signos vitales
  String presionArterial;
  String frecuenciaCardiaca;
  String temperatura;
  String frecuenciaRespiratoria;

  // Examen del sistema estomatognático (texto libre por región)
  Map<String, String> examenEstomatognatico;

  ClinicalHistory({
    required this.id,
    required this.patientId,
    this.motivoConsulta = '',
    this.enfermedadActual = '',
    Map<String, bool>? antecedentes,
    this.antecedentesDetalle = '',
    this.presionArterial = '',
    this.frecuenciaCardiaca = '',
    this.temperatura = '',
    this.frecuenciaRespiratoria = '',
    Map<String, String>? examenEstomatognatico,
  })  : antecedentes = antecedentes ??
            {
              'alergiaAntibiotico': false,
              'alergiaAnestesia': false,
              'hemorragias': false,
              'vihSida': false,
              'tuberculosis': false,
              'asma': false,
              'diabetes': false,
              'hipertension': false,
              'enfCardiaca': false,
              'otro': false,
            },
        examenEstomatognatico = examenEstomatognatico ??
            {
              for (final r in [
                'labios', 'mejillas', 'maxilarSuperior', 'maxilarInferior',
                'lengua', 'paladar', 'piso', 'carrillos', 'glandulasSalivales',
                'oroFaringe', 'atm', 'ganglios',
              ])
                r: ''
            };

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'motivoConsulta': motivoConsulta,
        'enfermedadActual': enfermedadActual,
        'antecedentes': jsonEncode(antecedentes),
        'antecedentesDetalle': antecedentesDetalle,
        'presionArterial': presionArterial,
        'frecuenciaCardiaca': frecuenciaCardiaca,
        'temperatura': temperatura,
        'frecuenciaRespiratoria': frecuenciaRespiratoria,
        'examenEstomatognatico': jsonEncode(examenEstomatognatico),
      };

  factory ClinicalHistory.fromMap(Map<String, dynamic> m) => ClinicalHistory(
        id: m['id'],
        patientId: m['patientId'],
        motivoConsulta: m['motivoConsulta'] ?? '',
        enfermedadActual: m['enfermedadActual'] ?? '',
        antecedentes: Map<String, bool>.from(
            jsonDecode(m['antecedentes'] ?? '{}').map(
                (k, v) => MapEntry(k, v == true))),
        antecedentesDetalle: m['antecedentesDetalle'] ?? '',
        presionArterial: m['presionArterial'] ?? '',
        frecuenciaCardiaca: m['frecuenciaCardiaca'] ?? '',
        temperatura: m['temperatura'] ?? '',
        frecuenciaRespiratoria: m['frecuenciaRespiratoria'] ?? '',
        examenEstomatognatico: Map<String, String>.from(
            jsonDecode(m['examenEstomatognatico'] ?? '{}')),
      );
}

/// ---------------------------------------------------------------------
/// ODONTOGRAMA — una marca por diente/superficie.
/// Soporta tanto símbolo tocado (tap) como trazo libre de lápiz (freehand).
/// ---------------------------------------------------------------------
enum OdontoSymbol {
  caries,
  obturado,
  extraccionIndicada,
  perdidaPorCaries,
  perdidaOtraCausa,
  sellanteNecesario,
  sellanteRealizado,
  endodoncia,
  corona,
  protesisFija,
  protesisRemovible,
  protesisTotal,
  ninguno,
}

class ToothMark {
  final String id;
  final String patientId;
  final int toothNumber; // notación FDI (11-18, 21-28, ...55-85 en niños)
  final String surface; // vestibular, lingual, mesial, distal, oclusal
  OdontoSymbol symbol;
  int movilidad; // 0-3
  bool recesion;
  String color; // 'rojo' = patología actual, 'azul' = tratamiento realizado
  List<List<Offset2D>> freehandStrokes; // trazos de lápiz sobre el diente

  ToothMark({
    required this.id,
    required this.patientId,
    required this.toothNumber,
    required this.surface,
    this.symbol = OdontoSymbol.ninguno,
    this.movilidad = 0,
    this.recesion = false,
    this.color = 'rojo',
    List<List<Offset2D>>? freehandStrokes,
  }) : freehandStrokes = freehandStrokes ?? [];

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'toothNumber': toothNumber,
        'surface': surface,
        'symbol': symbol.name,
        'movilidad': movilidad,
        'recesion': recesion ? 1 : 0,
        'color': color,
        'freehandStrokes': jsonEncode(
            freehandStrokes.map((s) => s.map((p) => p.toJson()).toList()).toList()),
      };

  factory ToothMark.fromMap(Map<String, dynamic> m) => ToothMark(
        id: m['id'],
        patientId: m['patientId'],
        toothNumber: m['toothNumber'],
        surface: m['surface'],
        symbol: OdontoSymbol.values.firstWhere(
            (e) => e.name == m['symbol'],
            orElse: () => OdontoSymbol.ninguno),
        movilidad: m['movilidad'] ?? 0,
        recesion: m['recesion'] == 1,
        color: m['color'] ?? 'rojo',
        freehandStrokes: (jsonDecode(m['freehandStrokes'] ?? '[]') as List)
            .map((s) => (s as List)
                .map((p) => Offset2D.fromJson(p))
                .toList())
            .toList(),
      );
}

/// Punto simple serializable (evita depender de dart:ui en el modelo).
class Offset2D {
  final double dx;
  final double dy;
  Offset2D(this.dx, this.dy);
  Map<String, dynamic> toJson() => {'x': dx, 'y': dy};
  factory Offset2D.fromJson(Map<String, dynamic> j) =>
      Offset2D((j['x'] as num).toDouble(), (j['y'] as num).toDouble());
}

/// ---------------------------------------------------------------------
/// PLAN DE TRATAMIENTO INTEGRAL
/// ---------------------------------------------------------------------
class TreatmentPlanItem {
  final String id;
  final String patientId;
  String diagnostico;
  String detalle;
  String piezas;
  double costo;

  TreatmentPlanItem({
    required this.id,
    required this.patientId,
    this.diagnostico = '',
    this.detalle = '',
    this.piezas = '',
    this.costo = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'diagnostico': diagnostico,
        'detalle': detalle,
        'piezas': piezas,
        'costo': costo,
      };

  factory TreatmentPlanItem.fromMap(Map<String, dynamic> m) =>
      TreatmentPlanItem(
        id: m['id'],
        patientId: m['patientId'],
        diagnostico: m['diagnostico'] ?? '',
        detalle: m['detalle'] ?? '',
        piezas: m['piezas'] ?? '',
        costo: (m['costo'] ?? 0).toDouble(),
      );
}

/// ---------------------------------------------------------------------
/// SESIONES DE TRATAMIENTO
/// ---------------------------------------------------------------------
class TreatmentSession {
  final String id;
  final String patientId;
  int numeroSesion;
  DateTime fecha;
  String diagnosticosComplicaciones;
  String procedimientos;
  String prescripciones;
  String profesionalCodigo;

  TreatmentSession({
    required this.id,
    required this.patientId,
    required this.numeroSesion,
    DateTime? fecha,
    this.diagnosticosComplicaciones = '',
    this.procedimientos = '',
    this.prescripciones = '',
    this.profesionalCodigo = '',
  }) : fecha = fecha ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'numeroSesion': numeroSesion,
        'fecha': fecha.toIso8601String(),
        'diagnosticosComplicaciones': diagnosticosComplicaciones,
        'procedimientos': procedimientos,
        'prescripciones': prescripciones,
        'profesionalCodigo': profesionalCodigo,
      };

  factory TreatmentSession.fromMap(Map<String, dynamic> m) =>
      TreatmentSession(
        id: m['id'],
        patientId: m['patientId'],
        numeroSesion: m['numeroSesion'],
        fecha: DateTime.tryParse(m['fecha'] ?? '') ?? DateTime.now(),
        diagnosticosComplicaciones: m['diagnosticosComplicaciones'] ?? '',
        procedimientos: m['procedimientos'] ?? '',
        prescripciones: m['prescripciones'] ?? '',
        profesionalCodigo: m['profesionalCodigo'] ?? '',
      );
}

/// ---------------------------------------------------------------------
/// HISTORIAL DE PAGOS
/// ---------------------------------------------------------------------
class PaymentRecord {
  final String id;
  final String patientId;
  DateTime fecha;
  String tratamientoRealizado;
  double debe;
  double haber;
  double saldo;

  PaymentRecord({
    required this.id,
    required this.patientId,
    DateTime? fecha,
    this.tratamientoRealizado = '',
    this.debe = 0,
    this.haber = 0,
    this.saldo = 0,
  }) : fecha = fecha ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'fecha': fecha.toIso8601String(),
        'tratamientoRealizado': tratamientoRealizado,
        'debe': debe,
        'haber': haber,
        'saldo': saldo,
      };

  factory PaymentRecord.fromMap(Map<String, dynamic> m) => PaymentRecord(
        id: m['id'],
        patientId: m['patientId'],
        fecha: DateTime.tryParse(m['fecha'] ?? '') ?? DateTime.now(),
        tratamientoRealizado: m['tratamientoRealizado'] ?? '',
        debe: (m['debe'] ?? 0).toDouble(),
        haber: (m['haber'] ?? 0).toDouble(),
        saldo: (m['saldo'] ?? 0).toDouble(),
      );
}

/// ---------------------------------------------------------------------
/// CONSENTIMIENTO INFORMADO (con firma capturada como imagen PNG base64)
/// ---------------------------------------------------------------------
class ConsentRecord {
  final String id;
  final String patientId;
  String propositos;
  String terapiaProcedimientos;
  String resultadosEsperados;
  String riesgos;
  String profesionalNombre;
  Map<String, bool> itemsAceptados; // A..I del formulario
  String firmaPacienteBase64Png;
  String firmaProfesionalBase64Png;
  DateTime fecha;

  ConsentRecord({
    required this.id,
    required this.patientId,
    this.propositos = '',
    this.terapiaProcedimientos = '',
    this.resultadosEsperados = '',
    this.riesgos = '',
    this.profesionalNombre = '',
    Map<String, bool>? itemsAceptados,
    this.firmaPacienteBase64Png = '',
    this.firmaProfesionalBase64Png = '',
    DateTime? fecha,
  })  : itemsAceptados = itemsAceptados ??
            {for (final k in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I']) k: false},
        fecha = fecha ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'propositos': propositos,
        'terapiaProcedimientos': terapiaProcedimientos,
        'resultadosEsperados': resultadosEsperados,
        'riesgos': riesgos,
        'profesionalNombre': profesionalNombre,
        'itemsAceptados': jsonEncode(itemsAceptados),
        'firmaPacienteBase64Png': firmaPacienteBase64Png,
        'firmaProfesionalBase64Png': firmaProfesionalBase64Png,
        'fecha': fecha.toIso8601String(),
      };

  factory ConsentRecord.fromMap(Map<String, dynamic> m) => ConsentRecord(
        id: m['id'],
        patientId: m['patientId'],
        propositos: m['propositos'] ?? '',
        terapiaProcedimientos: m['terapiaProcedimientos'] ?? '',
        resultadosEsperados: m['resultadosEsperados'] ?? '',
        riesgos: m['riesgos'] ?? '',
        profesionalNombre: m['profesionalNombre'] ?? '',
        itemsAceptados: Map<String, bool>.from(
            jsonDecode(m['itemsAceptados'] ?? '{}')
                .map((k, v) => MapEntry(k, v == true))),
        firmaPacienteBase64Png: m['firmaPacienteBase64Png'] ?? '',
        firmaProfesionalBase64Png: m['firmaProfesionalBase64Png'] ?? '',
        fecha: DateTime.tryParse(m['fecha'] ?? '') ?? DateTime.now(),
      );
}
