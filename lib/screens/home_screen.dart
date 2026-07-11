import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/database_helper.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'patient_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  List<Patient> _patients = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load([String? q]) async {
    final list = await DatabaseHelper.instance.getPatients(query: q);
    setState(() => _patients = list);
  }

  Future<void> _newPatient() async {
    final p = Patient(id: const Uuid().v4());
    await DatabaseHelper.instance.upsertPatient(p);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PatientDetailScreen(patientId: p.id)),
    );
    _load(_searchCtrl.text);
  }

  String _initials(Patient p) {
    final a = p.apellidoPaterno.isNotEmpty ? p.apellidoPaterno[0] : '';
    final b = p.primerNombre.isNotEmpty ? p.primerNombre[0] : '';
    final i = '$a$b'.toUpperCase();
    return i.isEmpty ? '?' : i;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 130,
            backgroundColor: scheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.health_and_safety_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text('SmileVault',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20)),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.primary, scheme.primary.withOpacity(0.75)],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: scheme.primary),
                  hintText: 'Buscar por nombre, cédula o N° historia clínica',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: _load,
              ),
            ),
          ),
          if (_patients.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_open_rounded,
                        size: 56, color: scheme.primary.withOpacity(0.4)),
                    const SizedBox(height: 12),
                    Text('No hay pacientes registrados todavía',
                        style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Text('Toca "Nuevo paciente" para empezar',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final p = _patients[i];
                    final color = AppTheme.avatarColorFor(p.apellidoPaterno);
                    return Card(
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: color,
                          child: Text(_initials(p),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        title: Text(
                          p.nombreCompleto.trim().isEmpty
                              ? '(Sin nombre aún)'
                              : p.nombreCompleto,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                            'HC: ${p.numeroHistoriaClinica.isEmpty ? "—" : p.numeroHistoriaClinica}   ·   Cédula: ${p.cedula.isEmpty ? "—" : p.cedula}',
                            style: const TextStyle(fontSize: 12.5)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    PatientDetailScreen(patientId: p.id)),
                          );
                          _load(_searchCtrl.text);
                        },
                      ),
                    );
                  },
                  childCount: _patients.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newPatient,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo paciente'),
      ),
    );
  }
}
