import 'package:flutter/material.dart';
import 'tabs/admission_tab.dart';
import 'tabs/clinical_tab.dart';
import 'tabs/odontogram_tab.dart';
import 'tabs/treatment_plan_tab.dart';
import 'tabs/sessions_tab.dart';
import 'tabs/payments_tab.dart';
import 'tabs/consent_tab.dart';

/// Contenedor con pestañas — refleja las hojas del formulario en papel
/// (Admisión / Historia clínica / Odontograma / Plan / Sesiones / Pagos /
/// Consentimiento). Cada pestaña se guarda de forma independiente en SQLite,
/// así que se puede llenar en cualquier orden y en varias visitas.
class PatientDetailScreen extends StatelessWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  static const _tabs = [
    (Icons.badge_outlined, 'Admisión'),
    (Icons.medical_information_outlined, 'Historia'),
    (Icons.grid_view_rounded, 'Odontograma'),
    (Icons.checklist_rounded, 'Plan'),
    (Icons.event_note_outlined, 'Sesiones'),
    (Icons.payments_outlined, 'Pagos'),
    (Icons.fact_check_outlined, 'Consentimiento'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historia Clínica'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _tabs
                .map((t) => Tab(icon: Icon(t.$1, size: 18), text: t.$2))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: [
            AdmissionTab(patientId: patientId),
            ClinicalHistoryTab(patientId: patientId),
            OdontogramTab(patientId: patientId),
            TreatmentPlanTab(patientId: patientId),
            SessionsTab(patientId: patientId),
            PaymentsTab(patientId: patientId),
            ConsentTab(patientId: patientId),
          ],
        ),
      ),
    );
  }
}
