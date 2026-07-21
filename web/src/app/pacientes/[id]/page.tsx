import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import {
  avatarColorFor,
  initials,
  nombreCompleto,
  type ClinicalHistory,
  type ConsentRecord,
  type Patient,
  type PaymentRecord,
  type ToothMark,
  type TreatmentPlanItem,
  type TreatmentSession,
} from "@/lib/types";
import PatientTabs from "./patient-tabs";

export const dynamic = "force-dynamic";

export default async function PatientDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const supabase = await createClient();

  const [
    { data: patient },
    { data: clinicalHistory },
    { data: toothMarks },
    { data: treatmentPlan },
    { data: sessions },
    { data: payments },
    { data: consent },
  ] = await Promise.all([
    supabase.from("patients").select("*").eq("id", id).single<Patient>(),
    supabase
      .from("clinical_history")
      .select("*")
      .eq("patient_id", id)
      .order("updated_at", { ascending: false })
      .limit(1)
      .maybeSingle<ClinicalHistory>(),
    supabase
      .from("tooth_marks")
      .select("*")
      .eq("patient_id", id)
      .returns<ToothMark[]>(),
    supabase
      .from("treatment_plan")
      .select("*")
      .eq("patient_id", id)
      .order("updated_at", { ascending: true })
      .returns<TreatmentPlanItem[]>(),
    supabase
      .from("treatment_sessions")
      .select("*")
      .eq("patient_id", id)
      .order("numero_sesion", { ascending: true })
      .returns<TreatmentSession[]>(),
    supabase
      .from("payments")
      .select("*")
      .eq("patient_id", id)
      .order("fecha", { ascending: true })
      .returns<PaymentRecord[]>(),
    supabase
      .from("consents")
      .select("*")
      .eq("patient_id", id)
      .order("updated_at", { ascending: false })
      .limit(1)
      .maybeSingle<ConsentRecord>(),
  ]);

  if (!patient) notFound();

  const name = nombreCompleto(patient) || "Paciente";
  const color = avatarColorFor(patient.apellido_paterno ?? "");

  return (
    <main className="min-h-screen bg-bg pb-16">
      <div className="rounded-b-[2rem] bg-gradient-to-br from-[#7FAAD6] to-primary pb-9 text-white shadow-md">
        <div className="flex items-center gap-3 px-6 pt-5">
          <Link
            href="/pacientes"
            className="rounded-full p-1 transition-[background-color,transform] duration-150 ease-[var(--ease-out)] hover:bg-white/15 active:scale-90"
          >
            <BackIcon className="h-5 w-5" />
          </Link>
          <span className="text-xs font-medium uppercase tracking-wide text-white/75">
            Ficha del paciente
          </span>
        </div>

        <div className="mt-4 flex items-center gap-4 px-6">
          <div
            className="flex h-16 w-16 shrink-0 items-center justify-center rounded-full bg-white text-xl font-bold shadow-sm"
            style={{ color }}
          >
            {initials(patient)}
          </div>
          <div className="min-w-0">
            <h1 className="truncate font-display text-2xl font-extrabold tracking-tight">
              {name}
            </h1>
            <div className="mt-1.5 flex flex-wrap gap-2">
              <span className="rounded-full bg-white/15 px-2.5 py-1 text-xs font-medium">
                HC: {patient.numero_historia_clinica || "—"}
              </span>
              <span className="rounded-full bg-white/15 px-2.5 py-1 text-xs font-medium">
                Cédula: {patient.cedula || "—"}
              </span>
            </div>
          </div>
        </div>
      </div>

      <div className="mx-auto max-w-4xl px-6 pb-16 pt-6">
        <PatientTabs
          patient={patient}
          clinicalHistory={clinicalHistory ?? null}
          toothMarks={toothMarks ?? []}
          treatmentPlan={treatmentPlan ?? []}
          sessions={sessions ?? []}
          payments={payments ?? []}
          consent={consent ?? null}
        />
      </div>
    </main>
  );
}

function BackIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" className={className} aria-hidden>
      <polyline points="15 18 9 12 15 6" />
    </svg>
  );
}
