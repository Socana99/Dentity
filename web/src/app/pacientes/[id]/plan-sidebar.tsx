import type { TreatmentPlanItem } from "@/lib/types";

function money(n: number): string {
  return `$${n.toFixed(2)}`;
}

export default function PlanSidebar({
  treatmentPlan,
  onOpenPlan,
}: {
  treatmentPlan: TreatmentPlanItem[];
  onOpenPlan?: () => void;
}) {
  const total = treatmentPlan.reduce((sum, i) => sum + (i.costo ?? 0), 0);
  const items = treatmentPlan.slice(0, 5);

  return (
    <aside className="lg:sticky lg:top-24 lg:self-start">
      <div className="overflow-hidden rounded-3xl bg-white shadow-sm">
        <div className="bg-gradient-to-br from-[#7FAAD6] to-primary px-5 py-4">
          <p className="text-xs font-semibold uppercase tracking-wide text-white/80">
            Plan de tratamiento
          </p>
          <p className="mt-0.5 text-sm font-medium text-white">
            {treatmentPlan.length} diagnóstico(s)
          </p>
        </div>

        <div className="p-5">
          <p className="text-xs font-medium text-gray-400">
            Presupuesto total
          </p>
          <p className="mt-1 font-display text-2xl font-extrabold text-primary">
            {money(total)}
          </p>

          {items.length > 0 ? (
            <ul className="mt-4 flex flex-col gap-2">
              {items.map((item) => (
                <li
                  key={item.id}
                  className="flex items-baseline gap-2 text-sm"
                >
                  <span className="truncate text-gray-500">
                    {item.diagnostico || "Sin título"}
                  </span>
                  <span className="h-0 flex-1 border-b border-dotted border-gray-300" />
                  <span className="shrink-0 font-medium text-text-dark">
                    {money(item.costo ?? 0)}
                  </span>
                </li>
              ))}
            </ul>
          ) : (
            <p className="mt-4 text-sm text-gray-400">
              Aún no hay diagnósticos en el plan.
            </p>
          )}

          {treatmentPlan.length > items.length && (
            <p className="mt-2 text-xs text-gray-400">
              +{treatmentPlan.length - items.length} más…
            </p>
          )}

          <button
            type="button"
            onClick={onOpenPlan}
            className="mt-5 w-full rounded-full bg-primary/10 py-2.5 text-center text-sm font-semibold text-primary transition-[background-color,transform] duration-150 ease-[var(--ease-out)] hover:bg-primary/20 active:scale-[0.98]"
          >
            Ver plan completo
          </button>
        </div>
      </div>
    </aside>
  );
}
