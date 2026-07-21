import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/models.dart';

/// Los TextField normales de Flutter ya aceptan escritura a mano de lápiz
/// (Android "Scribble"/reconocimiento de escritura) además del teclado,
/// así que no se necesita nada especial para ese requisito en formularios
/// de texto — solo en el odontograma y las firmas se dibuja directamente
/// sobre un canvas (ver odontogram_widget.dart y signature_pad.dart).
class AdmissionTab extends StatefulWidget {
  final String patientId;
  const AdmissionTab({super.key, required this.patientId});
  @override
  State<AdmissionTab> createState() => _AdmissionTabState();
}

class _AdmissionTabState extends State<AdmissionTab> {
  static const _provincias = [
    'Azuay',
    'Bolívar',
    'Cañar',
    'Carchi',
    'Chimborazo',
    'Cotopaxi',
    'El Oro',
    'Esmeraldas',
    'Galápagos',
    'Guayas',
    'Imbabura',
    'Loja',
    'Los Ríos',
    'Manabí',
    'Morona Santiago',
    'Napo',
    'Orellana',
    'Pastaza',
    'Pichincha',
    'Santa Elena',
    'Santo Domingo de los Tsáchilas',
    'Sucumbíos',
    'Tungurahua',
    'Zamora Chinchipe',
  ];

  Patient? _patient;
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _c = {};

  final _fields = <String, String>{
    'institucion': 'Institución del sistema',
    'unidadOperativa': 'Unidad operativa',
    'numeroHistoriaClinica': 'N° historia clínica',
    'parroquia': 'Parroquia',
    'canton': 'Cantón',
    'provincia': 'Provincia',
    'apellidoPaterno': 'Apellido paterno',
    'apellidoMaterno': 'Apellido materno',
    'primerNombre': 'Primer nombre',
    'segundoNombre': 'Segundo nombre',
    'cedula': 'N° cédula de ciudadanía',
    'direccion': 'Dirección de residencia habitual',
    'barrio': 'Barrio',
    'telefono': 'N° teléfono',
    'lugarNacimiento': 'Lugar de nacimiento',
    'nacionalidad': 'Nacionalidad (país)',
    'grupoCultural': 'Grupo cultural',
    'instruccion': 'Instrucción / último año aprobado',
    'ocupacion': 'Ocupación',
    'empresa': 'Empresa donde trabaja',
    'tipoSeguro': 'Tipo de seguro de salud',
    'referidoDe': 'Referido de',
    'contactoEmergenciaNombre': 'En caso necesario llamar a',
    'contactoEmergenciaParentesco': 'Parentesco / afinidad',
    'contactoEmergenciaDireccion': 'Dirección del contacto',
    'contactoEmergenciaTelefono': 'Teléfono del contacto',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await DatabaseHelper.instance.getPatient(widget.patientId);
    _patient = p ?? Patient(id: widget.patientId);
    final map = _patient!.toMap();
    for (final key in _fields.keys) {
      _c[key] = TextEditingController(text: map[key]?.toString() ?? '');
    }
    _c['edad'] = TextEditingController(text: '${_patient!.edad}');
    setState(() {});
  }

  Future<void> _save() async {
    if (_patient == null) return;
    final p = _patient!;
    p.institucion = _c['institucion']!.text;
    p.unidadOperativa = _c['unidadOperativa']!.text;
    p.numeroHistoriaClinica = _c['numeroHistoriaClinica']!.text;
    p.parroquia = _c['parroquia']!.text;
    p.canton = _c['canton']!.text;
    p.provincia = _c['provincia']!.text;
    p.apellidoPaterno = _c['apellidoPaterno']!.text;
    p.apellidoMaterno = _c['apellidoMaterno']!.text;
    p.primerNombre = _c['primerNombre']!.text;
    p.segundoNombre = _c['segundoNombre']!.text;
    p.cedula = _c['cedula']!.text;
    p.direccion = _c['direccion']!.text;
    p.barrio = _c['barrio']!.text;
    p.telefono = _c['telefono']!.text;
    p.lugarNacimiento = _c['lugarNacimiento']!.text;
    p.nacionalidad = _c['nacionalidad']!.text;
    p.grupoCultural = _c['grupoCultural']!.text;
    p.instruccion = _c['instruccion']!.text;
    p.ocupacion = _c['ocupacion']!.text;
    p.empresa = _c['empresa']!.text;
    p.tipoSeguro = _c['tipoSeguro']!.text;
    p.referidoDe = _c['referidoDe']!.text;
    p.contactoEmergenciaNombre = _c['contactoEmergenciaNombre']!.text;
    p.contactoEmergenciaParentesco = _c['contactoEmergenciaParentesco']!.text;
    p.contactoEmergenciaDireccion = _c['contactoEmergenciaDireccion']!.text;
    p.contactoEmergenciaTelefono = _c['contactoEmergenciaTelefono']!.text;
    p.edad = int.tryParse(_c['edad']!.text) ?? 0;
    await DatabaseHelper.instance.upsertPatient(p);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Guardado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_patient == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('1. Registro de primera admisión'),
          _grid(_fields.keys.toList()),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _c['edad'],
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Edad (años cumplidos)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _patient!.sexo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Sexo'),
                  items: const [
                    DropdownMenuItem(value: 'M', child: Text('Masculino')),
                    DropdownMenuItem(value: 'F', child: Text('Femenino')),
                  ],
                  onChanged: (v) => setState(() => _patient!.sexo = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _patient!.estadoCivil,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Estado civil'),
                  items: const [
                    DropdownMenuItem(value: 'SOL', child: Text('Soltero')),
                    DropdownMenuItem(value: 'CAS', child: Text('Casado')),
                    DropdownMenuItem(value: 'DIV', child: Text('Divorciado')),
                    DropdownMenuItem(value: 'VIU', child: Text('Viudo')),
                    DropdownMenuItem(value: 'U-L', child: Text('Unión libre')),
                  ],
                  onChanged: (v) => setState(() => _patient!.estadoCivil = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Guardar admisión'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: Theme.of(context).textTheme.titleMedium),
      );

  // Ancho adaptativo: 320 en tablets (donde caben 2+ campos por fila), pero
  // nunca más que el espacio disponible, para que no se desborde en
  // celulares angostos (ej. Galaxy S8, ~360dp de ancho).
  Widget _grid(List<String> keys) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth =
            constraints.maxWidth < 320 ? constraints.maxWidth : 320.0;
        return Wrap(
          spacing: 12,
          runSpacing: 8,
          children: keys.map((k) {
            if (k == 'provincia') {
              final current = _c[k]!.text;
              return SizedBox(
                width: fieldWidth,
                child: DropdownButtonFormField<String>(
                  value: _provincias.contains(current) ? current : null,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: _fields[k]),
                  items: _provincias
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _c[k]!.text = v ?? ''),
                ),
              );
            }
            return SizedBox(
              width: fieldWidth,
              child: TextFormField(
                controller: _c[k],
                decoration: InputDecoration(labelText: _fields[k]),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
