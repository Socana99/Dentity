"use client";

import { useActionState } from "react";
import { updateAdmission } from "./actions";
import type { Patient } from "@/lib/types";

const PROVINCIAS = [
  "Azuay", "Bolívar", "Cañar", "Carchi", "Chimborazo", "Cotopaxi", "El Oro",
  "Esmeraldas", "Galápagos", "Guayas", "Imbabura", "Loja", "Los Ríos",
  "Manabí", "Morona Santiago", "Napo", "Orellana", "Pastaza", "Pichincha",
  "Santa Elena", "Santo Domingo de los Tsáchilas", "Sucumbíos", "Tungurahua",
  "Zamora Chinchipe",
];

const FIELDS: [keyof Patient, string][] = [
  ["institucion", "Institución del sistema"],
  ["unidad_operativa", "Unidad operativa"],
  ["numero_historia_clinica", "N° historia clínica"],
  ["parroquia", "Parroquia"],
  ["canton", "Cantón"],
  ["apellido_paterno", "Apellido paterno"],
  ["apellido_materno", "Apellido materno"],
  ["primer_nombre", "Primer nombre"],
  ["segundo_nombre", "Segundo nombre"],
  ["cedula", "N° cédula de ciudadanía"],
  ["direccion", "Dirección de residencia habitual"],
  ["barrio", "Barrio"],
  ["telefono", "N° teléfono"],
  ["lugar_nacimiento", "Lugar de nacimiento"],
  ["nacionalidad", "Nacionalidad (país)"],
  ["grupo_cultural", "Grupo cultural"],
  ["instruccion", "Instrucción / último año aprobado"],
  ["ocupacion", "Ocupación"],
  ["empresa", "Empresa donde trabaja"],
  ["tipo_seguro", "Tipo de seguro de salud"],
  ["referido_de", "Referido de"],
  ["contacto_emergencia_nombre", "En caso necesario llamar a"],
  ["contacto_emergencia_parentesco", "Parentesco / afinidad"],
  ["contacto_emergencia_direccion", "Dirección del contacto"],
  ["contacto_emergencia_telefono", "Teléfono del contacto"],
];

const inputClass =
  "w-full rounded-2xl border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-text-dark outline-none focus:ring-2 focus:ring-primary";
const labelClass = "mb-1 block text-xs font-medium text-gray-500";

export default function AdmissionTab({ patient }: { patient: Patient }) {
  const boundAction = updateAdmission.bind(null, patient.id);
  const [state, action, pending] = useActionState(boundAction, {
    error: null,
    ok: false,
  });

  return (
    <form action={action} className="flex flex-col gap-6">
      <section>
        <h3 className="mb-3 font-display text-base font-bold text-text-dark">
          1. Registro de primera admisión
        </h3>
        <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {FIELDS.map(([key, label]) => (
            <label key={key} className="block">
              <span className={labelClass}>{label}</span>
              <input
                name={key}
                defaultValue={patient[key]?.toString() ?? ""}
                className={inputClass}
              />
            </label>
          ))}
          <label className="block">
            <span className={labelClass}>Provincia</span>
            <select
              name="provincia"
              defaultValue={patient.provincia ?? ""}
              className={inputClass}
            >
              <option value="">Selecciona…</option>
              {PROVINCIAS.map((p) => (
                <option key={p} value={p}>
                  {p}
                </option>
              ))}
            </select>
          </label>
        </div>
      </section>

      <section className="grid grid-cols-1 gap-3 sm:grid-cols-3">
        <label className="block">
          <span className={labelClass}>Edad (años cumplidos)</span>
          <input
            name="edad"
            type="number"
            defaultValue={patient.edad ?? 0}
            className={inputClass}
          />
        </label>
        <label className="block">
          <span className={labelClass}>Sexo</span>
          <select
            name="sexo"
            defaultValue={patient.sexo ?? "F"}
            className={inputClass}
          >
            <option value="M">Masculino</option>
            <option value="F">Femenino</option>
          </select>
        </label>
        <label className="block">
          <span className={labelClass}>Estado civil</span>
          <select
            name="estado_civil"
            defaultValue={patient.estado_civil ?? "SOL"}
            className={inputClass}
          >
            <option value="SOL">Soltero</option>
            <option value="CAS">Casado</option>
            <option value="DIV">Divorciado</option>
            <option value="VIU">Viudo</option>
            <option value="U-L">Unión libre</option>
          </select>
        </label>
      </section>

      <div className="flex items-center gap-3">
        <button
          type="submit"
          disabled={pending}
          className="rounded-2xl bg-gradient-to-r from-[#BA8BFF] to-[#D9B4FF] px-5 py-2.5 text-sm font-semibold text-white shadow-md transition-[opacity,transform] duration-150 ease-[var(--ease-out)] active:scale-[0.98] disabled:opacity-60 disabled:active:scale-100"
        >
          {pending ? "Guardando…" : "Guardar admisión"}
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
