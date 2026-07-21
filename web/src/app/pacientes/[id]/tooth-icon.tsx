import type { OdontoSymbol } from "@/lib/types";

// Corona redondeada + raíz visible que se afina hacia abajo (como en una
// lámina dental clásica) — el molar termina en dos puntas (raíz bifurcada)
// en vez de una sola, el resto en una punta.
export const TOOTH_PATHS = {
  incisor:
    "M16 2 C11 2 9 6 9 11 L9 33 C9 39 12 42 16 42 C20 42 23 39 23 33 L23 11 C23 6 21 2 16 2 Z",
  canine:
    "M16 1 L21 10 C22.5 12 23 14 23 17 L23 33 C23 39 20 42 16 42 C12 42 9 39 9 33 L9 17 C9 14 9.5 12 11 10 Z",
  premolar:
    "M16 3 C9.5 3 6 8 6 15 L6 32 C6 39 10.5 42 16 42 C21.5 42 26 39 26 32 L26 15 C26 8 22.5 3 16 3 Z",
  molar:
    "M16 3 C8 3 4 8 4 15 L4 30 C4 36 7.5 39.5 12 41 C13.5 41.5 14.5 40 15 38 C15.3 38.7 15.6 39 16 39 C16.4 39 16.7 38.7 17 38 C17.5 40 18.5 41.5 20 41 C24.5 39.5 28 36 28 30 L28 15 C28 8 24 3 16 3 Z",
} as const;

export type ToothShape = keyof typeof TOOTH_PATHS;

/** FDI: la última cifra indica la posición dentro del cuadrante
 * (1-2 incisivo, 3 canino, 4-5 premolar, 6-8 molar) — igual en los 4 cuadrantes. */
export function toothShapeFor(toothNumber: number): ToothShape {
  const pos = toothNumber % 10;
  if (pos <= 2) return "incisor";
  if (pos === 3) return "canine";
  if (pos <= 5) return "premolar";
  return "molar";
}

/** Color y abreviatura por estado clínico — la abreviatura se muestra como
 * insignia junto a la pieza marcada (igual que el "PR" de la referencia). */
export const SYMBOL_STYLE: Record<
  OdontoSymbol,
  { fill: string; stroke: string; dashed?: boolean; abbr?: string }
> = {
  ninguno: { fill: "#FFFFFF", stroke: "#94A3B8" },
  caries: { fill: "#FBBF24", stroke: "#B45309", abbr: "C" },
  obturado: { fill: "#7DD3FC", stroke: "#0369A1", abbr: "OB" },
  sellanteNecesario: { fill: "#FFFFFF", stroke: "#F59E0B", dashed: true, abbr: "SN" },
  sellanteRealizado: { fill: "#BAE6FD", stroke: "#0EA5E9", abbr: "SR" },
  extraccionIndicada: { fill: "#FCA5A5", stroke: "#DC2626", dashed: true, abbr: "EI" },
  perdidaPorCaries: { fill: "none", stroke: "#9CA3AF", dashed: true },
  perdidaOtraCausa: { fill: "none", stroke: "#9CA3AF", dashed: true },
  endodoncia: { fill: "#E5E7EB", stroke: "#7C3AED", abbr: "TE" },
  corona: { fill: "#D1D5DB", stroke: "#4B5563", abbr: "CR" },
  protesisFija: { fill: "#C4B5FD", stroke: "#6D28D9", abbr: "PR" },
  protesisRemovible: { fill: "#C4B5FD", stroke: "#6D28D9", dashed: true, abbr: "PR" },
  protesisTotal: { fill: "#A78BFA", stroke: "#5B21B6", abbr: "PR" },
};
