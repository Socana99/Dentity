"use client";

import { useState, useTransition } from "react";
import { saveToothMark } from "./actions";
import {
  FDI_QUADRANTS,
  ODONTO_SYMBOL_LABELS,
  type OdontoSymbol,
  type ToothMark,
} from "@/lib/types";
import ToothIcon from "./tooth-icon";

type MarkState = {
  id: string | null;
  symbol: OdontoSymbol;
  movilidad: number;
  recesion: boolean;
  color: string;
};

const EMPTY: MarkState = {
  id: null,
  symbol: "ninguno",
  movilidad: 0,
  recesion: false,
  color: "rojo",
};

const UPPER_ARCH = [...FDI_QUADRANTS[0][1], ...FDI_QUADRANTS[1][1]];
const LOWER_ARCH = [...FDI_QUADRANTS[2][1], ...FDI_QUADRANTS[3][1]];

export default function OdontogramTab({
  patientId,
  marks: initialMarks,
}: {
  patientId: string;
  marks: ToothMark[];
}) {
  const [marks, setMarks] = useState<Record<number, MarkState>>(() => {
    const map: Record<number, MarkState> = {};
    for (const m of initialMarks) {
      map[m.tooth_number] = {
        id: m.id,
        symbol: m.symbol,
        movilidad: m.movilidad,
        recesion: m.recesion,
        color: m.color,
      };
    }
    return map;
  });
  const [selected, setSelected] = useState<number | null>(null);
  const [pending, startTransition] = useTransition();
  const [saved, setSaved] = useState(false);

  const current = selected != null ? marks[selected] ?? EMPTY : null;

  function updateCurrent(patch: Partial<MarkState>) {
    if (selected == null) return;
    setMarks((prev) => ({
      ...prev,
      [selected]: { ...(prev[selected] ?? EMPTY), ...patch },
    }));
    setSaved(false);
  }

  function save() {
    if (selected == null || !current) return;
    startTransition(async () => {
      const result = await saveToothMark(patientId, selected, current.id, {
        symbol: current.symbol,
        movilidad: current.movilidad,
        recesion: current.recesion,
        color: current.color,
      });
      if (result.ok) {
        setSaved(true);
        setMarks((prev) => ({
          ...prev,
          [selected]: { ...(prev[selected] ?? EMPTY), id: result.id },
        }));
      }
    });
  }

  function ArchRow({ teeth, flip }: { teeth: number[]; flip: boolean }) {
    const left = teeth.slice(0, 8);
    const right = teeth.slice(8);
    const renderTooth = (tooth: number) => {
      const marked = (marks[tooth]?.symbol ?? "ninguno") !== "ninguno";
      const isSelected = selected === tooth;
      return (
        <button
          key={tooth}
          type="button"
          onClick={() => setSelected(tooth)}
          className="flex flex-col items-center gap-1 rounded-lg p-0.5 transition-transform duration-150 ease-[var(--ease-out)] active:scale-90"
        >
          <ToothIcon
            toothNumber={tooth}
            marked={marked}
            className={`h-9 w-7 sm:h-11 sm:w-8 drop-shadow-sm transition-transform duration-150 ease-[var(--ease-out)] ${
              flip ? "-scale-y-100" : ""
            } ${isSelected ? "scale-110" : ""}`}
          />
          <span
            className={`flex h-6 w-6 items-center justify-center rounded-full text-[10px] font-semibold transition-colors duration-150 ${
              isSelected
                ? "bg-primary text-white ring-2 ring-primary/40"
                : marked
                  ? "bg-coral text-white"
                  : "border border-gray-200 bg-white text-gray-500"
            }`}
          >
            {tooth}
          </span>
        </button>
      );
    };
    return (
      <div className="flex items-start justify-center gap-1 overflow-x-auto sm:gap-1.5">
        {left.map(renderTooth)}
        <div className="w-2 shrink-0 sm:w-3" />
        {right.map(renderTooth)}
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-6">
      <p className="text-sm text-gray-500">
        Toca una pieza (notación FDI) para registrar su estado. Las piezas
        marcadas se resaltan en color coral.
      </p>

      <div className="rounded-3xl bg-white p-4 shadow-sm sm:p-6">
        <p className="mb-2 text-center text-[11px] font-semibold uppercase tracking-wide text-gray-400">
          Arcada superior
        </p>
        <ArchRow teeth={UPPER_ARCH} flip />

        <div className="my-5 border-t border-dashed border-gray-200" />

        <ArchRow teeth={LOWER_ARCH} flip={false} />
        <p className="mt-2 text-center text-[11px] font-semibold uppercase tracking-wide text-gray-400">
          Arcada inferior
        </p>
      </div>

      {current && selected != null && (
        <div
          key={selected}
          className="animate-fade-in-up rounded-3xl bg-white p-5 shadow-sm"
        >
          <h3 className="mb-3 font-display text-base font-bold text-text-dark">
            Pieza {selected}
          </h3>
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
            <label className="block">
              <span className="mb-1 block text-xs font-medium text-gray-500">
                Estado
              </span>
              <select
                value={current.symbol}
                onChange={(e) =>
                  updateCurrent({ symbol: e.target.value as OdontoSymbol })
                }
                className="w-full rounded-2xl border border-gray-200 bg-gray-50 px-3.5 py-2.5 text-sm text-text-dark outline-none focus:border-primary focus:ring-2 focus:ring-primary"
              >
                {Object.entries(ODONTO_SYMBOL_LABELS).map(([value, label]) => (
                  <option key={value} value={value}>
                    {label}
                  </option>
                ))}
              </select>
            </label>
            <label className="block">
              <span className="mb-1 block text-xs font-medium text-gray-500">
                Movilidad (0-3)
              </span>
              <select
                value={current.movilidad}
                onChange={(e) =>
                  updateCurrent({ movilidad: Number(e.target.value) })
                }
                className="w-full rounded-2xl border border-gray-200 bg-gray-50 px-3.5 py-2.5 text-sm text-text-dark outline-none focus:border-primary focus:ring-2 focus:ring-primary"
              >
                {[0, 1, 2, 3].map((v) => (
                  <option key={v} value={v}>
                    {v}
                  </option>
                ))}
              </select>
            </label>
            <label className="block">
              <span className="mb-1 block text-xs font-medium text-gray-500">
                Color de marca
              </span>
              <select
                value={current.color}
                onChange={(e) => updateCurrent({ color: e.target.value })}
                className="w-full rounded-2xl border border-gray-200 bg-gray-50 px-3.5 py-2.5 text-sm text-text-dark outline-none focus:border-primary focus:ring-2 focus:ring-primary"
              >
                <option value="rojo">Rojo (patología actual)</option>
                <option value="azul">Azul (tratamiento realizado)</option>
              </select>
            </label>
          </div>
          <label className="mt-3 flex items-center gap-2 text-sm text-text-dark">
            <input
              type="checkbox"
              checked={current.recesion}
              onChange={(e) => updateCurrent({ recesion: e.target.checked })}
            />
            Recesión
          </label>
          <div className="mt-4 flex items-center gap-3">
            <button
              type="button"
              onClick={save}
              disabled={pending}
              className="rounded-2xl bg-gradient-to-r from-[#BA8BFF] to-[#D9B4FF] px-5 py-2.5 text-sm font-semibold text-white shadow-md transition-[opacity,transform] duration-150 ease-[var(--ease-out)] active:scale-[0.98] disabled:opacity-60 disabled:active:scale-100"
            >
              {pending ? "Guardando…" : "Guardar pieza"}
            </button>
            {saved && (
              <span className="animate-fade-in-up text-sm text-primary">
                Guardado ✓
              </span>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
