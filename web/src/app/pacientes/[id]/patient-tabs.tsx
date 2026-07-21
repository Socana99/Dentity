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
import AdmissionTab from "./admission-tab";
import ClinicalTab from "./clinical-tab";
import OdontogramTab from "./odontogram-tab";
import TreatmentPlanTab from "./treatment-plan-tab";
import SessionsTab from "./sessions-tab";
import PaymentsTab from "./payments-tab";
import ConsentTab from "./consent-tab";

const TABS = [
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
  const [active, setActive] = useState<(typeof TABS)[number]>("Admisión");

  return (
    <div>
      <div className="-mx-6 mb-6 overflow-x-auto px-6">
        <div className="flex w-max gap-2">
          {TABS.map((tab) => (
            <button
              key={tab}
              type="button"
              onClick={() => setActive(tab)}
              className={`whitespace-nowrap rounded-full px-4 py-2 text-sm font-medium transition-[background-color,color,transform] duration-150 ease-[var(--ease-out)] active:scale-95 ${
                active === tab
                  ? "bg-primary text-white shadow-sm"
                  : "bg-white text-text-dark hover:bg-primary/10"
              }`}
            >
              {tab}
            </button>
          ))}
        </div>
      </div>

      <div key={active} className="animate-tab-in rounded-3xl bg-bg">
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
  );
}
