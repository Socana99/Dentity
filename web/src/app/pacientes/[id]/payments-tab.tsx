"use client";

import { useState, useTransition } from "react";
import { addPayment, updatePayment } from "./actions";
import type { PaymentRecord } from "@/lib/types";

type Row = {
  id: string;
  fecha: string;
  tratamiento_realizado: string;
  debe: number;
  haber: number;
  saldo: number;
};

function toDateInputValue(iso: string) {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "";
  return d.toISOString().slice(0, 10);
}

export default function PaymentsTab({
  patientId,
  payments,
}: {
  patientId: string;
  payments: PaymentRecord[];
}) {
  const [rows, setRows] = useState<Row[]>(
    payments.map((p) => ({
      id: p.id,
      fecha: p.fecha,
      tratamiento_realizado: p.tratamiento_realizado ?? "",
      debe: p.debe ?? 0,
      haber: p.haber ?? 0,
      saldo: p.saldo ?? 0,
    }))
  );
  const [, startTransition] = useTransition();

  function patchRow(id: string, patch: Partial<Row>) {
    setRows((prev) =>
      prev.map((r) => {
        if (r.id !== id) return r;
        const next = { ...r, ...patch };
        next.saldo = next.debe - next.haber;
        return next;
      })
    );
  }

  function persistRow(row: Row) {
    startTransition(() => {
      updatePayment(row.id, patientId, {
        fecha: row.fecha,
        tratamiento_realizado: row.tratamiento_realizado,
        debe: row.debe,
        haber: row.haber,
      });
    });
  }

  function addRow() {
    const prevSaldo = rows.length > 0 ? rows[rows.length - 1].saldo : 0;
    startTransition(async () => {
      const result = await addPayment(patientId, prevSaldo);
      if (result.id && result.fecha) {
        setRows((prev) => [
          ...prev,
          {
            id: result.id!,
            fecha: result.fecha!,
            tratamiento_realizado: "",
            debe: 0,
            haber: 0,
            saldo: prevSaldo,
          },
        ]);
      }
    });
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="overflow-x-auto rounded-2xl bg-white shadow-sm">
        <table className="min-w-full text-sm">
          <thead>
            <tr className="border-b border-gray-100 text-left text-xs font-semibold text-gray-400">
              <th className="px-4 py-3">Fecha</th>
              <th className="px-4 py-3">Tratamiento realizado</th>
              <th className="px-4 py-3">Debe</th>
              <th className="px-4 py-3">Haber</th>
              <th className="px-4 py-3">Saldo</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.id} className="border-b border-gray-50 last:border-0">
                <td className="px-4 py-2">
                  <input
                    type="date"
                    value={toDateInputValue(row.fecha)}
                    onChange={(e) => {
                      const iso = new Date(e.target.value).toISOString();
                      patchRow(row.id, { fecha: iso });
                    }}
                    onBlur={() => persistRow(row)}
                    className="rounded-xl border border-gray-200 bg-gray-50 px-2 py-1.5 text-sm text-text-dark outline-none focus:border-primary focus:ring-2 focus:ring-primary"
                  />
                </td>
                <td className="px-4 py-2">
                  <input
                    value={row.tratamiento_realizado}
                    onChange={(e) =>
                      patchRow(row.id, { tratamiento_realizado: e.target.value })
                    }
                    onBlur={() => persistRow(row)}
                    className="w-56 rounded-xl border border-gray-200 bg-gray-50 px-2 py-1.5 text-sm text-text-dark outline-none focus:border-primary focus:ring-2 focus:ring-primary"
                  />
                </td>
                <td className="px-4 py-2">
                  <input
                    type="number"
                    step="0.01"
                    value={row.debe === 0 ? "" : row.debe}
                    onChange={(e) =>
                      patchRow(row.id, { debe: Number(e.target.value) || 0 })
                    }
                    onBlur={() => persistRow(row)}
                    className="w-24 rounded-xl border border-gray-200 bg-gray-50 px-2 py-1.5 text-sm text-text-dark outline-none focus:border-primary focus:ring-2 focus:ring-primary"
                  />
                </td>
                <td className="px-4 py-2">
                  <input
                    type="number"
                    step="0.01"
                    value={row.haber === 0 ? "" : row.haber}
                    onChange={(e) =>
                      patchRow(row.id, { haber: Number(e.target.value) || 0 })
                    }
                    onBlur={() => persistRow(row)}
                    className="w-24 rounded-xl border border-gray-200 bg-gray-50 px-2 py-1.5 text-sm text-text-dark outline-none focus:border-primary focus:ring-2 focus:ring-primary"
                  />
                </td>
                <td className="px-4 py-2 font-semibold text-text-dark">
                  ${row.saldo.toFixed(2)}
                </td>
              </tr>
            ))}
            {rows.length === 0 && (
              <tr>
                <td colSpan={5} className="px-4 py-6 text-center text-gray-400">
                  No hay pagos registrados todavía.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      <button
        type="button"
        onClick={addRow}
        className="self-start rounded-2xl bg-gradient-to-r from-[#BA8BFF] to-[#D9B4FF] px-5 py-2.5 text-sm font-semibold text-white shadow-md transition-transform duration-150 ease-[var(--ease-out)] active:scale-[0.98]"
      >
        + Agregar pago
      </button>
    </div>
  );
}
