import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../db/database_helper.dart';
import '../../models/models.dart';

class SessionsTab extends StatefulWidget {
  final String patientId;
  const SessionsTab({super.key, required this.patientId});
  @override
  State<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<SessionsTab> {
  List<TreatmentSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await DatabaseHelper.instance.getSessions(widget.patientId);
    setState(() => _sessions = list);
  }

  Future<void> _addSession() async {
    final s = TreatmentSession(
      id: const Uuid().v4(),
      patientId: widget.patientId,
      numeroSesion: _sessions.length + 1,
    );
    await DatabaseHelper.instance.upsertSession(s);
    _load();
  }

  Future<void> _save(TreatmentSession s) async {
    await DatabaseHelper.instance.upsertSession(s);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _sessions.length,
            itemBuilder: (ctx, i) {
              final s = _sessions[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Sesión ${s.numeroSesion}',
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(DateFormat('dd/MM/yyyy').format(s.fecha)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: s.fecha,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                s.fecha = picked;
                                _save(s);
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: s.diagnosticosComplicaciones,
                        decoration: const InputDecoration(
                            labelText: 'Diagnósticos y complicaciones'),
                        onChanged: (v) {
                          s.diagnosticosComplicaciones = v;
                          _save(s);
                        },
                      ),
                      TextFormField(
                        initialValue: s.procedimientos,
                        decoration:
                            const InputDecoration(labelText: 'Procedimientos'),
                        onChanged: (v) {
                          s.procedimientos = v;
                          _save(s);
                        },
                      ),
                      TextFormField(
                        initialValue: s.prescripciones,
                        decoration:
                            const InputDecoration(labelText: 'Prescripciones'),
                        onChanged: (v) {
                          s.prescripciones = v;
                          _save(s);
                        },
                      ),
                      TextFormField(
                        initialValue: s.profesionalCodigo,
                        decoration: const InputDecoration(
                            labelText: 'Código / firma profesional'),
                        onChanged: (v) {
                          s.profesionalCodigo = v;
                          _save(s);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _addSession,
            icon: const Icon(Icons.add),
            label: const Text('Nueva sesión'),
          ),
        ),
      ],
    );
  }
}
