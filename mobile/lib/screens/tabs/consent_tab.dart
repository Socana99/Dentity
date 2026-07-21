import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../db/database_helper.dart';
import '../../models/models.dart';
import '../../widgets/signature_pad.dart';

class ConsentTab extends StatefulWidget {
  final String patientId;
  const ConsentTab({super.key, required this.patientId});
  @override
  State<ConsentTab> createState() => _ConsentTabState();
}

class _ConsentTabState extends State<ConsentTab> {
  ConsentRecord? _c;
  final _propositosCtrl = TextEditingController();
  final _terapiaCtrl = TextEditingController();
  final _resultadosCtrl = TextEditingController();
  final _riesgosCtrl = TextEditingController();
  final _profesionalCtrl = TextEditingController();
  final _pacienteSignKey = GlobalKey<SignaturePadState>();
  final _profesionalSignKey = GlobalKey<SignaturePadState>();

  // Mientras el lápiz está tocando una firma, se bloquea el scroll de toda
  // la pestaña para que el trazo no se pierda (ver signature_pad.dart).
  ScrollPhysics _physics = const ClampingScrollPhysics();
  void _setDrawing(bool drawing) {
    setState(() {
      _physics = drawing
          ? const NeverScrollableScrollPhysics()
          : const ClampingScrollPhysics();
    });
  }

  static const items = {
    'A': 'El profesional me ha informado sobre los motivos y propósitos del tratamiento',
    'B': 'El profesional me ha explicado las actividades esenciales del tratamiento',
    'C': 'Consiento a que se realicen las intervenciones/procedimientos necesarios',
    'D': 'Consiento a que me administren la anestesia propuesta',
    'E': 'Entiendo que hay garantía de calidad de los medios, no de resultados',
    'F': 'He comprendido los beneficios y riesgos de complicaciones',
    'G': 'Se garantiza respeto a mi intimidad, creencias y confidencialidad',
    'H': 'Puedo anular este consentimiento cuando lo considere necesario',
    'I': 'Declaro haber entregado información completa y fidedigna',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await DatabaseHelper.instance.getConsents(widget.patientId);
    _c = list.isNotEmpty
        ? list.last
        : ConsentRecord(id: const Uuid().v4(), patientId: widget.patientId);
    _propositosCtrl.text = _c!.propositos;
    _terapiaCtrl.text = _c!.terapiaProcedimientos;
    _resultadosCtrl.text = _c!.resultadosEsperados;
    _riesgosCtrl.text = _c!.riesgos;
    _profesionalCtrl.text = _c!.profesionalNombre;
    setState(() {});
  }

  Future<void> _save() async {
    final c = _c!;
    c.propositos = _propositosCtrl.text;
    c.terapiaProcedimientos = _terapiaCtrl.text;
    c.resultadosEsperados = _resultadosCtrl.text;
    c.riesgos = _riesgosCtrl.text;
    c.profesionalNombre = _profesionalCtrl.text;
    c.firmaPacienteBase64Png =
        await _pacienteSignKey.currentState?.exportPng() ?? c.firmaPacienteBase64Png;
    c.firmaProfesionalBase64Png = await _profesionalSignKey.currentState
            ?.exportPng() ??
        c.firmaProfesionalBase64Png;
    await DatabaseHelper.instance.upsertConsent(c);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consentimiento guardado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_c == null) return const Center(child: CircularProgressIndicator());
    final primary = Theme.of(context).colorScheme.primary;
    return ListView(
      padding: const EdgeInsets.all(16),
      // physics se bloquea desde SignaturePad mientras se está dibujando.
      physics: _physics,
      children: [
        _sectionCard(
          icon: Icons.info_outline,
          title: 'Información entregada por el profesional tratante',
          child: Column(children: [
            TextField(
                controller: _propositosCtrl,
                decoration: const InputDecoration(labelText: 'Propósitos')),
            const SizedBox(height: 10),
            TextField(
                controller: _terapiaCtrl,
                decoration: const InputDecoration(
                    labelText: 'Terapia y procedimientos propuestos')),
            const SizedBox(height: 10),
            TextField(
                controller: _resultadosCtrl,
                decoration:
                    const InputDecoration(labelText: 'Resultados esperados')),
            const SizedBox(height: 10),
            TextField(
                controller: _riesgosCtrl,
                decoration: const InputDecoration(
                    labelText: 'Riesgos de complicaciones clínicas')),
            const SizedBox(height: 10),
            TextField(
                controller: _profesionalCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nombre del profesional tratante')),
          ]),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          icon: Icons.fact_check_outlined,
          title: 'Consentimiento informado del paciente',
          child: Column(
            children: items.entries.map((e) {
              final checked = _c!.itemsAceptados[e.key] ?? false;
              return CheckboxListTile(
                dense: true,
                activeColor: primary,
                title: Text('${e.key}. ${e.value}',
                    style: const TextStyle(fontSize: 13.5)),
                value: checked,
                onChanged: (v) =>
                    setState(() => _c!.itemsAceptados[e.key] = v ?? false),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          icon: Icons.border_color_outlined,
          title: 'Firmas',
          child: Column(
            children: [
              SignaturePad(
                key: _pacienteSignKey,
                label: 'Firma del paciente',
                onDrawingChanged: _setDrawing,
              ),
              const SizedBox(height: 20),
              SignaturePad(
                key: _profesionalSignKey,
                label: 'Firma del profesional tratante',
                onDrawingChanged: _setDrawing,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('Guardar consentimiento'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionCard(
      {required IconData icon, required String title, required Widget child}) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            ]),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}
