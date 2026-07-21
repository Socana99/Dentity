"use client";

import { useMemo, useState, useTransition } from "react";
import { saveToothMark } from "./actions";
import {
  FDI_QUADRANTS,
  ODONTO_SYMBOL_LABELS,
  type OdontoSymbol,
  type ToothMark,
} from "@/lib/types";
import { SYMBOL_STYLE, TOOTH_PATHS, toothShapeFor } from "./tooth-icon";

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

// Misma X en ambos modos (solo la corona se mueve verticalmente); el anillo
// con el número queda fijo como referencia estable entre las dos arcadas.
const SPACING = 38;
const MIDLINE_GAP = 16;
const MARGIN_X = 48;
const ARCH_AMPLITUDE = 36;

const UPPER_CROWN_Y = 65;
const UPPER_RING_Y = 145;
const LOWER_RING_Y = 175;
const LOWER_CROWN_Y = 255;

function archX(i: number) {
  const half = i < 8 ? i : i - 8;
  const side = i < 8 ? 0 : 1;
  return MARGIN_X + half * SPACING + side * (7 * SPACING + MIDLINE_GAP);
}

// Como una boca real: las piezas centrales (incisivos, i≈7-8) casi no se
// mueven, y las piezas del fondo (molares, i≈0 y i≈15 — "las comisuras")
// se acercan a la arcada opuesta, cerrando el óvalo por los costados.
function archOffset(i: number, arch: boolean, upper: boolean) {
  if (!arch) return 0;
  const t = (i - 7.5) / 7.5;
  const bulge = ARCH_AMPLITUDE * t * t;
  return upper ? bulge : -bulge;
}

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
  const [archView, setArchView] = useState(true);
  const [pending, startTransition] = useTransition();
  const [saved, setSaved] = useState(false);

  const current = selected != null ? marks[selected] ?? EMPTY : null;

  const teeth = useMemo(() => {
    const list: {
      tooth: number;
      x: number;
      crownY: number;
      ringY: number;
      upper: boolean;
    }[] = [];
    UPPER_ARCH.forEach((tooth, i) => {
      list.push({
        tooth,
        x: archX(i),
        crownY: UPPER_CROWN_Y + archOffset(i, archView, true),
        ringY: UPPER_RING_Y,
        upper: true,
      });
    });
    LOWER_ARCH.forEach((tooth, i) => {
      list.push({
        tooth,
        x: archX(i),
        crownY: LOWER_CROWN_Y + archOffset(i, archView, false),
        ringY: LOWER_RING_Y,
        upper: false,
      });
    });
    return list;
  }, [archView]);

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

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <p className="text-sm text-gray-500">
          Toca una pieza para registrar su estado. El color de la corona
          refleja la condición guardada.
        </p>
        <button
          type="button"
          onClick={() => setArchView((v) => !v)}
          className="flex shrink-0 items-center gap-2 rounded-full bg-primary/10 px-4 py-2 text-xs font-semibold text-primary transition-[background-color,transform] duration-150 ease-[var(--ease-out)] hover:bg-primary/20 active:scale-95"
        >
          <MouthIcon className="h-4 w-4" />
          {archView ? "Ver como lista" : "Ver como boca"}
        </button>
      </div>

      <div className="rounded-3xl bg-white p-2 shadow-sm sm:p-4">
        <svg viewBox="0 0 700 300" className="h-auto w-full select-none">
          {teeth.map(({ tooth, x, crownY, ringY, upper }) => {
            const mark = marks[tooth];
            const symbol = mark?.symbol ?? "ninguno";
            const style = SYMBOL_STYLE[symbol];
            const shape = toothShapeFor(tooth);
            const isSelected = selected === tooth;
            const marked = symbol !== "ninguno";
            const ringFill = isSelected ? "#A7C7E7" : marked ? style.fill : "#FFFFFF";
            const ringStroke = isSelected ? "#A7C7E7" : marked ? style.stroke : "#D1D5DB";
            const ringText = isSelected || marked ? "#FFFFFF" : "#6B7280";
            const badgeY = upper ? crownY - 24 : crownY + 24;

            return (
              <g
                key={tooth}
                role="button"
                tabIndex={0}
                aria-label={`Pieza ${tooth}`}
                onClick={() => setSelected(tooth)}
                onKeyDown={(e) => {
                  if (e.key === "Enter" || e.key === " ") setSelected(tooth);
                }}
                className="cursor-pointer focus:outline-none"
              >
                <rect
                  x={x - 17}
                  y={(upper ? crownY - 30 : ringY - 14) - 4}
                  width={34}
                  height={
                    (upper ? ringY + 14 : crownY + 30) -
                    (upper ? crownY - 30 : ringY - 14) +
                    8
                  }
                  fill="transparent"
                  style={{ pointerEvents: "all" }}
                />

                {isSelected && (
                  <rect
                    x={x - 20}
                    y={upper ? crownY - 32 : ringY - 16}
                    width={40}
                    height={
                      (upper ? ringY + 14 : crownY + 32) -
                      (upper ? crownY - 32 : ringY - 16)
                    }
                    rx={14}
                    className="fill-primary/10"
                  />
                )}

                {/* Corona */}
                <g
                  className="transition-transform duration-150 ease-[var(--ease-out)]"
                  style={{
                    transform: `translate(${x}px, ${crownY}px) scale(${
                      isSelected ? 1.15 : 1
                    }) ${upper ? "scale(1,-1)" : ""} translate(-16px, -22px)`,
                  }}
                >
                  <path
                    d={TOOTH_PATHS[shape]}
                    fill={style.fill}
                    stroke={isSelected ? "#A7C7E7" : style.stroke}
                    strokeWidth={isSelected ? 2.6 : 2.2}
                    strokeLinejoin="round"
                    strokeDasharray={style.dashed ? "3 3" : undefined}
                  />
                </g>

                {/* Insignia de tratamiento (ej. "PR", "OB") */}
                {style.abbr && (
                  <g style={{ transform: `translate(${x + 13}px, ${badgeY}px)` }}>
                    <circle r={8} fill={style.stroke} />
                    <text
                      textAnchor="middle"
                      dominantBaseline="central"
                      fontSize={8}
                      fontWeight={700}
                      fill="#FFFFFF"
                    >
                      {style.abbr}
                    </text>
                  </g>
                )}

                {/* Anillo con el número FDI */}
                <g style={{ transform: `translate(${x}px, ${ringY}px)` }}>
                  <circle
                    r={11}
                    fill={ringFill}
                    stroke={ringStroke}
                    strokeWidth={1.5}
                  />
                  <text
                    textAnchor="middle"
                    dominantBaseline="central"
                    fontSize={10}
                    fontWeight={600}
                    fill={ringText}
                  >
                    {tooth}
                  </text>
                </g>
              </g>
            );
          })}
        </svg>
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

function MouthIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" className={className} aria-hidden>
      <path
        d="M3 10c3 5 15 5 18 0-3 8-15 8-18 0Z"
        stroke="currentColor"
        strokeWidth={2}
        strokeLinejoin="round"
      />
    </svg>
  );
}
