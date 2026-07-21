"use client";

import { useState } from "react";
import type {
  ClinicalHistory,
  ConsentRecord,
  Patient,
  PaymentRecord,
  ToothMark,
  TreatmentPlanItem,
  TreatmentSession,
} from "@/lib/types";
import PlanSidebar from "./plan-sidebar";
import SummaryTab from "./summary-tab";
import AdmissionTab from "./admission-tab";
import ClinicalTab from "./clinical-tab";
import OdontogramTab from "./odontogram-tab";
import TreatmentPlanTab from "./treatment-plan-tab";
import SessionsTab from "./sessions-tab";
import PaymentsTab from "./payments-tab";
import ConsentTab from "./consent-tab";

const TABS = [
  "Resumen",
  "Admisión",
  "Historia",
  "Odontograma",
  "Plan",
  "Sesiones",
  "Pagos",
  "Consentimiento",
] as const;

export default function PatientTabs({
  patient,
  clinicalHistory,
  toothMarks,
  treatmentPlan,
  sessions,
  payments,
  consent,
}: {
  patient: Patient;
  clinicalHistory: ClinicalHistory | null;
  toothMarks: ToothMark[];
  treatmentPlan: TreatmentPlanItem[];
  sessions: TreatmentSession[];
  payments: PaymentRecord[];
  consent: ConsentRecord | null;
}) {
  const [active, setActive] = useState<(typeof TABS)[number]>("Resumen");

  return (
    <div className="grid grid-cols-1 gap-6 lg:grid-cols-[280px_1fr]">
      <PlanSidebar
        treatmentPlan={treatmentPlan}
        onOpenPlan={() => setActive("Plan")}
      />

      <div className="min-w-0">
        <nav className="mb-6 flex gap-6 overflow-x-auto border-b border-gray-200">
          {TABS.map((tab) => (
            <button
              key={tab}
              type="button"
              onClick={() => setActive(tab)}
              className={`shrink-0 whitespace-nowrap border-b-2 px-0.5 pb-3 text-sm font-medium transition-colors duration-150 ease-[var(--ease-out)] ${
                active === tab
                  ? "border-primary text-primary"
                  : "border-transparent text-gray-500 hover:text-text-dark"
              }`}
            >
              {tab}
            </button>
          ))}
        </nav>

        <div key={active} className="animate-tab-in">
          {active === "Resumen" && (
            <SummaryTab
              patient={patient}
              toothMarks={toothMarks}
              treatmentPlan={treatmentPlan}
              sessions={sessions}
              payments={payments}
              consent={consent}
            />
          )}
          {active === "Admisión" && <AdmissionTab patient={patient} />}
          {active === "Historia" && (
            <ClinicalTab patientId={patient.id} history={clinicalHistory} />
          )}
          {active === "Odontograma" && (
            <OdontogramTab patientId={patient.id} marks={toothMarks} />
          )}
          {active === "Plan" && (
            <TreatmentPlanTab patientId={patient.id} items={treatmentPlan} />
          )}
          {active === "Sesiones" && (
            <SessionsTab patientId={patient.id} sessions={sessions} />
          )}
          {active === "Pagos" && (
            <PaymentsTab patientId={patient.id} payments={payments} />
          )}
          {active === "Consentimiento" && (
            <ConsentTab patientId={patient.id} consent={consent} />
          )}
        </div>
      </div>
    </div>
  );
}
