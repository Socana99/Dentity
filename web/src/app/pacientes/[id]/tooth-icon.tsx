const TOOTH_PATHS = {
  incisor:
    "M16 2 C11 2 9 6 9 11 L9 33 C9 39 12 42 16 42 C20 42 23 39 23 33 L23 11 C23 6 21 2 16 2 Z",
  canine:
    "M16 1 L21 10 C22.5 12 23 14 23 17 L23 33 C23 39 20 42 16 42 C12 42 9 39 9 33 L9 17 C9 14 9.5 12 11 10 Z",
  premolar:
    "M16 3 C9.5 3 6 8 6 15 L6 32 C6 39 10.5 42 16 42 C21.5 42 26 39 26 32 L26 15 C26 8 22.5 3 16 3 Z",
  molar:
    "M16 3 C8 3 4 8 4 15 L4 32 C4 39 9 42 16 42 C23 42 28 39 28 32 L28 15 C28 8 24 3 16 3 Z",
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

export default function ToothIcon({
  toothNumber,
  marked,
  className,
}: {
  toothNumber: number;
  marked: boolean;
  className?: string;
}) {
  return (
    <svg viewBox="0 0 32 44" className={className} aria-hidden>
      <path
        d={TOOTH_PATHS[toothShapeFor(toothNumber)]}
        strokeWidth={2}
        className={
          marked
            ? "fill-coral/25 stroke-coral"
            : "fill-white stroke-gray-300"
        }
      />
    </svg>
  );
}
