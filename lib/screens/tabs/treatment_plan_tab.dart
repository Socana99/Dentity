import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../db/database_helper.dart';
import '../../models/models.dart';

class TreatmentPlanTab extends StatefulWidget {
  final String patientId;
  const TreatmentPlanTab({super.key, required this.patientId});
  @override
  State<TreatmentPlanTab> createState() => _TreatmentPlanTabState();
}

class _TreatmentPlanTabState extends State<TreatmentPlanTab> {
  List<TreatmentPlanItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list =
        await DatabaseHelper.instance.getTreatmentPlan(widget.patientId);
    setState(() => _items = list);
  }

  Future<void> _addRow() async {
    final item =
        TreatmentPlanItem(id: const Uuid().v4(), patientId: widget.patientId);
    await DatabaseHelper.instance.upsertTreatmentPlanItem(item);
    _load();
  }

  Future<void> _saveRow(TreatmentPlanItem item) async {
    await DatabaseHelper.instance.upsertTreatmentPlanItem(item);
  }

  double get _total => _items.fold(0, (sum, i) => sum + i.costo);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _items.length,
            itemBuilder: (ctx, i) {
              final item = _items[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _field('Diagnóstico', item.diagnostico, 220,
                          (v) => item.diagnostico = v, item),
                      _field('Detalle', item.detalle, 260,
                          (v) => item.detalle = v, item),
                      _field('Diente/s', item.piezas, 100,
                          (v) => item.piezas = v, item),
                      LayoutBuilder(
                        builder: (context, constraints) => SizedBox(
                          width: constraints.maxWidth < 100
                              ? constraints.maxWidth
                              : 100,
                          child: TextFormField(
                            initialValue:
                                item.costo == 0 ? '' : item.costo.toString(),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration:
                                const InputDecoration(labelText: 'Costo'),
                            onChanged: (v) {
                              item.costo = double.tryParse(v) ?? 0;
                              _saveRow(item);
                              setState(() {});
                            },
                          ),
                        ),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add),
                label: const Text('Agregar diagnóstico'),
              ),
              Text('TOTAL: \$${_total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(String label, String value, double width,
      void Function(String) onChanged, TreatmentPlanItem item) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.maxWidth < width ? constraints.maxWidth : width,
        child: TextFormField(
          initialValue: value,
          decoration: InputDecoration(labelText: label),
          onChanged: (v) {
            onChanged(v);
            _saveRow(item);
          },
        ),
      ),
    );
  }
}
