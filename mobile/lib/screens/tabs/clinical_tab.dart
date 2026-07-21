import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../db/database_helper.dart';
import '../../models/models.dart';

class ClinicalHistoryTab extends StatefulWidget {
  final String patientId;
  const ClinicalHistoryTab({super.key, required this.patientId});
  @override
  State<ClinicalHistoryTab> createState() => _ClinicalHistoryTabState();
}

class _ClinicalHistoryTabState extends State<ClinicalHistoryTab> {
  ClinicalHistory? _h;
  final _motivoCtrl = TextEditingController();
  final _enfermedadCtrl = TextEditingController();
  final _antecedentesDetalleCtrl = TextEditingController();
  final _presionCtrl = TextEditingController();
  final _frecCardCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _frecRespCtrl = TextEditingController();
  final Map<String, TextEditingController> _examenCtrls = {};

  static const antecedentesLabels = {
    'alergiaAntibiotico': 'Alergia a antibiótico',
    'alergiaAnestesia': 'Alergia a anestesia',
    'hemorragias': 'Hemorragias',
    'vihSida': 'VIH/SIDA',
    'tuberculosis': 'Tuberculosis',
    'asma': 'Asma',
    'diabetes': 'Diabetes',
    'hipertension': 'Hipertensión',
    'enfCardiaca': 'Enf. cardiaca',
    'otro': 'Otro',
  };

  static const examenLabels = {
    'labios': 'Labios',
    'mejillas': 'Mejillas',
    'maxilarSuperior': 'Maxilar superior',
    'maxilarInferior': 'Maxilar inferior',
    'lengua': 'Lengua',
    'paladar': 'Paladar',
    'piso': 'Piso',
    'carrillos': 'Carrillos',
    'glandulasSalivales': 'Glándulas salivales',
    'oroFaringe': 'Oro faringe',
    'atm': 'A.T.M.',
    'ganglios': 'Ganglios',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h =
        await DatabaseHelper.instance.getClinicalHistory(widget.patientId) ??
            ClinicalHistory(id: const Uuid().v4(), patientId: widget.patientId);
    _h = h;
    _motivoCtrl.text = h.motivoConsulta;
    _enfermedadCtrl.text = h.enfermedadActual;
    _antecedentesDetalleCtrl.text = h.antecedentesDetalle;
    _presionCtrl.text = h.presionArterial;
    _frecCardCtrl.text = h.frecuenciaCardiaca;
    _tempCtrl.text = h.temperatura;
    _frecRespCtrl.text = h.frecuenciaRespiratoria;
    for (final k in examenLabels.keys) {
      _examenCtrls[k] = TextEditingController(text: h.examenEstomatognatico[k]);
    }
    setState(() {});
  }

  Future<void> _save() async {
    final h = _h!;
    h.motivoConsulta = _motivoCtrl.text;
    h.enfermedadActual = _enfermedadCtrl.text;
    h.antecedentesDetalle = _antecedentesDetalleCtrl.text;
    h.presionArterial = _presionCtrl.text;
    h.frecuenciaCardiaca = _frecCardCtrl.text;
    h.temperatura = _tempCtrl.text;
    h.frecuenciaRespiratoria = _frecRespCtrl.text;
    for (final k in examenLabels.keys) {
      h.examenEstomatognatico[k] = _examenCtrls[k]!.text;
    }
    await DatabaseHelper.instance.upsertClinicalHistory(h);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Guardado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_h == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _title('1. Motivo de consulta'),
        TextField(
            controller: _motivoCtrl,
            maxLines: 2,
            decoration: const InputDecoration(border: OutlineInputBorder())),
        const SizedBox(height: 16),
        _title('2. Enfermedad o problema actual'),
        TextField(
          controller: _enfermedadCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText:
                'Cronología, localización, características, intensidad, causa aparente, síntomas asociados, evolución, estado actual',
          ),
        ),
        const SizedBox(height: 16),
        _title('3. Antecedentes personales y familiares'),
        Wrap(
          spacing: 8,
          children: antecedentesLabels.entries.map((e) {
            return FilterChip(
              label: Text(e.value),
              selected: _h!.antecedentes[e.key] ?? false,
              onSelected: (v) => setState(() => _h!.antecedentes[e.key] = v),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _antecedentesDetalleCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
              labelText: 'Detalle de antecedentes',
              border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        _title('4. Signos vitales'),
        Wrap(spacing: 12, runSpacing: 8, children: [
          _small('Presión arterial', _presionCtrl),
          _small('Frecuencia cardíaca (min)', _frecCardCtrl),
          _small('Temperatura °C', _tempCtrl),
          _small('F. respiratoria (min)', _frecRespCtrl),
        ]),
        const SizedBox(height: 16),
        _title('5. Examen del sistema estomatognático'),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: examenLabels.entries
              .map((e) => _small(e.value, _examenCtrls[e.key]!))
              .toList(),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('Guardar historia clínica'),
        ),
      ],
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(t, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _small(String label, TextEditingController c) => LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          width: constraints.maxWidth < 260 ? constraints.maxWidth : 260.0,
          child: TextField(
            controller: c,
            decoration: InputDecoration(labelText: label),
          ),
        ),
      );
}
