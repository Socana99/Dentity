"use client";

import { useState, useTransition } from "react";
import {
  addTreatmentItem,
  deleteTreatmentItem,
  updateTreatmentItem,
} from "./actions";
import type { TreatmentPlanItem } from "@/lib/types";

const inputClass =
  "w-full rounded-2xl border border-gray-200 bg-gray-50 px-3 py-2 text-sm text-text-dark outline-none focus:border-primary focus:ring-2 focus:ring-primary";

type Row = {
  id: string;
  diagnostico: string;
  detalle: string;
  piezas: string;
  costo: number;
};

export default function TreatmentPlanTab({
  patientId,
  items,
}: {
  patientId: string;
  items: TreatmentPlanItem[];
}) {
  const [rows, setRows] = useState<Row[]>(
    items.map((i) => ({
      id: i.id,
      diagnostico: i.diagnostico ?? "",
      detalle: i.detalle ?? "",
      piezas: i.piezas ?? "",
      costo: i.costo ?? 0,
    }))
  );
  const [, startTransition] = useTransition();

  const total = rows.reduce((sum, r) => sum + (r.costo || 0), 0);

  function patchRow(id: string, patch: Partial<Row>) {
    setRows((prev) => prev.map((r) => (r.id === id ? { ...r, ...patch } : r)));
  }

  function persistRow(row: Row) {
    startTransition(() => {
      updateTreatmentItem(row.id, patientId, {
        diagnostico: row.diagnostico,
        detalle: row.detalle,
        piezas: row.piezas,
        costo: row.costo,
      });
    });
  }

  function addRow() {
    startTransition(async () => {
      const result = await addTreatmentItem(patientId);
      if (result.id) {
        setRows((prev) => [
          ...prev,
          { id: result.id!, diagnostico: "", detalle: "", piezas: "", costo: 0 },
        ]);
      }
    });
  }

  function removeRow(id: string) {
    setRows((prev) => prev.filter((r) => r.id !== id));
    startTransition(() => {
      deleteTreatmentItem(id, patientId);
    });
  }

  return (
    <div className="flex flex-col gap-4">
      {rows.length === 0 && (
        <p className="text-sm text-gray-400">
          No hay diagnósticos en el plan todavía.
        </p>
      )}
      {rows.map((row) => (
        <div key={row.id} className="animate-fade-in-up rounded-2xl bg-white p-4 shadow-sm">
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-[2fr_2.5fr_1fr_1fr_auto] sm:items-end">
            <label>
              <span className="mb-1 block text-xs font-medium text-gray-500">
                Diagnóstico
              </span>
              <input
                value={row.diagnostico}
                onChange={(e) => patchRow(row.id, { diagnostico: e.target.value })}
                onBlur={() => persistRow(row)}
                className={inputClass}
              />
            </label>
            <label>
              <span className="mb-1 block text-xs font-medium text-gray-500">
                Detalle
              </span>
              <input
                value={row.detalle}
                onChange={(e) => patchRow(row.id, { detalle: e.target.value })}
                onBlur={() => persistRow(row)}
                className={inputClass}
              />
            </label>
            <label>
              <span className="mb-1 block text-xs font-medium text-gray-500">
                Diente/s
              </span>
              <input
                value={row.piezas}
                onChange={(e) => patchRow(row.id, { piezas: e.target.value })}
                onBlur={() => persistRow(row)}
                className={inputClass}
              />
            </label>
            <label>
              <span className="mb-1 block text-xs font-medium text-gray-500">
                Costo
              </span>
              <input
                type="number"
                step="0.01"
                value={row.costo === 0 ? "" : row.costo}
                onChange={(e) =>
                  patchRow(row.id, { costo: Number(e.target.value) || 0 })
                }
                onBlur={() => persistRow(row)}
                className={inputClass}
              />
            </label>
            <button
              type="button"
              onClick={() => removeRow(row.id)}
              className="justify-self-start rounded-full px-3 py-2 text-xs font-medium text-red-500 transition-[background-color,transform] duration-150 ease-[var(--ease-out)] hover:bg-red-50 active:scale-95 sm:justify-self-center"
            >
              Eliminar
            </button>
          </div>
        </div>
      ))}

      <div className="flex flex-wrap items-center justify-between gap-3 pt-2">
        <button
          type="button"
          onClick={addRow}
          className="rounded-2xl bg-gradient-to-r from-[#BA8BFF] to-[#D9B4FF] px-5 py-2.5 text-sm font-semibold text-white shadow-md transition-transform duration-150 ease-[var(--ease-out)] active:scale-[0.98]"
        >
          + Agregar diagnóstico
        </button>
        <span className="font-display text-base font-bold text-text-dark">
          TOTAL: ${total.toFixed(2)}
        </span>
      </div>
    </div>
  );
}
