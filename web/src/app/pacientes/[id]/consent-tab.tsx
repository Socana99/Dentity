"use client";

import { useState, useTransition } from "react";
import { saveConsent } from "./actions";
import { CONSENT_ITEMS, type ConsentRecord } from "@/lib/types";
import SignaturePad from "./signature-pad";

const inputClass =
  "w-full rounded-2xl border border-gray-200 bg-gray-50 px-3.5 py-2.5 text-sm text-text-dark outline-none focus:border-primary focus:ring-2 focus:ring-primary";
const labelClass = "mb-1 block text-xs font-medium text-gray-500";

export default function ConsentTab({
  patientId,
  consent,
}: {
  patientId: string;
  consent: ConsentRecord | null;
}) {
  const [propositos, setPropositos] = useState(consent?.propositos ?? "");
  const [terapia, setTerapia] = useState(consent?.terapia_procedimientos ?? "");
  const [resultados, setResultados] = useState(
    consent?.resultados_esperados ?? ""
  );
  const [riesgos, setRiesgos] = useState(consent?.riesgos ?? "");
  const [profesional, setProfesional] = useState(
    consent?.profesional_nombre ?? ""
  );
  const [items, setItems] = useState<Record<string, boolean>>(
    consent?.items_aceptados ?? {}
  );
  const [firmaPaciente, setFirmaPaciente] = useState(
    consent?.firma_paciente_base64_png ?? ""
  );
  const [firmaProfesional, setFirmaProfesional] = useState(
    consent?.firma_profesional_base64_png ?? ""
  );
  const [pending, startTransition] = useTransition();
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function save() {
    startTransition(async () => {
      const result = await saveConsent(patientId, consent?.id ?? null, {
        propositos,
        terapia_procedimientos: terapia,
        resultados_esperados: resultados,
        riesgos,
        profesional_nombre: profesional,
        items_aceptados: items,
        firma_paciente_base64_png: firmaPaciente,
        firma_profesional_base64_png: firmaProfesional,
      });
      if (result.ok) {
        setSaved(true);
        setError(null);
      } else {
        setError(result.error);
      }
    });
  }

  return (
    <div className="flex flex-col gap-5">
      <section className="rounded-3xl bg-white p-5 shadow-sm">
        <h3 className="mb-3 font-display text-base font-bold text-text-dark">
          Información entregada por el profesional tratante
        </h3>
        <div className="flex flex-col gap-3">
          <label>
            <span className={labelClass}>Propósitos</span>
            <input
              value={propositos}
              onChange={(e) => setPropositos(e.target.value)}
              className={inputClass}
            />
          </label>
          <label>
            <span className={labelClass}>Terapia y procedimientos propuestos</span>
            <input
              value={terapia}
              onChange={(e) => setTerapia(e.target.value)}
              className={inputClass}
            />
          </label>
          <label>
            <span className={labelClass}>Resultados esperados</span>
            <input
              value={resultados}
              onChange={(e) => setResultados(e.target.value)}
              className={inputClass}
            />
          </label>
          <label>
            <span className={labelClass}>Riesgos de complicaciones clínicas</span>
            <input
              value={riesgos}
              onChange={(e) => setRiesgos(e.target.value)}
              className={inputClass}
            />
          </label>
          <label>
            <span className={labelClass}>Nombre del profesional tratante</span>
            <input
              value={profesional}
              onChange={(e) => setProfesional(e.target.value)}
              className={inputClass}
            />
          </label>
        </div>
      </section>

      <section className="rounded-3xl bg-white p-5 shadow-sm">
        <h3 className="mb-3 font-display text-base font-bold text-text-dark">
          Consentimiento informado del paciente
        </h3>
        <div className="flex flex-col gap-1">
          {Object.entries(CONSENT_ITEMS).map(([key, text]) => (
            <label
              key={key}
              className="flex items-start gap-2 rounded-xl px-2 py-1.5 text-sm text-text-dark transition-colors duration-150 ease-[var(--ease-out)] hover:bg-primary/5"
            >
              <input
                type="checkbox"
                checked={items[key] ?? false}
                onChange={(e) =>
                  setItems((prev) => ({ ...prev, [key]: e.target.checked }))
                }
                className="mt-0.5"
              />
              <span>
                <strong>{key}.</strong> {text}
              </span>
            </label>
          ))}
        </div>
      </section>

      <section className="rounded-3xl bg-white p-5 shadow-sm">
        <h3 className="mb-3 font-display text-base font-bold text-text-dark">
          Firmas
        </h3>
        <div className="flex flex-col gap-5">
          <SignaturePad
            label="Firma del paciente"
            initialValue={firmaPaciente}
            onChange={setFirmaPaciente}
          />
          <SignaturePad
            label="Firma del profesional tratante"
            initialValue={firmaProfesional}
            onChange={setFirmaProfesional}
          />
        </div>
      </section>

      <div className="flex items-center gap-3">
        <button
          type="button"
          onClick={save}
          disabled={pending}
          className="rounded-2xl bg-gradient-to-r from-[#BA8BFF] to-[#D9B4FF] px-5 py-2.5 text-sm font-semibold text-white shadow-md transition-[opacity,transform] duration-150 ease-[var(--ease-out)] active:scale-[0.98] disabled:opacity-60 disabled:active:scale-100"
        >
          {pending ? "Guardando…" : "Guardar consentimiento"}
        </button>
        {saved && (
          <span className="animate-fade-in-up text-sm text-primary">
            Guardado ✓
          </span>
        )}
        {error && (
          <span className="animate-fade-in-up text-sm text-red-500">
            {error}
          </span>
        )}
      </div>
    </div>
  );
}
