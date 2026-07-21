import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../db/database_helper.dart';
import '../../models/models.dart';

class PaymentsTab extends StatefulWidget {
  final String patientId;
  const PaymentsTab({super.key, required this.patientId});
  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  List<PaymentRecord> _payments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await DatabaseHelper.instance.getPayments(widget.patientId);
    setState(() => _payments = list);
  }

  Future<void> _addRow() async {
    final prevSaldo = _payments.isEmpty ? 0.0 : _payments.last.saldo;
    final p = PaymentRecord(
        id: const Uuid().v4(), patientId: widget.patientId, saldo: prevSaldo);
    await DatabaseHelper.instance.upsertPayment(p);
    _load();
  }

  Future<void> _save(PaymentRecord p) async {
    p.saldo = p.debe - p.haber;
    await DatabaseHelper.instance.upsertPayment(p);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            // Scroll horizontal propio: la tabla (fecha + tratamiento +
            // debe + haber + saldo) puede ser más ancha que la pantalla
            // en tablets angostas o en modo retrato.
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Tratamiento realizado')),
                  DataColumn(label: Text('Debe')),
                  DataColumn(label: Text('Haber')),
                  DataColumn(label: Text('Saldo')),
                ],
                rows: _payments.map((p) {
                  return DataRow(cells: [
                    DataCell(TextButton(
                      child: Text(DateFormat('dd/MM/yy').format(p.fecha)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: p.fecha,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          p.fecha = picked;
                          _save(p);
                        }
                      },
                    )),
                    DataCell(SizedBox(
                      width: 220,
                      child: TextFormField(
                        initialValue: p.tratamientoRealizado,
                        onChanged: (v) {
                          p.tratamientoRealizado = v;
                          _save(p);
                        },
                      ),
                    )),
                    DataCell(SizedBox(
                      width: 90,
                      child: TextFormField(
                        initialValue: p.debe == 0 ? '' : p.debe.toString(),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (v) {
                          p.debe = double.tryParse(v) ?? 0;
                          _save(p);
                        },
                      ),
                    )),
                    DataCell(SizedBox(
                      width: 90,
                      child: TextFormField(
                        initialValue: p.haber == 0 ? '' : p.haber.toString(),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (v) {
                          p.haber = double.tryParse(v) ?? 0;
                          _save(p);
                        },
                      ),
                    )),
                    DataCell(Text('\$${p.saldo.toStringAsFixed(2)}')),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add),
            label: const Text('Agregar pago'),
          ),
        ),
      ],
    );
  }
}
