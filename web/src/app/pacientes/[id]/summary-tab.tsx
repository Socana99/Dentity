import type {
  ConsentRecord,
  Patient,
  PaymentRecord,
  ToothMark,
  TreatmentPlanItem,
  TreatmentSession,
} from "@/lib/types";

function fmt(value: string | number | null | undefined): string {
  if (value === null || value === undefined || value === "") return "—";
  return String(value);
}

function money(n: number): string {
  return `$${n.toFixed(2)}`;
}

const PERSONAL_FIELDS: [keyof Patient, string][] = [
  ["cedula", "Cédula"],
  ["telefono", "Teléfono"],
  ["direccion", "Dirección"],
  ["edad", "Edad"],
  ["sexo", "Sexo"],
  ["estado_civil", "Estado civil"],
  ["nacionalidad", "Nacionalidad"],
  ["ocupacion", "Ocupación"],
  ["empresa", "Empresa"],
  ["tipo_seguro", "Seguro de salud"],
  ["contacto_emergencia_nombre", "Contacto de emergencia"],
  ["contacto_emergencia_telefono", "Teléfono de emergencia"],
];

export default function SummaryTab({
  patient,
  toothMarks,
  treatmentPlan,
  sessions,
  payments,
  consent,
}: {
  patient: Patient;
  toothMarks: ToothMark[];
  treatmentPlan: TreatmentPlanItem[];
  sessions: TreatmentSession[];
  payments: PaymentRecord[];
  consent: ConsentRecord | null;
}) {
  const totalPlan = treatmentPlan.reduce((sum, i) => sum + (i.costo ?? 0), 0);
  const totalDebe = payments.reduce((sum, p) => sum + (p.debe ?? 0), 0);
  const totalHaber = payments.reduce((sum, p) => sum + (p.haber ?? 0), 0);
  const saldoActual =
    payments.length > 0 ? payments[payments.length - 1].saldo ?? 0 : 0;
  const markedTeeth = toothMarks.filter((m) => m.symbol !== "ninguno").length;
  const consentStatus =
    consent?.firma_paciente_base64_png && consent?.firma_profesional_base64_png
      ? "Firmado"
      : consent
        ? "Pendiente de firma"
        : "Sin iniciar";

  return (
    <div className="flex flex-col gap-5">
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        <StatCard label="Sesiones" value={String(sessions.length)} accent="primary" />
        <StatCard label="Piezas marcadas" value={String(markedTeeth)} accent="coral" />
        <StatCard
          label="Ítems en el plan"
          value={String(treatmentPlan.length)}
          accent="lavender"
        />
        <StatCard label="Consentimiento" value={consentStatus} accent="primary" />
      </div>

      <div className="grid grid-cols-1 gap-5 lg:grid-cols-2">
        <div className="rounded-3xl bg-white p-5 shadow-sm">
          <h3 className="font-display text-base font-bold text-text-dark">
            Presupuesto total
          </h3>
          <p className="mt-2 font-display text-3xl font-extrabold text-primary">
            {money(totalPlan)}
          </p>
          <p className="mt-1 text-xs text-gray-400">
            {treatmentPlan.length} diagnóstico(s) en el plan de tratamiento
          </p>
        </div>

        <div className="rounded-3xl bg-white p-5 shadow-sm">
          <h3 className="font-display text-base font-bold text-text-dark">
            Pagos
          </h3>
          <div className="mt-3 grid grid-cols-3 gap-3 text-center">
            <div>
              <p className="text-xs text-gray-400">Debe</p>
              <p className="mt-1 font-semibold text-text-dark">
                {money(totalDebe)}
              </p>
            </div>
            <div>
              <p className="text-xs text-gray-400">Haber</p>
              <p className="mt-1 font-semibold text-text-dark">
                {money(totalHaber)}
              </p>
            </div>
            <div>
              <p className="text-xs text-gray-400">Saldo</p>
              <p className="mt-1 font-semibold text-coral">
                {money(saldoActual)}
              </p>
            </div>
          </div>
        </div>
      </div>

      <div className="rounded-3xl bg-white p-5 shadow-sm">
        <h3 className="mb-3 font-display text-base font-bold text-text-dark">
          Datos personales
        </h3>
        <dl className="grid grid-cols-1 gap-x-6 gap-y-3 sm:grid-cols-2 lg:grid-cols-3">
          {PERSONAL_FIELDS.map(([key, label]) => (
            <div key={key}>
              <dt className="text-xs font-medium text-gray-400">{label}</dt>
              <dd className="mt-0.5 truncate text-sm text-text-dark">
                {fmt(patient[key])}
              </dd>
            </div>
          ))}
        </dl>
      </div>
    </div>
  );
}

function StatCard({
  label,
  value,
  accent,
}: {
  label: string;
  value: string;
  accent: "primary" | "coral" | "lavender";
}) {
  const accentClass =
    accent === "coral"
      ? "bg-coral/15 text-coral"
      : accent === "lavender"
        ? "bg-lavender/20 text-lavender"
        : "bg-primary/15 text-primary";
  return (
    <div className="rounded-2xl bg-white p-4 shadow-sm">
      <span
        className={`inline-flex rounded-full px-2.5 py-1 text-[11px] font-semibold ${accentClass}`}
      >
        {label}
      </span>
      <p className="mt-2 font-display text-xl font-extrabold text-text-dark">
        {value}
      </p>
    </div>
  );
}
