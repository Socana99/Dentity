import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/models.dart';
import '../../widgets/odontogram_widget.dart';

class OdontogramTab extends StatefulWidget {
  final String patientId;
  const OdontogramTab({super.key, required this.patientId});
  @override
  State<OdontogramTab> createState() => _OdontogramTabState();
}

class _OdontogramTabState extends State<OdontogramTab> {
  Map<int, ToothMark>? _marks;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await DatabaseHelper.instance.getToothMarks(widget.patientId);
    setState(() {
      _marks = {for (final m in list) m.toothNumber: m};
    });
  }

  Future<void> _onMarkChanged(ToothMark m) async {
    await DatabaseHelper.instance.upsertToothMark(m);
  }

  @override
  Widget build(BuildContext context) {
    if (_marks == null) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(16),
      child: OdontogramWidget(
        initialMarks: _marks!,
        patientId: widget.patientId,
        onMarkChanged: _onMarkChanged, // se guarda automáticamente al marcar
      ),
    );
  }
}
