"use client";

import { useActionState, useState } from "react";
import { saveClinicalHistory } from "./actions";
import { ANTECEDENTES_LABELS, EXAMEN_LABELS, type ClinicalHistory } from "@/lib/types";

const inputClass =
  "w-full rounded-2xl border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-text-dark outline-none focus:ring-2 focus:ring-primary";
const labelClass = "mb-1 block text-xs font-medium text-gray-500";

export default function ClinicalTab({
  patientId,
  history,
}: {
  patientId: string;
  history: ClinicalHistory | null;
}) {
  const boundAction = saveClinicalHistory.bind(
    null,
    patientId,
    history?.id ?? null
  );
  const [state, action, pending] = useActionState(boundAction, {
    error: null,
    ok: false,
  });
  const [antecedentes, setAntecedentes] = useState<Record<string, boolean>>(
    history?.antecedentes ?? {}
  );

  return (
    <form action={action} className="flex flex-col gap-6">
      <section>
        <h3 className="mb-2 font-display text-base font-bold text-text-dark">
          1. Motivo de consulta
        </h3>
        <textarea
          name="motivo_consulta"
          defaultValue={history?.motivo_consulta ?? ""}
          rows={2}
          className={inputClass}
        />
      </section>

      <section>
        <h3 className="mb-2 font-display text-base font-bold text-text-dark">
          2. Enfermedad o problema actual
        </h3>
        <textarea
          name="enfermedad_actual"
          defaultValue={history?.enfermedad_actual ?? ""}
          rows={4}
          placeholder="Cronología, localización, características, intensidad, causa aparente, síntomas asociados, evolución, estado actual"
          className={inputClass}
        />
      </section>

      <section>
        <h3 className="mb-2 font-display text-base font-bold text-text-dark">
          3. Antecedentes personales y familiares
        </h3>
        <div className="flex flex-wrap gap-2">
          {Object.entries(ANTECEDENTES_LABELS).map(([key, label]) => {
            const checked = antecedentes[key] ?? false;
            return (
              <label
                key={key}
                className={`cursor-pointer rounded-full px-3.5 py-1.5 text-xs font-medium transition-colors ${
                  checked
                    ? "bg-primary text-white"
                    : "border border-gray-200 bg-white text-text-dark"
                }`}
              >
                <input
                  type="checkbox"
                  name={`antecedente_${key}`}
                  checked={checked}
                  onChange={(e) =>
                    setAntecedentes((prev) => ({
                      ...prev,
                      [key]: e.target.checked,
                    }))
                  }
                  className="sr-only"
                />
                {label}
              </label>
            );
          })}
        </div>
        <textarea
          name="antecedentes_detalle"
          defaultValue={history?.antecedentes_detalle ?? ""}
          rows={2}
          placeholder="Detalle de antecedentes"
          className={`${inputClass} mt-3`}
        />
      </section>

      <section>
        <h3 className="mb-2 font-display text-base font-bold text-text-dark">
          4. Signos vitales
        </h3>
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
          <label>
            <span className={labelClass}>Presión arterial</span>
            <input
              name="presion_arterial"
              defaultValue={history?.presion_arterial ?? ""}
              className={inputClass}
            />
          </label>
          <label>
            <span className={labelClass}>Frecuencia cardíaca (min)</span>
            <input
              name="frecuencia_cardiaca"
              defaultValue={history?.frecuencia_cardiaca ?? ""}
              className={inputClass}
            />
          </label>
          <label>
            <span className={labelClass}>Temperatura °C</span>
            <input
              name="temperatura"
              defaultValue={history?.temperatura ?? ""}
              className={inputClass}
            />
          </label>
          <label>
            <span className={labelClass}>F. respiratoria (min)</span>
            <input
              name="frecuencia_respiratoria"
              defaultValue={history?.frecuencia_respiratoria ?? ""}
              className={inputClass}
            />
          </label>
        </div>
      </section>

      <section>
        <h3 className="mb-2 font-display text-base font-bold text-text-dark">
          5. Examen del sistema estomatognático
        </h3>
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
          {Object.entries(EXAMEN_LABELS).map(([key, label]) => (
            <label key={key}>
              <span className={labelClass}>{label}</span>
              <input
                name={`examen_${key}`}
                defaultValue={history?.examen_estomatognatico?.[key] ?? ""}
                className={inputClass}
              />
            </label>
          ))}
        </div>
      </section>

      <div className="flex items-center gap-3">
        <button
          type="submit"
          disabled={pending}
          className="rounded-2xl bg-gradient-to-r from-[#BA8BFF] to-[#D9B4FF] px-5 py-2.5 text-sm font-semibold text-white shadow-md transition-[opacity,transform] duration-150 ease-[var(--ease-out)] active:scale-[0.98] disabled:opacity-60 disabled:active:scale-100"
        >
          {pending ? "Guardando…" : "Guardar historia clínica"}
        </button>
        {state.ok && (
          <span className="animate-fade-in-up text-sm text-primary">
            Guardado ✓
          </span>
        )}
        {state.error && (
          <span className="text-sm text-red-500">{state.error}</span>
        )}
      </div>
    </form>
  );
}
