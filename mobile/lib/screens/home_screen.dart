import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../db/database_helper.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'patient_detail_screen.dart';

/// Separa un texto de una o más palabras en (primera palabra, resto),
/// para repartir "Nombres"/"Apellidos" en los pares primer/segundo que
/// usa el formulario (ej. "Santiago Paul" -> ("Santiago", "Paul")).
(String, String) _splitName(String text) {
  final parts =
      text.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return ('', '');
  if (parts.length == 1) return (parts.first, '');
  return (parts.first, parts.sublist(1).join(' '));
}

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
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _QuickNewPatientDialog(),
    );
    if (result == null) return; // el usuario canceló

    // Solo se piden nombres, apellidos y cédula aquí; cada campo se separa
    // por palabras (primera palabra = primer nombre/apellido paterno, el
    // resto = segundo nombre/apellido materno) para que ya lleguen bien
    // ubicados a la pestaña "Admisión". El resto de campos (dirección,
    // teléfono, etc.) se completan después ahí mismo.
    final nombres = _splitName(result['nombres'] ?? '');
    final apellidos = _splitName(result['apellidos'] ?? '');
    final p = Patient(
      id: const Uuid().v4(),
      primerNombre: nombres.$1,
      segundoNombre: nombres.$2,
      apellidoPaterno: apellidos.$1,
      apellidoMaterno: apellidos.$2,
      cedula: result['cedula'] ?? '',
    );
    await DatabaseHelper.instance.upsertPatient(p);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PatientDetailScreen(patientId: p.id)),
    );
    _load(_searchCtrl.text);
  }

  Future<void> _confirmDelete(Patient p) async {
    final name =
        p.nombreCompleto.trim().isEmpty ? '(sin nombre)' : p.nombreCompleto;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar paciente?'),
        content:
            Text('Se eliminará permanentemente a "$name" junto con su historia '
                'clínica, odontograma, plan de tratamiento, sesiones, pagos y '
                'consentimientos. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper.instance.deletePatient(p.id);
      _load(_searchCtrl.text);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
            'Volverás a la pantalla de inicio de sesión. Tus datos locales '
            'no se borran.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await SupabaseService.instance.signOut();
    } catch (_) {
      // Sin cuenta / Supabase no configurado: no hay sesión que cerrar,
      // igual regresamos a la pantalla de inicio de sesión.
    }
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false);
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
            actions: [
              IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: _logout,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.health_and_safety_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text('Dentity',
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        onLongPress: () => _confirmDelete(p),
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

/// Diálogo inicial rápido para crear un paciente: pide solo lo mínimo
/// (nombres, apellidos y cédula) para poder identificarlo en la lista;
/// el resto del formulario (SNS-MSP HCU-001 completo) se llena después
/// en la pestaña "Admisión", que arranca con estos datos ya precargados
/// y repartidos en primer/segundo nombre y apellido paterno/materno.
class _QuickNewPatientDialog extends StatefulWidget {
  const _QuickNewPatientDialog();
  @override
  State<_QuickNewPatientDialog> createState() => _QuickNewPatientDialogState();
}

class _QuickNewPatientDialogState extends State<_QuickNewPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();
  final _cedula = TextEditingController();

  @override
  void dispose() {
    _nombres.dispose();
    _apellidos.dispose();
    _cedula.dispose();
    super.dispose();
  }

  void _continue() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'nombres': _nombres.text.trim(),
        'apellidos': _apellidos.text.trim(),
        'cedula': _cedula.text.trim(),
      });
    }
  }

  static const _proximosPasos = [
    (
      Icons.badge_outlined,
      'PASO 1 · ADMISIÓN',
      'Datos generales',
      'Institución, contacto y procedencia'
    ),
    (
      Icons.medical_information_outlined,
      'PASO 2 · HISTORIA',
      'Antecedentes',
      'Motivo de consulta y signos vitales'
    ),
    (
      Icons.grid_view_rounded,
      'PASO 3 · ODONTOGRAMA',
      'Estado dental',
      'Pieza por pieza, con lápiz o toque'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        // maxWidth (no ancho fijo): en tablet ocupa 320, pero se encoge en
        // celulares angostos (ej. Galaxy S8) en vez de desbordarse.
        constraints: const BoxConstraints(maxWidth: 320),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          // Con el teclado abierto (el campo "Nombres completos" tiene
          // autofocus) el alto disponible se reduce mucho; sin scroll el
          // contenido se desborda. Ver regla de overflow en memoria.
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Sección clara: avatar hexagonal + campos "título" ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                      child: Column(
                        children: [
                          ClipPath(
                            clipper: _HexagonClipper(),
                            child: Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [scheme.primary, AppTheme.lavender],
                                ),
                              ),
                              child: const Icon(Icons.person_add_alt_1_rounded,
                                  color: Colors.white, size: 52),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nombres,
                            textCapitalization: TextCapitalization.words,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.sora(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: 'Nombres',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Requerido'
                                : null,
                          ),
                          const SizedBox(height: 2),
                          TextFormField(
                            controller: _apellidos,
                            textCapitalization: TextCapitalization.words,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.sora(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: 'Apellidos',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Requerido'
                                : null,
                          ),
                          const SizedBox(height: 6),
                          Text('CÉDULA DEL PACIENTE',
                              style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark.withOpacity(0.55))),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _cedula,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: '0000000000',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Requerido'
                                : null,
                            onFieldSubmitted: (_) => _continue(),
                          ),
                        ],
                      ),
                    ),
                    // --- Panel de color: adelanto de los siguientes pasos ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [scheme.primary, AppTheme.lavender],
                        ),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < _proximosPasos.length; i++) ...[
                            if (i > 0)
                              Divider(
                                  height: 22,
                                  color: Colors.white.withOpacity(0.18)),
                            _stepRow(_proximosPasos[i]),
                          ],
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: scheme.primary,
                              ),
                              onPressed: _continue,
                              child: const Text('Continuar'),
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white70),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepRow((IconData, String, String, String) step) {
    final (icon, caption, title, subtitle) = step;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(icon, color: AppTheme.lavender, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(caption,
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 2),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 11.5, color: Colors.white.withOpacity(0.85))),
            ],
          ),
        ),
      ],
    );
  }
}

/// Silueta hexagonal para el avatar del diálogo, como en el diseño de
/// referencia (marco geométrico en vez de círculo).
class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2;
    for (int i = 0; i < 6; i++) {
      final angle = (pi / 180) * (60 * i);
      final point = Offset(cx + r * cos(angle), cy + r * sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
