"use client";

import { useState, useTransition } from "react";
import { addSession, updateSession } from "./actions";
import type { TreatmentSession } from "@/lib/types";

const inputClass =
  "w-full rounded-2xl border border-gray-200 bg-gray-50 px-3 py-2 text-sm text-text-dark outline-none focus:border-primary focus:ring-2 focus:ring-primary";
const labelClass = "mb-1 block text-xs font-medium text-gray-500";

type Row = {
  id: string;
  numero_sesion: number;
  fecha: string;
  diagnosticos_complicaciones: string;
  procedimientos: string;
  prescripciones: string;
  profesional_codigo: string;
};

function toDateInputValue(iso: string) {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "";
  return d.toISOString().slice(0, 10);
}

export default function SessionsTab({
  patientId,
  sessions,
}: {
  patientId: string;
  sessions: TreatmentSession[];
}) {
  const [rows, setRows] = useState<Row[]>(
    sessions.map((s) => ({
      id: s.id,
      numero_sesion: s.numero_sesion,
      fecha: s.fecha,
      diagnosticos_complicaciones: s.diagnosticos_complicaciones ?? "",
      procedimientos: s.procedimientos ?? "",
      prescripciones: s.prescripciones ?? "",
      profesional_codigo: s.profesional_codigo ?? "",
    }))
  );
  const [, startTransition] = useTransition();

  function patchRow(id: string, patch: Partial<Row>) {
    setRows((prev) => prev.map((r) => (r.id === id ? { ...r, ...patch } : r)));
  }

  function persistRow(row: Row) {
    startTransition(() => {
      updateSession(row.id, patientId, {
        fecha: row.fecha,
        diagnosticos_complicaciones: row.diagnosticos_complicaciones,
        procedimientos: row.procedimientos,
        prescripciones: row.prescripciones,
        profesional_codigo: row.profesional_codigo,
      });
    });
  }

  function addRow() {
    startTransition(async () => {
      const result = await addSession(patientId, rows.length + 1);
      if (result.id && result.fecha) {
        setRows((prev) => [
          ...prev,
          {
            id: result.id!,
            numero_sesion: prev.length + 1,
            fecha: result.fecha!,
            diagnosticos_complicaciones: "",
            procedimientos: "",
            prescripciones: "",
            profesional_codigo: "",
          },
        ]);
      }
    });
  }

  return (
    <div className="flex flex-col gap-4">
      {rows.length === 0 && (
        <p className="text-sm text-gray-400">No hay sesiones registradas todavía.</p>
      )}
      {rows.map((row) => (
        <div key={row.id} className="animate-fade-in-up rounded-2xl bg-white p-4 shadow-sm">
          <div className="mb-3 flex flex-wrap items-center gap-3">
            <span className="font-display text-sm font-bold text-text-dark">
              Sesión {row.numero_sesion}
            </span>
            <input
              type="date"
              value={toDateInputValue(row.fecha)}
              onChange={(e) => {
                const iso = new Date(e.target.value).toISOString();
                patchRow(row.id, { fecha: iso });
              }}
              onBlur={() => persistRow(row)}
              className="rounded-xl border border-gray-200 bg-gray-50 px-3 py-1.5 text-sm text-text-dark outline-none focus:border-primary focus:ring-2 focus:ring-primary"
            />
          </div>
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
            <label>
              <span className={labelClass}>Diagnósticos y complicaciones</span>
              <input
                value={row.diagnosticos_complicaciones}
                onChange={(e) =>
                  patchRow(row.id, { diagnosticos_complicaciones: e.target.value })
                }
                onBlur={() => persistRow(row)}
                className={inputClass}
              />
            </label>
            <label>
              <span className={labelClass}>Procedimientos</span>
              <input
                value={row.procedimientos}
                onChange={(e) => patchRow(row.id, { procedimientos: e.target.value })}
                onBlur={() => persistRow(row)}
                className={inputClass}
              />
            </label>
            <label>
              <span className={labelClass}>Prescripciones</span>
              <input
                value={row.prescripciones}
                onChange={(e) => patchRow(row.id, { prescripciones: e.target.value })}
                onBlur={() => persistRow(row)}
                className={inputClass}
              />
            </label>
            <label>
              <span className={labelClass}>Código / firma profesional</span>
              <input
                value={row.profesional_codigo}
                onChange={(e) =>
                  patchRow(row.id, { profesional_codigo: e.target.value })
                }
                onBlur={() => persistRow(row)}
                className={inputClass}
              />
            </label>
          </div>
        </div>
      ))}

      <button
        type="button"
        onClick={addRow}
        className="self-start rounded-2xl bg-gradient-to-r from-[#BA8BFF] to-[#D9B4FF] px-5 py-2.5 text-sm font-semibold text-white shadow-md transition-transform duration-150 ease-[var(--ease-out)] active:scale-[0.98]"
      >
        + Nueva sesión
      </button>
    </div>
  );
}
